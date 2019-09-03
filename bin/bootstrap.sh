#!/usr/bin/env bash
if [ "${WORKBIN}" == "" ]; then
    echo "WORKBIN not set...please set before running"
    exit 0
fi

curl -L -o ${WORKBIN}/t.zip https://releases.hashicorp.com/terraform/0.12.7/terraform_0.12.7_linux_amd64.zip
cd ${WORKBIN}
unzip t.zip
rm ${WORKBIN}/t.zip

wget -q --show-progress --https-only --timestamping https://pkg.cfssl.org/R1.2/cfssl_linux-amd64 https://pkg.cfssl.org/R1.2/cfssljson_linux-amd64
mv cfssl_linux-amd64 ${WORKBIN}/cfssl
mv cfssljson_linux-amd64 ${WORKBIN}/cfssljson
chmod +x ${WORKBIN}/cfssl ${WORKBIN}/cfssljson

wget https://storage.googleapis.com/kubernetes-release/release/v1.15.0/bin/linux/amd64/kubectl
mv kubectl ${WORKBIN}/kubectl
chmod +x ${WORKBIN}/kubectl
