import 'package:cava_ecommerce/core/error/failures.dart';
import 'package:cava_ecommerce/core/firebase/firebase_config.dart';
import 'package:cava_ecommerce/features/account/data/datasources/auth_firebase_datasource.dart';
import 'package:cava_ecommerce/features/account/data/firebase/firebase_auth_gateway.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebaseAuthGateway extends Mock implements FirebaseAuthGateway {}

class MockUser extends Mock implements User {}

class MockUserCredential extends Mock implements UserCredential {}

void main() {
  late MockFirebaseAuthGateway authGateway;
  late FakeFirebaseFirestore firestore;
  late AuthFirebaseDataSource dataSource;
  late MockUser user;
  late MockUserCredential credential;

  setUpAll(() {
    registerFallbackValue(MockUser());
  });

  setUp(() {
    authGateway = MockFirebaseAuthGateway();
    firestore = FakeFirebaseFirestore();
    dataSource = AuthFirebaseDataSource(authGateway, firestore);
    user = MockUser();
    credential = MockUserCredential();

    when(() => user.uid).thenReturn('uid-1');
    when(() => user.email).thenReturn('user@cava.test');
    when(() => user.displayName).thenReturn('Urim');
    when(() => credential.user).thenReturn(user);
  });

  test('login returns mapped user', () async {
    when(
      () => authGateway.signInWithEmailAndPassword(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async => credential);

    final result = await dataSource.login(
      email: 'user@cava.test',
      password: 'secret12',
    );

    expect(result.uid, 'uid-1');
    expect(result.email, 'user@cava.test');
  });

  test('login maps firebase auth exception', () async {
    when(
      () => authGateway.signInWithEmailAndPassword(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenThrow(FirebaseAuthException(code: 'wrong-password'));

    expect(
      () => dataSource.login(email: 'user@cava.test', password: 'bad'),
      throwsA(
        isA<AuthFailure>().having(
          (failure) => failure.message,
          'message',
          'Email ose fjalëkalim i pasaktë.',
        ),
      ),
    );
  });

  test('register writes users doc with client role', () async {
    when(
      () => authGateway.createUserWithEmailAndPassword(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async => credential);
    when(
      () => authGateway.updateDisplayName(any(), any()),
    ).thenAnswer((_) async {});

    await dataSource.register(
      email: 'user@cava.test',
      password: 'secret12',
      name: 'Urim',
    );

    final doc = await firestore
        .collection(FirebaseConfig.usersCollection)
        .doc('uid-1')
        .get();

    expect(doc.exists, isTrue);
    expect(doc.data()?['email'], 'user@cava.test');
    expect(doc.data()?['name'], 'Urim');
    expect(doc.data()?['role'], 'client');
    expect(doc.data()?['status'], 'active');
  });

  test('forgotPassword delegates to gateway', () async {
    when(
      () => authGateway.sendPasswordResetEmail(email: any(named: 'email')),
    ).thenAnswer((_) async {});

    await dataSource.forgotPassword(email: 'user@cava.test');

    verify(
      () => authGateway.sendPasswordResetEmail(email: 'user@cava.test'),
    ).called(1);
  });

  test('logout delegates to gateway', () async {
    when(() => authGateway.signOut()).thenAnswer((_) async {});

    await dataSource.logout();

    verify(() => authGateway.signOut()).called(1);
  });
}
