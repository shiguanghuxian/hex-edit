/// 数据源类型
enum DataSourceType {
  /// 文件数据源
  file,
  /// 剪贴板数据源
  clipboard,
  /// 空数据源(新建)
  empty,
}

/// 文件元数据
class FileMetadata {
  /// 文件名
  String? _fileName;
  
  /// 文件路径
  String? _filePath;
  
  /// 文件大小(字节)
  int _fileSize;
  
  /// 数据源类型
  DataSourceType _sourceType;
  
  /// 是否被修改
  bool _isModified;
  
  /// 创建时间
  final DateTime _createdAt;
  
  /// 最后修改时间
  DateTime? _lastModifiedAt;

  FileMetadata({
    String? fileName,
    String? filePath,
    int fileSize = 0,
    DataSourceType sourceType = DataSourceType.empty,
    bool isModified = false,
    DateTime? createdAt,
    DateTime? lastModifiedAt,
  })  : _fileName = fileName,
        _filePath = filePath,
        _fileSize = fileSize,
        _sourceType = sourceType,
        _isModified = isModified,
        _createdAt = createdAt ?? DateTime.now(),
        _lastModifiedAt = lastModifiedAt;

  /// 获取文件名
  String get fileName => _fileName ?? '无标题';

  /// 获取文件路径
  String? get filePath => _filePath;

  /// 获取文件大小
  int get fileSize => _fileSize;

  /// 获取数据源类型
  DataSourceType get sourceType => _sourceType;

  /// 是否被修改
  bool get isModified => _isModified;

  /// 创建时间
  DateTime get createdAt => _createdAt;

  /// 最后修改时间
  DateTime? get lastModifiedAt => _lastModifiedAt;

  /// 是否是文件数据源
  bool get isFile => _sourceType == DataSourceType.file;

  /// 是否是剪贴板数据源
  bool get isClipboard => _sourceType == DataSourceType.clipboard;

  /// 是否是空数据源
  bool get isEmpty => _sourceType == DataSourceType.empty;

  /// 获取显示标题
  String get displayTitle {
    if (_fileName != null) {
      return _isModified ? '$_fileName *' : _fileName!;
    }
    return _isModified ? '无标题 *' : '无标题';
  }

  /// 设置文件名
  void setFileName(String fileName) {
    _fileName = fileName;
  }

  /// 设置文件路径
  void setFilePath(String filePath) {
    _filePath = filePath;
  }

  /// 设置文件大小
  void setFileSize(int size) {
    _fileSize = size;
  }

  /// 设置数据源类型
  void setSourceType(DataSourceType type) {
    _sourceType = type;
  }

  /// 标记为已修改
  void markAsModified() {
    _isModified = true;
    _lastModifiedAt = DateTime.now();
  }

  /// 标记为未修改
  void markAsUnmodified() {
    _isModified = false;
  }

  /// 更新最后修改时间
  void updateLastModified() {
    _lastModifiedAt = DateTime.now();
  }

  /// 从文件创建元数据
  factory FileMetadata.fromFile({
    required String fileName,
    required String filePath,
    required int fileSize,
  }) {
    return FileMetadata(
      fileName: fileName,
      filePath: filePath,
      fileSize: fileSize,
      sourceType: DataSourceType.file,
      isModified: false,
    );
  }

  /// 从剪贴板创建元数据
  factory FileMetadata.fromClipboard({
    required int dataSize,
  }) {
    return FileMetadata(
      fileName: '剪贴板数据',
      fileSize: dataSize,
      sourceType: DataSourceType.clipboard,
      isModified: false,
    );
  }

  /// 创建空元数据
  factory FileMetadata.empty() {
    return FileMetadata(
      fileName: '无标题',
      fileSize: 0,
      sourceType: DataSourceType.empty,
      isModified: false,
    );
  }

  /// 格式化文件大小
  String get formattedSize {
    if (_fileSize < 1024) {
      return '$_fileSize B';
    } else if (_fileSize < 1024 * 1024) {
      return '${(_fileSize / 1024).toStringAsFixed(1)} KB';
    } else if (_fileSize < 1024 * 1024 * 1024) {
      return '${(_fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(_fileSize / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  /// 创建副本
  FileMetadata copy() {
    return FileMetadata(
      fileName: _fileName,
      filePath: _filePath,
      fileSize: _fileSize,
      sourceType: _sourceType,
      isModified: _isModified,
      createdAt: _createdAt,
      lastModifiedAt: _lastModifiedAt,
    );
  }

  @override
  String toString() {
    return 'FileMetadata(fileName: $fileName, size: $formattedSize, '
        'type: $_sourceType, modified: $_isModified)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FileMetadata &&
        other._fileName == _fileName &&
        other._filePath == _filePath &&
        other._fileSize == _fileSize &&
        other._sourceType == _sourceType &&
        other._isModified == _isModified;
  }

  @override
  int get hashCode => Object.hash(
        _fileName,
        _filePath,
        _fileSize,
        _sourceType,
        _isModified,
      );
}
