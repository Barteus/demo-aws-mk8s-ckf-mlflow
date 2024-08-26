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

TBD