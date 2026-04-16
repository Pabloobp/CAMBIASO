import 'package:dentalcare/core/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('registration and login validators', () {
    expect(Validators.name(''), isNotNull);
    expect(Validators.name('ab'), isNotNull);
    expect(Validators.name('Juan Pérez'), isNull);

    expect(Validators.email('a@b.'), isNotNull);
    expect(Validators.email('correo-invalido'), isNotNull);
    expect(Validators.email('cliente@dentalcare.com'), isNull);

    expect(Validators.phone('(+34) 612 345 678'), isNull);
    expect(Validators.phone('123'), isNotNull);
    expect(Validators.phone('612345678'), isNull);

    expect(Validators.password('12345678'), isNotNull);
    expect(Validators.password('dentalcare1'), isNotNull);
    expect(Validators.password('DENTAL123'), isNotNull);
    expect(Validators.password('Dental#1'), isNotNull);
    expect(Validators.password('Dental123'), isNull);
    expect(Validators.password('Aa123456'), isNull);
  });
}
