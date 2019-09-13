#!/usr/bin/env bash

function create_json() {
    host=$1
    ip=$2
    cat > $host-csr.json <<EOF
{
  "CN": "system:node:${host}",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "US",
      "L": "Chicago",
      "O": "system:nodes",
      "OU": "Kubernetes The Hard Way",
      "ST": "Illinois"
    }
  ]
}
EOF
    cfssl gencert \
	  -ca=private/ca.pem \
	  -ca-key=private/ca-key.pem \
	  -config=ca-config.json \
	  -hostname=${host},${ip} \
	  -profile=kubernetes \
	  ${host}-csr.json | cfssljson -bare private/${host}
}

file=${1}

if [[ ! -f $file ]] ; then
    echo "File $file is not accessible"
    exit 1
fi

process=0
exp="\[.+\]"
rsa=${HOME}/.ssh/mm-kube-management.pem
while read -r line ; do
    if [[ ${process} -eq 0 ]] ; then
	if [[ "${line}" == "[workers]" ]] ; then
	    process=1
	fi
    elif [[ ${process} -eq 1 ]] ; then
	if [[ ${line} =~ $exp ]] ; then
	    process=2
	    break
	elif [[ -n ${line} ]] ; then
	    # process the row...create the cert
	    host=${line#* }
	    ip=${line% *}
	    create_json $host $ip
	    scp  -i ${rsa} private/ca.pem private/${host}-key.pem private/${host}.pem ubuntu@$host:~/
	fi
    fi
done < ${file}

echo "Done..."
exit 0
