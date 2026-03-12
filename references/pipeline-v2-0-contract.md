# 星鉴流水线 v2.0 合约

## 版本信息
- **版本**: v2.0
- **日期**: 2026-03-11
- **状态**: 正式版本
- **上一版本**: v1.5

## 核心变革（相比 v1.5）

### 1. 轻量宪法 + NotebookLM 主研究双引擎
- **v1.5 问题**: Claude 上下文有限，深度不足
- **v2.0 方案**: 轻量宪法（规则约束）+ NotebookLM 主研究（深度理解）
- **核心理念**: 规则驱动 + 资料驱动，避免"资料漂移"

### 2. 宪法简报化
**v1.5**：完整宪法（规则制定、边界定义、风险评估）
**v2.0**：宪法简报（1-2 页，只包含核心约束）

**输出格式**：
```markdown
# 研究宪法简报

## 范围
- 研究边界
- 不包含的内容

## 定义
- 关键术语定义
- 评估标准

## 判定标准
- 可行性标准
- 质量标准

## 禁止项
- 不允许的方案
- 风险红线

## 证据门槛
- 证据要求
- 来源可信度

## 输出格式
- 报告结构
- 必须包含的章节
```

### 3. 宪法作为 Source
**关键创新**：把宪法简报作为首个 source 导入 NotebookLM

**优势**：
- 宪法和资料在同一个 notebook
- NotebookLM 可以随时参考宪法
- 避免"资料驱动"漂移
- 保持统一裁判尺

### 4. NotebookLM 定位升级
**v1.5 定位**: Step 2.5 知识补料（可选）
**v2.0 定位**: Step 2B 主研究引擎（必选）

**新定位**：项目级研究操作系统
- 证据池和知识库
- 基于来源的持续扩源器
- 研究产物工厂
- 研究状态管理能力

**产出能力**：
- Research report（主报告）
- Mind map（知识图谱）
- Briefing（简报）
- FAQ（常见问题）
- Data Tables（数据表）
- Slides（演示文稿）
- Audio/Video Overviews（音频/视频概览）

### 5. 流程重构
```
v1.5 流程：
Step 1.5: gemini 扫描（问题发现）
Step 2: openai 宪法（规则制定）
Step 2.5: notebooklm 补料（可选）
Step 3: claude 主方案

v2.0 流程：
Step 1.5: gemini 快速扫描（问题清单、盲点清单、待验证假设）
Step 2A: openai 宪法简报（1-2 页核心约束）
Step 2B: notebooklm 深度研究（宪法作为首个 source，主研究引擎）
Step 3: claude 复核优化（文字、结构、论证、找漏洞）
```

### 6. 角色重新定位
| Agent | v1.5 角色 | v2.0 角色 |
|-------|-----------|-----------|
| gemini | 扫描 + 复核 | 快速扫描（问题清单、盲点清单、待验证假设）+ 一致性检查 |
| openai | 宪法制定 + 仲裁 | **宪法简报**（1-2 页核心约束）+ 仲裁 |
| notebooklm | 知识补料（可选） | **主研究引擎**（项目级研究操作系统） |
| claude | 主方案 | 复核优化（文字、结构、论证、找漏洞） |

## 完整流程（v2.0）

```
Step 1: 任务分级（Q/S/D）
       ↓
Step 1.5: gemini 快速扫描（问题清单、盲点清单、待验证假设）
       ↓
Step 2A: openai 宪法简报（1-2 页核心约束）
       ↓
Step 2B: notebooklm 深度研究（宪法作为首个 source）
       ↓
Step 3: claude 复核优化（文字、结构、论证、找漏洞）
       ↓
Step 4: gemini 一致性检查（前后矛盾、遗漏、偏题、结论与证据不匹配）
       ↓
Step 5: openai|claude 仲裁（只处理争议点）
       ↓
Step 6: docs 交付定稿
       ↓
Step 7: main 统一交付
```

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

### Step 1.5: Gemini 快速扫描
**执行者**: gemini

**模型配置**:
- Q 级: gemini/medium
- S/D 级: gemini/high

**输入**:
- 用户需求
- 材料链接或内容

**输出**:
- 问题清单（What）
- 盲点清单（Blind Spots）
- 待验证假设（Hypotheses to Verify）
- 关键发现（Key Findings）

**产物路径**: `~/.openclaw/workspace/agents/gemini/scan-{timestamp}.md`

**角色定位**:
- 快速扫描，提供问题清单和盲点
- 为 OpenAI 宪法简报和 NotebookLM 研究提供方向
- 不做深度研究

**Spawn 示例**:
```javascript
sessions_spawn(
  agentId: "gemini",
  mode: "run",
  model: "gemini/gemini-3.1-pro-preview",
  thinking: "medium", // Q 级
  // thinking: "high",   // S/D 级
  task: `
