import 'package:chat/src/services/encryption/encrytion_service_contract.dart';
import 'package:encrypt/encrypt.dart';

class EncryptionService implements IEncryptionService {
  final Encrypter _encrypt; //  Encrypter
  final _iv = IV.fromLength(16); //  Encrypter lenght
  EncryptionService(this._encrypt);
  @override
  String dencrypt(String decryptedText) {
    final encrypted = Encrypted.from64(decryptedText); // encrypted text
    return _encrypt.decrypt(encrypted, iv: _iv); //  decrypted text
  }

  @override
  String encrypt(String text) {
    return _encrypt.encrypt(text, iv: _iv).base64; // encrypted text
  }
}
