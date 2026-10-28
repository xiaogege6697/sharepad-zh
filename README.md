# SharePad 中文改进版

把通过 USB 连接的 iPad 画面显示在 Mac 的独立窗口中，方便网课、讲解和会议共享。在 iPad 上用 Goodnotes 等 App 书写，再由会议软件共享 SharePad 窗口即可；Goodnotes 负责书写，SharePad 负责投屏，两者没有官方集成关系。

本项目基于 [jonyardley/SharePad](https://github.com/jonyardley/SharePad)，是遵循 **GPLv3** 的非官方中文改进版。主要改动是中文界面、原生窗口操作和 Retina 显示倍率同步。

## 下载

前往 [发行页面](https://github.com/xiaogege6697/sharepad-zh/releases/tag/v1.2.0-local-zh)。普通使用下载下面的安装包，无需安装开发工具。

| 文件 | 用途 |
|---|---|
| [SharePad-zh-2026.09.28-arm64.zip](https://github.com/xiaogege6697/sharepad-zh/releases/download/v1.2.0-local-zh/SharePad-zh-2026.09.28-arm64.zip) | 完整应用、中文安装说明与对应源码 |
| [SharePad-zh-source-2026.09.28.zip](https://github.com/xiaogege6697/sharepad-zh/releases/download/v1.2.0-local-zh/SharePad-zh-source-2026.09.28.zip) | 独立完整源码、测试、构建脚本与资源模板 |
| [INSTALL.zh-CN.txt](INSTALL.zh-CN.txt) | 简单中文安装说明 |

发行附件中的 `SHA256SUMS` 可用于核对下载文件完整性。

- **Mac：** Apple 芯片（M 系列），macOS 14 或更新版本；此安装包不支持 Intel Mac。
- **连接：** iPad 与 Mac 使用支持数据传输的 USB 线连接。
- **范围：** 只传输画面，不传输 iPad 音频；使用麦克风讲解时，在会议软件中选择麦克风。
- **版本：** 应用版本 `1.2.0-local-zh`，build `1`，对应 2026.09.28 固定版。本次发布沿用该应用，未重新编译或改变二进制版本。

## 安装与使用

1. 解压 ZIP，将 **SharePad.app** 拖到 Mac 的“应用程序”文件夹。
2. 双击打开。本版为临时签名（ad hoc），没有 Apple Developer ID 签名和公证。若 macOS 阻止打开，确认下载来源后，到“系统设置 → 隐私与安全性”找到 SharePad 的提示，点击“仍要打开”，再按系统提示确认。不同系统版本的按钮文字可能略有差异。
3. 在 Mac 顶部菜单栏点击 **iPad 图标**。SharePad 是菜单栏应用，启动后不一定立即出现主窗口。
4. 用 USB 连接并解锁 iPad，在 iPad 上选择“信任此电脑”；在 Mac 上允许 SharePad 使用摄像头。该权限用于读取 iPad 的 USB 画面。
5. 在 iPad 打开书写或演示 App。投屏出现后，在腾讯会议等会议软件中选择“共享窗口”，并选中 **SharePad**。会议软件需要的屏幕录制权限由该软件自行提示。

窗口支持关闭、最小化、全屏，以及菜单中的最大化／还原、恢复居中默认大小。关闭投屏窗口后可从菜单栏重新显示。每次重新启动程序后，首次显示使用居中默认大小，不记忆上次进程的窗口位置。

## 使用状态与已知限制

本机已实际使用，使用者反馈稳定；完整应用包已固定保存。**其他 Mac 的首次安装、权限和连接体验仍待验证**，尚无覆盖不同 Mac、iPad 和系统版本的兼容性测试结果。

- 本地构建不设试用限时，官方自动更新已关闭；后续版本请查看本仓库的发行页面。
- Retina 修正让显示倍率跟随 Mac 屏幕，不会提高 iPad 输入画面的分辨率。“画面发白”的原因尚未确认。
- 已在模拟测试中发现“恢复采集时拔线，旧恢复任务随后超时”的状态竞态，当前固定版未修复。这是代码模拟结果，尚未确认为实机故障。若遇到连接异常，可先退出 SharePad，再重新接线并启动。

未显示画面时，请依次检查：USB 线是否支持数据传输、iPad 是否解锁并信任电脑、Mac 是否已允许摄像头权限。只启动一份 SharePad。

## 诊断与反馈

诊断发送**默认关闭**。若手动开启，诊断数据会发送到上游服务 **`telemetry.sharepad.co`**，不是本中文改进版维护者的服务；不需要诊断发送即可使用投屏功能。

问题可提交到 [本仓库 Issues](https://github.com/xiaogege6697/sharepad-zh/issues)，说明 Mac 芯片、macOS／iPadOS 版本、发生步骤和错误提示。请勿附上含私人课件、聊天或账号信息的截图。

## 源码与许可证

本仓库提供对应修改源码、测试、构建配置和本地构建脚本，保留上游版权声明及 [GNU GPLv3 许可证](LICENSE)。你可以依许可证使用、修改及再分发；软件按现状提供，不作担保，具体条款见 LICENSE。

上游基准提交：[`b92dd65890ecefc43ffbd252cd03664691e5a310`](https://github.com/jonyardley/SharePad/commit/b92dd65890ecefc43ffbd252cd03664691e5a310)。本地修改于 2026-09-26 完成，2026-09-28 定版，2026-10-28 准备本次公开发行。改动详情见 [中文变更记录](CHANGES.zh-CN.md)。

### 从源码构建

在 Apple 芯片 Mac 上准备 Python 3 和 Apple Swift 工具链。该源码曾在 Swift 6.3.1、Swift 6 模式下编译；本地构建只使用系统框架，不需要下载 Sparkle。普通用户直接安装发行包即可。

在新下载、解压后的仓库目录运行：

```sh
python3 prepare-bundle.py
python3 local-build/build-local.py
```

产物为 `local-build/SharePad.app`，包含本地 ad hoc 签名，不会覆盖“应用程序”中的现用版本。`prepare-bundle.py` 遇到已有产物会停止，重复构建请使用新的源码目录。详细说明见 [BUILD.zh-CN.txt](BUILD.zh-CN.txt)。

`project.yml` 保留的是上游工程配置；要得到本中文无试用限时版本，请使用上面的 `LOCAL_BUILD` 脚本。`Tests/` 保留对应逻辑测试；运行 XCTest 需相应开发环境，商业试用及 Sparkle 测试不适用于 `LOCAL_BUILD`。
