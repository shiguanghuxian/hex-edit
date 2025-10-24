import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import '../models/file_metadata.dart';
import '../models/byte_buffer.dart';

/// 文件操作服务
class FileService {
  /// 打开文件
  Future<({ByteBuffer buffer, FileMetadata metadata})?> openFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        return null;
      }

      final file = result.files.first;
      if (file.path == null) {
        throw Exception('文件路径为空');
      }

      final fileData = await File(file.path!).readAsBytes();
      final buffer = ByteBuffer(Uint8List.fromList(fileData));
      
      final metadata = FileMetadata.fromFile(
        fileName: file.name,
        filePath: file.path!,
        fileSize: fileData.length,
      );

      return (buffer: buffer, metadata: metadata);
    } catch (e) {
      throw Exception('打开文件失败: $e');
    }
  }

  /// 保存文件
  Future<void> saveFile(String path, Uint8List data) async {
    try {
      final file = File(path);
      await file.writeAsBytes(data);
    } catch (e) {
      throw Exception('保存文件失败: $e');
    }
  }

  /// 另存为
  Future<String?> saveFileAs(Uint8List data) async {
    try {
      final path = await FilePicker.platform.saveFile(
        dialogTitle: '另存为',
        fileName: '未命名.bin',
      );

      if (path == null) {
        return null;
      }

      await saveFile(path, data);
      return path;
    } catch (e) {
      throw Exception('另存为失败: $e');
    }
  }

  /// 从剪贴板加载数据
  Future<({ByteBuffer buffer, FileMetadata metadata})> loadFromClipboard(String text) async {
    try {
      // 尝试解析为十六进制
      final bytes = _parseHexString(text);
      
      if (bytes.isEmpty) {
        // 如果不是十六进制,则作为文本处理
        final textBytes = Uint8List.fromList(text.codeUnits);
        final buffer = ByteBuffer(textBytes);
        final metadata = FileMetadata.fromClipboard(dataSize: textBytes.length);
        return (buffer: buffer, metadata: metadata);
      }

      final buffer = ByteBuffer(Uint8List.fromList(bytes));
      final metadata = FileMetadata.fromClipboard(dataSize: bytes.length);
      return (buffer: buffer, metadata: metadata);
    } catch (e) {
      throw Exception('从剪贴板加载失败: $e');
    }
  }

  /// 解析十六进制字符串
  List<int> _parseHexString(String hexString) {
    final cleaned = hexString.replaceAll(RegExp(r'[^0-9A-Fa-f]'), '');
    final bytes = <int>[];

    for (int i = 0; i < cleaned.length; i += 2) {
      if (i + 1 < cleaned.length) {
        try {
          final byte = int.parse(cleaned.substring(i, i + 2), radix: 16);
          bytes.add(byte);
        } catch (e) {
          // 如果解析失败,返回空列表表示不是有效的十六进制
          return [];
        }
      }
    }

    return bytes;
  }

  /// 检查文件是否存在
  Future<bool> fileExists(String path) async {
    try {
      final file = File(path);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }

  /// 获取文件大小
  Future<int> getFileSize(String path) async {
    try {
      final file = File(path);
      return await file.length();
    } catch (e) {
      throw Exception('获取文件大小失败: $e');
    }
  }
}
