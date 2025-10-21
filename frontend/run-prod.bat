@echo off
REM Flutter 앱을 프로덕션 서버(Railway)로 실행
echo Starting Flutter app with PRODUCTION environment (Railway)...
flutter run -d windows --dart-define=ENV=prod
