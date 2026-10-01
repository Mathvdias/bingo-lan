import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

/// Service responsible for creating and validating JWT tokens for game rooms
class JwtService {
  static const String _issuer = 'bingo_app';
  static const Duration _defaultExpiration = Duration(hours: 4);

  static final Random _secureRandom = Random.secure();

  /// Secret aleatório por sala (não usar timestamp como fonte de entropia).
  static String generateSecret() {
    final bytes = Uint8List.fromList(
      List<int>.generate(32, (_) => _secureRandom.nextInt(256)),
    );
    return sha256.convert(bytes).toString();
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
      final jwt = JWT.verify(token, SecretKey(secret), issuer: _issuer);
      return jwt.payload as Map<String, dynamic>;
    } on JWTExpiredException {
      throw JWTExpiredException();
    } on JWTException catch (e) {
      throw JWTInvalidException(e.message);
    }
  }

  /// Validates token and verifies it belongs to the specified room
  ///
  /// Checks signature, expiration and issuer; when [expectedRole] is given the
  /// `role` claim must match it (e.g. `'player'`).
  ///
  /// Returns true if token is valid and belongs to the room
  /// Returns false otherwise
  static bool validateRoomToken({
    required String token,
    required String secret,
    required String expectedRoomId,
    String? expectedRole,
  }) {
    try {
      final payload = validateToken(token: token, secret: secret);
      final roomId = payload['roomId'] as String?;
      if (roomId != expectedRoomId) return false;
      if (expectedRole != null && payload['role'] != expectedRole) {
        return false;
      }
      return true;
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
