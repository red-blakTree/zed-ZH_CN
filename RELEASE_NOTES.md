本版本发布为 **v1.29.3**（与上游最新正式发布 1.29.3 对齐），代码基线为 upstream/main 的 `27bbbc1cc4`（上游 `Cargo.toml` 为 1.30.0），本次合并了 76 个上游提交；另含 Linux 打包与发布链路修复（见下）。

### Zed 上游更新（1.29.0 之后）

- **gpui 性能**：利用深度缓冲减少重绘、改进图元批处理与路径渲染、按需计算 tab 顺序、减少文本 shaping 的逐行/逐字形开销、共享文本按字节比较改为引用计数路径、Levien 阴影近似。
- **git 面板**：提交视图新增「默认展开说明 / 默认展开文件」设置；仓库选择器识别同名仓库并右对齐状态图标；重命名分支名做规范化；修复两端删除的冲突被解析成两端新增；远程分支切换不再重发整张提交图。
- **编辑器与界面**：新增标题栏显示/隐藏设置；书签选择器；同一窗口内打开单个文件；文件查找支持绝对路径、选中文本预填默认值调整；Markdown 第一个已渲染块保持在顶部；侧边栏与无标题栏对齐修复。
- **智能体**：ACP SDK 升级到 5.2.0 并跟进 schema 1.17；配置选项按接收顺序从右到左渲染；空 plan 不再遮住可见 plan；grep 工具拒绝未知输入字段。
- **表格预览**：范围选择、边缘跳转与分页导航。
- **其他**：沙箱新增受保护文件名；文件系统在重负载下更响应、目录检查改为流式；修复排除符号链接时的索引损坏；设置 `disable_ai` 时启动不探测本地模型服务。

完整上游对比：https://github.com/zed-industries/zed/compare/b5cd310b3b...27bbbc1cc4

### 修复 (本 fork)

- **ACP 面板统计与自动压缩**：智能体在回合响应里上报的 input/output 用量不再被 `acp-beta` 门禁丢弃，ACP 面板能显示每轮 token 统计；自动压缩改为按智能体上报的前台活动判定空闲、排除 Zed 无权发 prompt 的子会话，并在回合结束上报 Idle 时补一次阈值检查；达到阈值但缺少 `compact` 命令、已触发未重新武装、用量回落重新武装三种情况各有日志。窗口上限未知时不再渲染永远为 0% 的圆环。
- **git 面板历史标签焦点边框**：构造函数把结构体字段写成了新建的焦点句柄，订阅与实际字段不是同一个，键盘焦点边框从不显示；改回共用同一句柄（该问题同时导致测试 `test_history_tab_focus_border_only_for_keyboard_focus` 长期失败）。
- **汉化补齐**：合并新增的 `title_bar.show`、提交视图两项设置等 7 个键；会话引用的 `Open Session` / `Unavailable Session` 改用已有汉化键。
- **Linux 包在非 GCC 12 环境无法启动**：旧包把构建机（Ubuntu 22.04 / GCC 12，最高 `GLIBCXX_3.4.30`）的 `libstdc++.so.6` 一并打进安装包，它经 `RPATH` 覆盖系统库；宿主 Mesa 的 Vulkan 驱动（`libSPIRV-Tools` 需要 `GLIBCXX_3.4.32`）因此加载失败，Zed 报 `No GPU adapters found`、窗口打不开。现在 `script/bundle-linux` 不再打包 `libstdc++`，构建机改用 `ubuntu-latest`，`.deb` 会自动声明 `libstdc++6` 依赖。

### 汉化 (本 fork)

- en / zh-CN 双侧键集合一致（各 4054 键），`scripts/i18n/check-missing-keys.py` 0 问题。

### 安装包与发布链路

- **Ubuntu / Debian**：`zed-zh-cn_1.29.3_amd64.deb`，安装到 `/usr/lib/zed`，注册 `/usr/bin/zed`、桌面项与图标；`Depends` 由 `ldd` 实测推导，并对 Ubuntu 24.04 的 t64 改名写备选。
- **构建机**：`ubuntu-latest`（GCC ≥ 13，`GLIBCXX` ≥ 3.4.33）；本轮只发布 Linux 产物（`.deb` 与 `tar.gz`），不再产出 Windows / macOS 安装包。
- **版本号**：`1.29.3` 由发布者指定，与上游最新正式 release 对齐（当前 1.29.3）；`release.yml` 校验其不低于上游正式版、与 `Cargo.lock` 一致，且标签名与 `crates/zed/Cargo.toml` 一致；代码基线 1.30.0 高于版本号属预期，下一轮发布再对齐。
- `run_tests.yml` 仅手动触发（`workflow_dispatch`），`check_style` 含汉化键完整性检查。

### 已知说明

- 仅提供 Linux 产物，且为未签名构建。构建机改用较新的 `ubuntu-latest` 后，二进制要求的最低 glibc 也随之抬升（当前为 Ubuntu 24.04 级别）；更旧的发行版请自行在旧环境从源码构建。
- 详细变更列表见下方自动生成的变更记录。