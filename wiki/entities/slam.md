---
title: slam
type: entity
tags: [elle_ws, ros2, slam, localization]
status: active
created: 2026-06-23
updated: 2026-06-23
---

# slam

## Summary
ELLE WS 的 SLAM（同步定位與地圖建構）模組，基於雷射雷達或視覺感測器即時建立環境地圖並計算機器人位置。

## Responsibility Boundaries
- 即時地圖建構（Occupancy Grid Map）
- 機器人定位（Particle Filter / Kalman Filter）
- 地圖發布（供導航使用）

## Dependencies
- [[elle_ws_hardware/lidar]] — 主要感測器輸入
- [[elle_ws_hardware/imu]] — 姿態輔助
- [[ax_navigation2]] — 與導航堆疊共享地圖

## Implementation Notes
- 可基於 Cartographer、Slam Toolbox 或 rtabmap_ros
- 代價地圖由 [[elle_ws_functions/costmap_converter]] 處理

## References
- Source: `repos/elle_ws_functions/src/functions/slam/`
