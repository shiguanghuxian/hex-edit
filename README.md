# Hex Edit - macOS 风格十六进制编辑器

一款面向开发者的十六进制编辑器,采用 macOS 原生设计语言,提供直观的数据编辑和分析能力。

## 项目状态

🚧 **开发中** - 当前已完成基础框架和核心数据模型

## 功能特性

### 核心功能
- ✅ **原生 macOS 体验** - 完全遵循 macOS 设计规范
- ✅ **双向编辑** - 支持十六进制和明文的实时双向编辑
- 🚧 **多编码支持** - UTF-8, GBK, ASCII, Shift-JIS 等
- 🚧 **搜索与替换** - 十六进制搜索、文本搜索、正则表达式
- 🚧 **编辑历史** - 撤销/重做功能
- 🚧 **文件操作** - 打开、保存、另存为

### 高级功能(计划中)
- 📋 剪贴板数据编辑
- 🔍 数据统计和分析
- 📊 字节分布可视化
- 🔖 书签系统
- 🔐 数据校验(MD5, SHA256, CRC32)

## 项目结构

```
hex-edit/
├── lib/
│   ├── models/              # 数据模型层
│   │   ├── byte_buffer.dart           # 字节缓冲区管理
│   │   ├── edit_history.dart          # 编辑历史管理
│   │   ├── file_metadata.dart         # 文件元数据
│   │   └── selection_cursor_state.dart # 选区和光标状态
│   ├── services/            # 服务层
│   │   ├── encoding_service.dart      # 编码转换服务
│   │   └── (其他服务待实现)
│   ├── widgets/             # UI 组件
│   ├── screens/             # 屏幕/页面
│   ├── providers/           # 状态管理
│   ├── utils/              # 工具类
│   └── main.dart           # 应用入口
├── test/                   # 测试文件
├── macos/                  # macOS 平台配置
└── pubspec.yaml           # 依赖配置
```

## 技术栈

- **框架**: Flutter 3.0+
- **UI 库**: [macos_ui](https://pub.dev/packages/macos_ui) - macOS 风格组件
- **窗口管理**: [window_manager](https://pub.dev/packages/window_manager) - 自定义标题栏
- **文件选择**: [file_picker](https://pub.dev/packages/file_picker)
- **编码支持**: [charset](https://pub.dev/packages/charset)
- **状态管理**: [provider](https://pub.dev/packages/provider)

## 安装和运行

### 前置要求

- Flutter SDK >= 3.0.0
- macOS 10.14 或更高版本
- Xcode(用于 macOS 构建)

### 安装步骤

1. 克隆仓库
```bash
git clone https://github.com/yourusername/hex-edit.git
cd hex-edit
```

2. 获取依赖
```bash
flutter pub get
```

3. 运行应用
```bash
flutter run -d macos
```

4. 构建发布版本
```bash
flutter build macos --release
```

## 开发计划

### 第一阶段 ✅ (已完成)
- [x] 项目初始化和依赖配置
- [x] 数据模型层实现
  - [x] ByteBuffer - 字节缓冲区
  - [x] EditHistory - 编辑历史
  - [x] SelectionState & CursorState - 选区和光标
  - [x] FileMetadata - 文件元数据
- [x] 编码转换服务
- [x] 基础 UI 框架

### 第二阶段 🚧 (进行中)
- [ ] UI 组件实现
  - [ ] 偏移地址列
  - [ ] 十六进制编辑区
  - [ ] 明文显示区
  - [ ] 虚拟滚动支持
- [ ] 文件操作功能
- [ ] 编辑功能(剪切/复制/粘贴)
- [ ] 搜索替换功能

### 第三阶段 📅 (计划中)
- [ ] 状态管理完善
- [ ] 用户偏好设置
- [ ] 错误处理和优化
- [ ] 性能优化(大文件支持)
- [ ] 单元测试和集成测试

### 第四阶段 📅 (未来)
- [ ] 高级功能
  - [ ] 数据统计
  - [ ] 书签系统
  - [ ] 数据校验
  - [ ] 插件系统
- [ ] 跨平台支持(Windows, Linux)

## 架构设计

项目采用分层架构:

```
┌─────────────────────────────────┐
│      UI Layer (Widgets)         │
├─────────────────────────────────┤
│   State Management (Provider)   │
├─────────────────────────────────┤
│    Service Layer (Services)     │
├─────────────────────────────────┤
│    Data Layer (Models)          │
└─────────────────────────────────┘
```

### 核心设计理念

1. **数据与视图分离**: 数据模型独立于 UI 实现
2. **服务化**: 业务逻辑封装在服务层
3. **响应式更新**: 使用 Provider 实现状态响应
4. **虚拟化渲染**: 支持大文件高效显示

## 贡献指南

欢迎贡献! 请遵循以下步骤:

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启 Pull Request

### 代码规范

- 遵循 [Effective Dart](https://dart.dev/guides/language/effective-dart) 指南
- 使用 `flutter analyze` 检查代码
- 添加必要的注释和文档
- 编写单元测试

## 许可证

本项目采用 MIT 许可证 - 详见 [LICENSE](LICENSE) 文件

## 联系方式

- 项目主页: [GitHub](https://github.com/yourusername/hex-edit)
- 问题反馈: [Issues](https://github.com/yourusername/hex-edit/issues)

## 致谢

- [macos_ui](https://pub.dev/packages/macos_ui) - 提供优秀的 macOS UI 组件
- [window_manager](https://pub.dev/packages/window_manager) - 窗口管理支持
- Flutter 社区的所有贡献者

---

**注意**: 本项目目前处于早期开发阶段,API 可能会发生变化。
