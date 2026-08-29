# ==============================================================================
# Cloud Run LLM Server (llama.cpp + Qwen3-4B)
# ==============================================================================
FROM ghcr.io/ggml-org/llama.cpp:server

# Download official Qwen3-4B Q4_K_M GGUF model (~2.5GB)
ADD https://huggingface.co/Qwen/Qwen3-4B-GGUF/resolve/main/Qwen3-4B-Q4_K_M.gguf /models/model.gguf

# Configure llama-server via native environment variables
ENV LLAMA_ARG_MODEL=/models/model.gguf
ENV LLAMA_ARG_HOST=0.0.0.0
ENV LLAMA_ARG_PORT=8080
ENV LLAMA_ARG_CTX_SIZE=4096
ENV LLAMA_ARG_N_PARALLEL=1
ENV LLAMA_ARG_THREADS=2

ENV PORT=8080
ENV HOST=0.0.0.0

EXPOSE 8080
