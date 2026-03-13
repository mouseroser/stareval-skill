# Changelog

## 2026-03-13

### Changed
- Clarified notification reliability policy for the StarEval pipeline.
- Adopted **main-first** notification handling as the official default.
- Marked sub-agent self-messaging as **best-effort**, not a reliable delivery guarantee.
- Updated launch template guidance so `main` relays critical progress once completion/announce returns.
- Aligned legacy flowcharts and contract references with the new notification policy.

### Rationale
- Real-world verification showed that under `sessions_spawn(mode=run)`, subagent `completion/announce` and channel `message(...)` are separate delivery paths.
- A subagent may complete successfully and announce back to `main` even when its Telegram `message(...)` does not deliver.
- Therefore, reliable external visibility must be owned by `main`, not inferred from subagent self-push behavior.
