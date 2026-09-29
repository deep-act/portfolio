# HANDOFF · RL 作品集网页交接说明（2026-09-16 更新版）

> 本文件是给下一个接手 AI / 人的完整交接说明，可直接转交。
> 上一版交接说明中「唯一未完成项：LTX-2 生成视频」与「缺 Nano World Model 卡」两件事，
> 本次会话已处理，当前状态见下文第 3 节。

## 一句话目标
做一个**以图片/视频为主、文字精简**的单页作品集，展示四个强化学习项目
（TRL / SmolVLA / Nano World Model / RLinf），给"想做 RL 技术"的领导看。
用 LTX-2 生成贴合业务的短片增强，**不得复用** `LTX-2/outputs` 里的旧片（与项目无关）。

## 1. 交付物位置
- 主页面：`/ya/Code/tanghan/portfolio/index.html`（纯静态、自包含）
- 资源目录：`/ya/Code/tanghan/portfolio/assets/`（`trl/ rlinf/ vla/ gen/ nanowm/`）
- 生成守护脚本：`/ya/Code/tanghan/portfolio/gen_videos.sh`
- 预览服务：`python -m http.server 8099`（root=`portfolio/`），
  本地访问需 `ssh -p 30055 -L 8099:127.0.0.1:8099 root@117.50.80.100` 后开 `http://127.0.0.1:8099`
- 文字版完整文档：`/ya/Code/tanghan/portfolio/README.md`（指标、排障细节、证据路径都在里面）

## 2. 页面结构（四张项目卡，顺序即页面顺序）
1. **TRL**（LLM RL）：真实 GRPO 曲线 + LTX-2 生成主题视频（已上片 ✅）
2. **SmolVLA**（具身 VLA）：4 段真实 LIBERO rollout 视频（成功×3 / 长程失败×1）
3. **Nano World Model**（世界模型，**本次新增**）：2 段"生成|真值"对比 rollout 视频 + 自训 30k loss 曲线
4. **RLinf**（RL 引擎）：真实 GRPO success 曲线 + LTX-2 生成主题视频（已上片 ✅）

> 所有 `<figure class="ph">` 占位块均已替换完毕，页面无残留占位。

每卡结构 =「问题(红)/技术方案(绿)」+ 媒体墙 + 数字条 + 证据折叠 + 页脚。
页面 hero 文案、chips、footer 已同步更新为"四个项目"。

## 3. 素材清单（均为真实产出）

| 文件 | 来源/含义 |
|---|---|
| `assets/vla/*.mp4`(4段) | SmolVLA LIBERO 真实 rollout：object/goal/spatial 成功 + long10 长程失败 |
| `assets/trl/grpo_curve.png` | 真实 GRPO 曲线，从 `TRL/outputs/grpo-gsm8k-lora-v3/checkpoint-934/trainer_state.json` 画（930步，reward 0.40→0.55，峰值0.75） |
| `assets/rlinf/grpo_curve.png` | 真实 GRPO success 曲线，从 `RLinf/experiment_archive/medium_48g/20260830_162203/rlinf_grpo/metrics.log` 画 |
| `assets/nanowm/rollout_30k_long.mp4` | **自训 30k** checkpoint 的 20 帧长程 rollout（512×256 拼接：左=模型预测，右=真值），源自 `Nano World Model/results/long_rollout/point_maze_30k/` |
| `assets/nanowm/official_ckpt_cmp*.mp4` | 官方权重端到端推理验证（PSNR 36.88–37.13），源自 `Nano World Model/results/rollout_official_ckpt/` |
| `assets/nanowm/train_loss_curve.png` | 本次新画：从 `results/phase2/dino_wm_point_maze/rank_0.log` 解析（300 点，step 100→30000，train_loss ≈0.22→0.0028，log 轴） |
| `assets/gen/trl.mp4` | LTX-2 生成（✅ 已完成并上页，324KB，768×512 49帧） |
| `assets/gen/rlinf.mp4` | LTX-2 生成（✅ 已完成并上页，524KB，机器人 RL 集群意象） |
| `assets/gen/vla.mp4` | LTX-2 生成（✅ 已完成，232KB；页面 SmolVLA 卡用真实 rollout，本片作为备用素材/未来 hero 候选） |

## 4. LTX-2 生成：机制与当前状态
- 守护 `gen_videos.sh`：每 60s 查空闲显存，≥`FREE_MIN` 才开跑；失败（含 OOM/被抢占）每 300s 自动重试，
  每段最多 `MAX_TRIES=40` 次。产物落在 `assets/gen/<name>.mp4`，日志 `assets/gen/gen.log`。
- **本次结果（2026-09-16 07:50–07:59）**：三段全部一次成功，无 OOM——
  `trl.mp4`（07:50）→ `vla.mp4`（07:54）→ `rlinf.mp4`（07:59），每段约 4 分钟。
- **关键经验**：fp8-cast + `--offload cpu` 在**空闲约 11GB** 时即可跑通 49帧/512×768，
  因此本次以 `FREE_MIN=11000` 启动守护（上次会话阈值 18000 导致长期等不到窗口、唯一一次开跑还被其他租户抢占 OOM）。
- 启动命令（如守护不在了，重新拉起）：
  `FREE_MIN=11000 nohup bash /ya/Code/tanghan/portfolio/gen_videos.sh </dev/null >/dev/null 2>&1 & disown`
- 生成完成后把 RLinf 卡上残留的 `<figure class="ph">…</figure>` 占位块替换为
  `<figure class="gen"><video controls muted loop playsinline preload="metadata"><source src="assets/gen/rlinf.mp4" type="video/mp4"></video><figcaption>…</figcaption></figure>`
  （参照 TRL 卡现有写法；`.gen` 类自带左上角"LTX-2 生成"角标）。

## 5. 环境要点（避免踩坑）
- **共享 24GB RTX 4090 多租户**：GPU 上的其他进程 PID 在本机命名空间**看不到**（ps 查无此 PID），
  **严禁按 nvidia-smi 的 PID 盲杀**——只等显存空出，或联系管理员。
- LTX-2 调用细节全在 `/ya/Code/tanghan/LTX-2/scripts/nanobot_video.sh` 与 `gen_videos.sh`
  （torch 2.11+cu126 需 `LD_PRELOAD=/ya/Code/tanghan/LTX-2/libnccl_shim.so` 垫片，否则 import 即报 `ncclCommShrink` 缺符号）。
- 画曲线用 `/ya/Code/tanghan/SmolVLA/.venv/bin/python`（带 matplotlib/cv2，Agg 后端，图内标签用**英文**否则中文字形缺失）；
  该 venv **没有 tensorboard**，NanoWM 曲线请从 `rank_0.log` 文本解析。
- NanoWM 复跑实验前检查 `libcuda.so.1` 软链是否又被系统重置（CUDA Error 804，见其 REPRODUCTION_REPORT.md 第 2 节）。

## 6. 遗留事项
- [x] ~~LTX-2 三段生成 + 占位块替换~~（本次已全部完成）
- [x] ~~新增 Nano World Model 项目卡~~（本次已完成）
- [ ] 可选：`assets/gen/vla.mp4` 暂未上页（SmolVLA 卡用的是真实 rollout），可作为备用素材或未来 hero 候选；若想换 LTX-2 生成的 hero 片，另起 prompt 生成。
- [ ] 若再次生成：直接用第 4 节启动命令；fp8+offload 模式下 `FREE_MIN=11000` 即可，不必等 18GB。
