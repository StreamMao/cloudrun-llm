# Cloud Run Serverless LLM (Financial Sentiment & General Purpose)

本仓库提供在 **Google Cloud Run** 上以 **0 闲置成本（Scale to Zero）** 部署开源大语言模型的完整方案。当前默认配置为 **`DeepSeek-R1-Distill-Qwen-1.5B`（DeepSeek 官方蒸馏思考小钢炮）**，专为 **股票新闻翻译、金融资讯情绪打分（Sentiment Scoring）、长文要点提炼与多空推演** 深度优化，原生支持 **`<think>` 强化深度思考推理链**。

---

## 🎯 核心架构与费用优势

* **零闲置费用（Scale to Zero）**：
  * 配置 `--min-instances 0`：无请求时容器自动关机，**闲置费用为 $0.00**；
  * 配置 `--max-instances 1`：限制最大并发实例数，彻底防范恶意刷量与账单失控。
* **100% 运行在免费额度内**：
  * `DeepSeek-R1-Distill-Qwen-1.5B`（~1.11GB）仅需 **2 GiB 内存 / 2 vCPU**；
  * 完全运行在 Google Cloud 每月赠送的免费额度内（180,000 vCPU-秒 与 360,000 GiB-秒），**每月 $10 Credit 100% 保留，完全不消耗**！
* **极速唤醒**：约 5 秒极速冷启动，流式打字生成速度 **80+ 字/秒**。
* **原生 C++ 高性能引擎**：基于 `llama.cpp:server`，提供原生 OpenAI 兼容的 `/v1/chat/completions` API 与流式输出。

---

## 📊 全量可选模型深度对比与选型全景表

下表汇总了本项目的全量可选模型库、硬件资源需求与适用场景（**均已通过 API 连通性测试与环境兼容性验证**）：

| 模型型号 | 参数量 | GGUF体积 | 推荐 Cloud Run 配置 | 思考链 (`<think>`) | 股票金融场景匹配度 | 适用场景与核心特点 |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **DeepSeek-R1-Distill-Qwen-1.5B** *(当前默认)* | 1.5B | **~1.11 GB** | **2 GiB 内存 / 2 vCPU** | ✅ 深度强化推理 | ⭐⭐⭐⭐☆ **(免费推演)** | **免费档思考小钢炮**：DeepSeek R1 官方蒸馏版，自带 `<think>` 深度思考，精准处理**金融新闻情绪打分（-1.0 ~ +1.0）**，纯免费档 2G 内存 0 成本！ |
| **DeepSeek-R1-Distill-Qwen-7B** | 7B | **~4.68 GB** | **8 GiB 内存 / 4 vCPU** | ✅ 深度强化推理 | ⭐⭐⭐⭐⭐ **(深度推演)** | **深度推演神器**：7B 强化推理，多步骤财务数据计算、深度多空博弈（适合部署在 Oracle Always Free 24G 内存 VPS 上）。 |
| **Qwen3-0.6B (Q8_0 官方高精度)** | 0.6B | **~639 MB** | **2 GiB 内存 / 2 vCPU** | ✅ 原生支持 | ⭐⭐⭐☆☆ | **3~5秒极速冷启动**：官方 8-bit 无损精度，适合快速信息提取、打标、分类与日常快速问答，0 成本！ |
| **Qwen2.5-7B-Instruct** | 7B | **~4.68 GB** | **8 GiB 内存 / 4 vCPU** | ❌ 无显式思考 | ⭐⭐⭐⭐☆ **(专业稳健)** | **经典 7B 旗舰**：知识面极广，格式遵循能力强，直出高质量研报总结。 |
| **Qwen2.5-3B-Instruct** | 3B | **~1.93 GB** | **4 GiB 内存 / 2 vCPU** | ❌ 无显式思考 | ⭐⭐⭐⭐☆ **(轻快实用)** | **快速响应**：体积适中、速度飞快，适合日常新闻中英文快速翻译与摘要。 |
| **Qwen2.5-1.5B-Instruct** | 1.5B | **~986 MB** | **2 GiB 内存 / 2 vCPU** | ❌ 无显式思考 | ⭐⭐⭐☆☆ **(免费基准)** | **0 成本常驻基准**：不到 1GB 体积，5 秒冷启动，适合日常轻度对话。 |
| **Qwen3-4B-Instruct** | 4B | **~2.50 GB** | **需 GPU (NVIDIA L4) / Ollama** | ✅ 原生支持 | ⭐⭐⭐⭐⭐ **(金融平衡)** | **前沿架构**：含最新 MTP 架构，推荐配合 Cloud Run GPU 或 Ollama 引擎运行。 |

