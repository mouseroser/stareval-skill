#!/usr/bin/env bash
# stareval-launcher.sh - 星鉴流水线 v1.5 一键启动脚本
# 用法: ./stareval-launcher.sh <task-description> <report-level> [materials-path]

set -euo pipefail

TASK_DESC="${1:-}"
REPORT_LEVEL="${2:-S}"  # Q/S/D
MATERIALS_PATH="${3:-}"

if [[ -z "$TASK_DESC" ]]; then
  echo "用法: $0 <task-description> <report-level> [materials-path]"
  echo "示例: $0 'AI量化交易方案评估' D ~/.openclaw/workspace/intel/collaboration/ai-quant-book"
  exit 1
fi

TIMESTAMP=$(date +%Y%m%d-%H%M%S)
RUN_ID="stareval-${TIMESTAMP}"
WORKSPACE=~/.openclaw/workspace
MONITOR_GROUP="-5131273722"

echo "🚀 星鉴流水线 v1.5 启动"
echo "任务: $TASK_DESC"
echo "级别: $REPORT_LEVEL"
echo "Run ID: $RUN_ID"
echo ""

# Step 1: 任务分级（由 main 完成，这里只是记录）
echo "✅ Step 1: 任务分级 - $REPORT_LEVEL 级"

# Step 2A: Gemini 扫描
echo ""
echo "📡 Step 2A: 织梦扫描中..."
GEMINI_TASK="You are the Research Scanner in StarEval Pipeline v1.5 (Step 2A).

**Task**: Scan the materials and identify problems, boundaries, risks, and assumptions.

**Materials Path**: ${MATERIALS_PATH:-$WORKSPACE/intel/collaboration/}

