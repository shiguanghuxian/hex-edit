import 'dart:convert';
import 'dart:typed_data';
import 'package:charset/charset.dart';

/// 支持的字符编码
enum CharacterEncoding {
  ascii('ASCII', 'ASCII'),
  utf8('UTF-8', 'UTF-8'),
  utf16le('UTF-16 LE', 'UTF-16LE'),
  utf16be('UTF-16 BE', 'UTF-16BE'),
  utf32le('UTF-32 LE', 'UTF-32LE'),
  utf32be('UTF-32 BE', 'UTF-32BE'),
  gbk('GBK', 'GBK'),
  gb2312('GB2312', 'GB2312'),
  gb18030('GB18030', 'GB18030'),
  shiftJis('Shift-JIS', 'Shift_JIS'),
  eucJp('EUC-JP', 'EUC-JP'),
  big5('Big5', 'Big5'),
  windows1252('Windows-1252', 'Windows-1252'),
  iso88591('ISO-8859-1', 'ISO-8859-1');

  final String displayName;
  final String charsetName;

  const CharacterEncoding(this.displayName, this.charsetName);

  @override
  String toString() => displayName;
}

/// 编码转换服务
class EncodingService {
  /// 当前编码
  CharacterEncoding _currentEncoding = CharacterEncoding.utf8;

  /// 获取当前编码
  CharacterEncoding get currentEncoding => _currentEncoding;

  /// 设置当前编码
  void setEncoding(CharacterEncoding encoding) {
    _currentEncoding = encoding;
  }

  /// 字节转文本
  String bytesToText(Uint8List bytes, {CharacterEncoding? encoding}) {
    final enc = encoding ?? _currentEncoding;
    
    try {
      switch (enc) {
        case CharacterEncoding.ascii:
          return _decodeAscii(bytes);
        
        case CharacterEncoding.utf8:
          return utf8.decode(bytes, allowMalformed: true);
        
        case CharacterEncoding.utf16le:
          return _decodeUtf16(bytes, Endian.little);
        
        case CharacterEncoding.utf16be:
          return _decodeUtf16(bytes, Endian.big);
        
        case CharacterEncoding.utf32le:
          return _decodeUtf32(bytes, Endian.little);
        
        case CharacterEncoding.utf32be:
          return _decodeUtf32(bytes, Endian.big);
        
        case CharacterEncoding.iso88591:
          return latin1.decode(bytes);
        
        case CharacterEncoding.gbk:
        case CharacterEncoding.gb2312:
        case CharacterEncoding.gb18030:
          return _decodeWithCharset(bytes, enc.charsetName);
        
        case CharacterEncoding.shiftJis:
        case CharacterEncoding.eucJp:
        case CharacterEncoding.big5:
        case CharacterEncoding.windows1252:
          return _decodeWithCharset(bytes, enc.charsetName);
      }
    } catch (e) {
      // 解码失败,返回替换字符
      return '�' * (bytes.length);
    }
  }

  /// 文本转字节
  Uint8List textToBytes(String text, {CharacterEncoding? encoding}) {
    final enc = encoding ?? _currentEncoding;
    
    try {
      switch (enc) {
        case CharacterEncoding.ascii:
          return Uint8List.fromList(ascii.encode(text));
        
        case CharacterEncoding.utf8:
          return Uint8List.fromList(utf8.encode(text));
        
        case CharacterEncoding.utf16le:
          return _encodeUtf16(text, Endian.little);
        
        case CharacterEncoding.utf16be:
          return _encodeUtf16(text, Endian.big);
        
        case CharacterEncoding.utf32le:
          return _encodeUtf32(text, Endian.little);
        
        case CharacterEncoding.utf32be:
          return _encodeUtf32(text, Endian.big);
        
        case CharacterEncoding.iso88591:
          return Uint8List.fromList(latin1.encode(text));
        
        case CharacterEncoding.gbk:
        case CharacterEncoding.gb2312:
        case CharacterEncoding.gb18030:
        case CharacterEncoding.shiftJis:
        case CharacterEncoding.eucJp:
        case CharacterEncoding.big5:
        case CharacterEncoding.windows1252:
          return _encodeWithCharset(text, enc.charsetName);
      }
    } catch (e) {
      // 编码失败,返回空
      return Uint8List(0);
    }
  }

  /// 单个字节转字符
  String byteToChar(int byte, {CharacterEncoding? encoding}) {
    return bytesToText(Uint8List.fromList([byte]), encoding: encoding);
  }

