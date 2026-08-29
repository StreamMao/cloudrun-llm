# ==============================================================================
# Cloud Run LLM Server (llama.cpp + Qwen2.5-1.5B-Instruct)
# ==============================================================================
FROM ghcr.io/ggml-org/llama.cpp:server

# Download the Qwen2.5-1.5B-Instruct Q4_K_M GGUF model during image build
# (~986MB, provides the best balance between size, speed, and CPU RAM usage)
ADD https://huggingface.co/Qwen/Qwen2.5-1.5B-Instruct-GGUF/resolve/main/qwen2.5-1.5b-instruct-q4_k_m.gguf /models/model.gguf

ENV PORT=8080
ENV HOST=0.0.0.0

EXPOSE 8080

# Run llama-server with CPU optimizations
# -c 2048 : Context window length (sufficient for chats, keeps memory low)
# -np 2   : 2 parallel slots for handling concurrent prompts
# -t 2    : 2 CPU threads (matching Cloud Run 2 vCPU allocation)
ENTRYPOINT ["/llama-server", "-m", "/models/model.gguf", "--host", "0.0.0.0", "--port", "8080", "-c", "2048", "-np", "2", "-t", "2"]
