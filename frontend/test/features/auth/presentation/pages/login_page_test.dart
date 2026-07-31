import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:uni_sphere/features/auth/domain/entities/auth_entity.dart';
import 'package:uni_sphere/features/auth/domain/usecases/login_usercase.dart';
import 'package:uni_sphere/features/auth/domain/usecases/logout_usecase.dart';
import 'package:uni_sphere/features/auth/domain/usecases/register_usecase.dart';
import 'package:uni_sphere/features/auth/presentation/pages/login_page.dart';
import 'package:uni_sphere/features/auth/presentation/view_model/auth_view_model.dart';

import '../../helpers/test_helper.mocks.dart';

void main() {
  late MockIAuthRepository mockRepository;
  late MockAuthRemoteDataSource mockRemote;

  setUp(() {
    mockRepository = MockIAuthRepository();
    mockRemote = MockAuthRemoteDataSource();
  });

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        authRemoteDataSourceProvider.overrideWithValue(mockRemote),
        registerUseCaseProvider
            .overrideWith((ref) => RegisterUseCase(mockRepository)),
        loginUseCaseProvider
            .overrideWith((ref) => LoginUseCase(mockRepository)),
        logoutUseCaseProvider
            .overrideWith((ref) => LogoutUseCase(mockRepository)),
      ],
      child: MaterialApp(
        routes: {
          '/dashboard': (context) => const Scaffold(),
          '/landing': (context) => const Scaffold(),
          '/signup': (context) => const Scaffold(),
        },
        home: const LoginPage(),
      ),
    );
  }

  testWidgets('should display email and password fields', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.text('Email Address'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
  });

  testWidgets('should call login when sign in button is pressed', (tester) async {
    const tAuthEntity = AuthEntity(
      firstName: 'Test',
      lastName: 'User',
      email: 'test@example.com',
    );
    when(mockRemote.loginEntity(any, any))
        .thenAnswer((_) async => tAuthEntity);

    await tester.pumpWidget(createWidgetUnderTest());

    await tester.enterText(find.byType(TextField).first, 'test@example.com');
    await tester.enterText(find.byType(TextField).last, 'password123');

    await tester.tap(find.text('Sign in'));
    await tester.pump();

    verify(mockRemote.loginEntity('test@example.com', 'password123')).called(1);
  });

  testWidgets('should show SnackBar on login error', (tester) async {
    when(mockRemote.loginEntity(any, any))
        .thenThrow(Exception('Invalid Credentials'));

    await tester.pumpWidget(createWidgetUnderTest());

    await tester.enterText(find.byType(TextField).first, 'wrong@example.com');
    await tester.enterText(find.byType(TextField).last, 'wrong');

    await tester.tap(find.text('Sign in'));
    await tester.pump();
    await tester.pump();

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Invalid Credentials'), findsOneWidget);
  });

  testWidgets('should toggle password visibility when icon is pressed',
      (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    final passwordField = find.byType(TextField).last;
    expect(tester.widget<TextField>(passwordField).obscureText, isTrue);

    await tester.tap(find.byIcon(Icons.visibility_off_outlined));
    await tester.pump();

    expect(
      tester.widget<TextField>(find.byType(TextField).last).obscureText,
      isFalse,
    );
  });

  testWidgets('should navigate to sign up page when sign up link is clicked',
      (tester) async {
    bool navigated = false;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRemoteDataSourceProvider.overrideWithValue(mockRemote),
          registerUseCaseProvider
              .overrideWith((ref) => RegisterUseCase(mockRepository)),
          loginUseCaseProvider
              .overrideWith((ref) => LoginUseCase(mockRepository)),
          logoutUseCaseProvider
              .overrideWith((ref) => LogoutUseCase(mockRepository)),
        ],
        child: MaterialApp(
          routes: {
            '/signup': (context) {
              navigated = true;
              return const Scaffold();
            }
          },
          home: const LoginPage(),
        ),
      ),
    );

    await tester.tap(find.text('Sign Up'));
    await tester.pumpAndSettle();

    expect(navigated, isTrue);
  });
}
