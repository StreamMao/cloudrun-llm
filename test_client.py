#!/usr/bin/env python3
"""
Test client for Cloud Run LLM Server (OpenAI-compatible)
Usage:
    python3 test_client.py https://<your-cloud-run-url>
"""

import sys
import json
import time
import urllib.request
import urllib.error

def wait_for_ready(base_url: str, max_retries: int = 30, retry_delay: int = 2) -> bool:
    """Polls /health until the model finishes loading into RAM."""
    health_url = f"{base_url.rstrip('/')}/health"
    print(f"Checking server readiness at {health_url}...")

    for attempt in range(1, max_retries + 1):
        try:
            req = urllib.request.Request(health_url, headers={"User-Agent": "LLM-Client"})
            with urllib.request.urlopen(req, timeout=10) as resp:
                if resp.status == 200:
                    print("✅ Server is READY and model is loaded in RAM!\n")
                    return True
        except urllib.error.HTTPError as e:
            if e.code == 503:
                print(f"⏳ [{attempt}/{max_retries}] Model is loading into RAM... (Cloud Run cold start)")
            else:
                print(f"⚠️ [{attempt}/{max_retries}] HTTP {e.code}: {e.read().decode('utf-8')}")
        except Exception as e:
            print(f"⏳ [{attempt}/{max_retries}] Connecting to container... ({e})")

        time.sleep(retry_delay)

    print("❌ Timed out waiting for server to be ready.")
    return False

def chat_stream(base_url: str, prompt: str):
    url = f"{base_url.rstrip('/')}/v1/chat/completions"
    payload = {
        "messages": [
            {"role": "system", "content": "You are a helpful and concise AI assistant."},
            {"role": "user", "content": prompt}
        ],
        "temperature": 0.7,
        "max_tokens": 512,
        "stream": True
    }
    
    headers = {
        "Content-Type": "application/json",
        "User-Agent": "LLM-Client"
    }

    req = urllib.request.Request(
        url,
        data=json.dumps(payload).encode("utf-8"),
        headers=headers,
        method="POST"
    )

    print(f"[Prompt]: {prompt}")
    print("[Response]: ", end="", flush=True)

    try:
        with urllib.request.urlopen(req, timeout=120) as response:
            for line in response:
                line = line.decode("utf-8").strip()
                if not line or line.startswith(":"):
                    continue
                if line.startswith("data: "):
                    data_str = line[6:]
                    if data_str == "[DONE]":
                        break
                    try:
                        data = json.loads(data_str)
                        delta = data.get("choices", [{}])[0].get("delta", {})
                        content = delta.get("content", "")
                        print(content, end="", flush=True)
                    except json.JSONDecodeError:
                        pass
        print("\n" + "-"*50)
    except urllib.error.HTTPError as e:
        print(f"\nHTTP Error {e.code}: {e.read().decode('utf-8')}")
    except Exception as e:
        print(f"\nError: {e}")

def main():
    if len(sys.argv) > 1:
        base_url = sys.argv[1]
    else:
        base_url = input("Enter Cloud Run Service URL (e.g. https://cloudrun-llm-...a.run.app): ").strip()

    if not base_url:
        print("Error: URL cannot be empty.")
        sys.exit(1)

    print("=" * 50)
    print(f"Connecting to: {base_url}")
    print("=" * 50)

    # 1. Wait for cold-start / model loading
    if not wait_for_ready(base_url):
        sys.exit(1)

    # 2. Run chat tests
    chat_stream(base_url, "你好，请用一句话介绍你自己。")
    chat_stream(base_url, "请用Python写一个快速排序函数。")

if __name__ == "__main__":
    main()
