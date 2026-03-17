# ELV 直流無刷馬達驅動器 錯誤碼一覽表

## 驅動器型號
- **ELV 系列 (F01)**
- **版本**: Rev 9.1 (2023/1/22)
- **廠商**: 創盟電子工業股份有限公司 (Trumman Technology Corp)

---

## 錯誤碼表格

| 錯誤碼 | 說明 (中文) | 說明 (英文) | 嚴重程度 |
|--------|-------------|-------------|----------|
| 0 | 正常 | Normal | ✅ OK |
| 1 | 過電流 - 有大電流通過驅動器 | Overcurrent | 🔴 ERROR |
| 2 | 過負載 - 負載超過額定 5 秒以上 | Overload | 🔴 ERROR |
| 3 | 馬達回授訊號錯誤 - 霍爾訊號異常或未連接 | Motor feedback signal error | 🔴 ERROR |
| 4 | 過電壓 - 電源輸入電壓過高 | Overvoltage | 🔴 ERROR |
| 5 | 低電壓 - 電源輸入電壓過低 | Undervoltage | 🔴 ERROR |
| 6 | 驅動器過溫 - 驅動器溫度過高 | Driver overtemperature | 🔴 ERROR |
| 7 | 啟動失敗 - 馬達卡死或動力線鬆脫 | Startup failure | 🔴 ERROR |
| 8 | EEP 資料錯誤 - 無法用 ALM-RST 解除 | EEP data error | 🔴 ERROR |
| 10 | 馬達過溫 - 馬達溫度過高 | Motor overtemperature | 🔴 ERROR |
| 12 | 過速度 - 轉速超過設定上限 | Overspeed | 🔴 ERROR |
| 13 | Encoder 錯誤 - Encoder 未連接/位置Overflow/沒有Z訊號 | Encoder error | 🔴 ERROR |
| 14 | 初期運轉禁止 - FWD/REV 輸入作動時接主電源 | Initial operation prohibited | 🔴 ERROR |
| 15 | 外部停止 - EXT-ERROR 輸入訊號作動 | External stop | 🔴 ERROR |
| 20 | 霍爾序列錯誤 - 霍爾序列參數設定錯誤 | Hall sequence error | 🔴 ERROR |
| 21 | 通訊指令錯誤 - 參數超出範圍或指令不支援 | Communication command error | 🟡 WARN |
| 22 | 參數設定錯誤 - 參數設定值錯誤 | Parameter setting error | 🟡 WARN |

---

## 狀態分類

| 狀態 | 代碼範圍 |
|------|----------|
| **OK** | 0 |
| **ERROR** | 1-15, 20-22 |
| **WARN** | 21-22 |

---

## 標準化輸出格式 (JSON)

```json
{
  "error_codes": {
    "0": { "status": "OK", "description": "正常", "severity": "OK" },
    "1": { "status": "ERROR", "description": "過電流", "severity": "HIGH" },
    "2": { "status": "ERROR", "description": "過負載", "severity": "HIGH" },
    "3": { "status": "ERROR", "description": "馬達回授訊號錯誤", "severity": "HIGH" },
    "4": { "status": "ERROR", "description": "過電壓", "severity": "HIGH" },
    "5": { "status": "ERROR", "description": "低電壓", "severity": "HIGH" },
    "6": { "status": "ERROR", "description": "驅動器過溫", "severity": "HIGH" },
    "7": { "status": "ERROR", "description": "啟動失敗", "severity": "HIGH" },
    "8": { "status": "ERROR", "description": "EEP 資料錯誤", "severity": "HIGH" },
    "10": { "status": "ERROR", "description": "馬達過溫", "severity": "HIGH" },
    "12": { "status": "ERROR", "description": "過速度", "severity": "HIGH" },
    "13": { "status": "ERROR", "description": "Encoder 錯誤", "severity": "HIGH" },
    "14": { "status": "ERROR", "description": "初期運轉禁止", "severity": "HIGH" },
    "15": { "status": "ERROR", "description": "外部停止", "severity": "HIGH" },
    "20": { "status": "ERROR", "description": "霍爾序列錯誤", "severity": "HIGH" },
    "21": { "status": "WARN", "description": "通訊指令錯誤", "severity": "MEDIUM" },
    "22": { "status": "WARN", "description": "參數設定錯誤", "severity": "MEDIUM" }
  }
}
```

---

## 監控輸出範例

```json
{
  "timestamp": "2026-03-15T19:00:00Z",
  "driver": "ELVDR-K020CQ",
  "status": "ERROR",
  "error_code": "4",
  "description": "過電壓",
  "severity": "HIGH"
}
```

---

## 故障排除快速對照

| 錯誤碼 | 可能的解決方式 |
|--------|---------------|
| 1 過電流 | 檢查馬達接線是否短路、負載是否過重 |
| 2 過負載 | 減少負載、調高轉矩限制 |
| 3 馬達回授訊號錯誤 | 檢查霍爾感測器連接線 |
| 4 過電壓 | 檢查電源供應器電壓是否過高 |
| 5 低電壓 | 檢查電源供應器電壓是否過低 |
| 6 驅動器過溫 | 改善散熱環境 |
| 7 啟動失敗 | 檢查馬達是否卡死、動力線是否鬆脫 |
| 8 EEP 資料錯誤 | 聯繫原廠 |
| 10 馬達過溫 | 讓馬達降溫、檢查散熱 |
| 12 過速度 | 調高速度上限、檢查負載 |
| 13 Encoder 錯誤 | 檢查 Encoder 連接線 |
| 14 初期運轉禁止 | 確認 FWD/REV 輸入狀態後重新上電 |
| 15 外部停止 | 檢查 EXT-ERROR 輸入訊號 |
| 20 霍爾序列錯誤 | 檢查霍爾參數設定 |
| 21 通訊指令錯誤 | 檢查通訊參數設定 |
| 22 參數設定錯誤 | 修正參數設定值 |

---

## 檔案資訊

- **建立日期**: 2026-03-15
- **適用型號**: ELV 系列 (F01)
- **手冊版本**: Rev 9.1
- **廠商**: 創盟電子工業股份有限公司
