#!/usr/bin/env bash
workdir="${HOME}/workspace"

if [[ "$1" == "" ]] ; then
    echo "Usage: $0 workarea"
    exit 1
fi

cd ${workdir}
if [[ ! -d "${workdir}/${1}" ]] ; then
    mkdir ${workdir}/${1}
fi

cd ${workdir}/${1}
workarea=${workdir}/${1}

mkdir ansible terraform
cd ansible
python3 -m venv env
source env/bin/activate

pip3 install wheel
pip3 install -U pip
pip3 install -U setuptools
pip3 install ansible
deactivate
