---
title: ELLE WS Wiki Index
description: ELLE WS 知識庫的實體頁面索引
date: 2026-06-23
tags: [elle_ws, wiki]
---

# ELLE WS Wiki Index

## Entities（實體頁面）

### Functions Layer（11 packages）
| 頁面 | 說明 |
|------|------|
| [[amr_main]] | AMR 主控制節點 |
| [[ax_navigation2]] | 導航堆疊（Nav2）|
| [[slam]] | SLAM 地圖建構與定位 |
| [[costmap_converter]] | 障礙物 costmap 處理 |
| [[csv_log]] | CSV 格式日誌記錄 |
| [[laser_tools]] | 雷射雷達工具 |
| [[precision]] | 精準定位模組 |
| [[rosbag_log]] | ROS2 bag 錄製管理 |
| [[config_repost]] | 設定檔 report 工具 |

### Hardware Layer（17 packages）
| 頁面 | 說明 |
|------|------|
| [[lidar]] | 雷射雷達驅動 |
| [[motor]] | 馬達控制驅動 |
| [[imu]] | IMU 慣性測量 |
| [[camera]] | 相機驅動 |
| [[gps]] | GPS 定位 |
| [[battery]] | 電池管理 |
| [[beeper]] | 蜂鳴器警示 |
| [[audio]] | 音訊模組 |
| [[joy]] | 搖桿控制 |
| [[led]] | LED 控制 |
| [[wifi_module]] | WiFi 模組 |
| [[ultrasound]] | 超音波感測器 |
| [[io_module]] | IO 擴展模組 |
| [[ros_controls]] | ROS2 control 框架 |
| [[device_msgs]] | 統一設備訊息格式 |
| [[utils]] | 通用工具函式 |
| [[backup]] | 備份模組 |

### Bringup Layer
| 頁面 | 說明 |
|------|------|
| [[bringup]] | 系統啟動設定 |

### Simulations Layer
| 頁面 | 說明 |
|------|------|
| [[simulations]] | 模擬環境 |

### Tools Layer
| 頁面 | 說明 |
|------|------|
| [[tools]] | 工具程式 |

---

## Wiki 結構

```
elle_ws/
├── raw/           # 證據層（PM spec、會議記錄）
├── repos/         # 實際程式碼
├── graphify/      # 依賴圖譜（待建）
├── wiki/          # 知識庫（本 wiki）
│   ├── entities/  # 實體頁面（本文）
│   ├── concepts/  # 設計決策
│   ├── patterns/  # 執行經驗
│   └── comparisons/ # 方案比較
└── spec/          # OpenSpec 合約（待建）
```

## 最新更新
- 2026-06-23：初始化 Ouroboros 結構，建立 entities 頁面
