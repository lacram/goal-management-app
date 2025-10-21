@echo off
REM Flutter 앱을 개발 서버(192.168.0.11:8080)로 실행
echo Starting Flutter app with DEV environment (192.168.0.11:8080)...
flutter run -d windows --dart-define=ENV=dev
