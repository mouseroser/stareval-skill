---
name: xingjian-pipeline
description: 星鉴流水线 v1.2。用于 GitHub 项目评估、外部方案吸收、技术路线报告与落地建议：Gemini 研究宪法 → Claude 主方案 → Review/Gemini 一致性复核 → Review/GPT 按需仲裁 → Docs 交付定稿。优化 Thinking Level 配置，预计降本 10-15%。
---

# 星鉴流水线 v1.2

用于"读材料 → 提炼宪法 → 出方案 → 复核 → 交付报告"的专用流水线。

## When This Skill Triggers

触发条件：
- 用户要求阅读 GitHub 项目并给出适合我们的落地方案
- 用户要求吸收外部方案并产品化/本地化
- 用户要求技术路线评估、架构报告、方案报告、对比分析
- 用户要求输出"适合我们使用"的报告，而不是直接改代码
- 用户要求做研究、评估、判断、报告交付

## Required Read

执行前读取：
1. `references/PIPELINE_FLOWCHART_V1_0_EMOJI.md`
2. `references/pipeline-v1-contract.md`
3. `references/launch-template.md`
4. `references/report-contract-template.md`

## Architecture: main 编排模式

`main` 是顶层编排中心，所有阶段由 `main` 串联。

```
main（小光，编排中心）
├── Step 1：任务分级 + 报告类型判断
├── Step 2：spawn gemini → 研究宪法 / 问题定义
├── Step 3：spawn claude → 主方案 / 主报告
├── Step 4：spawn gemini/review → 一致性复核
├── Step 5：（按需）spawn gpt/review → 高风险仲裁
├── Step 6：spawn docs → 交付定稿 / 结构整理
└── Step 7：main → 汇总交付 + 通知
```

## Report Levels

- `Q`（Quick）: 快报，单材料、低分歧、轻量建议
- `S`（Standard）: 标准报告，常规评估与落地建议
- `D`（Deep）: 深报，多材料、强约束、高风险、需要仲裁

## Agent Roles

| Agent | Role | Key Steps |
|-------|------|-----------|
| main | 编排、分级、交付 | Step 1, 7 |
| gemini | 研究宪法 | Step 2 |
| claude | 主方案 / 主报告 | Step 3 |
| review (swap gemini) | 一致性复核 | Step 4 |
| review (swap gpt) | 高风险仲裁 | Step 5 |
| docs | 最终定稿与交付整理 | Step 6 |

## Workspace 架构

### Main Agent 工作目录
- `~/.openclaw/workspace/` - Main agent (小光) 的工作目录
- `workspace/intel/` - Agent 协作层（单写者原则）
  - `collaboration/` - 多 agent 联合工作的非正式产物（外部项目、本地镜像、共享分析素材等）
- `workspace/shared-context/` - 跨 agent 共享上下文
- `workspace/memory/` - 记忆文件

### Sub-Agent 工作目录
- `~/.openclaw/workspace/agents/gemini/` - 研究宪法产物
- `~/.openclaw/workspace/agents/claude/` - 计划报告产物
- `~/.openclaw/workspace/agents/review/` - 审查产物
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
| Step 2 | `gemini` | medium (Q) / high (S/D) | 读取材料，提炼问题宪法 |
| Step 3 | `claude / opus` | medium (Q/S) / high (D) | 基于宪法产出主方案 |
| Step 4 | `review / gemini` | medium | 一致性复核（spawn review 时 swap 到 gemini） |
| Step 5 | `review / gpt`（按需） | high | 高风险仲裁（spawn review 时 swap 到 gpt） |
| Step 6 | `docs / minimax` | medium | 统一结构、排版、交付摘要 |
| Step 7 | `main / opus` | high | 汇总与最终通知 |

**模型动态指派说明：**
- Step 4: spawn `review` agent 时动态覆盖：`model: "gemini/gemini-3.1-pro-preview", thinking: "medium"`
- Step 5: spawn `review` agent 时动态覆盖：`model: "openai/gpt-5.4", thinking: "high"`
- 都是 review agent，通过 swap 不同模型完成不同任务

**Thinking Level 优化策略：**
- Q 级（快报）：降低 thinking level，提升速度
- S 级（标准）：平衡 thinking level
- D 级（深报）：提升 thinking level，保证质量
- 预计降本 10-15%

## Constitution-First Rule

- `gemini` 的研究产物不是最终方案，而是 **宪法 / 问题定义层**。
- 下一步默认不是代码审查，而是 **`claude` 基于宪法出主方案**。
- Step 4: spawn `review` agent 时动态 swap 到 `gemini` 模型进行一致性复核，检查方案是否偏离宪法。
- Step 5: spawn `review` agent 时动态 swap 到 `gpt` 模型（`model: "openai/gpt-5.4"`），仅在高风险、明显漂移、重大分歧时进入仲裁链路。
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

- `claude` 是 Step 3 的主方案执行者。
- Step 3 的 `claude` 在星鉴中承担"主方案位"，负责基于宪法产出完整报告。
- Step 4: spawn `review` agent 时动态 swap 到 `gemini` 模型进行一致性复核。
- Step 5: spawn `review` agent 时动态 swap 到 `gpt` 模型，仅在满足条件时进入仲裁位。

**Spawn 示例：**
```javascript
// Step 4: spawn review 时 swap 到 gemini
sessions_spawn(
  agentId: "review",
  mode: "run",
  model: "gemini/gemini-3.1-pro-preview",  // 动态覆盖模型
  task: "检查 claude 主方案是否偏离 gemini 研究宪法...",
  runTimeoutSeconds: 300
)

// Step 5: spawn review 时 swap 到 gpt
sessions_spawn(
  agentId: "review",
  mode: "run",
  model: "openai/gpt-5.4",  // 动态覆盖模型
  task: "仲裁 claude 主方案与一致性复核的分歧...",
  runTimeoutSeconds: 300
)
```

## Versioning Policy

- 小更新不升版本号
- 大变动才升新版本
- 只保留最近两个版本
- 默认入口始终指向最新版本
