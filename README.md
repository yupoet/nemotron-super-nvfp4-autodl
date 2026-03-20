# 🚀 Nemotron 3 Super 120B NVFP4 - RTX PRO 6000 一键部署 | One-Click Deploy

[![AutoDL Image](https://img.shields.io/badge/AutoDL-镜像发布-blue)](https://www.autodl.art/i/yupoet/nemotron-super-nvfp4-autodl/nemotron-super-nvfp4-rtx-pro-6000)
[![NVIDIA](https://img.shields.io/badge/NVIDIA-Nemotron_3_Super-76B900?logo=nvidia)](https://huggingface.co/nvidia/NVIDIA-Nemotron-3-Super-120B-A12B-NVFP4)
[![vLLM](https://img.shields.io/badge/vLLM-0.17.1-orange)](https://github.com/vllm-project/vllm)
[![License](https://img.shields.io/badge/License-NVIDIA_Open_Model-green)](https://developer.nvidia.com/open-model-license)

**[中文](#中文) | [English](#english)**

---

# 中文

> 在 AutoDL RTX PRO 6000 (96GB) 上一键部署 NVIDIA Nemotron 3 Super 120B-A12B NVFP4 推理服务，
> 提供 OpenAI 兼容 API，支持 Tool Calling / Reasoning / 中英文对话。

**AutoDL 镜像地址：** [点击使用](https://www.autodl.art/i/yupoet/nemotron-super-nvfp4-autodl/nemotron-super-nvfp4-rtx-pro-6000)

## 📋 概览

| 项目 | 内容 |
|------|------|
| **模型** | NVIDIA Nemotron 3 Super 120B-A12B NVFP4 |
| **架构** | Mamba2-Transformer 混合 LatentMoE（120B 总参 / 12B 激活） |
| **精度** | NVFP4 — Blackwell 原生 4-bit 浮点 |
| **显存占用** | ~69.5 GiB |
| **推理框架** | vLLM 0.17.1 |
| **PyTorch** | 2.10.0+cu128 |
| **适用 GPU** | NVIDIA RTX PRO 6000 (96GB) / Blackwell 架构 |
| **API 格式** | OpenAI 兼容（`/v1/chat/completions`） |
| **上下文长度** | 65,536 tokens（可调至 128K） |
| **支持能力** | ✅ Tool Calling · ✅ Reasoning · ✅ 中英文 · ✅ Agent |

## ⚡ 为什么选这个方案？

- **单卡跑 120B**：RTX PRO 6000 96GB 单卡即可运行，无需多卡并行
- **12B 激活参数**：MoE 架构每 token 只激活 12B 参数，推理效率极高
- **Agent 能力顶级**：PinchBench 开源模型第一，tool call 成功率最高
- **Blackwell 原生加速**：NVFP4 利用 RTX PRO 6000 Tensor Core 硬件特性
- **开箱即用**：一条命令启动，OpenAI 兼容 API，直接对接 Dify / FastGPT / LobeChat

## 🚀 快速开始

### 1. 下载模型（首次使用，约 80GB，需 100GB 数据盘）

```bash
export HF_HUB_DISABLE_XET=1
export HF_ENDPOINT=https://hf-mirror.com
export HF_HUB_ENABLE_HF_TRANSFER=0

huggingface-cli download \
  nvidia/NVIDIA-Nemotron-3-Super-120B-A12B-NVFP4 \
  --local-dir /root/autodl-tmp/models/nemotron-super-nvfp4
```

### 2. 一键启动

```bash
bash /root/start_vllm.sh
```

等待 `Application startup complete.` 即启动成功。

### 3. 后台运行（防 SSH 断开）

```bash
screen -S vllm
bash /root/start_vllm.sh
# 启动后 Ctrl+A 再按 D 分离
# 重新连接：screen -r vllm
```

### 4. 测试

```bash
curl http://localhost:6006/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "nemotron-super",
    "messages": [{"role": "user", "content": "你好，介绍一下你自己"}],
    "max_tokens": 200
  }'
```

## 🔧 对接 Dify / 其他 AI 平台

| 配置项 | 值 |
|--------|-----|
| 模型供应商 | OpenAI-API-compatible |
| API Base URL | `https://<AutoDL公网地址>:8443/v1` |
| API Key | `dummy`（任意值，vLLM 不校验） |
| 模型名称 | `nemotron-super` |
| 上下文长度 | `65536` |
| 最大输出 token | `4096` |

AutoDL 端口 6006 自动映射到公网，在实例页面"自定义服务"查看 URL。

## 🛠 Tool Calling 示例

```bash
curl http://localhost:6006/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "nemotron-super",
    "messages": [
      {"role": "system", "content": "你是数据分析助手。当用户查询数据时，调用相应工具。"},
      {"role": "user", "content": "查一下深圳罗湖万象城500米内的奶茶店"}
    ],
    "tools": [{
      "type": "function",
      "function": {
        "name": "query_nearby_stores",
        "description": "查询指定地点附近的餐饮门店",
        "parameters": {
          "type": "object",
          "properties": {
            "location": {"type": "string", "description": "地点名称"},
            "city": {"type": "string", "description": "城市"},
            "radius_meters": {"type": "integer", "description": "搜索半径(米)"}
          },
          "required": ["location", "city"]
        }
      }
    }],
    "tool_choice": "auto",
    "max_tokens": 1024
  }'
```

## ⚙️ 参数调优

| 场景 | 参数 | 说明 |
|------|------|------|
| 更大上下文 | `--max-model-len 131072` | 减少并发能力 |
| 更多并发 | `--max-num-seqs 8 --max-model-len 32768` | 适合多用户 |
| 极限并发 | `--max-num-seqs 16 --max-model-len 16384` | 高吞吐场景 |

## 💻 环境信息

```
OS:           Ubuntu 22.04.5 LTS
Python:       3.12.3
PyTorch:      2.10.0+cu128
vLLM:         0.17.1
FlashInfer:   0.6.4
Triton:       3.6.0
Transformers: 4.57.6
NVIDIA Driver: 580.95.05
CUDA:         13.0 (Driver) / 12.8 (PyTorch)
```

## ⚠️ 注意事项

1. **GPU 要求**：必须使用 RTX PRO 6000（Blackwell 架构 96GB），其他 GPU 显存不够
2. **数据盘**：需扩容到 100GB，模型约 80GB
3. **模型不随镜像保存**：模型在数据盘 `/root/autodl-tmp/`，首次需下载
4. **国内下载加速**：已配置 `HF_HUB_DISABLE_XET=1` + `hf-mirror.com`
5. **后台运行**：建议使用 `screen -S vllm` 启动，防止 SSH 断连

## 🔗 同系列镜像

| 镜像 | GPU | 模型 |
|------|-----|------|
| [nemotron-nano-nvfp4-rtx5090](https://www.autodl.art/i/yupoet/nemotron-nano-nvfp4-autodl/nemotron-nano-nvfp4-rtx5090) | RTX 5090 (32GB) | Nano 30B-A3B NVFP4 |
| **本镜像** | **RTX PRO 6000 (96GB)** | **Super 120B-A12B NVFP4** |

---

# English

> One-click deployment of NVIDIA Nemotron 3 Super 120B-A12B NVFP4 on AutoDL RTX PRO 6000 (96GB),
> serving an OpenAI-compatible API with Tool Calling, Reasoning, and bilingual support.

**AutoDL Image:** [Use this image](https://www.autodl.art/i/yupoet/nemotron-super-nvfp4-autodl/nemotron-super-nvfp4-rtx-pro-6000)

## 📋 Overview

| Item | Detail |
|------|--------|
| **Model** | NVIDIA Nemotron 3 Super 120B-A12B NVFP4 |
| **Architecture** | Mamba2-Transformer Hybrid LatentMoE (120B total / 12B active) |
| **Precision** | NVFP4 — Blackwell native 4-bit floating point |
| **VRAM Usage** | ~69.5 GiB |
| **Inference Engine** | vLLM 0.17.1 |
| **PyTorch** | 2.10.0+cu128 |
| **Required GPU** | NVIDIA RTX PRO 6000 (96GB) / Blackwell architecture |
| **API Format** | OpenAI-compatible (`/v1/chat/completions`) |
| **Context Length** | 65,536 tokens (adjustable to 128K) |
| **Capabilities** | ✅ Tool Calling · ✅ Reasoning · ✅ Bilingual (EN/CN) · ✅ Agent |

## ⚡ Why This Setup?

- **Single-GPU 120B**: RTX PRO 6000 96GB runs the full model on one card
- **12B active parameters**: MoE activates only 12B params per token for high efficiency
- **Top agent performance**: #1 open model on PinchBench with highest tool call accuracy
- **Blackwell-native**: NVFP4 leverages RTX PRO 6000 Tensor Core hardware
- **Ready to use**: Single command startup, OpenAI-compatible API

## 🚀 Quick Start

### 1. Download Model (~80GB, first time only, requires 100GB data disk)

```bash
export HF_HUB_DISABLE_XET=1
export HF_HUB_ENABLE_HF_TRANSFER=0
# For China: export HF_ENDPOINT=https://hf-mirror.com

huggingface-cli download \
  nvidia/NVIDIA-Nemotron-3-Super-120B-A12B-NVFP4 \
  --local-dir /root/autodl-tmp/models/nemotron-super-nvfp4
```

### 2. Start Server

```bash
bash /root/start_vllm.sh
```

### 3. Run in Background

```bash
screen -S vllm
bash /root/start_vllm.sh
# Ctrl+A then D to detach | screen -r vllm to reattach
```

### 4. Test

```bash
curl http://localhost:6006/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "nemotron-super",
    "messages": [{"role": "user", "content": "Hello"}],
    "max_tokens": 200
  }'
```

## 🔧 Connect to Dify / Other Platforms

| Config | Value |
|--------|-------|
| API Base URL | `https://<your-autodl-url>:8443/v1` |
| API Key | `dummy` |
| Model Name | `nemotron-super` |
| Context Length | `65536` |
| Max Output Tokens | `4096` |

## ⚙️ Tuning Guide

| Scenario | Parameter | Notes |
|----------|-----------|-------|
| Larger context | `--max-model-len 131072` | Reduces concurrency |
| More concurrency | `--max-num-seqs 8 --max-model-len 32768` | Multi-user |
| Max throughput | `--max-num-seqs 16 --max-model-len 16384` | High concurrency |

## ⚠️ Important Notes

1. **GPU**: Must use RTX PRO 6000 (96GB Blackwell)
2. **Data disk**: Expand to 100GB
3. **Model not in image**: Download required on first use
4. **China acceleration**: `HF_HUB_DISABLE_XET=1` + `HF_ENDPOINT=https://hf-mirror.com`

## 🔗 Related

| Image | GPU | Model |
|-------|-----|-------|
| [nemotron-nano-nvfp4-rtx5090](https://www.autodl.art/i/yupoet/nemotron-nano-nvfp4-autodl/nemotron-nano-nvfp4-rtx5090) | RTX 5090 (32GB) | Nano 30B-A3B |
| **This image** | **RTX PRO 6000 (96GB)** | **Super 120B-A12B** |

- [Model Card](https://huggingface.co/nvidia/NVIDIA-Nemotron-3-Super-120B-A12B-NVFP4) · [Tech Report](https://arxiv.org/abs/2512.20856) · [vLLM Docs](https://docs.vllm.ai/) · [AutoDL](https://autodl.com)

**License:** Model: [NVIDIA Open Model License](https://developer.nvidia.com/open-model-license) · Code: MIT

**Made by [yupoet](https://github.com/yupoet)** ⭐
