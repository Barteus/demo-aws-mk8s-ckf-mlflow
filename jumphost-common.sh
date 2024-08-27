#!/bin/bash

sudo apt update 
sudo apt upgrade

sudo snap install jq yq

sudo snap install kubectl --classic
mkdir -p ~/.kube

sudo snap install juju --classic
mkdir -p ~/.local/share/juju