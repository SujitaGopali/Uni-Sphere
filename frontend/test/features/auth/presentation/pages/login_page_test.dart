import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:uni_sphere/core/error/failures.dart';
import 'package:uni_sphere/features/auth/domain/entities/auth_entity.dart';
import 'package:uni_sphere/features/auth/domain/usecases/login_usercase.dart';
import 'package:uni_sphere/features/auth/domain/usecases/logout_usecase.dart';
import 'package:uni_sphere/features/auth/domain/usecases/register_usecase.dart';
import 'package:uni_sphere/features/auth/presentation/pages/login_page.dart';
import 'package:uni_sphere/features/auth/presentation/view_model/auth_view_model.dart';

import '../../helpers/test_helper.mocks.dart';

void main() {
  late MockIAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockIAuthRepository();
  });

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        registerUseCaseProvider.overrideWith((ref) => RegisterUseCase(mockRepository)),
        loginUseCaseProvider.overrideWith((ref) => LoginUseCase(mockRepository)),
        logoutUseCaseProvider.overrideWith((ref) => LogoutUseCase(mockRepository)),
      ],
      child: MaterialApp(
        routes: {
          '/dashboard': (context) => const Scaffold(),
        },
        home: const LoginPage(),
      ),
    );
  }

  testWidgets('should display email and password fields', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.text('Email address'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
  });

  testWidgets('should call login when login button is pressed', (tester) async {
    const tAuthEntity = AuthEntity(
      name: 'Test', email: 'test@example.com', password: '', phone: '', address: ''
    );
    when(mockRepository.login(any, any)).thenAnswer((_) async => const Right(tAuthEntity));

    await tester.pumpWidget(createWidgetUnderTest());

    final emailField = find.byType(TextField).first;
    final passwordField = find.byType(TextField).last;

    await tester.enterText(emailField, 'test@example.com');
    await tester.enterText(passwordField, 'password123');

    final loginButton = find.byType(ElevatedButton);
    await tester.tap(loginButton);
    await tester.pump();

    verify(mockRepository.login('test@example.com', 'password123')).called(1);
  });

  testWidgets('should show SnackBar on login error', (tester) async {
    when(mockRepository.login(any, any))
        .thenAnswer((_) async => const Left(ApiFailure('Invalid Credentials')));

    await tester.pumpWidget(createWidgetUnderTest());

    await tester.enterText(find.byType(TextField).first, 'wrong@example.com');
    await tester.enterText(find.byType(TextField).last, 'wrong');

    await tester.tap(find.byType(ElevatedButton));
    await tester.pump(); 
    await tester.pump(); 

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Invalid Credentials'), findsOneWidget);
  });

  testWidgets('should toggle password visibility when icon is pressed', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    final passwordField = find.byType(TextField).last;
    expect(tester.widget<TextField>(passwordField).obscureText, isTrue);

    final visibilityButton = find.byIcon(Icons.visibility_off_outlined);
    expect(visibilityButton, findsOneWidget);

    await tester.tap(visibilityButton);
    await tester.pump();

    expect(tester.widget<TextField>(find.byType(TextField).last).obscureText, isFalse);
  });

  testWidgets('should navigate to sign up page when sign up link is clicked', (tester) async {
    bool navigated = false;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          registerUseCaseProvider.overrideWith((ref) => RegisterUseCase(mockRepository)),
          loginUseCaseProvider.overrideWith((ref) => LoginUseCase(mockRepository)),
          logoutUseCaseProvider.overrideWith((ref) => LogoutUseCase(mockRepository)),
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

    final signUpLink = find.text('Sign Up');
    await tester.tap(signUpLink);
    await tester.pumpAndSettle();

    expect(navigated, isTrue);
  });
}
