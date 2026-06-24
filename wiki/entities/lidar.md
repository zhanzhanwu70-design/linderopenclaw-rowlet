---
title: lidar
type: entity
tags: [elle_ws, ros2, hardware, sensor, lidar]
status: active
created: 2026-06-23
updated: 2026-06-23
---

# lidar

## Summary
雷射雷達驅動模組，支援多款常見 LiDAR 硬體（SLAMTEC、SICK、Hokuyo 等），將 raw 測距數據轉換為 ROS2 LaserScan / PointCloud2 話題。

## Responsibility Boundaries
- LiDAR 硬體通訊（Serial / UDP / Ethernet）
- 原始距離資料轉換為 ROS2 訊息格式
- 發布 `/scan`（2D）和 `/points`（3D）主題

## Hardware Support
| 型號 | 通訊介面 | 備註 |
|------|---------|------|
| RPLIDAR A1/A2 | USB Serial | 室內小範圍 |
| SICK LMS511 | Ethernet | 室外/工業 |
| Hokuyo UST-10LX | Ethernet | 室內高速 |

## Outputs
| Topic | Type | Description |
|-------|------|-------------|
| `/scan` | `sensor_msgs/LaserScan` | 2D 平面掃描 |
| `/points` | `sensor_msgs/PointCloud2` | 3D 點雲 |

## Dependencies
- [[amr_main]] — 狀態整合
- [[ax_navigation2]] — SLAM 資料來源

## References
- Source: `repos/elle_ws_hardware/src/hardware/lidar/`
