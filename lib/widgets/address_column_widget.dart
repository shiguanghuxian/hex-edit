import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';

/// 偏移地址列组件
class AddressColumnWidget extends StatelessWidget {
  final int startLine;
  final int visibleLines;
  final int bytesPerLine;
  final bool useHexAddress;
  final double lineHeight;

  const AddressColumnWidget({
    super.key,
    required this.startLine,
    required this.visibleLines,
    this.bytesPerLine = 16,
    this.useHexAddress = true,
    this.lineHeight = 20.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      decoration: BoxDecoration(
        color: MacosTheme.of(context).canvasColor.withOpacity(0.5),
        border: Border(
          right: BorderSide(
            color: MacosTheme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: visibleLines,
        itemBuilder: (context, index) {
          final lineIndex = startLine + index;
          final offset = lineIndex * bytesPerLine;
          return _buildAddressLine(context, offset);
        },
      ),
    );
  }

  Widget _buildAddressLine(BuildContext context, int offset) {
    final addressText = useHexAddress
        ? offset.toRadixString(16).toUpperCase().padLeft(8, '0')
        : offset.toString().padLeft(8, '0');

    return Container(
      height: lineHeight,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      alignment: Alignment.centerRight,
      child: Text(
        addressText,
        style: TextStyle(
          fontFamily: 'Courier New',
          fontSize: 12,
          color: MacosTheme.of(context).typography.body.color?.withOpacity(0.7),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
