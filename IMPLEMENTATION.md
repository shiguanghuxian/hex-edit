# macOS Hex Editor 项目实施说明

## 项目概述

本项目已完成基础架构搭建,包含核心数据模型和服务层实现。由于开发环境未安装 Flutter,项目代码已手动创建,待安装 Flutter 后即可运行。

## 已完成的工作

### 1. 项目结构 ✅
- 创建了完整的目录结构
- 配置了 pubspec.yaml 依赖文件
- 设置了代码分析规则

### 2. 数据层实现 ✅
已创建以下核心数据模型:

#### ByteBuffer (`lib/models/byte_buffer.dart`)
- 管理原始字节数据
- 支持字节的读取、修改、插入、删除
- 跟踪脏字节(被修改的字节)
- 提供数据副本功能

#### EditHistory (`lib/models/edit_history.dart`)
- 管理编辑操作历史
- 支持撤销/重做功能
- 限制历史记录大小
- 支持批量操作记录

#### SelectionState & CursorState (`lib/models/selection_cursor_state.dart`)
- **SelectionState**: 管理选区状态
  - 选区范围设置和获取
  - 扩展选区
  - 检查位置是否在选区内
- **CursorState**: 管理光标状态
  - 光标位置和移动
  - 编辑模式切换(Hex/Text)
  - 高低位切换(十六进制编辑)
  - 键盘导航支持

#### FileMetadata (`lib/models/file_metadata.dart`)
- 文件元数据管理
- 支持三种数据源:文件、剪贴板、空数据
- 文件大小格式化显示
- 修改状态跟踪

### 3. 服务层实现 ✅

#### EncodingService (`lib/services/encoding_service.dart`)
- 支持多种字符编码:
  - ASCII, UTF-8, UTF-16(LE/BE), UTF-32(LE/BE)
  - GBK, GB2312, GB18030
  - Shift-JIS, EUC-JP, Big5
  - Windows-1252, ISO-8859-1
- 字节与文本双向转换
- 可打印字符判断

### 4. 应用入口 ✅

#### Main App (`lib/main.dart`)
- 集成 window_manager 实现自定义标题栏
- 使用 macos_ui 构建 macOS 风格界面
- 基础窗口框架:
  - 自定义标题栏
  - 工具栏(文件操作、编辑、搜索)
  - 编辑器主区域(待实现)
  - 状态栏

## 待实现的功能

### 优先级 P0 (核心功能)
- [ ] 十六进制编辑区组件
- [ ] 明文显示区组件
- [ ] 偏移地址列组件
- [ ] 文件打开/保存功能
- [ ] 基础编辑功能(选择、复制、粘贴)

### 优先级 P1 (重要功能)
- [ ] 虚拟滚动列表(支持大文件)
- [ ] 搜索替换功能
- [ ] 编码切换功能
- [ ] 撤销/重做集成
- [ ] 状态管理(Provider)

### 优先级 P2 (增强功能)
- [ ] 右键菜单
- [ ] 快捷键处理
- [ ] 键盘导航
- [ ] 用户偏好设置
- [ ] 错误处理机制

### 优先级 P3 (高级功能)
- [ ] 数据统计和分析
- [ ] 书签系统
- [ ] 数据校验(MD5/SHA256)
- [ ] 单元测试和集成测试

## 如何继续开发

### 1. 环境准备
```bash
# 安装 Flutter SDK
# 参考: https://docs.flutter.dev/get-started/install/macos

# 验证安装
flutter doctor

# 获取依赖
cd /data/workspace/hex-edit
flutter pub get
```

### 2. 运行项目
```bash
# 运行调试版本
flutter run -d macos

# 构建 Release 版本
flutter build macos --release
```

### 3. 下一步开发建议

#### 步骤 1: 实现核心 UI 组件
1. 创建 `HexViewWidget` - 十六进制显示和编辑
2. 创建 `TextViewWidget` - 明文显示和编辑
3. 创建 `AddressColumnWidget` - 地址列显示
4. 组合为 `HexEditorWidget`

#### 步骤 2: 集成状态管理
```dart
// 创建 lib/providers/editor_provider.dart
class EditorProvider extends ChangeNotifier {
  ByteBuffer? _buffer;
  SelectionState _selection = SelectionState();
  CursorState _cursor = CursorState();
  EditHistory _history = EditHistory();
  
  // 实现状态更新方法...
}
```

