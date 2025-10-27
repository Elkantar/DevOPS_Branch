#!/bin/bash

KUBECONFIG="./k3s/k3s.yaml"

function help() {
    cat <<EOF
orchestrator CLI v0.0.1

Manage a Kubernetes cluster in a VM cluster running K3s

USAGE:
$ ./orchestrator.sh COMMAND

Available commands:
    create  Create the VM cluster using the local Vagrantfile config
    start   Start the Kubernetes cluster on the VM cluster
    stop    Stop the Kubernetes cluster on the VM cluster
    clean   Remove cluster and resources
EOF
}

function check_kubeconfig() {
    if [[ ! -f "$KUBECONFIG" ]]; then
        echo "Error: kubeconfig $KUBECONFIG not found. Make sure the cluster is created."
        exit 1
    fi
}

if [[ $# -ne 1 ]]; then
    help
    exit 1
fi

case $1 in
"create")
    echo "Creating cluster resources..."
    mkdir -p ./k3s
    vagrant up
    echo "Cluster creation finished."
    ;;
"start")
    echo "Starting cluster..."
    check_kubeconfig
    export KUBECONFIG=$KUBECONFIG
    echo "Checking cluster nodes..."
    kubectl get nodes || { echo "Cannot access cluster. Check if VMs are running."; exit 1; }
    echo "Applying manifests..."
    kubectl apply -k .
    kubectl apply -f ./manifests/ --validate=false
    echo "Cluster started successfully."
    ;;
"stop")
    echo "Stopping cluster..."
    vagrant suspend
    echo "Cluster stopped."
    ;;
"clean")
    echo "Removing cluster and resources..."
    vagrant destroy -f
    rm -rf ./k3s
    echo "Cluster cleaned."
    ;;
*)
    echo "${1} is an unknown command."
    help
    exit 1
    ;;
esac
