import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 配置窗口管理器
  await windowManager.ensureInitialized();
  
  const windowOptions = WindowOptions(
    size: Size(1200, 800),
    minimumSize: Size(800, 600),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden, // 隐藏系统标题栏
  );
  
  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });
  
  runApp(const HexEditApp());
}

class HexEditApp extends StatelessWidget {
  const HexEditApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MacosApp(
      title: 'Hex Editor',
      theme: MacosThemeData.light(),
      darkTheme: MacosThemeData.dark(),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: const HexEditorScreen(),
    );
  }
}

class HexEditorScreen extends StatefulWidget {
  const HexEditorScreen({super.key});

  @override
  State<HexEditorScreen> createState() => _HexEditorScreenState();
}

class _HexEditorScreenState extends State<HexEditorScreen> with WindowListener {
  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MacosWindow(
      sidebar: null, // 不使用侧边栏
      child: ContentArea(
        builder: (context, scrollController) {
          return Column(
            children: [
              // 自定义标题栏
              _buildTitleBar(),
              // 工具栏
              _buildToolBar(),
              // 编辑器主区域
              Expanded(
                child: _buildEditorArea(),
              ),
              // 状态栏
              _buildStatusBar(),
            ],
          );
        },
      ),
    );
  }

  /// 自定义标题栏
  Widget _buildTitleBar() {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: MacosTheme.of(context).canvasColor,
        border: Border(
          bottom: BorderSide(
            color: MacosTheme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 80), // 为窗口按钮预留空间
          Expanded(
            child: Center(
              child: Text(
                '无标题 - Hex Editor',
                style: MacosTheme.of(context).typography.headline,
              ),
            ),
          ),
          const SizedBox(width: 80),
        ],
      ),
    );
  }

  /// 工具栏
  Widget _buildToolBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: MacosTheme.of(context).canvasColor,
        border: Border(
          bottom: BorderSide(
            color: MacosTheme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          MacosIconButton(
            icon: const Icon(Icons.folder_open, size: 20),
            onPressed: () {
              // TODO: 打开文件
            },
          ),
          const SizedBox(width: 8),
          MacosIconButton(
            icon: const Icon(Icons.save, size: 20),
            onPressed: () {
              // TODO: 保存文件
            },
          ),
          const SizedBox(width: 16),
          MacosIconButton(
            icon: const Icon(Icons.undo, size: 20),
            onPressed: () {
              // TODO: 撤销
            },
          ),
          const SizedBox(width: 8),
          MacosIconButton(
            icon: const Icon(Icons.redo, size: 20),
            onPressed: () {
              // TODO: 重做
            },
          ),
          const SizedBox(width: 16),
          MacosIconButton(
            icon: const Icon(Icons.search, size: 20),
            onPressed: () {
              // TODO: 搜索
            },
          ),
          const Spacer(),
          const Text('编码:'),
          const SizedBox(width: 8),
          MacosPopupButton<String>(
            value: 'UTF-8',
            items: const [
              MacosPopupMenuItem(value: 'UTF-8', child: Text('UTF-8')),
              MacosPopupMenuItem(value: 'ASCII', child: Text('ASCII')),
              MacosPopupMenuItem(value: 'GBK', child: Text('GBK')),
            ],
            onChanged: (value) {
              // TODO: 切换编码
            },
          ),
        ],
      ),
    );
  }

  /// 编辑器主区域
  Widget _buildEditorArea() {
    return Container(
      color: MacosTheme.of(context).canvasColor,
      child: Center(
        child: Text(
          '十六进制编辑器界面将在此处显示',
          style: MacosTheme.of(context).typography.body,
        ),
      ),
    );
  }

  /// 状态栏
  Widget _buildStatusBar() {
    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: MacosTheme.of(context).canvasColor,
        border: Border(
          top: BorderSide(
            color: MacosTheme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Text(
            '选区: 无',
            style: MacosTheme.of(context).typography.caption1,
          ),
          const SizedBox(width: 24),
          Text(
            '光标: 0x00',
            style: MacosTheme.of(context).typography.caption1,
          ),
          const SizedBox(width: 24),
          Text(
            '大小: 0 B',
            style: MacosTheme.of(context).typography.caption1,
          ),
          const Spacer(),
          Text(
            'UTF-8',
            style: MacosTheme.of(context).typography.caption1,
          ),
        ],
      ),
    );
  }
}
