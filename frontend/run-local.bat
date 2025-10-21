@echo off
REM Flutter 앱을 로컬 서버(localhost:8080)로 실행
echo Starting Flutter app with LOCAL environment (localhost:8080)...
flutter run -d windows --dart-define=ENV=local
