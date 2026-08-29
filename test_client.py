#!/usr/bin/env python3
"""
Test client for Cloud Run LLM Server (OpenAI-compatible)
Usage:
    python test_client.py https://<your-cloud-run-url>
    python test_client.py http://localhost:8080
"""

import sys
import json
import urllib.request
import urllib.error

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
        "Content-Type": "application/json"
    }

    req = urllib.request.Request(
        url,
        data=json.dumps(payload).encode("utf-8"),
        headers=headers,
        method="POST"
    )

    print(f"\n[Prompt]: {prompt}")
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
        print("\n")
    except urllib.error.HTTPError as e:
        print(f"\nHTTP Error {e.code}: {e.read().decode('utf-8')}")
    except Exception as e:
        print(f"\nError: {e}")

def main():
    if len(sys.argv) > 1:
        base_url = sys.argv[1]
    else:
        base_url = input("Enter Cloud Run Service URL (or http://localhost:8080): ").strip()

    if not base_url:
        print("Error: URL cannot be empty.")
        sys.exit(1)

    print(f"Connecting to: {base_url}")
    print("Testing connection (this may take ~10s if the instance is cold-starting)...")

    # Sample queries
    chat_stream(base_url, "你好，请用一句话介绍你自己。")
    chat_stream(base_url, "写一首关于云计算的五言绝句。")

if __name__ == "__main__":
    main()
