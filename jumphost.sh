#!/bin/bash

sudo apt update 
sudo apt upgrade

sudo snap install jq yq

sudo snap install kubectl --classic
mkdir -p ~/.kube

sudo apt  install awscli -y
aws configure #provide Access and Secret Keys

sudo snap install juju --classic
mkdir -p ~/.local/share/juju
juju credentials

juju add-credential aws #provide region, Access and Secret Keys

juju bootstrap aws/eu-west-1 aws-controller --bootstrap-constraints 'cores=2 mem=4G'

juju add-model mk8s

juju deploy microk8s microk8s -n3 \
    --constraints 'instance-type=t3.xlarge root-disk=100G' \
    --channel 1.28/stable \
    --config hostpath_storage=true

juju deploy microk8s microk8s-gpu -n1 \
    --constraints 'instance-type=g4dn.xlarge root-disk=100G' \
    --channel 1.28/stable \
    --config hostpath_storage=true \
    --config role=worker

juju integrate microk8s:workers microk8s-gpu:control-plane

juju status --watch 5s

juju ssh microk8s/leader -- sudo microk8s status

juju ssh microk8s/leader -- sudo microk8s enable gpu ingress metallb:10.64.140.43-10.64.140.49

juju expose microk8s

juju ssh microk8s/leader -- sudo microk8s config > ~/.kube/config
kubectl get nodes

kubectl label node ip-172-31-6-136 node-preference=PreferNoSchedule
kubectl label node ip-172-31-28-213 node-preference=PreferNoSchedule
kubectl label node ip-172-31-32-31 node-preference=PreferNoSchedule

kubectl get nodes --no-headers -o custom-columns='NAME:.metadata.name, NODE_PREFERENCES:.metadata.labels.node-preference' | awk '{printf "%-30s %-30s\n", $1, $2}'

#volcano for microk8s
kubectl apply -f https://raw.githubusercontent.com/volcano-sh/volcano/master/installer/volcano-development.yaml