#### 步骤 3: 实现文件操作
```dart
// 创建 lib/services/file_service.dart
class FileService {
  Future<ByteBuffer> openFile(String path);
  Future<void> saveFile(String path, ByteBuffer buffer);
  // ...
}
```

#### 步骤 4: 实现虚拟滚动
使用 Flutter 的 `ListView.builder` 或自定义 `CustomScrollView`:
```dart
ListView.builder(
  itemCount: totalLines,
  itemBuilder: (context, index) {
    return HexLineWidget(lineIndex: index);
  },
)
```

## 项目架构图

```
┌─────────────────────────────────────────┐
│           MacOS Application             │
├─────────────────────────────────────────┤
│  Window Manager (window_manager)        │
│  - Custom Title Bar                     │
│  - Window Controls                      │
├─────────────────────────────────────────┤
│           UI Layer (Widgets)            │
│  - HexEditorWidget                      │
│  - ToolbarWidget                        │
│  - StatusBarWidget                      │
├─────────────────────────────────────────┤
│       State Management (Provider)       │
│  - EditorProvider                       │
│  - AppProvider                          │
├─────────────────────────────────────────┤
│         Service Layer                   │
│  - EncodingService ✅                   │
│  - FileService (TODO)                   │
│  - SearchService (TODO)                 │
├─────────────────────────────────────────┤
│         Data Layer (Models)             │
│  - ByteBuffer ✅                        │
│  - EditHistory ✅                       │
│  - SelectionState ✅                    │
│  - CursorState ✅                       │
│  - FileMetadata ✅                      │
└─────────────────────────────────────────┘
```

## 关键设计决策

### 1. 为什么选择 Provider?
- 轻量级,易于理解
- Flutter 官方推荐
- 足够满足当前需求

### 2. 虚拟滚动策略
- 只渲染可见行 + 缓冲区
- 按需从 ByteBuffer 获取数据
- 减少内存占用,提升性能

### 3. 编码处理
- 显示层与数据层分离
- 字节数据不变,只改变显示方式
- 支持实时编码切换

### 4. 编辑历史
- 增量记录,不保存完整数据副本
- 限制历史栈大小,避免内存溢出
- 支持批量操作

## 测试策略

### 单元测试
```dart
// test/models/byte_buffer_test.dart
void main() {
  test('ByteBuffer should set and get byte correctly', () {
    final buffer = ByteBuffer.fromBytes([0x00, 0x01, 0x02]);
    buffer.setByte(1, 0xFF);
    expect(buffer.getByte(1), 0xFF);
  });
}
```

### Widget 测试
```dart
// test/widgets/hex_editor_test.dart
void main() {
  testWidgets('HexEditor should display data', (tester) async {
    await tester.pumpWidget(
      MacosApp(home: HexEditorWidget(...))
    );
    expect(find.text('00'), findsWidgets);
  });
}
```

## 性能考虑

### 大文件处理
- 分块加载:每次只加载可见部分
- 懒加载:滚动时动态加载
- 内存映射:对于超大文件考虑使用 mmap

### UI 优化
- 使用 `const` 构造函数
- 避免不必要的 rebuild
- 使用 `RepaintBoundary` 隔离重绘区域

## 常见问题

### Q: 为什么不直接使用 MaterialApp?
A: macOS 应用应遵循 macOS 设计规范,macos_ui 提供了原生的 macOS 组件。

### Q: 如何处理非 UTF-8 编码的文本?
A: 使用 charset 包进行编码转换,EncodingService 已封装相关逻辑。

### Q: 如何支持超大文件(>1GB)?
A: 
1. 使用虚拟滚动只渲染可见部分
2. 考虑使用 Isolate 在后台线程处理
3. 对于超大文件,考虑分段加载策略

## 参考资源

- [Flutter macOS 桌面开发](https://docs.flutter.dev/development/platform-integration/macos/building)
- [macos_ui 文档](https://pub.dev/packages/macos_ui)
- [window_manager 文档](https://pub.dev/packages/window_manager)
- [Provider 状态管理](https://pub.dev/packages/provider)

## 贡献者

- 项目基础架构和核心模型实现

---
最后更新: 2025-10-24
