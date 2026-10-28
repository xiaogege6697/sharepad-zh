# 中文改进版变更记录

本项目是 [jonyardley/SharePad](https://github.com/jonyardley/SharePad) 的非官方修改版，保留上游版权及 GPLv3 许可证。

上游基准提交：`b92dd65890ecefc43ffbd252cd03664691e5a310`。

## 2026-09-26 · 本地修改

- 将常用菜单、控制项、连接与权限提示、关于面板和许可证界面改为中文。
- 为本地构建启用 `LOCAL_BUILD` 分支，跳过试用限时并关闭官方自动更新；使用独立应用标识 `local.sharepad.selfbuilt`。
- 改用原生关闭、最小化和全屏操作；增加最大化／还原及恢复居中默认大小，保持 iPad 画面宽高比。
- 每次程序启动后，首次显示使用适合当前屏幕的居中默认大小。关闭或最小化后可以重新显示窗口。
- 修正预览层的 Retina 显示倍率同步：挂接窗口、屏幕倍率变化及布局时跟随当前屏幕倍率。此改动不提升输入分辨率，未加入锐化、对比度或伽马补偿。
- 为关于面板补充主线程标记，消除对应编译警告。

最终版未保留早期的右下角快捷操作角标；USB 采集实现沿用该基准版本。

## 2026-09-28 · 固定版本

固定应用版本为 `1.2.0-local-zh`（build `1`），仅支持 arm64，最低 macOS 14.0。保留完整应用、对应源码、测试、许可证和构建材料。

本版使用 ad hoc 签名，没有 Developer ID 签名和 Apple 公证。诊断发送默认关闭；如手动开启，仍发送至上游 `telemetry.sharepad.co`。

## 2026-10-23 · 验证记录

本机使用者反馈实际使用稳定；核对固定载荷、已安装应用和开发区对应源码一致，并完成应用包解压及签名回验。其他 Mac 的安装、权限与投屏结果仍待反馈，不能据本机结果推定全面兼容。

模拟测试发现恢复采集过程中拔线的状态竞态：设备断开后，旧恢复任务可能继续尝试启动并写入失败状态。当前固定版未修复；这不是已确认的实机崩溃或黑屏记录。

## 2026-10-28 · GitHub 发布准备

- 以 `v1.2.0-local-zh` 作为发行标签。
- 整理完整修改源码、中文使用说明及构建脚本。
- 安装资源命名为 `SharePad-zh-2026.09.28-arm64.zip`，沿用 2026.09.28 固定应用，不重新编译，不更改应用版本或签名。

本次发布准备没有新增功能或修复上述模拟竞态。软件依 [GPLv3](LICENSE) 按现状提供，不作担保。

## 修改文件索引

以下文件包含相对于上游基准的本地修改（2026-09-26，2026-09-28 固定）；原有版权和许可证声明保留：

- `Sources/SharePad/App.swift`
- `Sources/SharePad/AppModel.swift`
- `Sources/SharePad/UI/AboutPanel.swift`
- `Sources/SharePad/UI/LicenseWindow.swift`
- `Sources/SharePad/UI/PopoverView.swift`
- `Sources/SharePad/UI/TrialOverlayView.swift`
- `Sources/SharePad/Updater/SparkleUpdater.swift`
- `Sources/SharePad/Windows/PreviewView.swift`
- `Sources/SharePad/Windows/ShareWindowController.swift`
- `Sources/SharePad/Windows/ShareWindowControlling.swift`
- `Sources/SharePad/Windows/WindowGeometry.swift`
- `Tests/SharePadTests/Fakes.swift`

2026-10-23 增加 `prepare-bundle.py` 和 `bundle-template/`，用于独立源码构建；2026-10-28 整理本仓库说明与 `.gitignore`。
