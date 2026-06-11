# 文字簡報：HTTP/2 Bomb / CVE-2026-49975 影片防禦向整理

影片：`6xyaPOMWXBc`  
標題：`【紧急】最有力气的漏洞！人人都能打崩网站，88万台服务器裸奔，CVSS 9.8拒绝服务漏洞 | CVE-2026-49975 | HTTP2 Bomb`  
頻道：網絡小白_Uncle城  
日期：2026-06-10  
長度：約 4 分 49 秒  
轉錄：本機 whisper.cpp，未使用外部 STT API

## 安全處理原則

本簡報只保留防禦資訊：影響面、機制概念、風險判斷、緩解方向、監控與驗證。影片中提到的攻擊指令、 exploit 腳本用法與可操作濫用步驟不整理、不複製。

## 驗證狀態

- 影片聲稱漏洞編號為 `CVE-2026-49975`，代號 `HTTP2 Bomb`，CVSS 9.8。
- 影片聲稱影響 Nginx、Apache、Microsoft IIS、Envoy、Cloudflare Pingora 等 HTTP/2 相關 server / proxy。
- 影片聲稱全球約 88 萬台伺服器暴露。
- 但在本次整理時，公開搜尋沒有找到可靠獨立索引結果可確認 `CVE-2026-49975` 或 `HTTP2 Bomb`。

因此：**目前應把影片內容視為待驗證情報，不應直接當成已確認 CVE 公告。**

建議後續確認來源：

- NVD / CVE 官方紀錄
- Nginx、Apache httpd / mod_http2、Microsoft、Envoy、Cloudflare Pingora 官方 advisory
- 上游 release notes / security changelog
- 研究公司原始技術報告

## 影片主張的漏洞機制

影片描述的概念是 HTTP/2 層面的記憶體放大型 DoS。

核心由兩個機制組合：

1. **HPACK header compression 動態表放大**
   - HTTP/2 使用 HPACK 壓縮 header。
   - 客戶端與伺服器維護動態表，後續 header 可用索引引用。
   - 影片聲稱攻擊者可用很小的傳輸量，讓伺服器解碼時展開成大量 header memory allocation。

2. **HTTP/2 flow control / window 停滯**
   - 影片聲稱攻擊者可使伺服器分配記憶體後，透過 flow control 讓回應無法正常送出。
   - 這導致已分配的記憶體長時間無法釋放，造成記憶體耗盡。

簡化理解：

> 小流量進入，伺服器端被迫做大量 header 解碼與記憶體配置，再因 flow control 停滯而無法釋放，形成 DoS。

## 影片聲稱的繞過點

影片說這類攻擊可能繞過傳統防禦：

- request count rate limit：因為請求數量可能很少。
- request body size limit：因為攻擊重點不是 body。
- header count limit：影片聲稱解碼後可能被視為合併後 header。
- header size limit：影片聲稱單個解碼後 header 仍可能看似正常。
- WAF / signature：影片聲稱流量和正常 HTTP/2 訪問相似。

以上仍需官方 technical advisory 驗證。

## 可能影響

若影片描述屬實，風險會集中在：

- 對外開啟 HTTP/2 的 web server。
- 反向代理 / API gateway / service mesh edge proxy。
- 沒有限制 worker memory 的裸機部署。
- 沒有前置 mitigation 的舊版 Nginx / Apache / IIS / Envoy 類服務。
- 高校、企業官網、API edge、CDN origin 等公開 HTTP/2 endpoint。

## 防禦建議

### 1. 先確認資產是否啟用 HTTP/2

盤點：

- Internet-facing web server 是否開啟 HTTP/2。
- CDN / reverse proxy / ingress controller 是否允許 HTTP/2 到 origin。
- Kubernetes ingress、Envoy Gateway、Nginx ingress、Apache httpd、IIS 等版本。

### 2. 優先查官方安全公告與升級

影片提到部分修復方向，例如 Nginx / Apache 相關版本，但因未獨立驗證，不應直接照抄版本號。實務上應以 vendor advisory 為準。

### 3. 暫時性 mitigation

若無法確認 patch 狀態，可考慮：

- 暫時關閉 HTTP/2，退回 HTTP/1.1。
- 在前置 proxy / CDN / WAF 限制 header 數量與 header 展開後大小。
- 限制單連線 / 單 stream 的記憶體占用。
- 設定 worker process memory limit，讓單個 worker 被打爆時可快速重啟。
- 在 container / cgroups 設 memory limit，避免整機被拖垮。
- 對 HTTP/2 flow-control 異常、長時間 pending response、header decompression memory spike 做監控。

### 4. 監控指標

可以觀察：

- HTTP/2 connection 數與 stream 數異常。
- worker RSS memory 快速上升。
- header decompression / request parsing CPU 或 memory spike。
- 大量連線長時間不完成 response。
- OOM kill、worker restart、502/503 暴增。
- 入口 proxy 的 per-client memory footprint。

## AI 安全觀察

影片最後提到此類漏洞可能由 AI 輔助組合已知技術發現，並且 patch diff 公開後，AI 也可能加速 exploit 生成。

防禦面啟示：

- 藍隊也需要把 AI 用在 patch diff 風險評估、資產盤點、版本比對與配置審查。
- 漏洞情報不能只看 exploit 是否公開；patch 一公開，攻擊路徑可能被快速重建。
- 對 OpenClaw / agent 系統而言，安全研究 cron 應該加入「可驗證來源」權重，不要只根據影片標題或單一社群來源下結論。

## 結論

這支影片的防禦價值在於提醒：HTTP/2 header compression 與 flow control 這類協議特性，可能組合成低流量、高放大的 DoS 風險。

但目前 `CVE-2026-49975` / `HTTP2 Bomb` 的公開可驗證資料不足。建議把它列入「待查高風險情報」，先做資產盤點與 vendor advisory 追蹤，不要直接把影片聲稱當成確定漏洞公告。
