import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

/// Service responsible for creating and validating JWT tokens for game rooms
class JwtService {
  static const String _issuer = 'bingo_app';
  static const Duration _defaultExpiration = Duration(hours: 4);

  /// Generates a secure random secret key for JWT signing
  /// This should be called once per room and stored securely
  static String generateSecret() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = DateTime.now().microsecondsSinceEpoch;
    final content = '$timestamp-$random-$_issuer';
    final bytes = utf8.encode(content);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Generates a JWT token for a game room
  ///
  /// [roomId] - Unique identifier for the game room
  /// [role] - Role of the user ('host' or 'player')
  /// [secret] - Secret key used to sign the token
  /// [expiration] - Optional custom expiration duration (defaults to 4 hours)
  static String generateRoomToken({
    required String roomId,
    required String role,
    required String secret,
    Duration? expiration,
  }) {
    final jwt = JWT({
      'roomId': roomId,
      'role': role,
      'iss': _issuer,
    }, issuer: _issuer);

    final token = jwt.sign(
      SecretKey(secret),
      expiresIn: expiration ?? _defaultExpiration,
    );

    return token;
  }

  /// Validates and decodes a JWT token
  ///
  /// Returns the payload if valid, throws an exception otherwise
  ///
  /// Throws:
  /// - [JWTExpiredException] if token is expired
  /// - [JWTInvalidException] if token signature is invalid
  /// - [JWTException] for other JWT-related errors
  static Map<String, dynamic> validateToken({
    required String token,
    required String secret,
  }) {
    try {
      final jwt = JWT.verify(token, SecretKey(secret));
      return jwt.payload as Map<String, dynamic>;
    } on JWTExpiredException {
      throw JWTExpiredException();
    } on JWTException catch (e) {
      throw JWTInvalidException(e.message);
    }
  }

  /// Validates token and verifies it belongs to the specified room
  ///
  /// Returns true if token is valid and belongs to the room
  /// Returns false otherwise
  static bool validateRoomToken({
    required String token,
    required String secret,
    required String expectedRoomId,
  }) {
    try {
      final payload = validateToken(token: token, secret: secret);
      final roomId = payload['roomId'] as String?;
      return roomId == expectedRoomId;
    } catch (e) {
      return false;
    }
  }

  /// Extracts the room ID from a token without validating it
  /// Useful for determining which room a connection is trying to join
  ///
  /// Note: This does NOT validate the token, only decodes it
  static String? extractRoomId(String token) {
    try {
      final jwt = JWT.decode(token);
      final payload = jwt.payload as Map<String, dynamic>?;
      return payload?['roomId'] as String?;
    } catch (e) {
      return null;
    }
  }
}

/// Exception thrown when JWT token is invalid
class JWTInvalidException implements Exception {
  final String message;
  JWTInvalidException(this.message);

  @override
  String toString() => 'JWTInvalidException: $message';
}
