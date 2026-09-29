# 具身智能与强化学习技术 · 项目作品集

> 围绕"让智能体在环境中通过强化学习掌握操作技能"这一主线，在受限的单卡 GPU 云环境上，
> 独立完成一整套**具身强化学习技术栈**的搭建、复现、训练与系统级调试：
> **RL 训练基础设施（RLinf）· VLA 策略（SmolVLA）· 世界模型（Nano World Model）**。
> 以下指标均来自项目内真实落盘的报告与训练日志。

> **角色说明（诚实前提）**：RLinf / LeRobot(SmolVLA) / DINO-WM(NanoWM) 均为业界成熟的开源框架与模型，非本人原创。
> 本人在其中的工作是 **环境搭建、端到端复现、真实训练执行、系统级排障、工具链与结果分析**——
> 即在资源受限（单张 24/48GB GPU、离线网络）条件下，把这些前沿 RL 系统真正跑起来并产出可复现结果。

---

## 一条主线：具身强化学习全栈

| 层 | 项目 | 作用 |
|---|---|---|
| ① 世界模型 / 可学习仿真器 | **Nano World Model** | Diffusion Forcing + DiT，作为 MBRL 的低成本 rollout 引擎 |
| ② 策略模型 VLA（被优化对象） | **SmolVLA** | 视觉-语言-动作策略本体，完成 LIBERO 训练+评测闭环 |
| ③ RL 训练基础设施（引擎） | **RLinf** | 支撑 GRPO/PPO/SAC，串起 数据→SFT→RL→评测，跑通 VLA+RL 真实训练 |

---

## 项目一 · RLinf：具身智能强化学习训练基础设施 （核心 RL 工作）

**框架**：RLinf（arXiv:2509.15965）面向 Embodied & Agentic AI 的开源 RL 基础设施，已入选 **PyTorch Ecosystem**、
被 **Isaac Lab v3** 官方采用，论文中稿 **OSDI / RSS 2026**；支持 GRPO/PPO/SAC/IQL/DAgger 等，后端覆盖 FSDP/vLLM/SGLang/Megatron，
混合执行相对同类框架最高 **2.434× 吞吐**。

**我实际完成的工作**
- 在**单张受限显存 GPU（24GB/48GB）**上端到端跑通 **VLA + RL 四阶段流水线**：
  VLM 对齐 → OpenVLA SFT(LoRA) → OpenVLA-OFT SFT(L1 回归, LoRA r=16) → **RLinf GRPO 强化微调**（ManiSkill / LIBERO）。
- 完成**真实 GRPO 强化训练**：medium **500 步**（每 50 步存 ckpt）、effective 50 步，产出 reward / success_once 曲线与全套元数据。
- `status.tsv` 逐阶段记录流水线时间线（effective_48g 四阶段全部 COMPLETE，GRPO 段 13:13→14:46）。

**系统级排障与根因分析（RL 工程硬核部分）**
- **7B 全参数 GRPO OOM 根因**：参数(bf16)14GB + 梯度(bf16)14GB + AdamW 状态(fp32)≈56GB，在 `warmup_optimizer_state` 必然爆显存；
  且 `cpu_offload` 只卸载参数/梯度、**不卸载优化器状态** → 据此改用 **LoRA GRPO** 落地。
- **actor↔rollout 权重同步 IPC OOM**：两份 ~14GB 模型副本同步瞬间同时驻留 → FSDP `cpu_offload` + 梯度检查点 + offload 组合解决。
- **无头渲染适配**：为仿真准备 EGL/Vulkan 版 MuJoCo 渲染库，保证云端容器 rollout 采图可用。
- **工程化**：pipeline 编排、断点续训 resume/retry、保留元数据同时清理大权重的归档脚本（释放 ~560GB）。

**RL 关联**：RLinf 是"把 RL 真正训起来"的引擎层，最能体现驾驭大模型 RL 训练的显存、分布式调度、算法落地能力。

---

## 项目二 · SmolVLA：视觉-语言-动作操作策略

**框架**：SmolVLA（~450M，SmolVLM2-500M 骨干 + Flow-Matching 动作专家），基于 LeRobot v0.6.2；
是 RLinf-VLA / RLT / DSRL 等**在线 RL 后训练**的典型对象。

**我实际完成的工作**
- 从零搭建**可复现环境**：独立 venv、版本锁定（`requirements-lock.txt`，114 包）、CUDA 驱动兼容修复、HF 镜像与离屏渲染适配。
- 在 **LIBERO 数据集完成 200k 步训练**（单张 RTX 4090），每 10k 步产出 checkpoint。
- **最终评测并可视化**：总成功率 **42%**，12 段 rollout 视频；构建**交互式实时仿真工具**（rerun 网页 + 终端 REPL）与可复现批量评测流水线。
- 沉淀源码地图 / 数据流 / 架构文档。

**分任务套件评测（最终 200k 模型）**

