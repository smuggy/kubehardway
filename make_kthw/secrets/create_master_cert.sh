#!/usr/bin/env bash
file=${1}

if [[ ! -f $file ]] ; then
    echo "File $file is not accessible"
    exit 1
fi

process=0
exp="\[.+\]"
all_ip=""
all_hosts=""
all_hosts_alt=""
first=1
while read -r line ; do
    if [[ ${process} -eq 0 ]] ; then
	if [[ "${line}" == "[masters]" ]] ; then
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
	    if [[ $first -eq 1 ]] ; then
		all_ip="${ip}"
		all_hosts="${host}"
		all_hosts_alt="${host}"
		first=0
	    else
		all_ip="${all_ip},${ip}"
		all_hosts="${all_hosts},${host}"
		all_hosts_alt="${all_hosts_alt} ${host}"
	    fi
	fi
    fi
done < ${file}
cfssl gencert \
      -ca=private/ca.pem \
      -ca-key=private/ca-key.pem \
      -config=ca-config.json \
      -hostname="${all_hosts},${all_ips},127.0.0.1,kubernetes.default" \
      -profile=kubernetes \
      kubernetes-csr.json | cfssljson -bare private/kubernetes

for h in ${all_hosts_alt} ; do
    scp -i ${HOME}/.ssh/mm-kube-management.pem private/ca.pem private/ca-key.pem private/kubernetes-key.pem private/kubernetes.pem private/service-account-key.pem private/service-account.pem ubuntu@$h:~/
done

echo "Done..."
exit 0