**Output Requirements**:
1. Problem inventory (what needs solving)
2. Key findings (what's important)
3. Potential risks (what could go wrong)
4. Boundary definitions (what's in/out of scope)
5. Assumptions to validate

**Output Path**: $WORKSPACE/agents/gemini/scan-${TIMESTAMP}.md

**After Completion, YOU MUST**:
1. Send completion message to 织梦群 (-5264626153)
2. Send completion message to 监控群 ($MONITOR_GROUP)

Message format:
\`\`\`
🔍 **星鉴 Step 2A 完成**

**任务**: $TASK_DESC
**产物**: scan-${TIMESTAMP}.md

**问题清单**: {top 3 problems}
**关键发现**: {key insight}

**下一步**: Step 2B（小曼宪法制定）
\`\`\`"

GEMINI_MODEL="gemini/gemini-3.1-pro-preview"
GEMINI_THINKING="medium"
if [[ "$REPORT_LEVEL" == "D" ]]; then
  GEMINI_THINKING="high"
fi

openclaw agent --agent gemini --model "$GEMINI_MODEL" --thinking "$GEMINI_THINKING" --timeout 1800 -m "$GEMINI_TASK"

# Step 2B: OpenAI 宪法
echo ""
echo "📜 Step 2B: 小曼宪法制定中..."
OPENAI_TASK="You are the Constitution Maker in StarEval Pipeline v1.5 (Step 2B).

**Task**: Based on the scan results, create the research constitution.

**Input**: $WORKSPACE/agents/gemini/scan-${TIMESTAMP}.md

**Output Requirements**:
1. Technical feasibility boundaries
2. Risk control rules
3. Compliance constraints
4. Implementation principles
5. Success criteria

**Output Path**: $WORKSPACE/agents/openai/constitution-${TIMESTAMP}.md

**After Completion, YOU MUST**:
1. Send completion message to 小曼群 (-5242027093)
2. Send completion message to 监控群 ($MONITOR_GROUP)

Message format:
\`\`\`
📜 **星鉴 Step 2B 完成**

**任务**: $TASK_DESC
**产物**: constitution-${TIMESTAMP}.md

**核心规则**: {top 3 rules}
**关键约束**: {key constraint}

**下一步**: Step 2.5（珊瑚知识补料）
\`\`\`"

OPENAI_MODEL="openai/gpt-5.4"
OPENAI_THINKING="medium"
if [[ "$REPORT_LEVEL" == "D" ]]; then
  OPENAI_THINKING="high"
fi

openclaw agent --agent openai --model "$OPENAI_MODEL" --thinking "$OPENAI_THINKING" --timeout 1800 -m "$OPENAI_TASK"

# Step 2.5: NotebookLM 补料（S/D 级）
if [[ "$REPORT_LEVEL" != "Q" ]]; then
  echo ""
  echo "📚 Step 2.5: 珊瑚知识补料中..."
  NOTEBOOKLM_TASK="You are the Knowledge Supplement Provider in StarEval Pipeline v1.5 (Step 2.5).

**Task**: Query stareval-research notebook for historical evaluation experience.

**Input**: $WORKSPACE/agents/openai/constitution-${TIMESTAMP}.md

**Query Focus**:
- Historical cases related to this domain
- Best practices and lessons learned
- Common pitfalls and traps
- Implementation recommendations

**Output Path**: $WORKSPACE/agents/notebooklm/research-supplement-${TIMESTAMP}.md

**After Completion, YOU MUST**:
1. Send completion message to 珊瑚群 (-5202217379)
2. Send completion message to 监控群 ($MONITOR_GROUP)

Message format:
\`\`\`
📚 **星鉴 Step 2.5 完成**

**任务**: $TASK_DESC
**产物**: research-supplement-${TIMESTAMP}.md

**核心发现**: {key finding}
**历史教训**: {top lesson}

**下一步**: Step 3（小克主方案）
\`\`\`"

  openclaw agent --agent notebooklm --model "anthropic/claude-opus-4-6" --thinking "high" --timeout 1800 -m "$NOTEBOOKLM_TASK"
fi

# Step 3: Claude 主方案
echo ""
echo "🧩 Step 3: 小克主方案制定中..."
CLAUDE_TASK="You are the Main Solution Expert in StarEval Pipeline v1.5 (Step 3).

**Task**: Based on the constitution and research supplement, produce the main implementation proposal.

**Input Materials**:
1. Constitution: $WORKSPACE/agents/openai/constitution-${TIMESTAMP}.md
2. Research Supplement: $WORKSPACE/agents/notebooklm/research-supplement-${TIMESTAMP}.md (if exists)
3. Original Materials: ${MATERIALS_PATH:-$WORKSPACE/intel/collaboration/}

**Output Requirements**:
1. System architecture and design
2. Implementation roadmap (phased approach)
3. Risk mitigation strategies
4. Technical stack recommendations
5. Success metrics and red flags

**Output Path**: $WORKSPACE/agents/claude/report-${TIMESTAMP}.md

**After Completion, YOU MUST**:
1. Send completion message to 小克群 (-5101947063)
2. Send completion message to 监控群 ($MONITOR_GROUP)

Message format:
\`\`\`
🧩 **星鉴 Step 3 完成**

**任务**: $TASK_DESC
**产物**: report-${TIMESTAMP}.md

**推荐路线**: {core recommendation}
**关键风险**: {top 3 risks}

**下一步**: Step 4（织梦一致性复核）
\`\`\`"

CLAUDE_MODEL="anthropic/claude-opus-4-6"
CLAUDE_THINKING="medium"
if [[ "$REPORT_LEVEL" == "D" ]]; then
  CLAUDE_THINKING="high"
fi

openclaw agent --agent claude --model "$CLAUDE_MODEL" --thinking "$CLAUDE_THINKING" --timeout 1800 -m "$CLAUDE_TASK"

# Step 4: Gemini 复核（S/D 级）
if [[ "$REPORT_LEVEL" != "Q" ]]; then
  echo ""
  echo "🔍 Step 4: 织梦一致性复核中..."
  REVIEW_TASK="You are the Consistency Reviewer in StarEval Pipeline v1.5 (Step 4).

**Task**: Check if the main proposal aligns with the constitution.

**Input Materials**:
1. Constitution: $WORKSPACE/agents/openai/constitution-${TIMESTAMP}.md
2. Main Proposal: $WORKSPACE/agents/claude/report-${TIMESTAMP}.md

**Output Requirements**:
- Verdict: ALIGN / DRIFT / MAJOR_DRIFT
- Alignment score (0-100)
- Key deviations (if any)
- Recommendations

**Output Path**: $WORKSPACE/agents/gemini/review-${TIMESTAMP}.md

**After Completion, YOU MUST**:
1. Send completion message to 织梦群 (-5264626153)
2. Send completion message to 监控群 ($MONITOR_GROUP)

Message format:
\`\`\`
🔍 **星鉴 Step 4 完成**

**任务**: $TASK_DESC
**判定**: {ALIGN/DRIFT/MAJOR_DRIFT}

**对齐度**: {score}%
**主要偏离**: {deviation if any}

**下一步**: {Step 5 仲裁 or Step 6 交付}
\`\`\`"

  openclaw agent --agent gemini --model "gemini/gemini-3.1-pro-preview" --thinking "medium" --timeout 1800 -m "$REVIEW_TASK"
  
  # 读取复核结果判断是否需要仲裁
  REVIEW_FILE="$WORKSPACE/agents/gemini/review-${TIMESTAMP}.md"
  if [[ -f "$REVIEW_FILE" ]]; then
    VERDICT=$(grep -i "verdict:" "$REVIEW_FILE" | head -1 || echo "UNKNOWN")
    
    # Step 5: 仲裁（D 级强制，S 级按需）
    if [[ "$REPORT_LEVEL" == "D" ]] || echo "$VERDICT" | grep -qi "MAJOR_DRIFT"; then
      echo ""
      echo "⚖️ Step 5: 仲裁中..."
      ARBITRATION_TASK="You are the Arbitrator in StarEval Pipeline v1.5 (Step 5).

**Task**: Make final judgment on the proposal.

**Input Materials**:
1. Constitution: $WORKSPACE/agents/openai/constitution-${TIMESTAMP}.md
2. Main Proposal: $WORKSPACE/agents/claude/report-${TIMESTAMP}.md
3. Review: $WORKSPACE/agents/gemini/review-${TIMESTAMP}.md

**Output Requirements**:
- Final verdict: GO / REVISE / BLOCK
- Reasoning
- Action items (if REVISE)

**Output Path**: $WORKSPACE/agents/openai/arbitration-${TIMESTAMP}.md

**After Completion, YOU MUST**:
1. Send completion message to 小曼群 (-5242027093)
2. Send completion message to 监控群 ($MONITOR_GROUP)

Message format:
\`\`\`
⚖️ **星鉴 Step 5 完成**

**任务**: $TASK_DESC
**判定**: {GO/REVISE/BLOCK}

**理由**: {reasoning}

**下一步**: Step 6（文档交付定稿）
\`\`\`"

      # 独立性规则：Claude 主方案 → OpenAI 仲裁（默认）
      ARBITRATOR="openai"
      ARBITRATOR_MODEL="openai/gpt-5.4"
      
      openclaw agent --agent "$ARBITRATOR" --model "$ARBITRATOR_MODEL" --thinking "high" --timeout 1800 -m "$ARBITRATION_TASK"
    fi
  fi
fi

# Step 6: Docs 交付定稿
echo ""
echo "📄 Step 6: 文档交付定稿中..."
DOCS_TASK="You are the Documentation Finalizer in StarEval Pipeline v1.5 (Step 6).

**Task**: Finalize the report structure and format for delivery.

**Input Materials**:
1. Main Proposal: $WORKSPACE/agents/claude/report-${TIMESTAMP}.md
2. Review (if exists): $WORKSPACE/agents/gemini/review-${TIMESTAMP}.md
3. Arbitration (if exists): $WORKSPACE/agents/openai/arbitration-${TIMESTAMP}.md

**Output Requirements**:
- Clean structure and formatting
- Executive summary
- Table of contents
- Consistent terminology
- Delivery-ready document

**Output Path**: $WORKSPACE/agents/docs/final-report-${TIMESTAMP}.md

**After Completion, YOU MUST**:
1. Send completion message to 项目文档群 (-5095976145)
2. Send completion message to 监控群 ($MONITOR_GROUP)

Message format:
\`\`\`
📄 **星鉴 Step 6 完成**

**任务**: $TASK_DESC
**产物**: final-report-${TIMESTAMP}.md

**报告已就绪，等待晨星确认**

**下一步**: Step 7（统一交付）
\`\`\`"

openclaw agent --agent docs --model "minimax/MiniMax-M2.5" --thinking "medium" --timeout 1800 -m "$DOCS_TASK"

# Step 7: 通知晨星确认
echo ""
echo "✅ 星鉴流水线执行完成"
echo ""
echo "📦 产物路径:"
echo "  - 扫描: $WORKSPACE/agents/gemini/scan-${TIMESTAMP}.md"
echo "  - 宪法: $WORKSPACE/agents/openai/constitution-${TIMESTAMP}.md"
if [[ "$REPORT_LEVEL" != "Q" ]]; then
  echo "  - 补料: $WORKSPACE/agents/notebooklm/research-supplement-${TIMESTAMP}.md"
fi
echo "  - 主方案: $WORKSPACE/agents/claude/report-${TIMESTAMP}.md"
if [[ "$REPORT_LEVEL" != "Q" ]]; then
  echo "  - 复核: $WORKSPACE/agents/gemini/review-${TIMESTAMP}.md"
fi
echo "  - 最终报告: $WORKSPACE/agents/docs/final-report-${TIMESTAMP}.md"
echo ""
echo "🔔 等待晨星确认..."