| LIBERO 套件 | 考察能力 | 成功率 |
|---|---|---|
| libero_object | 物体抓取放置 | **100% (3/3)** |
| libero_spatial | 空间关系推理 | 33% (1/3) |
| libero_goal | 目标条件操作 | 33% (1/3) |
| libero_10 | 长程多步任务 | 0% (0/3) |

**RL 关联**：SFT/模仿学习得到的 VLA，其长程低成功率任务（libero_10 = 0%）正是 **RL 后训练**要攻克的瓶颈；
本项目的训练+评测链路可作为 RLinf 对 VLA 做 GRPO/PPO 强化的起点与基线。

---

## 项目三 · Nano World Model：世界模型（MBRL 仿真底座）

**框架**：基于 **Diffusion Forcing** 的世界模型（DiT 架构，图像经 SD-VAE 编码为 latent），DINO-WM 数据集。
世界模型是**模型基强化学习**的核心——充当可学习"仿真器"，降低策略训练对真机/物理仿真的采样依赖。

**我实际完成的工作**
- 在**单张 RTX 4090 完整复现 PointMaze**：自训 **30k 步（约 6 小时）**，train_loss 0.59→0.0024，无 OOM 无报错。
- 修复 **CUDA Error 804**（libcuda 软链被系统重置导致驱动版本错配）、重建 venv、校验并解压 30GB 数据（SHA-256 与官方一致）、经 hf-mirror 获取官方权重。
- 跑通**训练 / 推理 / 评估**三条链路，端到端生成 rollout 视频（生成 vs 真值对比）。

**自训 30k vs 官方指标对齐（PointMaze）**

| 指标 | 自训 30k | 官方 | 结论 |
|---|---|---|---|
| PSNR ↑ | 36.40 | 36.74 | 基本对齐 |
| SSIM ↑ | 0.984 | 0.984 | 完全一致 |
| LPIPS ↓ | 0.0186 | 0.019 | 一致 |
| FID ↓ | 10.70 | 9.66 | 同量级（单卡等效 batch 差异） |

> 官方用 8×H20，本项目单卡 4090 梯度累积等效复现，指标落在同一区间，属可信复现。
> 已知限制（不影响训练/推理/评估）：MPC/CEM 规划缺 gym0.x+d4rl+mujoco-py，FVD 权重源不可达。

**RL 关联**：RLinf 已官方支持 **WoVR（世界模型作为可靠仿真器做 VLA 的 RL 后训练）** 及 Wan/OpenSora 世界模型 RL，
NanoWM 正是"世界模型 + RL"路线上可对接的仿真器底座。

---

## 可迁移的强化学习能力矩阵

- **RL 算法落地**：GRPO/PPO/SAC/IQL 在 VLA 策略与仿真基准上的真实训练经验
- **大模型显存与分布式工程**：OOM 根因定位、LoRA vs 全参、FSDP offload、梯度检查点、权重同步 IPC
- **机器人仿真与评测**：LIBERO/ManiSkill、headless 渲染、可复现批量评测与可视化
- **世界模型 / MBRL**：Diffusion Forcing、latent 建模、指标对齐复现
- **可复现工程**：版本锁定、环境诊断脚本、pipeline 编排与断点续训、归档与元数据管理
- **受限环境交付**：单卡、离线镜像网络（aliyun / hf-mirror）等真实约束下稳定产出

---

## 附录：证据与素材位置（绝对路径，可逐条核对）

```
# RLinf
/ya/Code/tanghan/RLinf/experiment_archive/EXPERIMENT_SUMMARY.md
/ya/Code/tanghan/RLinf/experiment_archive/medium_48g/.../rlinf_grpo/metrics.log   # GRPO 500 步奖励曲线
/ya/Code/tanghan/RLinf/logs/effective_48g/20260830_124937/status.tsv              # 四阶段时间线
/ya/Code/tanghan/RLinf/experiment_archive/scripts/*.sh                           # pipeline / resume / retry

# SmolVLA
/ya/Code/tanghan/SmolVLA/outputs/libero_interactive/FINAL_REPORT.md              # 42% 评测报告
/ya/Code/tanghan/SmolVLA/outputs/libero_interactive/*.mp4                        # 12 段 rollout 视频
/ya/Code/tanghan/SmolVLA/requirements-lock.txt                                   # 114 包版本锁定
/ya/Code/tanghan/SmolVLA/smolvla_code_map.md · smolvla_dataflow.md               # 源码地图 / 数据流

# Nano World Model
/ya/Code/tanghan/Nano World Model/REPRODUCTION_REPORT.md                         # 完整复现结论与命令
/ya/Code/tanghan/Nano World Model/results/rollout_official_ckpt/*.mp4            # 世界模型 rollout 视频
```

*本作品集数据均取自各项目实际运行产生的报告与日志，未使用合成/演示数据填充结果。*
