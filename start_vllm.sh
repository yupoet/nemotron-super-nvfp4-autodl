#!/bin/bash
export OMP_NUM_THREADS=1
export PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True

MODEL_PATH="/root/autodl-tmp/models/nemotron-super-nvfp4"
PORT=6006

if [ ! -f "$MODEL_PATH/config.json" ]; then
    echo "❌ 模型未找到: $MODEL_PATH"
    echo "请先下载模型（约80GB）："
    echo "  export HF_HUB_DISABLE_XET=1"
    echo "  export HF_ENDPOINT=https://hf-mirror.com"
    echo "  huggingface-cli download nvidia/NVIDIA-Nemotron-3-Super-120B-A12B-NVFP4 --local-dir $MODEL_PATH"
    exit 1
fi

if ! nvidia-smi &>/dev/null; then
    echo "❌ 未检测到 GPU"
    exit 1
fi

echo "🚀 Nemotron 3 Super 120B NVFP4 推理服务"
echo "📍 端口: $PORT"
echo "📍 模型: $(du -sh $MODEL_PATH | cut -f1)"
echo "📍 API:  http://localhost:$PORT/v1/chat/completions"

pkill -9 -f "vllm serve" 2>/dev/null
sleep 1

vllm serve $MODEL_PATH \
  --host 0.0.0.0 \
  --port $PORT \
  --max-num-seqs 4 \
  --tensor-parallel-size 1 \
  --max-model-len 65536 \
  --trust-remote-code \
  --served-model-name nemotron-super \
  --enable-auto-tool-choice \
  --tool-call-parser qwen3_coder \
  --reasoning-parser nemotron_v3 \
  --kv-cache-dtype fp8 \
  --gpu-memory-utilization 0.92
