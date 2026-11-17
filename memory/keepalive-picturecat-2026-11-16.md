# Picturecat Keep-Alive 巡檢日誌（cron 02eb0989）

job: `02eb0989-891b-43fe-8a6e-dbcb059a4124` — Picturecat Keep-Alive（每 3h，agentId=null → 實際跑在 rowlet lane）

## 2026-11-16 16:02 — PASS（lane 活；fleet 紅單 8/50，heartbeat-gengar 已轉綠）

- **本 job 自身**：上一輪 13:02:03 → lastStatus=ok、consecutiveErrors=0、durMs=261248；本輪 16:02:04 起跑（runId 6d404157）。
- **Picturecat lane**：`sessions_send` → agent:picturecat:main → 16:02 回 `pong — Picturecat (Luna) is up and idle, monitoring for English-coaching tasks; all systems nominal.`（runId 6d404157-f03b-4f32-b472-a956b9dc7177，status=ok）。
- **Gateway**：pid 2235362，uptime 7h45m（≈08:17 CST 起未再重啟）；host boot 2026-10-11。
- **preflight 保險**：掃 50 顆 job 的 payload.model + fallbacks，`modelPolicy.allow`（12 個型號）→ **0 筆落在 allow 之外**（11:38 那批 openai-codex/gpt-5.5 問題沒有復發）。

### Fleet 紅單（8/50，consecutiveErrors > 0）
| job | id | errs | 最後一輪 | 錯誤類別 | 下次 |
|---|---|---|---|---|---|
| Jormungand mrmime Codex A2A heartbeat | d7b0355b | 5 | 11-16 12:00 | 429 Token Plan | 11-16 18:00 |
| 每日 Agent × 軟體開發潮流研究 | a72cb46b | 5 | 11-16 11:07 | 容量過載 | 11-17 10:00 |
| push-llm-wiki | e2ffd70d | 4 | 11-16 05:11 | 429 Token Plan | 11-17 05:05 |
| 每日論文討論 | 58fe15dc | 4 | 11-16 07:08 | 429 Token Plan | 11-17 07:00 |
| rowlet-ut-veteran-cpc-maintenance-noon | 08b7c00b | 4 | 11-16 12:08 | 429 Token Plan | 11-17 12:00 |
| heartbeat-mrmime | bcf270b8 | 2 | 11-16 15:31 | (16:01 有 run 在跑) | — |
| 晨間情報 pipeline (Roaringmoon) | 45ccf4e9 | 2 | 11-16 08:10 | timeout（model-call-started, 454s） | 11-17 08:00 |
| 群體智能架構研究 | b37129c0 | 1 | — | gateway restart 誤記 | — |

### ✅ 心跳-gengar 轉綠（13:02 時為 3 連敗）
`c29eca0f heartbeat-gengar` 15:59:42 這一輪 = **skipped: no-route、consecutiveErrors=0** → 13:07 移除 M2.7 候選的修法生效，429 + 400(2013) 的鏈全滅沒再發生。剩下的 skipped 是 13:00 前就長期存在的良性狀態（先前 20+ 輪 skipped）。
<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 風險排序（未動手，需 Linder 決策）
1. **auto-disable 倒數**：d7b0355b 與 a72cb46b 各 5/10 → 再各敗 5 次自動停用。
2. **429 Token Plan 是帳號層**（minimax 與 minimax-portal 共用額度池），改 payload model 治不了 → 唯一真解是加額度或接第二家 provider（累積第 5 輪回報未決）。
3. **llm-wiki 307 項未提交變更**仍推不上去（push-llm-wiki 4 連敗 429）→ 需人工 commit。
4. `45ccf4e9` 的 lastError 已由「gateway restart 打斷」轉為「execution timed out (model-call-started)」→ 屬模型呼叫逾時，不是排程問題。

### 邊界（本次刻意沒動）
- 不改 provider / model / modelPolicy（全域層，需 Linder）。
- 不補額度、不開新 provider。
- 不為了讓紅單轉綠而手動 `run` 這些 job（會消耗同一份額度、掩蓋真實狀態）。
- llm-wiki 本輪刻意不歸檔：健康檢查非研究資料，避免每 3h 灌頁面。
<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

## 2026-11-16 19:02 — PASS（lane 通；紅單 7/50，d7b0355b 已轉綠、健康回報新轉紅）

