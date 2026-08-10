# SwipeSelection — iOS 15+ RootHide 构建（2.3）

基于 **iCraze 维护版 SwipeSelection 2.0 源码**（[iCrazeiOS/SwipeSelection](https://github.com/iCrazeiOS/SwipeSelection)，支持 iOS 4–16）移植，
专为 iOS 15.0+ RootHide 隐根越狱（arm64e）编译。原作者 Kyle Howells。

## 版本历史与安全模式问题

- **2.1**（重写版）：在手势识别器的 `touchesBegan` 里调 `_layout`/`keyHitTest:`，
  与 iOS 15 键盘任务队列锁重入死锁 → watchdog 杀死键盘/SpringBoard → 安全模式。
- **2.2**（仓库内 1.5.2 老源码）：代码停留在 iOS 13 之前，私有 API 假设过旧，仍会崩溃。
- **2.3（本版）**：改用 iCraze 维护版源码——带 iOS 13/14/16 分支、
  `_UIKeyboardTextSelectionInteraction` 手势冲突修复、ARC、且 `%ctor` 只注入 App 与
  SpringBoard 进程。

## 相对 iCraze 上游源码的改动（仅限编译与稳定性加固，无行为变更）

1. 所有 hook 体加 `@try/@catch`，且 `%orig` 无条件执行——异常不会拖垮宿主进程
   （含 SpringBoard），从机制上杜绝 watchdog 安全模式。
2. `SS_shouldSelect` 对 `isShiftKeyBeingHeld` 增加 `respondsToSelector` 防护。
3. `Tweak.h`：修复非法的 `(void)arg2` 参数声明；统一 `keyHitTest:` 返回类型为 `id`。
4. roothide/theos 工具链：`THEOS_PACKAGE_SCHEME = roothide`、`ARCHS = arm64e`、最低 iOS 15.0。

## 编译

**GitHub Actions（推荐）**：push 本目录任意文件即自动触发，
或在仓库 Actions 页手动运行 **Build (iOS 15 RootHide)**。
编译成功后 `.deb` 会出现在该次运行的 **Artifacts** 以及仓库 **Releases**（标签 `roothide-2.3`）中。

**本地编译**（macOS + roothide/theos）：

```bash
brew install ldid dpkg
git clone --recursive https://github.com/roothide/theos.git ~/theos
cd RootHide
make package FINALPACKAGE=1
```

产物在 `packages/` 目录。

## 安装

包 ID `com.icraze.swipeselection`，版本 2.3，安装后覆盖旧版。
把 deb 传到手机，用 RootHide 版 Sileo 安装，或用 Filza 安装后注销（Respring）即可。
