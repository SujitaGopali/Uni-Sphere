import 'package:mockito/annotations.dart';
import 'package:uni_sphere/features/auth/data/datasources/remote/auth_remote_datasource.dart';
import 'package:uni_sphere/features/auth/domain/repositories/auth_reposity.dart';

@GenerateMocks([IAuthRepository, AuthRemoteDataSource])
void main() {}