---

## 🔗 全量模型官方 Hugging Face 直链汇总

在 `Dockerfile` 中切换模型时，直接复制对应的一行即可（**已全部通过网络连通性实测验证**）：

```dockerfile
# 1. 【当前默认】DeepSeek-R1-Distill-Qwen-1.5B (~1.11GB，免费档自带 <think> 深度思考与情绪打分，推荐！)
ADD https://huggingface.co/unsloth/DeepSeek-R1-Distill-Qwen-1.5B-GGUF/resolve/main/DeepSeek-R1-Distill-Qwen-1.5B-Q4_K_M.gguf /models/model.gguf

# 2. DeepSeek-R1-Distill-Qwen-7B (~4.68GB，超强思考推理链，金融深度推演推荐)
ADD https://huggingface.co/unsloth/DeepSeek-R1-Distill-Qwen-7B-GGUF/resolve/main/DeepSeek-R1-Distill-Qwen-7B-Q4_K_M.gguf /models/model.gguf

# 3. Qwen3-0.6B (官方 Q8_0 高精度无损版，~639MB，秒级冷启动)
ADD https://huggingface.co/Qwen/Qwen3-0.6B-GGUF/resolve/main/Qwen3-0.6B-Q8_0.gguf /models/model.gguf

# 4. Qwen2.5-3B-Instruct (~1.93GB，轻快型 3B 实用模型)
ADD https://huggingface.co/Qwen/Qwen2.5-3B-Instruct-GGUF/resolve/main/qwen2.5-3b-instruct-q4_k_m.gguf /models/model.gguf

# 5. Qwen2.5-1.5B-Instruct (~986MB，纯免费档常驻基准)
ADD https://huggingface.co/Qwen/Qwen2.5-1.5B-Instruct-GGUF/resolve/main/qwen2.5-1.5b-instruct-q4_k_m.gguf /models/model.gguf

# 6. Qwen3-4B-Instruct (~2.50GB，推荐配合 GPU / Ollama 运行)
ADD https://huggingface.co/unsloth/Qwen3-4B-Instruct-2507-GGUF/resolve/main/Qwen3-4B-Instruct-2507-Q4_K_M.gguf /models/model.gguf
```

---

## 🔄 切换模型的极简操作步骤

当你需要切换模型时，只需 2 步：

### 第一步：修改 `Dockerfile`
将 `Dockerfile` 中的 `ADD ...` 行替换为上述目标模型的直链。

### 第二步：检查并调整 Cloud Run 内存（根据模型大小）
在 GCP 控制台的 Cloud Run 页面点击 **「修改并部署新的修订版本」**：
* **0.6B ~ 1.5B 模型（含 DeepSeek-R1-1.5B）**：设置为 **`2 GiB`** 内存；
* **3B 模型**：设置为 **`4 GiB`** 内存；
* **7B 模型**：设置为 **`8 GiB`** 内存。

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

### 2. Python 官方 SDK 调用示例（金融新闻情绪打分）

```python
from openai import OpenAI

client = OpenAI(
    base_url="https://<YOUR_CLOUD_RUN_URL>/v1",
    api_key="none"
)

# 股票新闻情绪打分 Prompt 模板
prompt = """
请对以下股票新闻进行情绪打分（Sentiment Score），范围为 -1.0 (极度利空) 到 +1.0 (极度利好)，0.0 为中性。
给出：
1. 情绪评分 (Score)
2. 核心看点与多空定性 (Bullish / Bearish / Neutral)
3. 简要理由 (1-2句话)

【新闻内容】：
Tesla (TSLA) Q3 全球交付量达到 462,890 辆，同比增长 6.4%，但略低于部分买方机构的极高预期；
同时储能业务装机量创历史新高，利润率大幅提升。
"""

response = client.chat.completions.create(
    model="deepseek-r1-1.5b",
    messages=[
        {"role": "system", "content": "你是一位资深的华尔街证券量化分析师，擅长从复合市场新闻中精准提炼多空情绪评分。"},
        {"role": "user", "content": prompt}
    ],
    temperature=0.6,
    stream=True
)

for chunk in response:
    content = chunk.choices[0].delta.content or ""
    print(content, end="", flush=True)
print()
```
