# 星鉴流水线 v1.3 Contract

Source of truth: `PIPELINE_FLOWCHART_V1_3_EMOJI.md`

## 1) 目标

星鉴用于：
- GitHub 项目评估
- 外部方案吸收
- 技术路线报告
- 落地建议报告
- 产品化吸收与本地化判断

它不是默认的 coding/test 流水线。

## 2) Level

- `Q`：快报
- `S`：标准报告
- `D`：深报 / 高风险 / 多材料

## 3) Step 2A 研究扫描

`gemini` 必须输出：
- 核心问题
- 边界
- 关键假设
- 风险
- 路线候选
- 需要由宪法定稿的项

## 4) Step 2B 研究宪法

`openai/gpt-5.4` 基于研究扫描输出最终研究宪法，至少包含：
- 目标
- 非目标
- 问题边界
- 评价标准
- 风险
- 默认假设
- 红线

## 5) Step 3 主方案

`claude/opus` 基于最终研究宪法产出主方案。

主方案必须包含：
- 核心结论
- 推荐路线
- 不推荐路线
- Phase 0 / 1 / 2
- 立即启用项
- 延后项
- 风险与回滚触发器

## 6) Step 4 一致性复核

`review/gemini` 对主方案输出：
- `ALIGN`
- `DRIFT`
- `MAJOR_DRIFT`

规则：
- `ALIGN` → Step 6
- `DRIFT` → 回 Step 3 修订一次
- `MAJOR_DRIFT` → Step 5

## 7) Step 5 仲裁

只在以下条件触发：
- `D` 级任务
- `MAJOR_DRIFT`
- 高风险改造
- 强分歧
- 多轮仍未对齐

默认由 `review/openai` 仲裁；若本轮主方案或主实现由 `openai/gpt-5.4` 产出，则切换 `review/claude` 执行独立仲裁。

输出：
- `GO`
- `REVISE`
- `BLOCK`

## 8) 完成信号

任务完成必须同时满足：
1. 文件已落地
2. 子任务返回结构化回执
3. 关键通知已发送或由 `main` 兜底

任何一个缺失，都不能视为真正完成。

