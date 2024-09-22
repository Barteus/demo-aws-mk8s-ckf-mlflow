#!/bin/bash

NIM_URL=$(kubectl get svc llama3-8b-instruct-1xgpu-predictor-00001-private -n admin -o jsonpath='{.spec.clusterIP}')

kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: chatbot-deployment
  labels:
    app: chatbot
spec:
  selector:
    matchLabels:
      app: chatbot
  template:
    metadata:
      labels:
        app: chatbot
    spec:
      containers:
      - name: ui
        image: bponieckiklotz/llm-chatbot:kserve-v3
        ports:
        - containerPort: 8501
        env:
        - name: OPENSEARCH_HOST
          valueFrom:
            secretKeyRef:
              name: opensearch-secret
              key: host
              optional: false
        - name: OPENSEARCH_PORT
          valueFrom:
            secretKeyRef:
              name: opensearch-secret
              key: port
              optional: false
        - name: OPENSEARCH_USER
          valueFrom:
            secretKeyRef:
              name: opensearch-secret
              key: username
              optional: false
        - name: OPENSEARCH_PASSWORD
          valueFrom:
            secretKeyRef:
              name: opensearch-secret
              key: password
              optional: false
        - name: LLM_API_URL
          value: "http://$NIM_URL/v1"
        - name: LLM_MODEL_NAME
          value: "meta/llama3-8b-instruct"
---
apiVersion: v1
kind: Service
metadata:
  name: chatbot-service
spec:
  selector:
    app: chatbot
  ports:
    - protocol: TCP
      port: 80
      targetPort: 8501
  type: LoadBalancer
EOF
