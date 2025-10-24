import 'dart:typed_data';

/// 字节缓冲区 - 管理编辑器的原始字节数据
class ByteBuffer {
  /// 原始字节数据
  Uint8List _data;
  
  /// 修改标记 - 记录哪些字节被修改过
  final Set<int> _dirtyBytes = {};
  
  /// 数据是否被修改过
  bool _isModified = false;

  ByteBuffer(this._data);

  /// 从文件路径创建
  factory ByteBuffer.fromBytes(List<int> bytes) {
    return ByteBuffer(Uint8List.fromList(bytes));
  }

  /// 创建空缓冲区
  factory ByteBuffer.empty() {
    return ByteBuffer(Uint8List(0));
  }

  /// 获取字节数据
  Uint8List get data => _data;

  /// 获取数据长度
  int get length => _data.length;

  /// 是否被修改
  bool get isModified => _isModified;

  /// 获取脏字节集合
  Set<int> get dirtyBytes => Set.unmodifiable(_dirtyBytes);

  /// 获取指定位置的字节
  int getByte(int offset) {
    if (offset < 0 || offset >= _data.length) {
      throw RangeError('Offset $offset out of range [0, ${_data.length})');
    }
    return _data[offset];
  }

  /// 获取指定范围的字节
  Uint8List getBytes(int start, int end) {
    if (start < 0 || end > _data.length || start > end) {
      throw RangeError('Invalid range [$start, $end)');
    }
    return Uint8List.fromList(_data.sublist(start, end));
  }

  /// 设置指定位置的字节
  void setByte(int offset, int value) {
    if (offset < 0 || offset >= _data.length) {
      throw RangeError('Offset $offset out of range [0, ${_data.length})');
    }
    if (value < 0 || value > 255) {
      throw RangeError('Byte value $value out of range [0, 255]');
    }
    _data[offset] = value;
    _dirtyBytes.add(offset);
    _isModified = true;
  }

  /// 设置指定范围的字节
  void setBytes(int offset, List<int> bytes) {
    if (offset < 0 || offset + bytes.length > _data.length) {
      throw RangeError('Range out of bounds');
    }
    for (int i = 0; i < bytes.length; i++) {
      setByte(offset + i, bytes[i]);
    }
  }

  /// 插入字节
  void insertBytes(int offset, List<int> bytes) {
    if (offset < 0 || offset > _data.length) {
      throw RangeError('Offset $offset out of range [0, ${_data.length}]');
    }
    
    final newData = Uint8List(_data.length + bytes.length);
    newData.setRange(0, offset, _data);
    newData.setRange(offset, offset + bytes.length, bytes);
    newData.setRange(offset + bytes.length, newData.length, _data, offset);
    
    _data = newData;
    _isModified = true;
    
    // 标记插入位置后的所有字节为脏数据
    for (int i = offset; i < _data.length; i++) {
      _dirtyBytes.add(i);
    }
  }

  /// 删除字节
  void deleteBytes(int start, int end) {
    if (start < 0 || end > _data.length || start > end) {
      throw RangeError('Invalid range [$start, $end)');
    }
    
    final newData = Uint8List(_data.length - (end - start));
    newData.setRange(0, start, _data);
    newData.setRange(start, newData.length, _data, end);
    
    _data = newData;
    _isModified = true;
    
    // 更新脏字节标记
    final newDirtyBytes = <int>{};
    for (final offset in _dirtyBytes) {
      if (offset < start) {
        newDirtyBytes.add(offset);
      } else if (offset >= end) {
        newDirtyBytes.add(offset - (end - start));
      }
    }
    _dirtyBytes.clear();
    _dirtyBytes.addAll(newDirtyBytes);
    
    // 标记删除位置后的所有字节为脏数据
    for (int i = start; i < _data.length; i++) {
      _dirtyBytes.add(i);
    }
  }

  /// 清除修改标记
  void clearModified() {
    _isModified = false;
    _dirtyBytes.clear();
  }

  /// 检查指定字节是否被修改
  bool isDirty(int offset) {
    return _dirtyBytes.contains(offset);
  }

  /// 替换整个数据
  void replaceAll(Uint8List newData) {
    _data = newData;
    _isModified = true;
    _dirtyBytes.clear();
    for (int i = 0; i < _data.length; i++) {
      _dirtyBytes.add(i);
    }
  }

  /// 创建副本
  ByteBuffer copy() {
    final buffer = ByteBuffer(Uint8List.fromList(_data));
    buffer._isModified = _isModified;
    buffer._dirtyBytes.addAll(_dirtyBytes);
    return buffer;
  }
}
