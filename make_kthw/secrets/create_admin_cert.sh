cfssl gencert -ca=private/ca.pem -ca-key=private/ca-key.pem -config=ca-config.json -profile=kubernetes admin-csr.json | cfssljson -bare private/admin
cfssl gencert -ca=private/ca.pem -ca-key=private/ca-key.pem -config=ca-config.json -profile=kubernetes kube-proxy-csr.json | cfssljson -bare private/kube-proxy
cfssl gencert -ca=private/ca.pem -ca-key=private/ca-key.pem -config=ca-config.json -profile=kubernetes kube-scheduler-csr.json | cfssljson -bare private/kube-scheduler
cfssl gencert -ca=private/ca.pem -ca-key=private/ca-key.pem -config=ca-config.json -profile=kubernetes kube-controller-manager-csr.json | cfssljson -bare private/kube-controller-manager
cfssl gencert -ca=private/ca.pem -ca-key=private/ca-key.pem -config=ca-config.json -profile=kubernetes service-account-csr.json | cfssljson -bare private/service-account
