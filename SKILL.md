---
name: xingjian-pipeline
description: 星鉴流水线 v2.0 正式版。轻量宪法 + NotebookLM 主研究双引擎：Gemini 快速扫描 → OpenAI 宪法简报（1-2 页核心约束）→ NotebookLM 深度研究（宪法作为首个 source，项目级研究操作系统）→ Claude 复核优化 → Gemini 一致性检查 → OpenAI/Claude 仲裁 → Docs 交付定稿。核心优势：规则驱动 + 资料驱动，避免"资料漂移"，预计研究深度提升 50-60%，方案完整性提升 40-50%，D 级质量提升 50-60%。
---

# 星鉴流水线 v2.0（正式版）

**核心优势**：轻量宪法 + NotebookLM 主研究双引擎，规则驱动 + 资料驱动。

用于"读材料 → 快速扫描 → 宪法简报 → 深度研究 → 复核优化 → 交付报告"的专用流水线。由 main（小光）通过 isolated session 编排执行。

## When This Skill Triggers

触发条件：
- "用星鉴评估 XXX"
- "星鉴分析 XXX 方案"
- 用户要求阅读 GitHub 项目并给出适合我们的落地方案
- 用户要求吸收外部方案并产品化/本地化
- 用户要求技术路线评估、架构报告、方案报告、对比分析
- 用户要求输出"适合我们使用"的报告，而不是直接改代码
- 用户要求做研究、评估、判断、报告交付

**Main 的职责**：
1. 接收任务："用星鉴评估 XXX，D 级"
2. 立即回复："收到！已启动星鉴流水线 D 级，运行 ID: stareval_YYYYMMDD_HHMMSS"
3. Spawn isolated session 执行整个流水线
4. 主私聊立即释放
5. 流水线完成后通过 announce 通知晨星

## Required Read

执行前读取：
1. `references/pipeline-v2-0-contract.md` — v2.0 流水线合约（必读）
2. `references/pipeline-v1-5-contract.md` — v1.5 流水线合约（回滚参考）
3. `references/PIPELINE_FLOWCHART_V1_5_EMOJI.md` — 流程图（待更新为 v2.0）
4. `references/launch-template.md`
5. `references/report-contract-template.md`

## Architecture: Main 编排 + Isolated Session

**告诉 Main，自动执行，全自动推进。** Main 通过 isolated session 编排所有步骤。

```
晨星: "用星鉴评估 AI 量化交易方案，D 级"
Main: "收到！已启动星鉴流水线 D 级，运行 ID: stareval_20260313_001234"
      → 主私聊立即释放
      → Spawn isolated session 执行流水线
      ├── Step 1：任务分级 + 报告类型判断
      ├── Step 1.5：spawn gemini → 快速扫描
      ├── Step 2A：spawn openai → 宪法简报
      ├── Step 2B：spawn notebooklm → 深度研究
      ├── Step 3：spawn claude → 复核优化
      ├── Step 4：spawn gemini → 一致性检查（S/D 级）
      ├── Step 5：spawn openai/claude → 仲裁（按需）
      ├── Step 6：spawn docs → 交付定稿
      └── Step 7：announce 通知晨星确认

**优势**：
- ✅ 用户体验好：只需告诉 Main "用星鉴评估 XXX"
- ✅ Main 不在私聊里等待和轮询
- ✅ 主私聊不占线：可以同时做其他事
- ✅ Main 职责清晰：保持顶层编排中心的角色
- ✅ 轻量宪法（规则约束）+ NotebookLM 主研究（深度理解）双引擎
- ✅ 宪法作为 source，避免"资料驱动"漂移
```

## Quick Start

```
晨星: "用星鉴评估 AI 量化交易方案，D 级，材料在 ~/.openclaw/workspace/intel/collaboration/ai-quant-book"
Main: "收到！已启动星鉴流水线 D 级"
```

## Execution Rules

