# Cloud Run Serverless LLM (Financial & General Purpose)

本仓库提供在 **Google Cloud Run** 上以 **0 闲置成本（Scale to Zero）** 部署开源大语言模型的完整方案。当前默认配置为 **`Qwen3-4B`**，专为 **股票新闻翻译、长文要点提炼、财经博主观点梳理、财报基本面与多空分析** 深度优化。

---

## 🎯 核心架构与费用优势

* **零闲置费用（Scale to Zero）**：
  * 配置 `--min-instances 0`：无请求时容器自动关机，**闲置费用为 $0.00**；
  * 配置 `--max-instances 1`：限制最大并发实例数，彻底防范恶意刷量与账单失控。
* **免费额度与 $10 预算覆盖**：
  * Google Cloud 每月赠送 180,000 vCPU-秒 与 360,000 GiB-秒 免费额度；
  * 配合每月 **$10 GCP Credit**，可支持每月 **15,000+ 篇** 完整股票财报与深度资讯的分析处理。
* **原生 C++ 高性能引擎**：基于 `llama.cpp:server`，提供原生 OpenAI 兼容的 `/v1/chat/completions` API 与流式打字输出。
* **自动化 CI/CD**：只要向 GitHub `main` 分支 push 代码，Cloud Build 就会自动拉取模型并无缝上线。

---

## 📊 可选模型深度对比与选型指南

下表汇总了经过测试、可直接在 Cloud Run 或本地运行的优质开源模型：

| 模型型号 | 参数量 | GGUF体积 | 推荐 Cloud Run 配置 | 思考链 (`<think>`) | 股票金融场景匹配度 | 适用场景特点 |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Qwen3-4B** *(当前默认)* | 4B | ~2.5 GB | **4 GiB 内存 / 2~4 vCPU** | ✅ 原生支持 | ⭐⭐⭐⭐⭐ **(最推荐)** | **金融分析黄金平衡**：财报对比、术语翻译、博主发帖梳理、多空分析。 |
| **DeepSeek-R1-Distill-Qwen-7B** | 7B | ~4.68 GB | **6~8 GiB 内存 / 4 vCPU** | ✅ 深度强化推理 | ⭐⭐⭐⭐⭐ **(强力推演)** | **高难度推演神器**：复杂多步骤财务数据计算、深度估值与逻辑辩证。 |
| **Qwen2.5-7B-Instruct** | 7B | ~4.68 GB | **6~8 GiB 内存 / 4 vCPU** | ❌ 无显式思考 | ⭐⭐⭐⭐☆ **(专业稳健)** | **经典 7B 旗舰**：知识面极广，格式遵循能力强，直出高质量结论。 |
| **Qwen2.5-3B-Instruct** | 3B | ~1.93 GB | **4 GiB 内存 / 2 vCPU** | ❌ 无显式思考 | ⭐⭐⭐⭐☆ **(轻快实用)** | **快速响应**：体积小、速度快，适合日常新闻中英文快速翻译与摘要。 |
| **Qwen3-0.6B** | 0.6B | ~420 MB | **1~2 GiB 内存 / 2 vCPU** | ✅ 原生支持 | ⭐⭐☆☆☆ **(偏小)** | **3秒极速冷启动**：适合简单的自动化标题提取、分类打标，不适合复杂分析。 |
| **Qwen2.5-1.5B-Instruct** | 1.5B | ~986 MB | **2 GiB 内存 / 2 vCPU** | ❌ 无显式思考 | ⭐⭐⭐☆☆ **(入门基准)** | **0 成本免费档常驻**：内存占用小，适合日常轻度对话。 |

---

## 🔗 各模型官方 Hugging Face 直链汇总

在 `Dockerfile` 中切换模型时，直接复制对应的一行即可：

```dockerfile
# 1. 【当前默认】Qwen3-4B (~2.5GB，金融分析/思考链推荐)
ADD https://huggingface.co/Qwen/Qwen3-4B-GGUF/resolve/main/Qwen3-4B-Q4_K_M.gguf /models/model.gguf

# 2. DeepSeek-R1-Distill-Qwen-7B (~4.68GB，超强思考推演)
ADD https://huggingface.co/unsloth/DeepSeek-R1-Distill-Qwen-7B-GGUF/resolve/main/DeepSeek-R1-Distill-Qwen-7B-Q4_K_M.gguf /models/model.gguf

# 3. Qwen2.5-7B-Instruct (~4.68GB，官方 7B 旗舰)
ADD https://huggingface.co/Qwen/Qwen2.5-7B-Instruct-GGUF/resolve/main/qwen2.5-7b-instruct-q4_k_m.gguf /models/model.gguf

# 4. Qwen2.5-3B-Instruct (~1.93GB，轻快型 3B)
ADD https://huggingface.co/Qwen/Qwen2.5-3B-Instruct-GGUF/resolve/main/qwen2.5-3b-instruct-q4_k_m.gguf /models/model.gguf

# 5. Qwen3-0.6B (~420MB，极速冷启动)
ADD https://huggingface.co/Qwen/Qwen3-0.6B-GGUF/resolve/main/Qwen3-0.6B-Q4_K_M.gguf /models/model.gguf

# 6. Qwen2.5-1.5B-Instruct (~986MB，纯免费档基准)
ADD https://huggingface.co/Qwen/Qwen2.5-1.5B-Instruct-GGUF/resolve/main/qwen2.5-1.5b-instruct-q4_k_m.gguf /models/model.gguf
```

---

## 🔄 切换模型的极简操作步骤

当你需要切换模型时，只需 2 步：

### 第一步：修改 `Dockerfile`
将 `Dockerfile` 中的 `ADD ...` 行替换为上述目标模型的链接。若切换为长文本/多并发，可顺带调整环境变量（如 `LLAMA_ARG_CTX_SIZE=4096`）。

### 第二步：检查并调整 Cloud Run 内存（根据模型大小）
在 GCP 控制台的 Cloud Run 页面点击 **「修改并部署新的修订版本」**：
* **0.6B ~ 1.5B 模型**：设置为 **`2 GiB`** 内存；
* **3B ~ 4B 模型**：设置为 **`4 GiB`** 内存；
* **7B 模型**：设置为 **`6 GiB` ~ `8 GiB`** 内存。

### 第三步：提交并推送
```bash
git add Dockerfile
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

# 股票财报分析提示词
prompt = """
【财报分析】
英伟达(NVDA)最新季度营收351亿美元，同比增长94%，净利润193亿美元。
数据中心营收308亿美元，Blackwell芯片需求强劲但面临供应链产能制约。
请提炼核心看点，并给出多空（Bull/Bear）简评。
"""

response = client.chat.completions.create(
    model="qwen3-4b",
    messages=[
        {"role": "system", "content": "你是一位资深的华尔街证券分析师，擅长基本面分析与多空逻辑拆解。"},
        {"role": "user", "content": prompt}
    ],
    temperature=0.7,
    stream=True
)

for chunk in response:
    content = chunk.choices[0].delta.content or ""
    print(content, end="", flush=True)
print()
```

### 3. 接入第三方客户端（如 NextChat / Chatbox / Open WebUI）
* **接口服务商**：`OpenAI` / `自定义 API`
* **API Host**：`https://<YOUR_CLOUD_RUN_URL>/v1`
* **API Key**：随便填写（如 `none`）
* **模型名称**：`qwen3-4b`
