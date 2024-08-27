# Multicloud E2E RAG demo

## TODO
- AWS cli command to create the jumphost
- Split the jumphost.sh script into:
    - general setup
    - juju setup (AWS for now, later added other clouds)
    - microk8s setup (gpu and nongpu nodes)
- Split apps.sh
    - COS integration
    - Opensearch
    - CKF + MLflow
- Implement notebook which:
    - takes data from S3 
    - create embeddings 
    - stores values in Opensearch 
- Create a pipeline from notebook, add:
    - 3 steps - download, create/recreate index, create embeddings, save in opensearch
- Deploy the LLM using vLLM & KServe
- Create Chat UI using embedder & KServe endpoint
    - simple chat application with history

**Enhancements**
- use Embeddings service as KServe endpoint
- multicloud:
    - juju cloud config
    - jumphost create command
- NVidia NIM as LLM & Embeddings

## Installation

### Create the jumphost

Skip if you already have a jumphost or decide to use your local machine.

For **AWS**, go to the aws-jumphost folder and use terraform:

```bash
cd ./aws-jumphost
terraform init
terraform apply
```

Export the public ip of the jumphost and SSH using defined key

```bash
export JUMPHOST_IP=$(terraform output -raw instance_public_ip)
export PATH_TO_KEY=...

ssh -i PATH_TO_KEY ubuntu@$JUMPHOST_IP
```

Install common packages for jumphost from project root directory

```bash
cd ./..
bash jumphost-common.sh
```

### Juju cloud configuration

Juju cloud credentials need to be configured separately for each of the clouds, more info can be found [here](https://juju.is/docs/juju/juju-add-credential)

For **AWS**, configure the aws cloud config file based on [template](`./aws-jumphost/aws-credentials.tmp`) with your AWS IAM user credentails and add them to the cloud:

```bash
juju add-credential aws -f ./aws-jumphost/aws-credentials.yaml
```

### Deploy Kubernetes cluster








## Cleanup
