#!/bin/bash

KSERVE_URL=llama3-8b-instruct-1xgpu-predictor-00001-private

curl http://${KSERVE_URL}/v1/models \
-H 'Cookie: auth=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyIjp7ImlkIjoxLCJsb2NhbGUiOiJlbiIsInZpZXdNb2RlIjoibW9zYWljIiwic2luZ2xlQ2xpY2siOmZhbHNlLCJwZXJtIjp7ImFkbWluIjp0cnVlLCJleGVjdXRlIjp0cnVlLCJjcmVhdGUiOnRydWUsInJlbmFtZSI6dHJ1ZSwibW9kaWZ5Ijp0cnVlLCJkZWxldGUiOnRydWUsInNoYXJlIjp0cnVlLCJkb3dubG9hZCI6dHJ1ZX0sImNvbW1hbmRzIjpbXSwibG9ja1Bhc3N3b3JkIjpmYWxzZSwiaGlkZURvdGZpbGVzIjpmYWxzZSwiZGF0ZUZvcm1hdCI6ZmFsc2V9LCJpc3MiOiJGaWxlIEJyb3dzZXIiLCJleHAiOjE3MjM1MzgxODYsImlhdCI6MTcyMzUzMDk4Nn0.YS8uD3XLcxMWTv51f9_daixfMJ7iLohDA2VRgbP_0yg; authservice_session=MTcyNjQxOTk5MXxOd3dBTkROTlNrUlZORXROVTBsU1ExUk5SRkJVU2s1YU4xcE1XRmxDVTA5VFFrOVJXVlpYTTFZeldsZFlNMW8yV1RSUlVWZEdTMUU9fNZndMus0uCkosHCHml5Ll_tInjxZ2D9jmHLbK88VhW5' 

#from notebook
curl http://${KSERVE_URL}/v1/models

curl http://${KSERVE_URL}/v1/chat/completions  \
  -H "Content-Type: application/json" \
  -d '{
    "model": "meta/llama3-8b-instruct",
    "messages": [{"role":"user","content":"What is KServe?"}],
    "temperature": 0.5,   
    "top_p": 1,
    "max_tokens": 1024,
    "stream": false 
    }'