- **本 job 自身**：上一輪 16:04:33 → status=ok、dur=148889ms、consecutiveErrors=0；本輪 19:02:03 起跑。
- **Picturecat lane**：`sessions_send` → agent:picturecat:main → 19:02 回 `pong — idle and ready; no active tasks, waiting on the next English-coaching request.`（runId 97b633a8-0ee5-4ea2-ab11-029cb7a2c3bb，status=ok）。
- **Gateway**：pid 2235362，uptime 10h45m（08:17:48 CST 起未再重啟）；host up 36 天；load 0.43。
- **preflight 保險**：50 顆 job 的 payload.model + fallbacks（21 顆有 fallbacks）對 modelPolicy.allow（12 個型號）→ **0 筆落在 allow 之外**；10:02 那批 openai-codex/gpt-5.5 越權問題沒有復發。

### Fleet 紅單（7/50，consecutiveErrors > 0）
| job | id | errs | 最後一輪 | 錯誤類別 | 下次 |
|---|---|---|---|---|---|
| 每日 Agent × 軟體開發潮流研究 | a72cb46b | 5 | 11-16 11:07 | provider 過載（overloaded，非 429） | 11-17 10:00 |
| 健康回報（mrmime） | 13ac4b5a | 4 | 11-16 17:12 | 429 Token Plan（全 4 個 model 全滅） | 11-16 20:05 |
| push-llm-wiki | e2ffd70d | 4 | 11-16 05:11 | 429 Token Plan | 11-17 05:05 |
| 每日論文討論 | 58fe15dc | 4 | 11-16 07:08 | 429 + provider cooldown | 11-17 07:00 |
| rowlet-ut-veteran-cpc-maintenance-noon | 08b7c00b | 4 | 11-16 12:08 | 429 Token Plan | 11-17 12:00 |
| 晨間情報 pipeline (Roaringmoon) | 45ccf4e9 | 2 | 11-16 08:10 | gateway restart 打斷（dur 454s） | 11-17 08:00 |
| 群體智能架構研究 | b37129c0 | 1 | 11-16 08:00 | gateway restart 打斷 | 11-17 08:00 |

### ✅ 本輪轉綠 / 新轉紅
- **d7b0355b（Jormungand mrmime Codex A2A heartbeat）**：18:05:58 這一輪 = **ok** → 5 連敗清零（16:02 當時還在 5/10 倒數）。
- **bcf270b8 heartbeat:mrmime**：18:33 ok，2 連敗清零。
- **13ac4b5a 健康回報**：17:06 / 17:07 / 17:12 三輪 429（4 個 model 全滅）→ 新列入紅單，mrmime lane 的 cron 側與 heartbeat 側分開計數。
- **Heartbeat 狀態**：8 個 heartbeat 中 5 個 skipped（no-route，良性長態）：celesteela 20、greninja 39、picturecat 39、roaringmoon 37、gengar 11；rowlet / charizard / mrmime = ok；flaaffy = every 417d → idle 從未跑過。

### 風險排序（未動手，需 Linder 決策）
1. **auto-disable 倒數**：a72cb46b 5/10 最前；13ac4b5a、e2ffd70d、58fe15dc、08b7c00b 各 4/10。再各敗 5～6 次會自動停用。
2. **429 Token Plan 是帳號層**（minimax 與 minimax-portal 共用額度池），21 顆 job 的 fallbacks 已含跨 provider 型號但全部同池 → 唯一真解是加額度或接第二家 provider（第 6 輪回報未決）。
3. **llm-wiki 307 項未提交變更**仍推不上去（push-llm-wiki 4 連敗 429；最後 commit = 44052aaebf "Daily sync 2026-11-15"）→ 需人工 commit。
4. `45ccf4e9` / `b37129c0` 是 08:17 那次 gateway restart 的中斷痕跡，非排程缺陷 → 下輪自癒，不需動作。

### 邊界（本次刻意沒動）
- 不改 provider / model / modelPolicy（全域層，需 Linder）。
- 不補額度、不開新 provider。
- 不為了讓紅單轉綠而手動 `run` 這些 job（會消耗同一份額度、掩蓋真實狀態）。
- llm-wiki 本輪刻意不歸檔：健康檢查非研究資料，避免每 3h 灌頁面。
<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
