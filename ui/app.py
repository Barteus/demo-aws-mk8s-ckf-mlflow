import streamlit as st
import os

from langchain_community.vectorstores import OpenSearchVectorSearch
from langchain_huggingface import HuggingFaceEmbeddings
from langchain_core.globals import set_verbose, set_debug

from langchain_community.llms import VLLMOpenAI

import logging

logging.getLogger().setLevel(logging.ERROR)
set_verbose(False)
set_debug(False)

def embeddings(model_name= "sentence-transformers/all-MiniLM-L6-v2", use_gpu=False):
    hfe = HuggingFaceEmbeddings(
        model_name=model_name,
        model_kwargs={"device": "cuda" if use_gpu else "cpu"},
    )
    return hfe

def vector_search(
    os_host, os_port, os_user, os_user_pass, 
    embedding_function, os_index_name = "pagedata_index"
):
    opensearch_vector_search = OpenSearchVectorSearch(
        opensearch_url = f"https://{os_host}:{os_port}",
        index_name = os_index_name,
        embedding_function = embedding_function,
        http_auth = (os_user,os_user_pass),
        verify_certs = False,
        ssl_assert_hostname = False,
        ssl_show_warn = False
    )
    return opensearch_vector_search

hfe = embeddings()
    
vs = vector_search(
    os_host=os.getenv('OPENSEARCH_HOST', "34.245.99.62"),
    os_port=os.getenv('OPENSEARCH_PORT', 9200),
    os_user=os.getenv('OPENSEARCH_USER', "admin"),
    os_user_pass=os.getenv('OPENSEARCH_PASSWORD', "admin"),
    embedding_function=hfe
)

llm = VLLMOpenAI(
    openai_api_key="EMPTY",
    openai_api_base=os.getenv('LLM_API_URL', "http://10.152.183.161/v1/"),
    model_name=os.getenv('LLM_MODEL_NAME', "meta/llama3-8b-instruct"),
    max_tokens=512
    
)

st.title("Canonical and NVIDIA RAG Demo with NIMs", anchor=False)

# Initialize chat history
if "messages" not in st.session_state:
    st.session_state.messages = []

# Display chat messages from history on app rerun
for message in st.session_state.messages:
    with st.chat_message(message["role"]):
        st.markdown(message["content"])

if question := st.chat_input("Ask your question!", key="chatbot_main_area"):
    # Display user message in chat message container
    with st.chat_message("user"):
        st.markdown(question)
    # Add user message to chat history
    st.session_state.messages.append({"role": "user", "content": question})

    # # Display assistant response in chat message container
    with st.chat_message("assistant"):
        response = st.write_stream(llm.stream(question))
    # Add assistant response to chat history
    st.session_state.messages.append(
        {"role": "assistant", "content": response}
    )

