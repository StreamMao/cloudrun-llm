# ==============================================================================
# Cloud Run LLM Server (llama.cpp + Qwen3-4B Fixed)
# ==============================================================================
FROM ghcr.io/ggml-org/llama.cpp:server

# Download patched Qwen3-4B-Instruct-2507 GGUF model (~2.5GB)
ADD https://huggingface.co/unsloth/Qwen3-4B-Instruct-2507-GGUF/resolve/main/Qwen3-4B-Instruct-2507-Q4_K_M.gguf /models/model.gguf

# Configure llama-server via native environment variables
ENV LLAMA_ARG_MODEL=/models/model.gguf
ENV LLAMA_ARG_HOST=0.0.0.0
ENV LLAMA_ARG_PORT=8080
ENV LLAMA_ARG_CTX_SIZE=2048
ENV LLAMA_ARG_N_PARALLEL=1
ENV LLAMA_ARG_THREADS=2

# Robust fixes: disable mmap, flash attention on CPU, and enable verbose tensor logging
ENV LLAMA_ARG_NO_MMAP=1
ENV LLAMA_ARG_MMAP=false
ENV LLAMA_ARG_FLASH_ATTN=0
ENV LLAMA_ARG_NO_WARMUP=1
ENV LLAMA_ARG_VERBOSE=1

ENV PORT=8080
ENV HOST=0.0.0.0

EXPOSE 8080
