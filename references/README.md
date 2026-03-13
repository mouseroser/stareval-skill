# StarEval References

## Status
- `current`
  - `pipeline-v1-3-contract.md`
  - `PIPELINE_FLOWCHART_V1_3_EMOJI.md`
- `previous`
  - `PIPELINE_FLOWCHART_V1_2_EMOJI.md`
- `supporting`
  - `launch-template.md`
  - `report-contract-template.md`

## Read Order
1. `pipeline-v1-3-contract.md`
2. `PIPELINE_FLOWCHART_V1_3_EMOJI.md`
3. Supporting documents as needed

## Notes
- Default execution entry is `pipeline-v1-3-contract.md`.
- Keep only current files, one previous reference, and supporting materials.
- Older deprecated references have been removed to reduce prompt drift.
- If a document conflicts with `pipeline-v1-3-contract.md`, follow the current contract.

## Recent Update (2026-03-13)
- Adopted **main-first** notification reliability as the default policy.
- Sub-agent self-messaging is treated as **best-effort**, not as a reliable delivery guarantee.
- Critical progress visibility should be guaranteed by `main`, not inferred from child-agent Telegram delivery.
