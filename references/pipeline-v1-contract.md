# 星鉴流水线 v1.0 Contract

Source of truth: `PIPELINE_FLOWCHART_V1_0_EMOJI.md`

## 1) 目标

星鉴用于：
- GitHub 项目评估
- 外部方案吸收
- 技术路线报告
- 落地建议报告
- 产品化吸收与本地化判断

它不是 coding/test 流水线。

## 2) Level

- `Q`：快报
- `S`：标准报告
- `D`：深报 / 高风险 / 多材料

## 3) Step 2 研究宪法

Gemini 必须输出：
- `Title`
- `Conclusion`
- `RecommendedRoute`
- `Risks`
- `ReportPath`

同时必须把研究报告写入自己的目录。

## 4) Step 3 主方案

review/opus 基于 Gemini 报告产出主方案。

主方案必须包含：
- 推荐架构位置
- Phase 0 / 1 / 2
- 现在启用什么
- 现在不要启用什么
- 配置基线
- 风险与回滚触发器

### Planner Role Rule

- Step 3 由 `review/opus` 承担主方案位
- 不得把 Step 3 错理解成星链式代码审查
- 不得把研究报告直接当最终报告交付

## 5) Step 4 一致性复核

Gemini 对主方案输出：
- `ALIGN`
- `DRIFT`
- `MAJOR_DRIFT`

规则：
- `ALIGN` → Step 6
- `DRIFT` → 回 Step 3 修订一次
- `MAJOR_DRIFT` → Step 5

## 6) Step 5 仲裁

只在以下条件触发：
- D 级任务
- 高风险改造
- 强分歧
- 多轮仍未对齐

输出：
- `GO`
- `REVISE`
- `BLOCK`

## 7) Step 6 交付定稿

Docs 或定稿位必须统一输出结构：
- 标题
- 核心结论
- 推荐路线
- 风险
- 报告路径
- 建议下一步

## 8) 完成信号

任务完成必须同时满足：
1. 文件已落地
2. 子任务返回结构化回执
3. 关键通知已发送或由 main 兜底

任何一个缺失，都不能视为真正完成。

## 9) 通知规范

- Agent 职能群通知为主链路
- 星鉴 Step 2 / 3 / 4 / 5 默认要求执行 agent 同时发送到职能群 + 监控群
- main 负责监控群、缺失补发、最终交付、告警
- 完成消息不得只有 `done`
- Step 2 / 3 / 4 / 5 一旦满足“文件已落地 + 群消息已发（至少职能群）”，main 必须立即检查并在必要时补发监控群进度
- 不允许把监控群通知建立在 parent run 一定会正常收尾的假设上

## 10) 版本规则

- 小更新不升版本号
- 大变动才生成新版本
- 只保留最近两个版本
- 默认入口始终指向最新版本