  /// 解码 ASCII
  String _decodeAscii(Uint8List bytes) {
    final buffer = StringBuffer();
    for (final byte in bytes) {
      if (byte >= 32 && byte < 127) {
        buffer.writeCharCode(byte);
      } else {
        buffer.write('.');
      }
    }
    return buffer.toString();
  }

  /// 解码 UTF-16
  String _decodeUtf16(Uint8List bytes, Endian endian) {
    if (bytes.length % 2 != 0) {
      // 补齐字节
      bytes = Uint8List.fromList([...bytes, 0]);
    }
    
    final codeUnits = <int>[];
    for (int i = 0; i < bytes.length; i += 2) {
      final unit = endian == Endian.little
          ? bytes[i] | (bytes[i + 1] << 8)
          : (bytes[i] << 8) | bytes[i + 1];
      codeUnits.add(unit);
    }
    
    return String.fromCharCodes(codeUnits);
  }

  /// 编码 UTF-16
  Uint8List _encodeUtf16(String text, Endian endian) {
    final codeUnits = text.codeUnits;
    final bytes = Uint8List(codeUnits.length * 2);
    
    for (int i = 0; i < codeUnits.length; i++) {
      final unit = codeUnits[i];
      if (endian == Endian.little) {
        bytes[i * 2] = unit & 0xFF;
        bytes[i * 2 + 1] = (unit >> 8) & 0xFF;
      } else {
        bytes[i * 2] = (unit >> 8) & 0xFF;
        bytes[i * 2 + 1] = unit & 0xFF;
      }
    }
    
    return bytes;
  }

  /// 解码 UTF-32
  String _decodeUtf32(Uint8List bytes, Endian endian) {
    if (bytes.length % 4 != 0) {
      // 补齐字节
      final padding = 4 - (bytes.length % 4);
      bytes = Uint8List.fromList([...bytes, ...List.filled(padding, 0)]);
    }
    
    final codePoints = <int>[];
    for (int i = 0; i < bytes.length; i += 4) {
      final codePoint = endian == Endian.little
          ? bytes[i] | (bytes[i + 1] << 8) | (bytes[i + 2] << 16) | (bytes[i + 3] << 24)
          : (bytes[i] << 24) | (bytes[i + 1] << 16) | (bytes[i + 2] << 8) | bytes[i + 3];
      codePoints.add(codePoint);
    }
    
    return String.fromCharCodes(codePoints);
  }

  /// 编码 UTF-32
  Uint8List _encodeUtf32(String text, Endian endian) {
    final codeUnits = text.codeUnits;
    final bytes = Uint8List(codeUnits.length * 4);
    
    for (int i = 0; i < codeUnits.length; i++) {
      final unit = codeUnits[i];
      if (endian == Endian.little) {
        bytes[i * 4] = unit & 0xFF;
        bytes[i * 4 + 1] = (unit >> 8) & 0xFF;
        bytes[i * 4 + 2] = (unit >> 16) & 0xFF;
        bytes[i * 4 + 3] = (unit >> 24) & 0xFF;
      } else {
        bytes[i * 4] = (unit >> 24) & 0xFF;
        bytes[i * 4 + 1] = (unit >> 16) & 0xFF;
        bytes[i * 4 + 2] = (unit >> 8) & 0xFF;
        bytes[i * 4 + 3] = unit & 0xFF;
      }
    }
    
    return bytes;
  }

  /// 使用 charset 包解码
  String _decodeWithCharset(Uint8List bytes, String charsetName) {
    try {
      final charset = Charset.getByName(charsetName);
      if (charset != null) {
        return charset.decode(bytes);
      }
    } catch (e) {
      // Fallback to UTF-8
    }
    return utf8.decode(bytes, allowMalformed: true);
  }

  /// 使用 charset 包编码
  Uint8List _encodeWithCharset(String text, String charsetName) {
    try {
      final charset = Charset.getByName(charsetName);
      if (charset != null) {
        return Uint8List.fromList(charset.encode(text));
      }
    } catch (e) {
      // Fallback to UTF-8
    }
    return Uint8List.fromList(utf8.encode(text));
  }

  /// 检查字符是否可打印
  static bool isPrintable(int byte) {
    return byte >= 32 && byte < 127;
  }

  /// 字节转可打印字符
  static String byteToDisplayChar(int byte) {
    return isPrintable(byte) ? String.fromCharCode(byte) : '.';
  }
}
