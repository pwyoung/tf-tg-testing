#!/bin/bash


function _set_vars {
    terraform show -json -no-color terraform.tfstate | jq . > ~/.tf-show-state.json

    # Public EC2 hosts
    #IP1=$(cat ~/.tf-show-state.json | jq -r .values.root_module.child_modules[0].child_modules[].child_modules[0].resources[0].values.public_ip | egrep -v 'null|^$' | head -1)
    #IP2=$(cat ~/.tf-show-state.json | jq -r .values.root_module.child_modules[0].child_modules[].child_modules[0].resources[0].values.public_ip | egrep -v 'null|^$' | head -2 | tail -1)
    IP1=$(cat ~/.tf-show-state.json  | grep public_dns | grep compute.amazonaws.com | cut -d'"' -f 4 | head -1)
    IP2=$(cat ~/.tf-show-state.json  | grep public_dns | grep compute.amazonaws.com | cut -d'"' -f 4 | head -2 | tail -1)

    # Private EC2 hosts  (in 10.100.2xx)
    PRIVATE_IP1=$(cat ~/.tf-show-state.json | jq -r .values.root_module.child_modules[0].child_modules[].child_modules[0].resources[0].values.private_ip | grep  '10.100.2' | egrep -v 'null|^$' | head -1)
    PRIVATE_IP2=$(cat ~/.tf-show-state.json | jq -r .values.root_module.child_modules[0].child_modules[].child_modules[0].resources[0].values.private_ip | grep  '10.100.2' | egrep -v 'null|^$' | head -2 | tail -1)

    echo "IP1 is $IP1"
    echo "IP2 is $IP2"
    echo "PRIVATE_IP1 is $PRIVATE_IP1"
    echo "PRIVATE_IP2 is $PRIVATE_IP2"

    export IP1
    export IP2
    export PRIVATE_IP1
    export PRIVATE_IP2
}

function _ssh {
    _set_vars

    if [ -z "$IP1" ]; then
        echo "IP1 is not set"
        return 1
    fi

    ssh -A ubuntu@$IP1 $@
}

function _ssh2 {
    _set_vars

    if [ -z "$IP2" ]; then
        echo "IP2 is not set"
        return 1
    fi

    ssh -A ubuntu@$IP2 $@
}

function _test_ssh_between_hosts {
    echo "Testing _ssh (into public ec2 instnace $IP1) and then SSH to private ec2 instance at $PRIVATE_IP1"
    _ssh "hostname && ssh -o StrictHostKeyChecking=no ubuntu@$PRIVATE_IP1 hostname"
}
