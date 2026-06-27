@echo off
echo ================================================
echo  Starting Flutter on http://localhost:8080
echo ================================================
flutter run -d web-server --web-port 8080 --web-hostname 0.0.0.0
pause