0. **Main 编排，isolated session 执行。** Main 收到任务后 spawn isolated session，在其中逐步编排所有 agent。除 Step 7 晨星确认外，中间步骤不停顿。
1. Always start at Step 1 (Q/S/D classification).
2. Q 级跳过 Step 2.5/4/5；S 级跳过 Step 5（按需触发）；D 级强制执行全流程。
3. Main orchestrates all agent spawning via sessions_spawn(mode="run").
4. Use structured verdict flow exactly as defined.
5. Enforce notification policy: agents push to their channels + monitor; main guarantees monitor visibility.

## Report Levels

- `Q`（Quick）: 快报，单材料、低分歧、轻量建议
- `S`（Standard）: 标准报告，常规评估与落地建议
- `D`（Deep）: 深报，多材料、强约束、高风险、需要仲裁

## Agent Roles

| Agent | Role | Key Steps |
|-------|------|-----------|
| main | 编排、分级、交付 | Step 1, 7 |
| gemini | 快速扫描 + 一致性检查 | Step 1.5, Step 4 |
| openai (gpt) | 宪法简报 + 仲裁 | Step 2A, Step 5 |
| notebooklm | 深度研究（项目级研究操作系统） | Step 2B |
| claude | 复核优化（文字、结构、论证、找漏洞） | Step 3 |
| docs | 最终定稿与交付整理 | Step 6 |

## Workspace 架构

### Main Agent 工作目录
- `~/.openclaw/workspace/` - Main agent (小光) 的工作目录
- `workspace/intel/` - Agent 协作层（单写者原则）
  - `collaboration/` - 多 agent 联合工作的非正式产物（外部项目、本地镜像、共享分析素材等）
- `workspace/shared-context/` - 跨 agent 共享上下文
- `workspace/memory/` - 记忆文件

### Sub-Agent 工作目录
- `~/.openclaw/workspace/agents/gemini/` - 研究扫描与复核产物
- `~/.openclaw/workspace/agents/openai/` - 研究宪法与仲裁产物
- `~/.openclaw/workspace/agents/claude/` - 主方案产物
- `~/.openclaw/workspace/agents/review/` - 审查与仲裁索引产物
- `~/.openclaw/workspace/agents/docs/` - 文档产物

### 文件传递规则
- 每个 agent 在自己的 workspace 目录中生成工作产物（报告、审查结论、修复代码等）
- 通过 `~/.openclaw/workspace/intel/` 目录传递摘要或索引（单写者原则）
- 多 agent 联合工作的非正式产物（外部 GitHub 项目、本地镜像、共享分析素材等）统一放到 `intel/collaboration/`
- Main agent 或其他 agent 直接读取对应 agent 的 workspace 目录获取完整产物

## Model Baseline

| Step | 默认模型/执行者 | Thinking Level | 说明 |
|------|------------------|----------------|------|
| Step 1 | `main / opus` | high | 判断任务类型、复杂度、是否需要仲裁 |
| Step 1.5 | `gemini` | medium (Q) / high (S/D) | 快速扫描（问题清单、盲点清单、待验证假设） |
| Step 2A | `openai (gpt)` | medium (Q) / high (S/D) | 宪法简报（1-2 页核心约束） |
| Step 2B | `notebooklm / opus` | high | 深度研究（宪法作为首个 source） |
| Step 3 | `claude / opus` | medium (Q/S) / high (D) | 复核优化（文字、结构、论证、找漏洞） |
| Step 4 | `gemini` | medium | 一致性检查（Main 直接 spawn） |
| Step 5 | `openai`（按需） | high | 高风险仲裁（Main 直接 spawn） |
| Step 6 | `docs / minimax` | medium | 统一结构、排版、交付摘要 |
| Step 7 | `main / opus` | high | 汇总与最终通知 |

**模型动态指派说明：**
- Step 1.5: spawn `gemini` agent，使用 `gemini-3.1-pro-preview` 模型
- Step 2A: spawn `openai` agent，使用 `gpt-5.4` 模型
- Step 2B: spawn `notebooklm` agent，使用 `opus` 模型（内部调用 NotebookLM）
- Step 3: spawn `claude` agent
- Step 4: spawn `gemini` agent（main 直接 spawn）
- Step 5: spawn `openai` 或 `claude` agent（main 直接 spawn，按独立性规则）

