---
title: "Lost in the Middle: How Language Models Use Long Contexts"
category: source
type: research-paper
tags: [context-window, long-context, multi-document-qa, key-value-retrieval, primacy-bias, recency-bias, u-shaped-curve, evaluation, retrieval-augmented, context-position]
domain: code-agent
created: 2026-06-19
modified: 2026-06-19
related wikis: [code-agent]
---

# Source: Lost in the Middle (Liu et al., 2023)

## 基本資訊

| 欄位 | 內容 |
|------|------|
| **論文** | Lost in the Middle: How Language Models Use Long Contexts |
| **作者** | Nelson F. Liu, Kevin Lin, John Hewitt, Ashwin Paranjape, Michele Bevilacqua, Fabio Petroni, Percy Liang |
| **單位** | Stanford University / UC Berkeley / Samaya AI |
| **發表** | arXiv:2307.03172v3, 2023-11-20 |
| **出版** | Transactions of the Association for Computational Linguistics (TACL), 2023 |
| **領域** | cs.CL — Long-context evaluation / Context window utilization |
| **長度** | 18 pages, 16 figures |
| **URL** | https://arxiv.org/abs/2307.03172 |
| **PDF** | raw/references/papers/ai/lost-in-the-middle-2023-liu.pdf |
| **Metadata** | raw/references/papers/ai/lost-in-the-middle-2023-liu.md |

---

## 核心論點

### 問題背景

近年 LLM 開始支援 4K → 32K → 100K+ tokens 的 context window，產業敘事通常是「context 越長越好」。Liu et al. (2023) 用 controlled experiment 直接挑戰這個假設：

> **LLM 並沒有真正「用」好長 context。** 一旦 relevant information 落在 context 中段，即使模型是 explicitly designed for long context，performance 都會顯著掉到接近不使用該資訊的水準。

### 實驗設計

兩個 task family：

1. **Multi-document QA**：給模型一份 gold passage + 許多 distractor documents + 一個問題。改變 gold passage 在整段 context 中的位置（beginning → middle → end）。
2. **Key-value retrieval (KVR)**：合成 JSON 格式的 (key, value) 配對，要求模型根據 key 取出 value。一樣改變 gold 配對的位置。

評估的模型：
- Open: MPT-30B-Instruct, LongChat-13B (16K)
- Closed: OpenAI GPT-3.5-Turbo, Anthropic Claude-1.3

### 核心發現：U-shaped performance curve

不管 open 還是 closed 模型，都呈現一致的 **U-shaped curve**：

- **Beginning of context** → 高準確率（**primacy bias**）
- **End of context** → 高準確率（**recency bias**）
- **Middle of context** → 顯著掉到接近 random baseline

關鍵令人不安的點：

- LongChat-13B (16K) — explicitly fine-tuned for 16K context — 仍然呈現 U-shaped curve
- GPT-3.5-Turbo 與 Claude-1.3 — 兩個 SOTA closed 模型 — 也沒免疫
- 當 input 越長（越多 distractor documents），U-shape 的谷底越深，連 end-of-context 的 performance 都會下降

### 為什麼這篇對 agent 重要

對於要把多文件、多 tool 結果、多輪對話塞進 prompt 的 agent 來說，這篇的訊息很直接：

- **不要假設 context 變長 = 表現變好**。把 critical information 放在中段是最糟的策略。
- 對 long-horizon agent 任務（多文件 QA、code repo understanding、multi-session chat），單純擴大 context window 是一個「看起來有效但其實沒效」的解法。
- 這篇是後續所有 **selective context / RAG / virtual context / memory paging** 路線的經驗基礎 — MemGPT、ContextWeaver、LongLLMLingua、Self-RAG、Mem0 全部都在用這篇的 finding 來 motivate 自己的方法。

---

## 和現有 Code-Agent Wiki 的關聯

### 和 [[code-agent]] 的關聯

這篇是 [[code-agent]] 這個 map 的 **經驗地基** — 它告訴我們「為什麼需要 selective retrieval / memory paging」。

| 論文 | 對 lost-in-the-middle 的回應方式 |
|------|-------------------------------|
| **Lost in the Middle** | 量化問題：context 中段會被忽略 |
| **MemGPT** | 改用 paging + function call，只把當下需要的部分 page in |
| **ContextWeaver** | 把 context 結構化成 dependency graph，避免把無關／弱依賰的內容塞在中段 |
| **Memory-R2** | 訓練時學會「何時該把什麼寫入記憶」，根本性地減少 stuffing |
| **HORMA** | hierarchical organize-then-retrieve，挑選 minimal sufficient context（22.17% baseline tokens） |
| **Context Engineering Survey** | 把這個 finding 收進「Asymmetry Problem」與「Context Compression」章節 |

### 對 OpenClaw / Rowlet 的啟發

1. **SOUL.md / USER.md 應該放在 prompt 的邊緣**。在現有架構中，system prompt 開頭會放 SOUL/IDENTITY/AGENTS，這正好踩在 primacy bias 上 — 是好的。但如果中途插入大量的 daily memory、tool results、wiki dumps，critical state 可能會落在中段，掉進 U-shape 谷底。
2. **Long context 不是免費的午餐**。當 heartbeat 拉進 `memory/YYYY-MM-DD.md` + `wiki/sources/*.md` + transcript chunks 時，要意識到：放在中間的東西容易被忽略。要嘛 page-in 結構化摘要，要嘛靠 graphify 預先挑出最相關的少數 nodes。
3. **Multi-session chat 的 memory 設計要正面面對 lost-in-the-middle**。如果單純把過去 session 串接成 append-only 歷史，相關的 earlier context 很容易掉到中段被忽略。MemGPT 的 recall storage / HORMA 的 hierarchical summarization 都是直接處理這件事。
4. **這篇是評估 protocol 的基礎**。之後如果要評估 Rowlet 自己的 long-context 行為，可以直接抄作者的實驗設計（多文件 QA + KV retrieval，sweep 過位置）作為 in-house benchmark。

---

## 討論問題（值得團隊討論）

1. **我們有沒有實際踩到 lost-in-the-middle？** 在長時間 cron/heartbeat-driven 任務中，是否曾經觀察到模型「記得開頭的 instruction 但忽略中間的 tool result」這種行為？應該怎麼 instrument 才能量化？
2. **Page-in vs. Page-out 的設計取捨**：MemGPT / HORMA 主張「不要把全部 history 塞進 context，只 page-in 需要的」。但 OpenClaw 目前是「把高價值長期檔（SOUL/USER/MEMORY）放在 system 開頭，把工作狀態放在中段」— 這套架構在多長以後會開始掉？
3. **位置 engineering**：除了 paging 之外，是否有更便宜的做法 — 例如刻意重排 prompt 順序、把 critical instructions 重複出現在 prompt 兩端（duplicate the edges）？這會和 [[context-engineering-2025-mei]] 的「prompt engineering」章節呼應。
4. **Closed model 的差距**：Liu et al. 測到 2023 年的 GPT-3.5/Claude-1.3 都會 lost-in-the-middle。2025-2026 的 frontier model（GPT-5、Claude 4、Gemini 2.5、DeepSeek-V3）是否已經解決？值得做一次重測。

---

## 備註

- PDF 已存：`raw/references/papers/ai/lost-in-the-middle-2023-liu.pdf` (747 KB)
- 讀取來源：arXiv abstract + ar5iv HTML version
- 為 [[code-agent]] map 的第六篇論文，補上「context window 利用效率」的經驗基礎
