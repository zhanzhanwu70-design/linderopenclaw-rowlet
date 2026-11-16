# Gengar Keep-Alive 巡檢日誌（cron 9d8b6001）

job: `9d8b6001-3178-46bf-ad9b-dfbb1ec0faa7` — Gengar Keep-Alive（每 3h，sessionTarget=isolated，agentId=null → 跑在 rowlet lane）

## 2026-11-16 13:02 — PASS（lane 雙向通，2 項未結案）

- rowlet lane：minimax-portal/MiniMax-M3 正常；上一輪 11:43 ok。
- gengar lane：sessions_send 進 agent:gengar:main → 13:02 回「lane alive」；耿鬼回 sessions_send 給本 cron session → 雙向通。
- gengar 5 顆 cron：全部 ok / consecutiveErrors=0（11:38 的 429 連敗已由 11:45/11:47 recovery 收復，Token Plan cap 已重置）。
- 未結案 A：heartbeat-gengar（c29eca0f）3 連敗 `heartbeat failed: agent-runner-failure`（11:59/250.9s、12:29/14.9s、12:59/15.5s）；先前 20+ 輪為 `skipped: no-route`。耿鬼自報的「600s 上限」與 15s 實測不符 → 已給原始 table 請其自診。
- 未結案 B：每日論文討論（58fe15dc，rowlet 07:00）4 連敗，429 Token Plan cap；不補額度明天再敗第 5 次，10 次自動停用。
- 漂移：本 job agentId=null；停用中的 b7a56e10（gengar keep-alive, agentId=gengar, 5m）才是真正打 agent 的版本。
<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

## 2026-11-16 13:07 — 根因修正（依耿鬼 journal）

heartbeat-gengar 3 連敗真因：M3 → 429 Token Plan；minimax-portal M3 → 429；fallback `minimax/MiniMax-M2.7` → **400 (2013) context window exceeds limit**（gengar main session 363k tokens > M2.7 200k 視窗）→ 鏈全滅 → agent-runner-failure ≈15s。11:59 那輪 250s = 跨憑證重試 4 分鐘。
→ 「3 個 fallback」不構成冗餘（同一份 plan + 無大視窗備援）。修法只有 credits / 跨廠商 provider。
<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

## 2026-11-16 13:10 — 全艦掃描（400(2013) 風險盤點）

- 含 M2.7 fallback 的 job 全是 sessionTarget=isolated（小 context）；唯一非 isolated 的 `45ccf4e9`（roaringmoon-morning-pipeline）實測 23,479 tokens → 都不會撞 200k。**陷阱只在 gengar main session（363k）**，已被移除 M2.7 候選修掉。
- agent chain 實測：gengar = `minimax/MiniMax-M3 → minimax-portal/MiniMax-M3`；其餘 8 agent = 單一 `minimax-portal/MiniMax-M3`。
- fleet 紅單分類：429 限額（e2ffd70d 4、58fe15dc 4）／容量過載（a72cb46b 5）／timeout（45ccf4e9 2）。
- 13:29 驗收 heartbeat-gengar 是否轉綠。
<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
