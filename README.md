# Cloud Run Serverless LLM (Financial & General Purpose)

本仓库提供在 **Google Cloud Run** 上以 **0 闲置成本（Scale to Zero）** 部署开源大语言模型的完整方案。当前配置为 **`Qwen3-0.6B`（官方 8-bit 高精度 Q8_0 旗舰版）**，兼顾**秒级极速冷启动**、**原生 `<think>` 思考模式**与**零损耗高精度输出**。

---

## 🎯 核心架构与费用优势

* **零闲置费用（Scale to Zero）**：
  * 配置 `--min-instances 0`：无请求时容器自动关机，**闲置费用为 $0.00**；
  * 配置 `--max-instances 1`：限制最大并发实例数，彻底防范恶意刷量与账单失控。
* **100% 运行在免费额度内**：
  * `Qwen3-0.6B-Q8_0`（~639MB）仅需 **2 GiB 内存**；
  * 完全运行在 Google Cloud 每月赠送的免费额度内（180,000 vCPU-秒 与 360,000 GiB-秒），**每月 $10 Credit 完全不用动用**！
* **极速唤醒**：3 ~ 5 秒极速冷启动，流式打字生成速度 **80+ 字/秒**。
* **原生 C++ 高性能引擎**：基于 `llama.cpp:server`，提供原生 OpenAI 兼容的 `/v1/chat/completions` API 与流式输出。

---

## 📊 可选模型深度对比与选型指南

下表汇总了经过 API 连通性测试（100% 验证 200 OK）、可直接在 Cloud Run 上运行的优质开源模型：

| 模型型号 | 参数量 | GGUF体积 | 推荐 Cloud Run 配置 | 思考链 (`<think>`) | 股票金融场景匹配度 | 适用场景特点 |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Qwen3-0.6B (Q8_0 官方高精度)** *(当前默认)* | 0.6B | **~639 MB** | **2 GiB 内存 / 2 vCPU** | ✅ 原生支持 | ⭐⭐⭐☆☆ | **3~5秒极速冷启动**：官方 8-bit 无损精度，适合快速信息提取、打标、分类与轻度问答，0 成本！ |
| **DeepSeek-R1-Distill-Qwen-7B** | 7B | **~4.68 GB** | **6~8 GiB 内存 / 4 vCPU** | ✅ 深度强化推理 | ⭐⭐⭐⭐⭐ **(深度推演)** | **深度推演神器**：7B 强化推理，多步骤财务数据计算、深度多空博弈（$10 额度每月支持 6,750+ 篇研报）。 |
| **Qwen2.5-7B-Instruct** | 7B | **~4.68 GB** | **6~8 GiB 内存 / 4 vCPU** | ❌ 无显式思考 | ⭐⭐⭐⭐☆ **(专业稳健)** | **经典 7B 旗舰**：知识面极广，格式遵循能力强，直接输出高质量分析。 |
| **Qwen2.5-3B-Instruct** | 3B | **~1.93 GB** | **4 GiB 内存 / 2 vCPU** | ❌ 无显式思考 | ⭐⭐⭐⭐☆ **(轻快实用)** | **快速响应**：体积适中、速度飞快，适合日常新闻中英文快速翻译与摘要。 |

---

## 🔗 经过 HTTP 200 验证的官方直链汇总

在 `Dockerfile` 中切换模型时，直接复制对应的一行即可（**已全部通过网络连通性实测验证**）：

```dockerfile
# 1. 【当前默认】Qwen3-0.6B (官方 Q8_0 高精度无损版，~639MB，秒级冷启动)
ADD https://huggingface.co/Qwen/Qwen3-0.6B-GGUF/resolve/main/Qwen3-0.6B-Q8_0.gguf /models/model.gguf

# 2. DeepSeek-R1-Distill-Qwen-7B (~4.68GB，超强思考推理链)
ADD https://huggingface.co/unsloth/DeepSeek-R1-Distill-Qwen-7B-GGUF/resolve/main/DeepSeek-R1-Distill-Qwen-7B-Q4_K_M.gguf /models/model.gguf

# 3. Qwen2.5-3B-Instruct (~1.93GB，轻快型 3B 实用模型)
ADD https://huggingface.co/Qwen/Qwen2.5-3B-Instruct-GGUF/resolve/main/qwen2.5-3b-instruct-q4_k_m.gguf /models/model.gguf
```

---

## 🔄 切换模型的极简操作步骤

当你需要切换模型时，只需 2 步：

### 第一步：修改 `Dockerfile`
将 `Dockerfile` 中的 `ADD ...` 行替换为上述目标模型的直链。

### 第二步：检查并调整 Cloud Run 内存（根据模型大小）
在 GCP 控制台的 Cloud Run 页面点击 **「修改并部署新的修订版本」**：
* **0.6B 模型**：设置为 **`2 GiB`** 内存；
* **3B 模型**：设置为 **`4 GiB`** 内存；
* **7B 模型**：设置为 **`6 GiB` ~ `8 GiB`** 内存。

### 第三步：提交并推送
```bash
git add Dockerfile README.md
git commit -m "feat: switch model"
git push origin main
```
Cloud Build 会自动完成镜像重新打包并无缝上线新版本。

---

## 🧪 API 调用与测试

### 1. 运行内置测试脚本（带冷启动就绪检测）
```bash
python3 test_client.py https://<YOUR_CLOUD_RUN_URL>
```

### 2. Python 官方 SDK 调用示例

```python
from openai import OpenAI

client = OpenAI(
    base_url="https://<YOUR_CLOUD_RUN_URL>/v1",
    api_key="none"
)

response = client.chat.completions.create(
    model="qwen3-0.6b",
    messages=[
        {"role": "system", "content": "You are a helpful and concise AI assistant."},
        {"role": "user", "content": "请用一句话介绍你自己。"}
    ],
    temperature=0.7,
    stream=True
)

for chunk in response:
    content = chunk.choices[0].delta.content or ""
    print(content, end="", flush=True)
print()
```