你是星鉴流水线的快速扫描专家。

任务：快速阅读材料，提供问题清单和盲点。

材料：
${材料内容或链接}

输出要求：
1. 问题清单（What）
2. 盲点清单（Blind Spots）
3. 待验证假设（Hypotheses to Verify）
4. 关键发现（Key Findings）

注意：你只负责快速扫描，不需要深度研究。

输出路径：~/.openclaw/workspace/agents/gemini/scan-${timestamp}.md

完成后：
1. 发送到织梦群（-5264626153）
2. 发送到监控群（-5131273722）
`,
  runTimeoutSeconds: 600
)
```

---

### Step 2A: OpenAI 宪法简报
**执行者**: openai

**模型配置**:
- Q 级: openai/medium
- S/D 级: openai/high

**输入**:
- Step 1.5 的 Gemini 扫描结果
- 用户需求

**输出**:
- 宪法简报（1-2 页）
  - 范围
  - 定义
  - 判定标准
  - 禁止项
  - 证据门槛
  - 输出格式

**产物路径**: `~/.openclaw/workspace/agents/openai/constitution-brief-{timestamp}.md`

**角色定位**:
- **轻量宪法制定者**：只输出核心约束，不做完整宪法
- 为 NotebookLM 深度研究提供统一裁判尺
- 避免"资料驱动"漂移

**关键要求**:
- 压缩到 1-2 页
- 只包含核心约束
- 清晰、可执行

**Spawn 示例**:
```javascript
sessions_spawn(
  agentId: "openai",
  mode: "run",
  model: "openai/gpt-5.4",
  thinking: "medium", // Q 级
  // thinking: "high",   // S/D 级
  task: `
你是星鉴流水线的宪法简报专家。

任务：基于 Gemini 的扫描结果，制定宪法简报（1-2 页）。

Gemini 扫描结果：
${读取 gemini 的扫描结果}

输出要求（必须压缩到 1-2 页）：
1. 范围（研究边界、不包含的内容）
2. 定义（关键术语定义、评估标准）
3. 判定标准（可行性标准、质量标准）
4. 禁止项（不允许的方案、风险红线）
5. 证据门槛（证据要求、来源可信度）
6. 输出格式（报告结构、必须包含的章节）

注意：
- 只输出核心约束，不做完整宪法
- 清晰、可执行
- 这份简报将作为首个 source 导入 NotebookLM

输出路径：~/.openclaw/workspace/agents/openai/constitution-brief-${timestamp}.md

完成后：
1. 发送到小曼群（-5242027093）
2. 发送到监控群（-5131273722）
`,
  runTimeoutSeconds: 600
)
```

---

### Step 2B: NotebookLM 深度研究
**执行者**: notebooklm（珊瑚）

**模型配置**:
- 所有级别: opus/high（NotebookLM 内部使用 Gemini 2.0 Flash Thinking）

**输入**:
- Step 1.5 的 Gemini 扫描结果
- Step 2A 的 OpenAI 宪法简报（作为首个 source）
- 完整材料（上传到专用 notebook）
- 用户需求

**输出**:
- **完整研究报告**（基于宪法约束）
- Research report（主报告）
- Mind map（知识图谱）
- Briefing（简报）
- FAQ（常见问题）
- 其他研究产物（按需）

**产物路径**: `~/.openclaw/workspace/agents/notebooklm/research-report-{timestamp}.md`

**核心理念**:
- NotebookLM 是**项目级研究操作系统**
- 在宪法约束下工作，避免"资料驱动"漂移
- 充分利用研究状态管理能力
- 证据池和知识库
- 基于来源的持续扩源器
- 研究产物工厂

**执行流程**:
1. **导入宪法简报**（作为首个 source）
2. **创建专用 notebook**（或使用现有 stareval-research）
3. **上传完整材料**（所有相关文档）
4. **执行深度研究**（基于宪法约束）
   - 扩源（Deep Research）
   - 证据组织
   - 多份资料对齐
5. **生成研究产物**
   - Research report（主报告）
   - Mind map（知识图谱）
   - Briefing（简报）
   - FAQ（常见问题）

**Spawn 示例**:
```javascript
sessions_spawn(
  agentId: "notebooklm",
  mode: "run",
  model: "anthropic/claude-opus-4-6", // notebooklm agent 的默认模型
  thinking: "high",
  task: `
你是星鉴流水线的主研究引擎（项目级研究操作系统）。

任务：基于宪法约束，进行深度研究并生成完整方案。

执行步骤：
1. 导入宪法简报（作为首个 source）
   ${读取 openai 的宪法简报路径}

2. 创建或使用专用 notebook（stareval-research 或新建）

3. 上传完整材料到 notebook
   ${材料路径或 notebook ID}

4. 执行深度研究（基于宪法约束）
   - 扩源（Deep Research）
   - 证据组织
   - 多份资料对齐

