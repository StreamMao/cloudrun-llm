# Cloud Run LLM (Qwen2.5-1.5B-Instruct on Free Tier)

本仓库提供在 **Google Cloud Run 免费额度** 内零成本部署开源大语言模型（**Qwen2.5-1.5B-Instruct Q4_K_M**）的完整方案，并提供未来无缝升级到 **Qwen2.5-7B-Instruct** 的指南。

---

## 🎯 特性与免费保障

* **零成本运行（Free Tier）**：
  * 利用 Cloud Run 自动缩容机制（`--min-instances 0`），**无请求时 0 费用**。
  * 设置单实例上限（`--max-instances 1`），防止突发流量或被刷量导致扣费。
  * 每月系统赠送 180,000 vCPU-秒 与 360,000 GiB-秒 额度，足以支持数千次问答调用。
* **原生 C++ 极速引擎**：基于 `llama.cpp`，内置轻量级 HTTP Server，支持 OpenAI 兼容 API (`/v1/chat/completions`)。
* **镜像打包模型**：构建时固化 GGUF 模型，冷启动只需 5~10 秒，无需启动时从外部拉取。

---

## 📁 目录结构

```
.
├── Dockerfile             # 容器定义（llama.cpp server + Qwen2.5-1.5B GGUF）
├── .dockerignore          # 构建过滤规则
├── deploy.sh              # Linux / macOS 一键部署脚本
├── deploy.ps1             # Windows PowerShell 一键部署脚本
├── test_client.py         # 零依赖测试脚本（支持流式输出）
└── README.md              # 本说明文档
```

---

## 🚀 快速部署到 Cloud Run

### 1. 前置准备
确保已安装并登录 Google Cloud CLI (`gcloud`)：

```bash
# 登录 GCP 账号
gcloud auth login

# 设置你的 GCP Project ID
gcloud config set project YOUR_PROJECT_ID
```

### 2. 执行一键部署

* **Windows (PowerShell)**:
  ```powershell
  .\deploy.ps1
  ```

* **Linux / macOS**:
  ```bash
  chmod +x deploy.sh
  ./deploy.sh
  ```

部署完成后，脚本会输出类似如下的 Cloud Run URL：
```
Service URL: https://qwen-1-5b-xxxxxx-uc.a.run.app
```

---

## 🧪 接口调用与测试

### 1. 运行内置测试脚本
```bash
python test_client.py https://qwen-1-5b-xxxxxx-uc.a.run.app
```

### 2. 使用 cURL
```bash
curl https://<YOUR_SERVICE_URL>/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "messages": [
      {"role": "system", "content": "You are a helpful assistant."},
      {"role": "user", "content": "你好，请介绍一下你自己。"}
    ],
    "temperature": 0.7,
    "max_tokens": 256
  }'
```

### 3. 使用 Python `openai` SDK
因为服务完全兼容 OpenAI 接口规范，你可以直接对接各类 LangChain、LlamaIndex 或前端 Web UI：

```python
from openai import OpenAI

client = OpenAI(
    base_url="https://<YOUR_SERVICE_URL>/v1",
    api_key="none" # llama.cpp 默认无需 API key
)

response = client.chat.completions.create(
    model="qwen2.5-1.5b-instruct",
    messages=[{"role": "user", "content": "写一首赞美春天的诗。"}],
    stream=True
)

for chunk in response:
    if chunk.choices[0].delta.content:
        print(chunk.choices[0].delta.content, end="", flush=True)
print()
```

---

## 🔄 未来升级到 Qwen2.5-7B-Instruct 指南

当你希望获得更强大的逻辑和推理能力，并拥有约 **\$10/月** 的预算时，升级只需要以下两步：

### 第一步：修改 `Dockerfile`
将模型下载链接替换为 7B 的 Q4 量化版本：
```dockerfile
# 替换为 7B 模型 (~4.68GB)
ADD https://huggingface.co/Qwen/Qwen2.5-7B-Instruct-GGUF/resolve/main/qwen2.5-7b-instruct-q4_k_m.gguf /models/model.gguf
```

### 第二步：调整部署内存与 CPU
在 `deploy.sh` 或 `deploy.ps1` 中，调整 Cloud Run 资源参数：
* 将 `--memory 2Gi` 调整为 `--memory 6Gi`（或 `8Gi`）
* 将 `--cpu 2` 调整为 `--cpu 4`（获得更快的生成速度）

再次运行部署脚本即可平滑升级！
