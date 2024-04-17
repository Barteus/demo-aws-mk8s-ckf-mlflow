#!/bin/bash

juju add-k8s mk8s --cluster-name=microk8s-cluster --client --controller aws-controller

juju add-model cos mk8s

juju deploy cos-lite --model cos \
  --trust \
  --overlay ./cos/offers-overlay.yaml \
  --overlay ./cos/storage-small-overlay.yaml

juju run traefik/0 show-proxied-endpoints --format=yaml --model cos \
  | yq '."traefik/0".results."proxied-endpoints"' \
  | jq

juju run grafana/leader get-admin-password --model cos

juju consume aws-controller:admin/cos.alertmanager-karma-dashboard cos-alertmanager -m mk8s
juju consume aws-controller:admin/cos.grafana-dashboards cos-grafana -m mk8s
juju consume aws-controller:admin/cos.loki-logging cos-loki -m mk8s
juju consume aws-controller:admin/cos.prometheus-receive-remote-write cos-prometheus -m mk8s

juju deploy grafana-agent grafana-agent-cos --channel latest/edge -m mk8s

juju relate grafana-agent-cos:cos-agent microk8s:cos-agent -m mk8s
juju relate cos-loki:logging grafana-agent-cos:logging-consumer -m mk8s
juju relate cos-prometheus:receive-remote-write grafana-agent-cos:send-remote-write -m mk8s
juju relate cos-grafana:grafana-dashboard grafana-agent-cos:grafana-dashboards-provider -m mk8s

juju status -m mk8s
