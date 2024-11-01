#!/bin/bash

kubectl create secret docker-registry ngc-secret -n admin \
 --docker-server=nvcr.io\
 --docker-username='$oauthtoken'\
 --docker-password=${NGC_API_KEY}

kubectl apply -n admin -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: nvidia-nim-secrets
data:
  NGC_API_KEY: $(echo -n "$NGC_API_KEY" | base64 -w0)
type: Opaque
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: nvidia-nim-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 200G
---
apiVersion: serving.kserve.io/v1alpha1
kind: ClusterServingRuntime
metadata:
  name: nvidia-nim-llama3-8b-instruct-24.05
spec:
  annotations:
    prometheus.kserve.io/path: /metrics
    prometheus.kserve.io/port: "8000"
    serving.kserve.io/enable-metric-aggregation: "true"
    serving.kserve.io/enable-prometheus-scraping: "true"
  containers:
  - env:
    - name: NIM_CACHE_PATH
      value: /opt/nim/.cache
    - name: NGC_API_KEY
      valueFrom:
        secretKeyRef:
          name: nvidia-nim-secrets
          key: NGC_API_KEY
    image: nvcr.io/nim/meta/llama3-8b-instruct:1.0.0
    name: kserve-container
    ports:
    - containerPort: 8000
      protocol: TCP
    volumeMounts:
    - mountPath: /dev/shm
      name: dshm
  imagePullSecrets:
  - name: ngc-secret
  protocolVersions:
  - v2
  - grpc-v2
  supportedModelFormats:
  - autoSelect: true
    name: nvidia-nim-llama3-8b-instruct
    priority: 1
    version: "24.05"
  volumes:
  - emptyDir:
      medium: Memory
      sizeLimit: 16Gi
    name: dshm
EOF

kubectl apply -n admin -f - <<EOF
apiVersion: serving.kserve.io/v1beta1
kind: InferenceService
metadata:
  annotations:
    autoscaling.knative.dev/target: "10"
    sidecar.istio.io/inject: "false"
  name: llama3-8b-instruct-1xgpu
spec:
  predictor:
    minReplicas: 1
    tolerations:
      - key: "node-preference"
        operator: "Equal"
        value: "true"
        effect: "PreferNoSchedule"
    model:
      modelFormat:
        name: nvidia-nim-llama3-8b-instruct
      resources:
        limits:
          nvidia.com/gpu: "1"
        requests:
          nvidia.com/gpu: "1"
      runtime: nvidia-nim-llama3-8b-instruct-24.05
      storageUri: pvc://nvidia-nim-pvc/
---
apiVersion: serving.kserve.io/v1alpha1
kind: ClusterServingRuntime
metadata:
  name: nvidia-nim-nv-embedqa-e5-v5-1.0.0
spec:
  annotations:
    prometheus.kserve.io/path: /metrics
    prometheus.kserve.io/port: "8000"
    serving.kserve.io/enable-metric-aggregation: "true"
    serving.kserve.io/enable-prometheus-scraping: "true"
  containers:
  - env:
    - name: NIM_CACHE_PATH
      value: /mnt/models/cache
    - name: NGC_API_KEY
      valueFrom:
        secretKeyRef:
          name: nvidia-nim-secrets
          key: NGC_API_KEY
    image: nvcr.io/nim/nvidia/nv-embedqa-e5-v5:1.0.0
    name: kserve-container
    ports:
    - containerPort: 8000
      protocol: TCP
    resources:
      limits:
        cpu: "16000m"
        memory: 32Gi
      requests:
        cpu: "4000m"
        memory: 16Gi
    volumeMounts:
    - mountPath: /dev/shm
      name: dshm
  imagePullSecrets:
  - name: ngc-secret
  protocolVersions:
  - v2
  - grpc-v2
  supportedModelFormats:
  - autoSelect: true
    name:  nvidia-nim-nv-embedqa-e5-v5
    priority: 1
    version: "1.0.0"
  volumes:
  - emptyDir:
      medium: Memory
      sizeLimit: 16Gi
    name: dshm
EOF

# kubectl apply -n admin -f - <<EOF
# apiVersion: serving.kserve.io/v1beta1
# kind: InferenceService
# metadata:
#   annotations:
#     autoscaling.knative.dev/target: "10"
#     sidecar.istio.io/inject: "false"
#   name: nv-embedqa-e5-v5-1xgpu
# spec:
#   predictor:
#     minReplicas: 1
#     model:
#       modelFormat:
#         name: nvidia-nim-nv-embedqa-e5-v5
#       resources:
#         limits:
#           nvidia.com/gpu: "1"
#         requests:
#           nvidia.com/gpu: "1"
#       runtime: nvidia-nim-nv-embedqa-e5-v5-1.0.0
#       storageUri: pvc://nvidia-nim-pvc/
# EOF
