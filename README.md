# Zoom VideoSDK Flutter Demo

Use of this sample app is subject to our [Terms of Use](https://explore.zoom.us/en/video-sdk-terms/).

A Flutter application demonstrating integration with the Zoom Video SDK for creating video conferencing capabilities in a mobile application.

## Prerequisites

- Flutter SDK (^3.6.1)
- Dart SDK (^3.6.1)
- Zoom Video SDK account and credentials
- iOS 12.0+ / Android API level 21+

## Dependencies

- `flutter_zoom_videosdk: ^1.14.0` - Zoom Video SDK Flutter plugin
- `dart_jsonwebtoken: ^2.17.0` - For JWT token generation

## Setup

1. Clone the repository:
   ```
   git clone https://github.com/zoom/VideoSDK-flutter-quickstart
   cd VideoSDK-flutter-quickstart
   ```

2. Install dependencies:
   ```
   flutter pub get
   ```

3. Configure your Zoom SDK credentials:
   - Open `lib/config.dart`
   - Replace the placeholder values with your Zoom SDK Key and Secret:
     ```dart
     const Map configs = {
       'ZOOM_SDK_KEY': 'your_zoom_sdk_key',
       'ZOOM_SDK_SECRET': 'your_zoom_sdk_secret',
     };
     ```
     > **Disclaimer**: It's not recommended to store your credentials in the source code. This is only for demonstration purposes for sake of simplicity. You should use a secure backend to generate the token and pass it to the client.
   - Customize the session details as needed:
     ```dart
     const Map sessionDetails = {
       'sessionName': 'YourSessionName',
       'sessionPassword': '',
       'displayName': 'YourDisplayName',
       'sessionTimeout': '40',
       'roleType': '1',
     };
     ```

4. Run the application:
   ```
   flutter run
   ```

## Project Structure

- `lib/main.dart` - Application entry point and Zoom SDK initialization
- `lib/videochat.dart` - Main video chat interface and functionality
- `lib/config.dart` - Configuration for Zoom SDK and session details
- `lib/utils/jwt.dart` - JWT token generation for Zoom authentication

- If you encounter issues with the Zoom SDK, ensure your credentials are correct and that your Zoom account has the necessary permissions.

## License

This project is for demonstration purposes. Ensure you comply with Zoom's terms of service when using their SDK.

## Resources

- [Zoom Video SDK Documentation](https://developers.zoom.us/docs/video-sdk/flutter/)
- [Flutter Documentation](https://docs.flutter.dev/)
