import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer';

/// Service responsible for managing Supabase client and database operations
class SupabaseService {
  static SupabaseClient? _client;

  /// Initialize Supabase client
  static Future<void> initialize({
    required String supabaseUrl,
    required String supabaseAnonKey,
  }) async {
    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
    _client = Supabase.instance.client;
    log('Supabase initialized successfully');
  }

  /// Get Supabase client instance
  static SupabaseClient get client {
    if (_client == null) {
      throw Exception('Supabase not initialized. Call initialize() first.');
    }
    return _client!;
  }

  /// Sync Firebase user to Supabase
  static Future<void> syncUser({
    required String firebaseUid,
    String? email,
    String? displayName,
    String? photoUrl,
    String? provider,
    String? revenuecatUserId,
  }) async {
    try {
      await client.from('users').upsert({
        'firebase_uid': firebaseUid,
        'email': email,
        'display_name': displayName,
        'photo_url': photoUrl,
        'provider': provider,
        'revenuecat_user_id': revenuecatUserId,
        'last_seen': DateTime.now().toIso8601String(),
      }, onConflict: 'firebase_uid');

      log('User synced to Supabase: $firebaseUid');
    } catch (e) {
      log('Error syncing user to Supabase: $e');
      rethrow;
    }
  }

  /// Get user data from Supabase by Firebase UID
  static Future<Map<String, dynamic>?> getUserByFirebaseUid(
    String firebaseUid,
  ) async {
    try {
      final response = await client
          .from('users')
          .select()
          .eq('firebase_uid', firebaseUid)
          .maybeSingle();

      return response;
    } catch (e) {
      log('Error getting user from Supabase: $e');
      rethrow;
    }
  }

  /// Update user preferences
  static Future<void> updatePreferences({
    required String userId,
    bool? notificationsEnabled,
    int? notificationsPerDay,
    DateTime? notificationStartTime,
    DateTime? notificationEndTime,
    Map<String, dynamic>? themeSettings,
    Map<String, dynamic>? gameSettings,
  }) async {
    try {
      final data = <String, dynamic>{
        'user_id': userId,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (notificationsEnabled != null) {
        data['notifications_enabled'] = notificationsEnabled;
      }
      if (notificationsPerDay != null) {
        data['notifications_per_day'] = notificationsPerDay;
      }
      if (notificationStartTime != null) {
        data['notification_start_time'] = notificationStartTime
            .toIso8601String();
      }
      if (notificationEndTime != null) {
        data['notification_end_time'] = notificationEndTime.toIso8601String();
      }
      if (themeSettings != null) data['theme_settings'] = themeSettings;
      if (gameSettings != null) data['game_settings'] = gameSettings;

      await client.from('preferences').upsert(data, onConflict: 'user_id');

      log('Preferences updated for user: $userId');
    } catch (e) {
      log('Error updating preferences: $e');
      rethrow;
    }
  }

  /// Log analytics event to Supabase
  static Future<void> logEvent({
    required String userId,
    required String eventName,
    Map<String, dynamic>? eventParams,
    String? screenName,
  }) async {
    try {
      await client.from('analytics_events').insert({
        'user_id': userId,
        'event_name': eventName,
        'event_params': eventParams,
        'screen_name': screenName,
        'created_at': DateTime.now().toIso8601String(),
      });

      log('Event logged: $eventName');
    } catch (e) {
      log('Error logging event: $e');
      // Don't rethrow - analytics failures shouldn't break the app
    }
  }

  /// Save game history
  static Future<void> saveGameHistory({
    required String userId,
    required String roomId,
    required String role,
    required DateTime startedAt,
    DateTime? endedAt,
    int? playersCount,
    bool completed = false,
  }) async {
    try {
      await client.from('game_history').insert({
        'user_id': userId,
        'room_id': roomId,
        'role': role,
        'started_at': startedAt.toIso8601String(),
        'ended_at': endedAt?.toIso8601String(),
        'players_count': playersCount,
        'completed': completed,
      });

      log('Game history saved for room: $roomId');
    } catch (e) {
      log('Error saving game history: $e');
      rethrow;
    }
  }
}
