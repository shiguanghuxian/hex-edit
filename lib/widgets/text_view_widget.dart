import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';
import 'dart:typed_data';
import '../services/encoding_service.dart';

/// 明文显示区组件
class TextViewWidget extends StatefulWidget {
  final Uint8List? data;
  final int startLine;
  final int visibleLines;
  final int bytesPerLine;
  final int? cursorPosition;
  final Set<int> selectedBytes;
  final double lineHeight;
  final EncodingService encodingService;
  final Function(int offset, String char)? onCharChanged;
  final Function(int offset)? onCharClicked;

  const TextViewWidget({
    super.key,
    this.data,
    required this.startLine,
    required this.visibleLines,
    this.bytesPerLine = 16,
    this.cursorPosition,
    this.selectedBytes = const {},
    this.lineHeight = 20.0,
    required this.encodingService,
    this.onCharChanged,
    this.onCharClicked,
  });

  @override
  State<TextViewWidget> createState() => _TextViewWidgetState();
}

class _TextViewWidgetState extends State<TextViewWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      decoration: BoxDecoration(
        color: MacosTheme.of(context).canvasColor.withOpacity(0.5),
        border: Border(
          left: BorderSide(
            color: MacosTheme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: widget.visibleLines,
        itemBuilder: (context, index) {
          final lineIndex = widget.startLine + index;
          return _buildTextLine(context, lineIndex);
        },
      ),
    );
  }

  Widget _buildTextLine(BuildContext context, int lineIndex) {
    final startOffset = lineIndex * widget.bytesPerLine;
    final endOffset = startOffset + widget.bytesPerLine;

    return Container(
      height: widget.lineHeight,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Row(
        children: List.generate(widget.bytesPerLine, (i) {
          final offset = startOffset + i;
          if (widget.data == null || offset >= widget.data!.length) {
            return _buildEmptyChar();
          }
          return _buildTextChar(context, offset, widget.data![offset]);
        }),
      ),
    );
  }

  Widget _buildEmptyChar() {
    return const SizedBox(
      width: 10,
      child: Text(' ', style: TextStyle(fontFamily: 'Courier New', fontSize: 12)),
    );
  }

  Widget _buildTextChar(BuildContext context, int offset, int byteValue) {
    final isSelected = widget.selectedBytes.contains(offset);
    final isCursor = widget.cursorPosition == offset;

    // 使用编码服务转换字节到字符
    final charText = widget.encodingService.byteToChar(byteValue);
    final displayChar = _getDisplayChar(charText);

    Color? backgroundColor;
    if (isSelected) {
      backgroundColor = MacosTheme.of(context).accentColor?.withOpacity(0.3);
    } else if (isCursor) {
      backgroundColor = MacosTheme.of(context).accentColor?.withOpacity(0.1);
    }

    return GestureDetector(
      onTap: () => widget.onCharClicked?.call(offset),
      child: Container(
        width: 10,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(2),
          border: isCursor
              ? Border.all(color: MacosTheme.of(context).accentColor ?? Colors.blue, width: 1)
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          displayChar,
          style: TextStyle(
            fontFamily: 'Courier New',
            fontSize: 12,
            color: _isPrintable(byteValue)
                ? MacosTheme.of(context).typography.body.color
                : MacosTheme.of(context).typography.body.color?.withOpacity(0.3),
          ),
        ),
      ),
    );
  }

  String _getDisplayChar(String char) {
    if (char.isEmpty || char == '\u0000') return '.';
    if (char.length == 1) {
      final code = char.codeUnitAt(0);
      if (code < 32 || code == 127) return '.';
    }
    return char.length == 1 ? char : '.';
  }

  bool _isPrintable(int byte) {
    return byte >= 32 && byte < 127;
  }
}
