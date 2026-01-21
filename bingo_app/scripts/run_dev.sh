#!/bin/bash
flutter run -t lib/main_dev.dart \
  --dart-define=SUPABASE_URL=REDACTED \
  --dart-define=SUPABASE_ANON_KEY=REDACTED \
  --dart-define=RC_ANDROID_KEY=REDACTED \
  --dart-define=RC_IOS_KEY=REDACTED \
  --dart-define=CLARITY_PROJECT_ID=REDACTED \
  --dart-define=GEMINI_API_KEY=REDACTED \
  --dart-define=ENVIRONMENT=dev \
  --dart-define=ENABLE_DEBUG_LOGS=true
