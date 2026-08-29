# ==============================================================================
# Cloud Run LLM Server (llama.cpp + Qwen2.5-1.5B-Instruct)
# ==============================================================================
FROM ghcr.io/ggml-org/llama.cpp:server

# Download the Qwen2.5-1.5B-Instruct Q4_K_M GGUF model during image build (~986MB)
ADD https://huggingface.co/Qwen/Qwen2.5-1.5B-Instruct-GGUF/resolve/main/qwen2.5-1.5b-instruct-q4_k_m.gguf /models/model.gguf

# Configure llama-server via native environment variables
ENV LLAMA_ARG_MODEL=/models/model.gguf
ENV LLAMA_ARG_HOST=0.0.0.0
ENV LLAMA_ARG_PORT=8080
ENV LLAMA_ARG_CTX_SIZE=2048
ENV LLAMA_ARG_N_PARALLEL=2
ENV LLAMA_ARG_THREADS=2

ENV PORT=8080
ENV HOST=0.0.0.0

EXPOSE 8080
