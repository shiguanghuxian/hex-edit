/// 选区状态管理
class SelectionState {
  /// 选区起始位置 (字节偏移)
  int? _start;
  
  /// 选区结束位置 (字节偏移, 不包含)
  int? _end;

  SelectionState({int? start, int? end})
      : _start = start,
        _end = end;

  /// 获取起始位置
  int? get start => _start;

  /// 获取结束位置
  int? get end => _end;

  /// 是否有选区
  bool get hasSelection => _start != null && _end != null && _start != _end;

  /// 获取选区长度
  int get length {
    if (!hasSelection) return 0;
    return (_end! - _start!).abs();
  }

  /// 获取选区范围 (总是返回 start < end)
  ({int start, int end})? get range {
    if (!hasSelection) return null;
    final s = _start!;
    final e = _end!;
    return s < e ? (start: s, end: e) : (start: e, end: s);
  }

  /// 设置选区
  void setSelection(int start, int end) {
    _start = start;
    _end = end;
  }

  /// 扩展选区到指定位置
  void extendTo(int position) {
    if (_start == null) {
      _start = position;
      _end = position;
    } else {
      _end = position;
    }
  }

  /// 清除选区
  void clear() {
    _start = null;
    _end = null;
  }

  /// 检查指定位置是否在选区内
  bool contains(int offset) {
    final r = range;
    if (r == null) return false;
    return offset >= r.start && offset < r.end;
  }

  /// 全选
  void selectAll(int dataLength) {
    _start = 0;
    _end = dataLength;
  }

  /// 选择指定范围
  void selectRange(int start, int end) {
    if (start < 0 || end < start) {
      throw ArgumentError('Invalid selection range');
    }
    _start = start;
    _end = end;
  }

  /// 创建副本
  SelectionState copy() {
    return SelectionState(start: _start, end: _end);
  }

  @override
  String toString() {
    if (!hasSelection) return 'SelectionState(no selection)';
    final r = range!;
    return 'SelectionState(${r.start} - ${r.end}, length: $length)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SelectionState &&
        other._start == _start &&
        other._end == _end;
  }

  @override
  int get hashCode => Object.hash(_start, _end);
}

/// 编辑模式
enum EditMode {
  /// 十六进制编辑模式
  hex,
  /// 文本编辑模式
  text,
}

/// 光标状态管理
class CursorState {
  /// 光标位置 (字节偏移)
  int _position;
  
  /// 编辑模式
  EditMode _mode;
  
  /// 是否在十六进制的高位 (仅在 hex 模式下有效)
  bool _isHighNibble;

  CursorState({
    int position = 0,
    EditMode mode = EditMode.hex,
    bool isHighNibble = true,
  })  : _position = position,
        _mode = mode,
        _isHighNibble = isHighNibble;

  /// 获取光标位置
  int get position => _position;

  /// 获取编辑模式
  EditMode get mode => _mode;

  /// 是否在高位
  bool get isHighNibble => _isHighNibble;

  /// 设置光标位置
  void setPosition(int position) {
    if (position < 0) {
      throw ArgumentError('Position cannot be negative');
    }
    _position = position;
    _isHighNibble = true; // 重置为高位
  }

  /// 移动光标
  void move(int delta) {
    _position = (_position + delta).clamp(0, double.infinity).toInt();
    _isHighNibble = true;
  }

  /// 移动到下一个字节
  void moveNext() {
    if (_mode == EditMode.hex) {
      if (_isHighNibble) {
        _isHighNibble = false;
      } else {
        _position++;
        _isHighNibble = true;
      }
    } else {
      _position++;
    }
  }

  /// 移动到上一个字节
  void movePrevious() {
    if (_mode == EditMode.hex) {
      if (!_isHighNibble) {
        _isHighNibble = true;
      } else if (_position > 0) {
        _position--;
        _isHighNibble = false;
      }
    } else if (_position > 0) {
      _position--;
    }
  }

  /// 切换编辑模式
  void toggleMode() {
    _mode = _mode == EditMode.hex ? EditMode.text : EditMode.hex;
    _isHighNibble = true;
  }

  /// 设置编辑模式
  void setMode(EditMode mode) {
    _mode = mode;
    _isHighNibble = true;
  }

  /// 移动到行首
  void moveToLineStart(int bytesPerLine) {
    final lineStart = (_position ~/ bytesPerLine) * bytesPerLine;
    _position = lineStart;
    _isHighNibble = true;
  }

  /// 移动到行尾
  void moveToLineEnd(int bytesPerLine, int maxPosition) {
    final lineEnd = ((_position ~/ bytesPerLine) + 1) * bytesPerLine - 1;
    _position = lineEnd.clamp(0, maxPosition - 1);
    _isHighNibble = true;
  }

  /// 上移一行
  void moveUp(int bytesPerLine) {
    if (_position >= bytesPerLine) {
      _position -= bytesPerLine;
    }
  }

  /// 下移一行
  void moveDown(int bytesPerLine, int maxPosition) {
    _position = (_position + bytesPerLine).clamp(0, maxPosition - 1);
  }

  /// 移动到文件开头
  void moveToStart() {
    _position = 0;
    _isHighNibble = true;
  }

  /// 移动到文件结尾
  void moveToEnd(int maxPosition) {
    _position = (maxPosition - 1).clamp(0, maxPosition);
    _isHighNibble = true;
  }

  /// 翻页向上
  void pageUp(int bytesPerPage) {
    _position = (_position - bytesPerPage).clamp(0, double.infinity).toInt();
    _isHighNibble = true;
  }

  /// 翻页向下
  void pageDown(int bytesPerPage, int maxPosition) {
    _position = (_position + bytesPerPage).clamp(0, maxPosition - 1);
    _isHighNibble = true;
  }

  /// 创建副本
  CursorState copy() {
    return CursorState(
      position: _position,
      mode: _mode,
      isHighNibble: _isHighNibble,
    );
  }

  @override
  String toString() {
    return 'CursorState(position: $_position, mode: $_mode, isHighNibble: $_isHighNibble)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CursorState &&
        other._position == _position &&
        other._mode == _mode &&
        other._isHighNibble == _isHighNibble;
  }

  @override
  int get hashCode => Object.hash(_position, _mode, _isHighNibble);
}
