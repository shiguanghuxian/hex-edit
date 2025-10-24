import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';
import 'dart:typed_data';

/// 十六进制编辑区组件
class HexViewWidget extends StatefulWidget {
  final Uint8List? data;
  final int startLine;
  final int visibleLines;
  final int bytesPerLine;
  final int? cursorPosition;
  final Set<int> selectedBytes;
  final Set<int> dirtyBytes;
  final double lineHeight;
  final Function(int offset, int value)? onByteChanged;
  final Function(int offset)? onByteClicked;
  final Function(int offset)? onByteDoubleClicked;

  const HexViewWidget({
    super.key,
    this.data,
    required this.startLine,
    required this.visibleLines,
    this.bytesPerLine = 16,
    this.cursorPosition,
    this.selectedBytes = const {},
    this.dirtyBytes = const {},
    this.lineHeight = 20.0,
    this.onByteChanged,
    this.onByteClicked,
    this.onByteDoubleClicked,
  });

  @override
  State<HexViewWidget> createState() => _HexViewWidgetState();
}

class _HexViewWidgetState extends State<HexViewWidget> {
  int? _editingOffset;
  final TextEditingController _editController = TextEditingController();

  @override
  void dispose() {
    _editController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: MacosTheme.of(context).canvasColor,
      ),
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: widget.visibleLines,
        itemBuilder: (context, index) {
          final lineIndex = widget.startLine + index;
          return _buildHexLine(context, lineIndex);
        },
      ),
    );
  }

  Widget _buildHexLine(BuildContext context, int lineIndex) {
    final startOffset = lineIndex * widget.bytesPerLine;
    final endOffset = startOffset + widget.bytesPerLine;
    
    return Container(
      height: widget.lineHeight,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Row(
        children: List.generate(widget.bytesPerLine, (i) {
          final offset = startOffset + i;
          if (widget.data == null || offset >= widget.data!.length) {
            return _buildEmptyByte();
          }
          return _buildHexByte(context, offset, widget.data![offset]);
        }),
      ),
    );
  }

  Widget _buildEmptyByte() {
    return Container(
      width: 24,
      margin: const EdgeInsets.only(right: 4),
      child: const Text('  ', style: TextStyle(fontFamily: 'Courier New', fontSize: 12)),
    );
  }

  Widget _buildHexByte(BuildContext context, int offset, int byteValue) {
    final isSelected = widget.selectedBytes.contains(offset);
    final isCursor = widget.cursorPosition == offset;
    final isDirty = widget.dirtyBytes.contains(offset);
    final isEditing = _editingOffset == offset;

    Color? backgroundColor;
    if (isSelected) {
      backgroundColor = MacosTheme.of(context).accentColor?.withOpacity(0.3);
    } else if (isCursor) {
      backgroundColor = MacosTheme.of(context).accentColor?.withOpacity(0.1);
    }

    if (isEditing) {
      return _buildEditingByte(context, offset, byteValue);
    }

    return GestureDetector(
      onTap: () => widget.onByteClicked?.call(offset),
      onDoubleTap: () {
        widget.onByteDoubleClicked?.call(offset);
        _startEditing(offset, byteValue);
      },
      child: Container(
        width: 24,
        margin: const EdgeInsets.only(right: 4),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(2),
          border: isCursor
              ? Border.all(color: MacosTheme.of(context).accentColor ?? Colors.blue, width: 1)
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          byteValue.toRadixString(16).toUpperCase().padLeft(2, '0'),
          style: TextStyle(
            fontFamily: 'Courier New',
            fontSize: 12,
            fontWeight: isDirty ? FontWeight.bold : FontWeight.normal,
            color: isDirty
                ? Colors.orange
                : MacosTheme.of(context).typography.body.color,
          ),
        ),
      ),
    );
  }

  Widget _buildEditingByte(BuildContext context, int offset, int byteValue) {
    return Container(
      width: 24,
      margin: const EdgeInsets.only(right: 4),
      child: TextField(
        controller: _editController,
        autofocus: true,
        maxLength: 2,
        style: const TextStyle(
          fontFamily: 'Courier New',
          fontSize: 12,
        ),
        decoration: const InputDecoration(
          counterText: '',
          contentPadding: EdgeInsets.zero,
          border: OutlineInputBorder(),
          isDense: true,
        ),
        onSubmitted: (value) {
          _submitEdit(offset, value);
        },
        onEditingComplete: () {
          _cancelEdit();
        },
      ),
    );
  }

  void _startEditing(int offset, int byteValue) {
    setState(() {
      _editingOffset = offset;
      _editController.text = byteValue.toRadixString(16).toUpperCase().padLeft(2, '0');
      _editController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _editController.text.length,
      );
    });
  }

  void _submitEdit(int offset, String value) {
    try {
      final newValue = int.parse(value, radix: 16);
      if (newValue >= 0 && newValue <= 255) {
        widget.onByteChanged?.call(offset, newValue);
      }
    } catch (e) {
      // 无效输入,忽略
    }
    _cancelEdit();
  }

  void _cancelEdit() {
    setState(() {
      _editingOffset = null;
      _editController.clear();
    });
  }
}
