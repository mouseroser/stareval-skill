# 星鉴启动模板

用于 main 在私聊里正式发起一条星鉴任务。

## 主启动模板

```text
让星鉴阅读 <材料/仓库/链接> ，给出适合我们使用的落地方案。

目标：<希望得到什么>
约束：
- <约束1>
- <约束2>
- <约束3>

交付要求：
- 输出正式报告
- 明确推荐路线
- 明确风险
- 明确现在启用什么 / 暂时不要启用什么
```

## main 编排模板

### Step 1 分级

判断：
- `Q`：单材料、低风险、快报
- `S`：标准评估、常规方案
- `D`：多材料、高风险、需要仲裁

### Step 2 Gemini 研究宪法 Prompt

```text
星鉴 Step 2：研究宪法任务

请阅读以下材料：
- <repo/url/file>

目标：
- 提炼问题定义、边界、约束、假设、风险
- 给出适合我们系统的研究结论
- 不要直接把研究报告当成最终实施方案

通知要求：
- 同时向职能群 + 监控群发送开始 / 关键进度 / 完成
- 完成消息必须包含：Title / Conclusion / RecommendedRoute / Risks / ReportPath
- main 仍会检查并在必要时补发监控群；不要假设 parent run 收尾后才会有监控群通知

必须输出：
- Title
- Conclusion
- RecommendedRoute
- Risks
- ReportPath

正式报告写入：
`reports/<slug>-research-<date>.md`
```

### Step 3 review/opus 主方案 Prompt

```text
星鉴 Step 3：主方案任务

把 Gemini 的研究报告视为宪法，不要重新定义问题。

由 `review/opus` 基于这份宪法，产出适合我们系统的实施方案。

通知要求：
- 同时向职能群 + 监控群发送开始 / 关键进度 / 完成
- 完成消息必须包含：Title / Conclusion / RecommendedArchitecture / PhasePlan / Risks / ReportPath
- main 仍会检查并在必要时补发监控群；不要假设 parent run 收尾后才会有监控群通知

必须包含：
- RecommendedArchitecture
- PhasePlan
- EnableNow
- DeferNow
- ConfigBaseline
- Risks
- RollbackTriggers
- ReportPath

正式报告写入对应 agent 自己目录。
```

### Step 4 Gemini 一致性复核 Prompt

```text
星鉴 Step 4：一致性复核

请检查主方案是否偏离 Gemini 研究宪法。

输出仅允许：
- ALIGN
- DRIFT
- MAJOR_DRIFT

并附：
- Why
- FixSuggestion
- ReportPath
```

### Step 5 GPT / Review 仲裁 Prompt

```text
星鉴 Step 5：仲裁

仅在高风险 / D 级 / 强分歧时进入。

请在研究宪法与主方案之间做仲裁判断。

输出：
- GO
- REVISE
- BLOCK

并附：
- Rationale
- KeyRisk
- ReportPath
```