5. 生成研究产物
   - Research report（主报告）
   - Mind map（知识图谱）
   - Briefing（简报）
   - FAQ（常见问题）

Gemini 扫描结果：
${读取 gemini 的扫描结果}

注意：
- 你是主研究引擎，必须遵守宪法约束
- 充分利用 NotebookLM 的研究状态管理能力
- 输出完整研究报告和多种研究产物

输出路径：~/.openclaw/workspace/agents/notebooklm/research-report-${timestamp}.md

完成后：
1. 发送到珊瑚群（-5202217379）
2. 发送到监控群（-5131273722）
`,
  runTimeoutSeconds: 1800
)
```

---

### Step 3: Claude 复核优化
**执行者**: claude

**模型配置**:
- Q 级: claude/sonnet/medium
- S 级: claude/opus/medium
- D 级: claude/opus/high

**输入**:
- Step 2A 的 OpenAI 宪法简报
- Step 2B 的 NotebookLM 研究报告
- 用户需求

**输出**:
- 复核意见
- 优化建议（文字、结构、论证）
- 漏洞清单

**产物路径**: `~/.openclaw/workspace/agents/claude/review-{timestamp}.md`

**角色定位**:
- 把研究结果变成更好的文字、结构和论证
- 找漏洞
- 基于宪法基准评估

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
你是星鉴流水线的复核优化专家。

任务：基于宪法基准，复核 NotebookLM 的研究报告，提供优化建议。

OpenAI 宪法简报：
${读取 openai 的宪法简报}

NotebookLM 研究报告：
${读取 notebooklm 的研究报告}

输出要求：
1. 复核意见（是否遵守宪法）
2. 优化建议（文字、结构、论证）
3. 漏洞清单

注意：你负责复核与优化，把研究结果变成更好的文字、结构和论证。

输出路径：~/.openclaw/workspace/agents/claude/review-${timestamp}.md

完成后：
1. 发送到小克群（-5101947063）
2. 发送到监控群（-5131273722）
`,
  runTimeoutSeconds: 1200
)
```

---

### Step 4: Gemini 一致性检查（按需）
**执行者**: gemini（main 直接 spawn）

**触发条件**:
- Q 级: 跳过
- S 级: 按需（如果 claude 提出重大分歧）
- D 级: 强制执行

**模型配置**:
- S 级: gemini/medium
- D 级: gemini/high

**输入**:
- Step 2A 的 OpenAI 宪法简报
- Step 2B 的 NotebookLM 研究报告
- Step 3 的 Claude 复核意见

**输出**:
- 一致性评估（ALIGN / DRIFT / MAJOR_DRIFT）
- 前后矛盾清单
- 遗漏清单
- 偏题清单
- 结论与证据不匹配清单

**产物路径**: `~/.openclaw/workspace/agents/gemini/consistency-check-{timestamp}.md`

**角色定位**:
- 专门查：前后矛盾、遗漏、偏题、结论与证据不匹配
- 不做深度研究，只做一致性检查

---

### Step 5: OpenAI|Claude 仲裁（按需）
**执行者**: openai 或 claude（main 直接 spawn）

**触发条件**:
- Q 级: 跳过
- S 级: MAJOR_DRIFT / 强分歧
- D 级: 强制执行

**模型配置**:
- openai/high（默认）
- claude/opus/high（若 Claude 已参与 Step 3）

**独立性规则**:
- 若 OpenAI 参与了 Step 2A 宪法制定，仲裁时优先使用 Claude
- 若 Claude 参与了 Step 3 复核，仲裁时优先使用 OpenAI

**角色定位**:
- 只处理争议点，不重做整篇

---

### Step 6: Docs 交付定稿
**执行者**: docs/minimax/medium

**输入**:
- Step 2A 的 OpenAI 宪法简报
- Step 2B 的 NotebookLM 研究报告
- Step 3 的 Claude 复核意见
- Step 4 的一致性检查（S/D 级）
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

## 分级策略（v2.0）

### Q 级（快报）
**流程**: 1 → 1.5 → 2A → 2B → 3 → 6 → 7

**模型配置**:
- Step 1.5: gemini/medium
- Step 2A: openai/medium
- Step 2B: notebooklm/opus/high
- Step 3: claude/sonnet/medium
- Step 6: docs/minimax/medium

**跳过步骤**:
- Step 4: 一致性检查（跳过）
- Step 5: 仲裁（跳过）

**预计时间**: 12-18 分钟

### S 级（标准）
**流程**: 1 → 1.5 → 2A → 2B → 3 → 4（按需）→ 6 → 7

**模型配置**:
- Step 1.5: gemini/high
- Step 2A: openai/high
- Step 2B: notebooklm/opus/high
- Step 3: claude/opus/medium
- Step 4: gemini/medium（按需）
- Step 6: docs/minimax/medium

