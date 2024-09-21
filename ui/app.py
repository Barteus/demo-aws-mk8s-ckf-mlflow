import streamlit as st
import os

from langchain_community.vectorstores import OpenSearchVectorSearch
from langchain_huggingface import HuggingFaceEmbeddings
from langchain_core.globals import set_verbose, set_debug

from langchain_community.llms import VLLMOpenAI

from langchain_core.output_parsers import StrOutputParser
from langchain_core.runnables import RunnableParallel, RunnablePassthrough, RunnableLambda

from langchain import hub

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
    embedding_function, os_index_name = "rag_index"
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
    os_host=os.getenv('OPENSEARCH_HOST', "3.250.131.254"),
    os_port=os.getenv('OPENSEARCH_PORT', 9200),
    os_user=os.getenv('OPENSEARCH_USER', "admin"),
    os_user_pass=os.getenv('OPENSEARCH_PASSWORD', "An1IpI0BMfcqUo2XCYjwEWdk1fXKuz1Y"),
    embedding_function=hfe
)

llm = VLLMOpenAI(
    openai_api_key="EMPTY",
    openai_api_base=os.getenv('LLM_API_URL', "http://10.152.183.118/v1/"),
    model_name=os.getenv('LLM_MODEL_NAME', "meta/llama3-8b-instruct"),
    max_tokens=256,
    verbose=True
)

prompt = hub.pull("rlm/rag-prompt-llama")

def format_docs(docs):
    return "\n\n".join(doc.page_content for doc in docs)

rag_chain_from_docs = (
    RunnablePassthrough.assign(context=(lambda x: format_docs(x["context"])))
    | prompt
    | llm
    | StrOutputParser()
)

def post_process_rag_ans(input_stream):
    for t in input_stream:
        if "answer" in t.keys():
            val = t["answer"]
            if val == " [/":
                break
            else:
                yield val
        if "question" in t.keys():
            yield f"\n**Question**: {t['question']}\n"
        if "context" in t.keys():
            yield "\n**Context**\n"
            formatted_documents = "\n\n".join(f"\nDocument source: {doc.metadata['source']}\n\nContent: {doc.page_content}\n" for doc in t["context"])
            yield formatted_documents
            yield "\n**Answer**:\n\n"

rag_chain_with_source = RunnableParallel(
    {"context": vs.as_retriever(), "question": RunnablePassthrough()}
).assign(answer=rag_chain_from_docs)

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
        response = st.write_stream(
            post_process_rag_ans(rag_chain_with_source.stream(question)))
    # Add assistant response to chat history
    st.session_state.messages.append(
        {"role": "assistant", "content": response}
    )

