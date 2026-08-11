# SwipeSelection — iOS 15+ RootHide 构建（2.4）

基于 **iCraze 维护版 SwipeSelection 2.0 源码**（[iCrazeiOS/SwipeSelection](https://github.com/iCrazeiOS/SwipeSelection)，支持 iOS 4–16）移植，
专为 iOS 15.0+ RootHide 隐根越狱（arm64e）编译。原作者 Kyle Howells。

## 2.1–2.3 闪退/安全模式的真正根因

用户设备（iPhone XS Max, iOS 15.0）的崩溃日志显示：设置 App 启动 1 秒即崩，
调用栈为 `dyld → libinjector（ellekit）→ dyld 加载 dylib → libobjc 读取元数据`，
错误是 `pointer authentication failure`，出错地址在本插件 dylib 的 `__DATA` 段内
（libobjc 正在读取 `SSPanGestureRecognizer` 的类信息）。**代码一行都没执行就崩了**。

根因：2.1–2.3 全部在 `macos-latest`（Xcode 26 / iPhoneOS26 SDK）上编译，
新工具链生成的 arm64e ObjC 元数据/指针鉴权格式，iOS 15.0 的老 libobjc 无法识别
——所以改代码没用，任何进程注入这个 dylib 都会在加载时崩溃
（SpringBoard 崩 = 安全模式；设置崩 = 闪退）。

**2.4 修复**：改用 Dopamine2-roothide 官方 CI 同款组合——
`macos-13` 运行器（Xcode 14 时代工具链）+ theos 补丁版 `iPhoneOS16.5.sdk`
（`TARGET = iphone:clang:16.5:15.0`），生成 iOS 15.0 能正确加载的 arm64e 二进制。

## 相对 iCraze 上游源码的改动（仅限编译与稳定性加固，无行为变更）

1. 所有 hook 体加 `@try/@catch`，`%orig` 无条件执行——异常不会拖垮宿主进程。
2. `SS_shouldSelect` 对 `isShiftKeyBeingHeld` 增加 `respondsToSelector` 防护。
3. `Tweak.h`：修复非法的 `(void)arg2` 参数声明；统一 `keyHitTest:` 返回类型为 `id`。
4. 自定义协议 `UITextInputPrivate` 改名 `SSPrivateTextInput`
   （与 UIKit 真实私有协议重名，加载时元数据冲突）。
5. roothide/theos 工具链：`THEOS_PACKAGE_SCHEME = roothide`、`ARCHS = arm64e`、iOS 15.0+。

## 编译

**GitHub Actions（推荐）**：push 本目录任意文件即自动触发，
或在仓库 Actions 页手动运行 **Build (iOS 15 RootHide)**。
编译成功后 `.deb` 会出现在该次运行的 **Artifacts** 以及仓库 **Releases**（标签 `roothide-2.4`）中。

**本地编译**（macOS + roothide/theos，注意不要用太新的 Xcode，推荐 Xcode 14/15）：

```bash
brew install ldid dpkg
git clone --recursive https://github.com/roothide/theos.git ~/theos
curl -L https://github.com/theos/sdks/releases/latest/download/iPhoneOS16.5.sdk.tar.xz | tar -xJ -C ~/theos/sdks
cd RootHide
make package FINALPACKAGE=1
```

产物在 `packages/` 目录。

## 安装

包 ID `com.icraze.swipeselection`，版本 2.4，安装后覆盖旧版。
把 deb 传到手机，用 RootHide 版 Sileo 安装，或用 Filza 安装后注销（Respring）即可。
