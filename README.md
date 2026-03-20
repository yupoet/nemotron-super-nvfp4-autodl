# Nemotron 3 Super 120B NVFP4 - RTX PRO 6000 一键部署

> NVIDIA Nemotron 3 Super 120B-A12B NVFP4 | RTX PRO 6000 (96GB) | vLLM 0.17.1
> Author: github.com/yupoet

## 镜像信息

| 项目 | 内容 |
|------|------|
| 模型 | NVIDIA Nemotron 3 Super 120B-A12B NVFP4 |
| 架构 | Mamba2-Transformer LatentMoE (120B总参/12B激活) |
| 显存占用 | ~69.5 GiB |
| 推理框架 | vLLM 0.17.1 / PyTorch 2.10.0+cu128 |
| 适用GPU | RTX PRO 6000 (96GB) Blackwell |
| 上下文 | 65,536 tokens |
| 能力 | Tool Calling / Reasoning / 中英文 / Agent |

## 快速启动

### 1. 下载模型（首次，约80GB，需100GB数据盘）
```
export HF_HUB_DISABLE_XET=1
export HF_ENDPOINT=https://hf-mirror.com
huggingface-cli download nvidia/NVIDIA-Nemotron-3-Super-120B-A12B-NVFP4 --local-dir /root/autodl-tmp/models/nemotron-super-nvfp4
```

### 2. 一键启动
```
bash /root/start_vllm.sh
```

### 3. 后台运行
```
screen -S vllm && bash /root/start_vllm.sh
```

### 4. 测试
```
curl http://localhost:6006/v1/chat/completions -H "Content-Type: application/json" -d '{"model":"nemotron-super","messages":[{"role":"user","content":"hello"}],"max_tokens":200}'
```

## 对接 Dify

| 配置项 | 值 |
|--------|-----|
| API Base URL | https://<AutoDL公网地址>:8443/v1 |
| API Key | dummy |
| 模型名称 | nemotron-super |
| 上下文长度 | 65536 |
| 最大输出token | 4096 |

## 注意

- GPU必须RTX PRO 6000 (96GB Blackwell)
- 模型不随镜像保存，首次需下载
- 数据盘需扩容到100GB

License: NVIDIA Open Model License / MIT
