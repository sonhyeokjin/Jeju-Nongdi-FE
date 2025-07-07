import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:jejunongdi/core/models/auth_models.dart';

part 'auth_api.g.dart';

@RestApi(baseUrl: "https://jeju-nongdi-be.onrender.com/api")
abstract class AuthApi {
  factory AuthApi(Dio dio, {String baseUrl}) = _AuthApi;

  @POST("/auth/signup")
  Future<AuthResponse> signup(@Body() SignupRequest request);

  @POST("/auth/login")
  Future<AuthResponse> login(@Body() LoginRequest request);

  @GET("/auth/profile")
  Future<User> getCurrentUser();
}
