# SharePad 中文改进版 v1.2.0-local-zh

基于 [SharePad](https://github.com/jonyardley/SharePad) 的非官方 GPLv3 中文改进版。将 USB 连接的 iPad 画面显示为 Mac 窗口，方便在网课和会议中共享。

本次发行沿用 **2026.09.28 固定应用**：版本 `1.2.0-local-zh`、build `1`，没有重新编译或增加功能。本地修改日期为 2026-09-26，本次发布准备日期为 2026-10-28。

## 下载与安装

下载 **`SharePad-zh-2026.09.28-arm64.zip`**，解压后将 SharePad.app 拖到“应用程序”文件夹。

附件同时提供 **`SharePad-zh-source-2026.09.28.zip`** 完整源码、**`INSTALL.zh-CN.txt`** 中文安装说明和 **`SHA256SUMS`** 校验文件。本次以跨 Mac 测试发行提供；本机稳定使用反馈已有，其他 Mac 的安装结果仍待收集。

适用 **Apple 芯片 Mac、macOS 14+**；不支持 Intel Mac。使用支持数据传输的 USB 线连接 iPad，仅传画面，不传 iPad 音频。

本版为 ad hoc 签名，未获 Apple 公证。首次打开若被系统阻止，确认来源后可在“系统设置 → 隐私与安全性”中选择“仍要打开”。随后点击 Mac 菜单栏的 iPad 图标，解锁并信任已连接的 iPad，允许 SharePad 摄像头权限。在会议软件中共享 SharePad 窗口即可。

## 主要改动

- 常用界面及提示中文化。
- 原生窗口按钮、全屏、最大化／还原和恢复居中。
- Retina 显示倍率同步，不改变输入分辨率。
- 本地构建不设试用限时，关闭官方自动更新。

## 当前边界

本机使用者反馈稳定，完整应用包已固化；其他 Mac 的实际安装和兼容性尚待验证。模拟测试发现恢复采集时拔线的状态竞态，当前固定版未修复，尚未确认为实机故障。

诊断发送默认关闭；若手动开启，数据仍发送至上游 **`telemetry.sharepad.co`**。

完整修改源码、构建材料及详细说明见 [本仓库](https://github.com/xiaogege6697/sharepad-zh/tree/v1.2.0-local-zh)。上游基准为 [`b92dd65890ecefc43ffbd252cd03664691e5a310`](https://github.com/jonyardley/SharePad/commit/b92dd65890ecefc43ffbd252cd03664691e5a310)。原版权声明和 GPLv3 许可证保留；软件按现状提供，不作担保。
