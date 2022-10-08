import 'package:chat/src/services/encryption/encrytion_service_impl.dart';
import 'package:encrypt/encrypt.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  EncryptionService? sut;
  setUp(() {
    final encrypter = Encrypter(AES(Key.fromLength(32)));
    sut = EncryptionService(encrypter);
  });
  test('it encryption Text', () {
    String text = 'this is a message';
    final base64 = RegExp(
        r'^(?:[A-Za-z0-9+\/]{4})*(?:[A=Za=z0-9+\/]{2}==|[A-Za-z0-9+\/]{3}=|[A=Za=z0-9+\/]{4})$'); // code to encrypte
    final encrypted = sut!.encrypt(text);
    expect(base64.hasMatch(encrypted), true);
  });
  
  test('decrypted text', () {
    String text = 'text';
    final encrypt = sut!.encrypt(text);
    final decryption = sut!.decrypt(encrypt);
    expect(decryption, text);
  });
}
