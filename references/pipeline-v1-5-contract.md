# 星鉴流水线 v1.5 合约

## 版本信息
- **版本**: v1.5
- **日期**: 2026-03-10
- **状态**: 生产版本
- **上一版本**: v1.4

## 核心变更（相比 v1.4）

### 1. Constitution-First 前置链完整化
- **新增 Step 1.5**: gemini 扫描（问题发现）
- **Step 2 重定位**: openai 宪法（规则制定）
- **分离职责**: 扫描 + 宪法分离，避免同源偏差

### 2. NotebookLM 补料机制
- **新增 Step 2.5**: notebooklm 补料（S/D 级）
- **用途**: 查询相关技术文档、历史类似报告
- **触发条件**: S/D 级任务，Q 级跳过

### 3. Main 直接编排（去掉 review 中间层）
- **Step 4**: main 直接 spawn gemini 做复核
- **Step 5**: main 直接 spawn openai|claude 做仲裁
- **收益**: 效率提升 15-20%，推送更可靠

### 4. 分级模型策略
- **Q 级**: 快速通道，使用 sonnet 代替 opus
- **S 级**: 标准流程，平衡质量和成本
- **D 级**: 深度流程，强制仲裁

## 完整流程

```
Step 1: 任务分级（Q/S/D）
       ↓
Step 1.5: gemini 扫描（问题发现）
       ↓
Step 2: openai 宪法（规则制定）
       ↓
Step 2.5: notebooklm 补料（S/D 级，可选）
       ↓
Step 3: claude 主方案（基于宪法）
       ↓
Step 4: gemini 复核（一致性检查）
       ↓
Step 5: openai|claude 仲裁（按需）
       ↓
Step 6: docs 交付定稿
       ↓
Step 7: main 统一交付
```

## 分级策略

### Q 级（快报）
**流程**: 1 → 1.5 → 2 → 3 → 6 → 7

**模型配置**:
- Step 1.5: gemini/medium
- Step 2: openai/medium
- Step 3: claude/sonnet/medium
- Step 6: docs/minimax/medium

**跳过步骤**:
- Step 2.5: NotebookLM 补料（跳过）
- Step 4: 一致性复核（跳过）
- Step 5: 仲裁（跳过）

**预计时间**: 5-10 分钟

### S 级（标准）
**流程**: 1 → 1.5 → 2 → 2.5 → 3 → 4 → 6 → 7

**模型配置**:
- Step 1.5: gemini/high
- Step 2: openai/high
- Step 2.5: notebooklm（查询）
- Step 3: claude/opus/medium
- Step 4: gemini/medium
- Step 6: docs/minimax/medium

**跳过步骤**:
- Step 5: 仲裁（按需触发）

**预计时间**: 15-25 分钟

### D 级（深报）
**流程**: 1 → 1.5 → 2 → 2.5 → 3 → 4 → 5 → 6 → 7

**模型配置**:
- Step 1.5: gemini/high
- Step 2: openai/high
- Step 2.5: notebooklm（查询）
- Step 3: claude/opus/high
- Step 4: gemini/high
- Step 5: openai/high（强制）
- Step 6: docs/minimax/medium

**预计时间**: 25-40 分钟

## 详细步骤说明

### Step 1: 任务分级
**执行者**: main/opus/high

**输入**:
- 用户需求
- 材料链接或描述

**输出**:
- 任务级别（Q/S/D）
- 报告类型
- 是否需要仲裁

**判断标准**:
- Q 级: 单材料、低分歧、轻量建议
- S 级: 常规评估与落地建议
- D 级: 多材料、强约束、高风险

---

### Step 1.5: Gemini 扫描（问题发现）
**执行者**: gemini

**模型配置**:
- Q 级: gemini/medium
- S/D 级: gemini/high

**输入**:
- 用户需求
- 材料链接或内容

**输出**:
- 问题清单
- 关键发现
- 潜在风险
- 边界定义

**产物路径**: `~/.openclaw/workspace/agents/gemini/scan-{timestamp}.md`

**Spawn 示例**:
```javascript
sessions_spawn(
  agentId: "gemini",
  mode: "run",
  model: "gemini/gemini-3.1-pro-preview",
  thinking: "medium", // Q 级
  // thinking: "high",   // S/D 级
  task: `
你是星鉴流水线的扫描专家。

任务：阅读以下材料，进行问题发现和边界定义。

材料：
${材料内容或链接}

输出要求：
1. 问题清单（What）
2. Key Findings）
3. 潜在风险（Risks）
4. 边界定义（Scope）

输出路径：~/.openclaw/workspace/agents/gemini/scan-${timestamp}.md

