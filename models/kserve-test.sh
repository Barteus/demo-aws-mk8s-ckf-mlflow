#!/bin/bash

kubectl apply -n admin -f - <<EOF
apiVersion: "serving.kserve.io/v1beta1"
kind: "InferenceService"
metadata:
  name: "sklearn-iris"
spec:
  predictor:
    model:
      modelFormat:
        name: sklearn
      storageUri: "gs://kfserving-examples/models/sklearn/1.0/model"
EOF

kubectl get po -n admin

# sklearn-iris.admin.10.64.140.43.nip.io
curl -H "Host: sklearn-iris.admin.10.64.140.43.nip.io" \
    -H 'Cookie: auth=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyIjp7ImlkIjoxLCJsb2NhbGUiOiJlbiIsInZpZXdNb2RlIjoibW9zYWljIiwic2luZ2xlQ2xpY2siOmZhbHNlLCJwZXJtIjp7ImFkbWluIjp0cnVlLCJleGVjdXRlIjp0cnVlLCJjcmVhdGUiOnRydWUsInJlbmFtZSI6dHJ1ZSwibW9kaWZ5Ijp0cnVlLCJkZWxldGUiOnRydWUsInNoYXJlIjp0cnVlLCJkb3dubG9hZCI6dHJ1ZX0sImNvbW1hbmRzIjpbXSwibG9ja1Bhc3N3b3JkIjpmYWxzZSwiaGlkZURvdGZpbGVzIjpmYWxzZSwiZGF0ZUZvcm1hdCI6ZmFsc2V9LCJpc3MiOiJGaWxlIEJyb3dzZXIiLCJleHAiOjE3MjM1MzgxODYsImlhdCI6MTcyMzUzMDk4Nn0.YS8uD3XLcxMWTv51f9_daixfMJ7iLohDA2VRgbP_0yg; authservice_session=MTcyNjQxOTk5MXxOd3dBTkROTlNrUlZORXROVTBsU1ExUk5SRkJVU2s1YU4xcE1XRmxDVTA5VFFrOVJXVlpYTTFZeldsZFlNMW8yV1RSUlVWZEdTMUU9fNZndMus0uCkosHCHml5Ll_tInjxZ2D9jmHLbK88VhW5' \
    -H "Content-Type: application/json" \
    "http://10.64.140.43.nip.io/v1/models/sklearn-iris:predict" \
    -d '{ "instances": [ [6.8,  2.8,  4.8,  1.4], [6.0,  3.4,  4.5,  1.6] ] }'
#{"predictions":[1,1]}

kubectl delete -n admin -f - <<EOF
apiVersion: "serving.kserve.io/v1beta1"
kind: "InferenceService"
metadata:
  name: "sklearn-iris"
spec:
  predictor:
    model:
      modelFormat:
        name: sklearn
      storageUri: "gs://kfserving-examples/models/sklearn/1.0/model"
EOF

