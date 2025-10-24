import 'dart:typed_data';

/// 编辑操作类型
enum EditOperationType {
  /// 修改字节
  modify,
  /// 插入字节
  insert,
  /// 删除字节
  delete,
}

/// 编辑操作记录
class EditOperation {
  /// 操作类型
  final EditOperationType type;
  
  /// 操作起始位置
  final int offset;
  
  /// 旧数据(用于撤销)
  final Uint8List? oldData;
  
  /// 新数据(用于重做)
  final Uint8List? newData;
  
  /// 操作时间戳
  final DateTime timestamp;

  EditOperation({
    required this.type,
    required this.offset,
    this.oldData,
    this.newData,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  /// 创建修改操作
  factory EditOperation.modify({
    required int offset,
    required Uint8List oldData,
    required Uint8List newData,
  }) {
    return EditOperation(
      type: EditOperationType.modify,
      offset: offset,
      oldData: oldData,
      newData: newData,
    );
  }

  /// 创建插入操作
  factory EditOperation.insert({
    required int offset,
    required Uint8List data,
  }) {
    return EditOperation(
      type: EditOperationType.insert,
      offset: offset,
      newData: data,
    );
  }

  /// 创建删除操作
  factory EditOperation.delete({
    required int offset,
    required Uint8List deletedData,
  }) {
    return EditOperation(
      type: EditOperationType.delete,
      offset: offset,
      oldData: deletedData,
    );
  }

  @override
  String toString() {
    return 'EditOperation(type: $type, offset: $offset, timestamp: $timestamp)';
  }
}

/// 编辑历史管理器
class EditHistory {
  /// 撤销栈
  final List<EditOperation> _undoStack = [];
  
  /// 重做栈
  final List<EditOperation> _redoStack = [];
  
  /// 最大历史记录数
  final int maxHistorySize;

  EditHistory({this.maxHistorySize = 100});

  /// 是否可以撤销
  bool get canUndo => _undoStack.isNotEmpty;

  /// 是否可以重做
  bool get canRedo => _redoStack.isNotEmpty;

  /// 撤销栈大小
  int get undoStackSize => _undoStack.length;

  /// 重做栈大小
  int get redoStackSize => _redoStack.length;

  /// 记录一个编辑操作
  void record(EditOperation operation) {
    _undoStack.add(operation);
    
    // 清空重做栈(因为进行了新的编辑)
    _redoStack.clear();
    
    // 限制历史记录大小
    if (_undoStack.length > maxHistorySize) {
      _undoStack.removeAt(0);
    }
  }

  /// 获取撤销操作
  EditOperation? undo() {
    if (!canUndo) return null;
    
    final operation = _undoStack.removeLast();
    _redoStack.add(operation);
    
    return operation;
  }

  /// 获取重做操作
  EditOperation? redo() {
    if (!canRedo) return null;
    
    final operation = _redoStack.removeLast();
    _undoStack.add(operation);
    
    return operation;
  }

  /// 清空历史记录
  void clear() {
    _undoStack.clear();
    _redoStack.clear();
  }

  /// 获取撤销栈的副本(只读)
  List<EditOperation> get undoStack => List.unmodifiable(_undoStack);

  /// 获取重做栈的副本(只读)
  List<EditOperation> get redoStack => List.unmodifiable(_redoStack);

  /// 批量记录操作(用于组合操作)
  void recordBatch(List<EditOperation> operations) {
    for (final operation in operations) {
      _undoStack.add(operation);
    }
    
    _redoStack.clear();
    
    // 限制历史记录大小
    while (_undoStack.length > maxHistorySize) {
      _undoStack.removeAt(0);
    }
  }

  /// 获取历史统计信息
  Map<String, dynamic> getStatistics() {
    final modifyCount = _undoStack.where((op) => op.type == EditOperationType.modify).length;
    final insertCount = _undoStack.where((op) => op.type == EditOperationType.insert).length;
    final deleteCount = _undoStack.where((op) => op.type == EditOperationType.delete).length;
    
    return {
      'totalOperations': _undoStack.length,
      'modifyOperations': modifyCount,
      'insertOperations': insertCount,
      'deleteOperations': deleteCount,
      'canUndo': canUndo,
      'canRedo': canRedo,
    };
  }
}