**Thinking Level 优化策略：**
- Q 级（快报）：降低 thinking level，提升速度
- S 级（标准）：平衡 thinking level
- D 级（深报）：提升 thinking level，保证质量
- 预计降本 10-15%

## Constitution-First Rule

- `gemini` 的扫描产物是 **问题清单 / 盲点清单 / 待验证假设层**。
- `openai` 基于 `gemini` 的扫描结果，输出 **宪法简报（1-2 页核心约束）**。
- `notebooklm` 把宪法简报作为首个 source 导入，在宪法约束下进行 **深度研究并输出完整方案**。
- `claude` 基于宪法基准，对 `notebooklm` 的方案进行 **复核与优化（文字、结构、论证、找漏洞）**。
- Step 4: spawn `gemini` agent（main 直接 spawn），做一致性检查，检查前后矛盾、遗漏、偏题、结论与证据不匹配。
- Step 5: spawn `openai` 或 `claude` agent（main 直接 spawn），执行独立仲裁，只处理争议点。
- 不允许把"研究完成"直接误接成星链式代码交叉审查。

## Completion Contract

完成信号必须同时满足：
- 正式报告文件已写入对应 agent 自己的目录
- 返回结构化回执（不能只写 `done`）
- 关键阶段通知已发出或由 `main` 兜底补发

不要把"群里发了完成消息"当成父链已经完成的唯一依据。

## Notification Policy

- 有消息能力的 agent：向自己的职能群发送开始 / 关键进度 / 完成 / 失败
- 星鉴默认要求 Step 2 / 3 / 4 / 5 的执行 agent **同时发送到职能群 + 监控群**
- `main`：负责监控群、缺失补发、最终交付、告警
- 报告类任务完成通知必须携带：标题、结论、推荐路线、主要风险、报告路径
- 群消息完成 ≠ 父链完成；以"文件落地 + 结构化回执 + 通知到位"三者共同成立为准
- **星鉴补充规则**：Step 2 / 3 / 4 / 5 只要已确认"文件落地 + 群消息已发（至少职能群）"，`main` 就应立即检查并在必要时补发监控群进度，不再等待 parent run 正常收尾
- **监控群职责规则**：子 agent 可以直接发监控群，但监控群可靠可见性仍由 `main` 兜底保证

## Planner Constraint

- `openai` 是 Step 2A 的宪法简报制定者，负责输出 1-2 页核心约束（范围、定义、判定标准、禁止项、证据门槛、输出格式）。
- `notebooklm` 是 Step 2B 的深度研究引擎（项目级研究操作系统），把宪法简报作为首个 source 导入，在宪法约束下输出完整方案。
- `claude` 是 Step 3 的复核优化者，基于宪法基准评估方案，把研究结果变成更好的文字、结构和论证，找漏洞。
- Step 4: spawn `gemini` agent（main 直接 spawn），进行一致性检查（前后矛盾、遗漏、偏题、结论与证据不匹配）。
- Step 5: spawn `openai` 或 `claude` agent（main 直接 spawn），按独立性规则仲裁，只处理争议点。

**独立性规则**：
- 若 OpenAI 参与了 Step 2A 宪法简报，仲裁时优先使用 Claude
- 若 Claude 参与了 Step 3 复核，仲裁时优先使用 OpenAI

**Spawn 示例**：
```javascript
// Step 4: spawn gemini（main 直接 spawn）
sessions_spawn(
  agentId: "gemini",
  mode: "run",
  thinking: "medium",
  task: "检查 notebooklm 方案的一致性：前后矛盾、遗漏、偏题、结论与证据不匹配...",
  runTimeoutSeconds: 300
)

// Step 5: spawn openai 或 claude（main 直接 spawn，按独立性规则）
sessions_spawn(
  agentId: "openai", // 或 "claude"
  mode: "run",
  thinking: "high",
  task: "仲裁 notebooklm 方案与一致性检查的分歧，只处理争议点...",
  runTimeoutSeconds: 300
)
```

## Versioning Policy

- 小更新不升版本号
- 大变动才升新版本
- 只保留最近两个版本
- 默认入口始终指向最新版本