**跳过步骤**:
- Step 5: 仲裁（按需触发）

**预计时间**: 20-30 分钟

### D 级（深报）
**流程**: 1 → 1.5 → 2A → 2B → 3 → 4 → 5 → 6 → 7

**模型配置**:
- Step 1.5: gemini/high
- Step 2A: openai/high
- Step 2B: notebooklm/opus/high
- Step 3: claude/opus/high
- Step 4: gemini/high
- Step 5: openai/high（强制）
- Step 6: docs/minimax/medium

**预计时间**: 30-45 分钟

---

## NotebookLM 使用策略

### 1. 专用 Notebook 管理
**stareval-research** (998ab871-27c7-4127-9491-e3d824e10e27)
- 用途：星鉴流水线的专用研究 notebook
- 内容：历史评估报告 + 当前任务材料
- 维护：每次任务完成后，保留关键材料，清理临时文件

### 2. 宪法简报作为首个 Source
**关键操作**：
1. 把 Step 2A 的宪法简报导入 NotebookLM（作为首个 source）
2. 再导入核心资料
3. NotebookLM 在宪法约束下做深度研究

**优势**：
- 宪法和资料在同一个 notebook
- NotebookLM 可以随时参考宪法
- 避免"资料驱动"漂移

### 3. 材料上传策略
**完整上传**：
- 上传所有相关文档（不只是 README）
- 包括：文档、代码、配置、示例
- 目标：让 NotebookLM 理解完整上下文

**临时 vs 永久**：
- 临时材料：任务完成后删除
- 永久材料：历史评估报告、最佳实践、失败案例

### 4. 深度研究策略
**利用 NotebookLM 的能力**：
- Deep Research（自动扩源）
- 证据组织
- 多份资料对齐
- 跨文档关联分析

**产出多种研究产物**：
- Research report（主报告）
- Mind map（知识图谱）
- Briefing（简报）
- FAQ（常见问题）
- Data Tables（数据表）
- Slides（演示文稿）
- Audio/Video Overviews（音频/视频概览）

---

## 预期收益（v2.0 vs v1.5）

| 指标 | v1.5 | v2.0 | 提升 | 说明 |
|------|------|------|------|------|
| 宪法环节时间 | 5-10 分钟 | 2-3 分钟 | -50% | 简报化 |
| NotebookLM 利用率 | 30%（可选） | 90%（主研究） | +200% | 充分利用 |
| 研究深度 | 基准 | +50-60% | 显著提升 | NotebookLM 主研究 |
| 方案完整性 | 基准 | +40-50% | 显著提升 | 扩源 + 证据组织 |
| 方案质量 | 基准 | +45-55% | 显著提升 | 宪法约束 + 深度理解 |
| 降本 | 20-30% | 25-30% | 持平 | 宪法简报化节省成本 |
| Q 级速度 | +30-40% | +20-30% | 略降 | 增加宪法环节 |
| D 级质量 | +15-20% | +50-60% | 显著提升 | 双引擎最大化 |

**核心优势**：
- 规则驱动 + 资料驱动，避免"资料漂移"
- NotebookLM 作为项目级研究操作系统，充分利用研究状态管理能力
- 宪法简报化，节省时间和成本
- 质量显著提升，特别是 D 级深报任务

---

## 版本对比总结

### v1.5: Constitution-First（宪法优先）
- Gemini 扫描 → OpenAI 宪法 → Claude 主方案 → NotebookLM 补料（可选）
- 优势：规则约束清晰
- 劣势：Claude 上下文有限，深度不足；NotebookLM 只是补料工具

### v2.0: Constitution + Research（轻量宪法 + NotebookLM 主研究）
- Gemini 扫描 → OpenAI 宪法简报 → NotebookLM 主研究（宪法作为首个 source）→ Claude 复核优化
- 优势：规则约束（轻量宪法）+ 深度理解（NotebookLM），质量最高
- 核心创新：宪法作为 source，NotebookLM 作为项目级研究操作系统

---

## 回滚策略

如果 v2.0 出现问题，可以回滚到 v1.5：
1. 恢复 `SKILL.md` 引用到 v1.5
2. 使用 `references/pipeline-v1-5-contract.md`
3. 使用 `references/PIPELINE_FLOWCHART_V1_5_EMOJI.md`

---

## 版本历史

- v2.0 (2026-03-11): 轻量宪法 + NotebookLM 主研究双引擎，宪法作为 source
- v1.5 (2026-03-10): Constitution-First 完整化 + NotebookLM 补料 + Main 直接编排 + 分级模型策略
- v1.4 (2026-03-08): Main 直接编排，Review 只做单一审查
- v1.3 (2026-03-07): 角色分工优化
- v1.2 (2026-03-06): 初始版本
