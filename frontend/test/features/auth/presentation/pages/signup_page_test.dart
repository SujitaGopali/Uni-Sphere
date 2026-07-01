import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:uni_sphere/features/auth/domain/usecases/login_usercase.dart';
import 'package:uni_sphere/features/auth/domain/usecases/logout_usecase.dart';
import 'package:uni_sphere/features/auth/domain/usecases/register_usecase.dart';
import 'package:uni_sphere/features/auth/presentation/pages/signup_page.dart';
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
      child: const MaterialApp(
        home: SignupPage(),
      ),
    );
  }

  testWidgets('should display all input fields', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.byType(TextField), findsNWidgets(5));
    expect(find.text('Full Name'), findsOneWidget);
    expect(find.text('Student ID'), findsOneWidget);
    expect(find.text('Email address'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Confirm Password'), findsOneWidget);
  });

  testWidgets('should show error snackbar when student ID is empty', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Student ID is required'), findsOneWidget);
  });

  testWidgets('should show error snackbar when passwords do not match', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    final textFields = find.byType(TextField);
    await tester.enterText(textFields.at(0), 'John Doe');
    await tester.enterText(textFields.at(1), '123456');
    await tester.enterText(textFields.at(2), 'john@example.com');
    await tester.enterText(textFields.at(3), 'password123');
    await tester.enterText(textFields.at(4), 'password321');

    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Passwords do not match'), findsOneWidget);
  });

  testWidgets('should call register when all fields are valid', (tester) async {
    when(mockRepository.register(any)).thenAnswer((_) async => const Right(true));

    await tester.pumpWidget(createWidgetUnderTest());

    final textFields = find.byType(TextField);
    await tester.enterText(textFields.at(0), 'John Doe');
    await tester.enterText(textFields.at(1), '123456');
    await tester.enterText(textFields.at(2), 'john@example.com');
    await tester.enterText(textFields.at(3), 'password123');
    await tester.enterText(textFields.at(4), 'password123');

    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();
    await tester.pump();

    verify(mockRepository.register(any)).called(1);
  });

  testWidgets('should navigate to login page when login link is clicked', (tester) async {
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
            '/login': (context) {
              navigated = true;
              return const Scaffold();
            }
          },
          home: const SignupPage(),
        ),
      ),
    );

    final loginLink = find.text('Login');
    await tester.ensureVisible(loginLink);
    await tester.tap(loginLink);
    await tester.pumpAndSettle();

    expect(navigated, isTrue);
  });
}
