import 'package:flutter_test/flutter_test.dart';
import 'package:hex_edit/models/byte_buffer.dart';
import 'dart:typed_data';

void main() {
  group('ByteBuffer Tests', () {
    test('should create ByteBuffer from bytes', () {
      final data = [0x48, 0x65, 0x6C, 0x6C, 0x6F]; // "Hello"
      final buffer = ByteBuffer.fromBytes(data);
      
      expect(buffer.length, 5);
      expect(buffer.getByte(0), 0x48);
      expect(buffer.getByte(4), 0x6F);
    });

    test('should set and get byte correctly', () {
      final buffer = ByteBuffer.fromBytes([0x00, 0x01, 0x02]);
      
      buffer.setByte(1, 0xFF);
      
      expect(buffer.getByte(1), 0xFF);
      expect(buffer.isModified, true);
      expect(buffer.isDirty(1), true);
    });

    test('should insert bytes correctly', () {
      final buffer = ByteBuffer.fromBytes([0x00, 0x01, 0x02]);
      
      buffer.insertBytes(1, [0xAA, 0xBB]);
      
      expect(buffer.length, 5);
      expect(buffer.getByte(1), 0xAA);
      expect(buffer.getByte(2), 0xBB);
      expect(buffer.getByte(3), 0x01);
    });

    test('should delete bytes correctly', () {
      final buffer = ByteBuffer.fromBytes([0x00, 0x01, 0x02, 0x03, 0x04]);
      
      buffer.deleteBytes(1, 3);
      
      expect(buffer.length, 3);
      expect(buffer.getByte(0), 0x00);
      expect(buffer.getByte(1), 0x03);
      expect(buffer.getByte(2), 0x04);
    });

    test('should get bytes range correctly', () {
      final buffer = ByteBuffer.fromBytes([0x00, 0x01, 0x02, 0x03, 0x04]);
      
      final bytes = buffer.getBytes(1, 4);
      
      expect(bytes.length, 3);
      expect(bytes[0], 0x01);
      expect(bytes[1], 0x02);
      expect(bytes[2], 0x03);
    });

    test('should throw error on invalid offset', () {
      final buffer = ByteBuffer.fromBytes([0x00, 0x01, 0x02]);
      
      expect(() => buffer.getByte(-1), throwsRangeError);
      expect(() => buffer.getByte(10), throwsRangeError);
    });

    test('should throw error on invalid byte value', () {
      final buffer = ByteBuffer.fromBytes([0x00, 0x01, 0x02]);
      
      expect(() => buffer.setByte(0, -1), throwsRangeError);
      expect(() => buffer.setByte(0, 256), throwsRangeError);
    });

    test('should clear modified flag', () {
      final buffer = ByteBuffer.fromBytes([0x00, 0x01, 0x02]);
      
      buffer.setByte(0, 0xFF);
      expect(buffer.isModified, true);
      
      buffer.clearModified();
      expect(buffer.isModified, false);
      expect(buffer.dirtyBytes.isEmpty, true);
    });

    test('should create copy correctly', () {
      final buffer = ByteBuffer.fromBytes([0x00, 0x01, 0x02]);
      buffer.setByte(0, 0xFF);
      
      final copy = buffer.copy();
      
      expect(copy.length, buffer.length);
      expect(copy.getByte(0), buffer.getByte(0));
      expect(copy.isModified, buffer.isModified);
    });

    test('should replace all data', () {
      final buffer = ByteBuffer.fromBytes([0x00, 0x01, 0x02]);
      
      buffer.replaceAll(Uint8List.fromList([0xAA, 0xBB, 0xCC, 0xDD]));
      
      expect(buffer.length, 4);
      expect(buffer.getByte(0), 0xAA);
      expect(buffer.getByte(3), 0xDD);
      expect(buffer.isModified, true);
    });
  });
}
