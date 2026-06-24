---
title: imu
type: entity
tags: [elle_ws, ros2, hardware, sensor, imu]
status: active
created: 2026-06-23
updated: 2026-06-23
---

# imu

## Summary
IMU（慣性測量單元）驅動模組，整合三軸加速度計與陀螺儀數據，提供姿態估測（Attitude Estimation）並可與 GPS 融合做擴展卡爾曼濾波（EKF）。

## Responsibility Boundaries
- IMU 硬體通訊（I2C / SPI / UART）
- 姿態結算（AHRS）— 加速計 + 陀螺儀融合
- 發布 `/imu/data`（未補償）與 `/imu/data_corrected`（融合後）
- 可選：EKF 融合 GPS 輸出 `/gps/fix`

## Outputs
| Topic | Type | Description |
|-------|------|-------------|
| `/imu/data` | `sensor_msgs/Imu` | 原始 IMU 數據 |
| `/imu/mag` | `sensor_msgs/MagneticField` | 地磁數據（可選）|

## Calibration
- Allan Variance 分析：用於評估隨機游走與零偏穩定性
- 零偏估測：靜置時自動估算 gyroscope bias

## Dependencies
- [[amr_main]] — 姿態回授
- [[ax_navigation2]] — 定位融合

## References
- Source: `repos/elle_ws_hardware/src/hardware/imu/`
