# Zoom VideoSDK Flutter Demo

Use of this sample app is subject to our [Terms of Use](https://explore.zoom.us/en/video-sdk-terms/).

A Flutter application demonstrating integration with the Zoom Video SDK for creating video conferencing capabilities in a mobile application.

![](screenshot.png)

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

3. Run the application:
   ```
   flutter run
   ```
## CLI Token Generator
For development and testing, a Dart CLI script is provided to generate JWT tokens:

1. Setup (one-time):
   ```bash
   cd scripts
   dart pub get
   ```

2. Create a `.env` file in the project root with your credentials:
   ```
   SDK_KEY=your_sdk_key_here
   SDK_SECRET=your_sdk_secret_here
   ```

3. Generate tokens:
   ```bash
   # Basic usage
   dart run scripts/generate_token.dart "Session Name" --copy-to-clipboard

   Replace "Session Name" with the name of the session you want to join.
   The token will be printed to the console.
   Copy the token and paste it into the JWT token field in the application.
   Click the "Start Session" button to join the session.

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
