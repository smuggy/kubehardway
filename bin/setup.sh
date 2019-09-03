#!/usr/bin/env bash
if [ "${workdir}" == "$HOME/workspace" ] ; then
    echo "workspace already setup..."
else

    workdir="$HOME/workspace"
    echo "setting up workspace $workdir"

    PATH="${workdir}/bin:$PATH"
    PS1="(workspace) ${PS1}"

    if [ -f ${workdir}/bin/aws_env.sh ] ; then
	source ${workdir}/bin/aws_env.sh
    else
	echo "Missing AWS environment setup"
    fi

    # Gather executables
    if [ ! -f ${workdir}/bin/terraform ] ; then
	export WORKBIN
	WORKBIN=${workdir}/bin
	${workdir}/bin/bootstrap.sh
    fi
fi