完成后：
1. 发送到织梦群（-5264626153）
2. 发送到监控群（-5131273722）
`,
  runTimeoutSeconds: 600
)
```

---

### Step 2: OpenAI 宪法（规则制定）
**执行者**: openai (gpt)

**模型配置**:
- Q 级: openai/medium
- S/D 级: openai/high

**输入**:
- Step 1.5 的扫描结果
- 用户需求

**输出**:
- 研究宪法
- 约束条件
- 评估标准
- 落地原则

**产物路径**: `~/.openclaw/workspace/agents/openai/constitution-{timestamp}.md`

**Spawn 示例**:
```javascript
sessions_spawn(
  agentId: "openai",
  mode: "run",
  model: "openai/gpt-5.4",
  thinking: "medium", // Q 级
  // thinking: "high",   // S/D 级
  task: `
你是星鉴流水线的宪法制定专家。

任务：基于 gemini 的扫描结果，制定研究宪法。

扫描结果：
${读取 gemini 的扫描结果}

输出要求：
1. 研究宪法（Constitution）
2. 约束条件（Constraints）
3. 评估标准（Criteria）
4. 落地原则（Principles）

输出路径：~/.openclaw/workspace/agents/openai/constitution-${timestamp}.md

完成后：
1. 发送到小曼群（-5242027093）
2. 发送到监控群（-5131273722）
`,
  runTimeoutSeconds: 600
)
```

---

### Step 2.5: NotebookLM 补料（S/D 级）
**执行者**: main（调用 notebooklm skill）

**触发条件**:
- S 级或 D 级任务
- Q 级跳过

**查询内容**:
1. **stareval-research notebook**（专用评估知识库）
   - 历史类似评估报告
   - 技术选型决策
   - 落地经验总结
   - 常见技术栈对比

2. **（可选）上传当前项目关键文档**
   - 如果项目 README/docs 很长
   - 上传到 stareval-research 作为临时 source
   - 评估完成后可以保留或删除

**输出**:
- 历史经验摘要
- 相关技术对比
- 落地建议参考
- （可选）当前项目文档摘要

**产物路径**: `~/.openclaw/workspace/intel/notebooklm-supplement-{timestamp}.md`

**执行示例**:
```bash
# 查询 stareval-research（历史评估经验）
~/.openclaw/skills/notebooklm/scripts/nlm-gateway.sh query \
  --agent main \
  --notebook stareval-research \
  --query "类似项目评估 技术选型 落地经验"

# （可选）上传当前项目文档
notebooklm source add \
  --notebook 998ab871-27c7-4127-9491-e3d824e10e27 \
  --file /path/to/project/README.md
```

**Notebook ID**: `998ab871-27c7-4127-9491-e3d824e10e27`

---

### Step 3: Claude 主方案（基于宪法）
**执行者**: claude

**模型配置**:
- Q 级: claude/sonnet/medium
- S 级: claude/opus/medium
- D 级: claude/opus/high

**输入**:
- Step 2 的宪法
- Step 2.5 的补料（S/D 级）
- 用户需求

**输出**:
- 主方案报告
- 落地建议
- 风险评估
- 实施路线

**产物路径**: `~/.openclaw/workspace/agents/claude/report-{timestamp}.md`

**Spawn 示例**:
```javascript
sessions_spawn(
  agentId: "claude",
  mode: "run",
  model: "anthropic/claude-sonnet-4-6", // Q 级
  // model: "anthropic/claude-opus-4-6",   // S/D 级
  thinking: "medium", // Q/S 级
  // thinking: "high",   // D 级
  task: `
你是星鉴流水线的主方案专家。

任务：基于宪法和补料，产出主方案报告。

宪法：
${读取 openai 的宪法}

补料（S/D 级）：
${读取 notebooklm 的补料}

输出要求：
1. 主方案报告
2. 落地建议
3. 风险评估
4. 实施路线

输出路径：~/.openclaw/workspace/agents/claude/report-${timestamp}.md

完成后：
1. 发送到小克群（-5101947063）
2. 发送到监控群（-5131273722）
`,
  runTimeoutSeconds: 1200
)
```

---

### Step 4: Gemini 复核（一致性检查）
**执行者**: gemini（main 直接 spawn）

**模型配置**:
- Q 级: 跳过
- S 级: gemini/medium
- D 级: gemini/high

**输入**:
- Step 2 的宪法
- Step 3 的主方案

**输出**:
- 一致性评估（ALIGN / DRIFT / MAJOR_DRIFT）
- 偏离点清单
- 修正建议

