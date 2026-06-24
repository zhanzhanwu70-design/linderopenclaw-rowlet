---
title: motor
type: entity
tags: [elle_ws, ros2, hardware, actuator, motor]
status: active
created: 2026-06-23
updated: 2026-06-23
---

# motor

## Summary
馬達驅動控制模組，負責將 ROS2 Twist 命令轉換為馬達驅動訊號（CAN / PWM / RS485），同時回傳編碼器計數以計算里程計（Odometry）。

## Responsibility Boundaries
- 接收 `/cmd_vel` 運動命令
- 馬達 PWM / CAN 通訊
- 編碼器脈衝計數與里程計算
- 發布 `/odom` 話題

## Inputs / Outputs
| Topic / Service | Type | Description |
|-----------------|------|-------------|
| `/cmd_vel` | `geometry_msgs/Twist` | 輸入：運動命令 |
| `/odom` | `nav_msgs/Odometry` | 輸出：里程計 |
| `/motors/status` | `DeviceMsg` | 馬達狀態回授 |

## Supported Drivers
| 類型 | 通訊介面 | 備註 |
|------|---------|------|
| DC 馬達 | PWM | 室內輪椅平台 |
| BLDC 馬達 | CAN | 高速機器人 |
| Stepper | Step/Dir | 精準定位 |

## Dependencies
- [[amr_main]] — 上層運動協調
- [[ros_controls]] — ROS2 control 框架整合

## References
- Source: `repos/elle_ws_hardware/src/hardware/motor/`
