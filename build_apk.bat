@echo off
echo ========================================
echo Building Speech Therapy APK for Testing
echo ========================================

echo Step 1: Cleaning project...
flutter clean

echo Step 2: Getting dependencies...
flutter pub get

echo Step 3: Building APK...
flutter build apk --debug

echo ========================================
echo Build completed!
echo APK location: build\app\outputs\flutter-apk\app-debug.apk
echo ========================================
pause