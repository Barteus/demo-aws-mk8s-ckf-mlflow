export AWS_KEY=
export AWS_SECRET=

cat <<EOF | kubectl apply -n admin -f -
apiVersion: v1
kind: Secret
metadata:
  name: ext-secret
type: Opaque
stringData:
  key: $AWS_KEY
  secret: $AWS_SECRET
---
apiVersion: kubeflow.org/v1alpha1
kind: PodDefault
metadata:
  name: access-ext-aws
spec:
  desc: Allow access to AWS Services
  env:
  - name: AWS_ACCESS_KEY_ID
    valueFrom:
      secretKeyRef:
        name: ext-secret
        key: key
        optional: false
  - name: AWS_SECRET_ACCESS_KEY
    valueFrom:
      secretKeyRef:
        name: ext-secret
        key: secret
        optional: false
  selector:
    matchLabels:
      access-ext-aws: "true"
EOF