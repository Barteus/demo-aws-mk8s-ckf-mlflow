cat <<EOF | kubectl apply -n admin -f -
---
apiVersion: v1
kind: Secret
metadata:
  name: opensearch-secret
type: Opaque
stringData:
  host: "$OS_IP"
  port: "$OS_PORT"
  username: "$OS_USERNAME"
  password: "$OS_PASSWORD"
---
apiVersion: kubeflow.org/v1alpha1
kind: PodDefault
metadata:
  name: access-opensearch
spec:
  desc: Allow access to Opensearch
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
  selector:
    matchLabels:
      access-opensearch: "true"
EOF

#for chatbot UI
cat <<EOF | kubectl apply  -f -
---
apiVersion: v1
kind: Secret
metadata:
  name: opensearch-secret
type: Opaque
stringData:
  host: "$OS_IP"
  port: "$OS_PORT"
  username: "$OS_USERNAME"
  password: "$OS_PASSWORD"
EOF