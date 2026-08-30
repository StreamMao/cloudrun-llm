# ==============================================================================
# Cloud Run LLM Server (llama.cpp + DeepSeek-R1-Distill-Qwen-1.5B)
# ==============================================================================
FROM ghcr.io/ggml-org/llama.cpp:server

# Download verified DeepSeek-R1-Distill-Qwen-1.5B Q4_K_M GGUF model (~1.11GB)
ADD https://huggingface.co/unsloth/DeepSeek-R1-Distill-Qwen-1.5B-GGUF/resolve/main/DeepSeek-R1-Distill-Qwen-1.5B-Q4_K_M.gguf /models/model.gguf

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
