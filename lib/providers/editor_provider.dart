import 'package:flutter/foundation.dart';
import 'dart:typed_data';
import '../models/byte_buffer.dart';
import '../models/edit_history.dart';
import '../models/selection_cursor_state.dart';
import '../models/file_metadata.dart';
import '../services/encoding_service.dart';

/// 编辑器状态 Provider
class EditorProvider extends ChangeNotifier {
  // 核心数据
  ByteBuffer? _buffer;
  EditHistory _history = EditHistory(maxHistorySize: 100);
  SelectionState _selection = SelectionState();
  CursorState _cursor = CursorState();
  FileMetadata _metadata = FileMetadata.empty();
  
  // 服务
  final EncodingService _encodingService = EncodingService();
  
  // 视图配置
  int _bytesPerLine = 16;
  bool _useHexAddress = true;
  
  // Getters
  ByteBuffer? get buffer => _buffer;
  EditHistory get history => _history;
  SelectionState get selection => _selection;
  CursorState get cursor => _cursor;
  FileMetadata get metadata => _metadata;
  EncodingService get encodingService => _encodingService;
  int get bytesPerLine => _bytesPerLine;
  bool get useHexAddress => _useHexAddress;
  
  // 是否有数据
  bool get hasData => _buffer != null && _buffer!.length > 0;
  
  // 总行数
  int get totalLines => hasData ? (_buffer!.length / _bytesPerLine).ceil() : 0;
  
  /// 加载数据
  void loadData(Uint8List data, FileMetadata? metadata) {
    _buffer = ByteBuffer(data);
    _metadata = metadata ?? FileMetadata.empty();
    _history.clear();
    _selection.clear();
    _cursor.setPosition(0);
    notifyListeners();
  }
  
  /// 修改字节
  void modifyByte(int offset, int newValue) {
    if (_buffer == null || offset >= _buffer!.length) return;
    
    final oldValue = _buffer!.getByte(offset);
    if (oldValue == newValue) return;
    
    // 记录历史
    final operation = EditOperation.modify(
      offset: offset,
      oldData: Uint8List.fromList([oldValue]),
      newData: Uint8List.fromList([newValue]),
    );
    _history.record(operation);
    
    // 执行修改
    _buffer!.setByte(offset, newValue);
    _metadata.markAsModified();
    
    notifyListeners();
  }
  
  /// 插入字节
  void insertBytes(int offset, List<int> bytes) {
    if (_buffer == null) return;
    
    // 记录历史
    final operation = EditOperation.insert(
      offset: offset,
      data: Uint8List.fromList(bytes),
    );
    _history.record(operation);
    
    // 执行插入
    _buffer!.insertBytes(offset, bytes);
    _metadata.setFileSize(_buffer!.length);
    _metadata.markAsModified();
    
    notifyListeners();
  }
  
  /// 删除字节
  void deleteBytes(int start, int end) {
    if (_buffer == null) return;
    
    final deletedData = _buffer!.getBytes(start, end);
    
    // 记录历史
    final operation = EditOperation.delete(
      offset: start,
      deletedData: deletedData,
    );
    _history.record(operation);
    
    // 执行删除
    _buffer!.deleteBytes(start, end);
    _metadata.setFileSize(_buffer!.length);
    _metadata.markAsModified();
    
    notifyListeners();
  }
  
  /// 撤销
  void undo() {
    final operation = _history.undo();
    if (operation == null || _buffer == null) return;
    
    _applyUndoOperation(operation);
    notifyListeners();
  }
  
  /// 重做
  void redo() {
    final operation = _history.redo();
    if (operation == null || _buffer == null) return;
    
    _applyRedoOperation(operation);
    notifyListeners();
  }
  
  void _applyUndoOperation(EditOperation operation) {
    switch (operation.type) {
      case EditOperationType.modify:
        if (operation.oldData != null) {
          _buffer!.setBytes(operation.offset, operation.oldData!);
        }
        break;
      case EditOperationType.insert:
        if (operation.newData != null) {
          _buffer!.deleteBytes(operation.offset, operation.offset + operation.newData!.length);
        }
        break;
      case EditOperationType.delete:
        if (operation.oldData != null) {
          _buffer!.insertBytes(operation.offset, operation.oldData!);
        }
        break;
    }
    _metadata.setFileSize(_buffer!.length);
  }
  
  void _applyRedoOperation(EditOperation operation) {
    switch (operation.type) {
      case EditOperationType.modify:
        if (operation.newData != null) {
          _buffer!.setBytes(operation.offset, operation.newData!);
        }
        break;
      case EditOperationType.insert:
        if (operation.newData != null) {
          _buffer!.insertBytes(operation.offset, operation.newData!);
        }
        break;
      case EditOperationType.delete:
        if (operation.oldData != null) {
          _buffer!.deleteBytes(operation.offset, operation.offset + operation.oldData!.length);
        }
        break;
    }
    _metadata.setFileSize(_buffer!.length);
  }
  
  /// 设置选区
  void setSelection(int start, int end) {
    _selection.setSelection(start, end);
    notifyListeners();
  }
  
  /// 清除选区
  void clearSelection() {
    _selection.clear();
    notifyListeners();
  }
  
  /// 移动光标
  void moveCursor(int position) {
    if (_buffer == null) return;
    _cursor.setPosition(position.clamp(0, _buffer!.length - 1));
    notifyListeners();
  }
  
  /// 切换编码
  void setEncoding(CharacterEncoding encoding) {
    _encodingService.setEncoding(encoding);
    notifyListeners();
  }
  
  /// 设置每行字节数
  void setBytesPerLine(int value) {
    _bytesPerLine = value.clamp(8, 32);
    notifyListeners();
  }
  
  /// 获取选中的字节
  Uint8List? getSelectedBytes() {
    if (_buffer == null || !_selection.hasSelection) return null;
    final range = _selection.range;
    if (range == null) return null;
    return _buffer!.getBytes(range.start, range.end);
  }
  
  /// 复制选中内容
  String? copySelection() {
    final bytes = getSelectedBytes();
    if (bytes == null) return null;
    
    // 返回十六进制字符串
    return bytes.map((b) => b.toRadixString(16).toUpperCase().padLeft(2, '0')).join(' ');
  }
  
  /// 粘贴数据
  void paste(String hexString) {
    if (_buffer == null) return;
    
    // 解析十六进制字符串
    final bytes = _parseHexString(hexString);
    if (bytes.isEmpty) return;
    
    final cursorPos = _cursor.position;
    
    if (_selection.hasSelection) {
      // 替换选中内容
      final range = _selection.range!;
      deleteBytes(range.start, range.end);
      insertBytes(range.start, bytes);
      _cursor.setPosition(range.start + bytes.length);
    } else {
      // 在光标位置插入
      insertBytes(cursorPos, bytes);
      _cursor.setPosition(cursorPos + bytes.length);
    }
    
    clearSelection();
    notifyListeners();
  }
  
  List<int> _parseHexString(String hexString) {
    final cleaned = hexString.replaceAll(RegExp(r'\s+'), '');
    final bytes = <int>[];
    
    for (int i = 0; i < cleaned.length; i += 2) {
      if (i + 1 < cleaned.length) {
        try {
          final byte = int.parse(cleaned.substring(i, i + 2), radix: 16);
          bytes.add(byte);
        } catch (e) {
          // 忽略无效字节
        }
      }
    }
    
    return bytes;
  }
  
  /// 保存数据
  Uint8List? saveData() {
    if (_buffer == null) return null;
    _buffer!.clearModified();
    _metadata.markAsUnmodified();
    notifyListeners();
    return _buffer!.data;
  }
}
