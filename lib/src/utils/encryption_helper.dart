import 'dart:convert';
import 'package:encrypt/encrypt.dart';

class EncryptionHelper {
  static const String _key = 'clippybara_secure_key_32_bytes_!!!'; // 32 chars
  late final Key _encryptionKey;
  late final IV _iv;
  late final Encrypter _encrypter;

  EncryptionHelper() {
    _encryptionKey = Key.fromUtf8(_key);
    _iv = IV.fromLength(16);
    _encrypter = Encrypter(AES(_encryptionKey));
  }

  Future<List<int>> encrypt(String data) async {
    final encrypted = _encrypter.encrypt(data, iv: _iv);
    return encrypted.bytes;
  }

  Future<String> decrypt(List<int> data) async {
    final encrypted = Encrypted(data);
    return _encrypter.decrypt(encrypted, iv: _iv);
  }
}