**产物路径**: `~/.openclaw/workspace/agents/gemini/review-{timestamp}.md`

**Spawn 示例**:
```javascript
sessions_spawn(
  agentId: "gemini",
  mode: "run",
  model: "gemini/gemini-3.1-pro-preview",
  thinking: "medium", // S 级
  // thinking: "high",   // D 级
  task: `
你是星鉴流水线的一致性复核专家。

任务：检查 claude 主方案是否偏离 openai 宪法。

宪法：
${读取 openai 的宪法}

主方案：
${读取 claude 的主方案}

输出要求：
1. 一致性评估（ALIGN / DRIFT / MAJOR_DRIFT）
2. 偏离点清单
3. 修正建议

输出路径：~/.openclaw/workspace/agents/gemini/review-${timestamp}.md

完成后：
1. 发送到织梦群（-5264626153）
2. 发送到监控群（-5131273722）
`,
  runTimeoutSeconds: 600
)
```

---

### Step 5: OpenAI|Claude 仲裁（按需）
**执行者**: openai 或 claude（main 直接 spawn）

**触发条件**:
- Q 级: 跳过
- S 级: MAJOR_DRIFT / 强分歧
- D 级: 强制执行

**模型配置**:
- openai/high（默认）
- claude/opus/high（若 GPT 同源）

**输入**:
- Step 2 的宪法
- Step 3 的主方案
- Step 4 的复核结果

**输出**:
- 仲裁决策（GO / REVISE / BLOCK）
- 裁决理由
- 修正方向

**产物路径**: `~/.openclaw/workspace/agents/openai/arbitration-{timestamp}.md`

**Spawn 示例**:
```javascript
sessions_spawn(
  agentId: "openai", // 默认
  // agentId: "claude", // 若 GPT 同源
  mode: "run",
  model: "openai/gpt-5.4",
  // model: "anthropic/claude-opus-4-6",
  thinking: "high",
  task: `
你是星鉴流水线的仲裁专家。

任务：仲裁 claude 主方案与一致性复核的分歧。

宪法：
${读取 openai 的宪法}

主方案：
${读取 claude 的主方案}

复核结果：
${读取 gemini 的复核结果}

输出要求：
1. 仲裁决策（GO / REVISE / BLOCK）
2. 裁决理由
3. 修正方向

输出路径：~/.openclaw/workspace/agents/openai/arbitration-${timestamp}.md

完成后：
1. 发送到小曼群（-5242027093）
2. 发送到监控群（-5131273722）
`,
  runTimeoutSeconds: 600
)
```

---

### Step 6: Docs 交付定稿
**执行者**: docs/minimax/medium

**输入**:
- Step 3 的主方案
- Step 4 的复核结果（S/D 级）
- Step 5 的仲裁结果（D 级）

**输出**:
- 最终报告
- 结构整理
- 交付摘要

**产物路径**: `~/.openclaw/workspace/agents/docs/final-report-{timestamp}.md`

---

### Step 7: Main 统一交付
**执行者**: main/opus/high

**输出**:
- 汇总报告
- 推送到监控群（-5131273722）
- 推送到晨星 DM (target:1099011886)

---

## 通知规范

### 职能群 + 监控群双推
所有 agent 的开始 / 完成 / 失败消息必须同时发送到：
1. 自己的职能群
2. 监控群（-5131273722）

### Main 兜底补发
Main 负责检查缺失并立即补发到监控群。

### 通知内容
- 开始: "Step X 开始：{任务描述}"
- 完成: "Step X 完成：{关键结论}"
- 失败: "Step X 失败：{错误原因}"

---

## 预期收益

| 指标 | v1.4 | v1.5 | 提升 |
|------|------|------|------|
| 降本 | 10-15% | 20-30% | +10-15% |
| Q 级速度 | 基准 | +30-40% | 显著提升 |
| D 级质量 | 基准 | +15-20% | 显著提升 |
| 效率 | 基准 | +15-20% | 去掉 review 中间层 |

---

## 回滚策略

如果 v1.5 出现问题，可以回滚到 v1.4：
1. 恢复 `SKILL.md` 引用到 v1.4
2. 使用 `references/pipeline-v1-4-contract.md`
3. 使用 `references/PIPELINE_FLOWCHART_V1_4_EMOJI.md`

---

## 版本历史

- v1.5 (2026-03-10): Constitution-First 完整化 + NotebookLM 补料 + Main 直接编排 + 分级模型策略
- v1.4 (2026-03-08): Main 直接编排，Review 只做单一审查
- v1.3 (2026-03-07): 角色分工优化
- v1.2 (2026-03-06): 初始版本
