#!/usr/bin/env bash
# gen_videos.sh —— 等 GPU 空闲后，用 LTX-2 生成三段贴合项目业务的短片。
# 不干扰现有进程：只有当空闲显存 >= FREE_MIN_MiB 时才启动，失败(含 OOM)自动重试。
# 产物：/ya/Code/tanghan/portfolio/assets/gen/{trl,vla,rlinf}.mp4
set -u

LTX_DIR="/ya/Code/tanghan/LTX-2"
PY="$LTX_DIR/.venv/bin/python"
OUTDIR="/ya/Code/tanghan/portfolio/assets/gen"
LOG="$OUTDIR/gen.log"
mkdir -p "$OUTDIR"

FREE_MIN=${FREE_MIN:-18000}     # 需要 >= 18GB 空闲才开跑
INTERVAL=${INTERVAL:-60}        # 轮询间隔秒
MAX_TRIES=${MAX_TRIES:-40}      # 每段最多重试次数

log(){ echo "[$(date '+%m-%d %H:%M:%S')] $*" | tee -a "$LOG"; }

free_mib(){ nvidia-smi --query-gpu=memory.free --format=csv,noheader,nounits 2>/dev/null | head -1; }

wait_free(){
  while :; do
    f=$(free_mib); [ -z "$f" ] && f=0
    if [ "$f" -ge "$FREE_MIN" ]; then log "GPU free=${f}MiB >= ${FREE_MIN}MiB，开始生成"; return 0; fi
    log "GPU 忙 (free=${f}MiB)，${INTERVAL}s 后重查"; sleep "$INTERVAL"
  done
}

gen(){  # name prompt
  local name="$1" prompt="$2" out="$OUTDIR/$1.mp4" try=0
  while [ "$try" -lt "$MAX_TRIES" ]; do
    wait_free
    log "生成 [$name] 第 $((try+1)) 次尝试 ..."
    ( cd "$LTX_DIR" && export PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True \
        LD_PRELOAD="$LTX_DIR/libnccl_shim.so" \
      && "$PY" -m ltx_pipelines.distilled \
        --distilled-checkpoint-path models/LTX-2/ltx-2-19b-distilled.safetensors \
        --gemma-root                models/gemma-3-12b-ltx \
        --spatial-upsampler-path    models/LTX-2/ltx-2-spatial-upscaler-x2-1.0.safetensors \
        --num-frames 49 --height 512 --width 768 --seed 42 \
        --quantization fp8-cast --offload cpu \
        --output-path "$out" --prompt "$prompt" ) >>"$LOG" 2>&1
    if [ $? -eq 0 ] && [ -f "$out" ]; then log "✅ [$name] 完成 -> $out"; return 0; fi
    try=$((try+1)); log "❌ [$name] 失败(可能显存不足/被抢占)，300s 后重试"; sleep 300
  done
  log "⛔ [$name] 达到最大重试次数，放弃"; return 1
}

log "==== gen_videos.sh 启动 (PID $$) ===="
gen trl  "A cinematic visualization of an artificial intelligence solving mathematics: glowing handwritten equations and numbers on a dark chalkboard assemble themselves into a correct final answer, camera slowly pushing in, clean futuristic high-tech aesthetic, soft blue light."
gen vla  "A realistic white robotic arm on a clean table in a bright modern laboratory precisely grasping a black bowl and placing it into a woven basket, smooth accurate motion, top-down then side view, shallow depth of field, natural lighting."
gen rlinf "Futuristic data-center style robotics lab where several robotic arms train together, streams of glowing particles flowing between them and GPU server racks in the background representing distributed reinforcement learning, sleek clean aesthetic, slow dolly camera move."
log "==== 全部任务结束 ===="
