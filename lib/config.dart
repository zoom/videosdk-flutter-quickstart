// Disclaimer: Do not store your app key and secret in your app in production. Use a server to generate tokens instead.
// These are used to generate JWTs.
// THIS IS NOT A SAFE OPERATION TO DO IN YOUR APP IN PRODUCTION.
// JWTs should be provided by a backend server as they require a secret
// WHICH IS NOT SAFE TO STORE ON DEVICE!
const Map config = {
  'ZOOM_SDK_KEY': '',
  'ZOOM_SDK_SECRET': '',
};

const Map sessionDetails = {
  'sessionName': 'Test',
  'sessionPassword': '',
  'displayName': 'Flutter',
  'sessionTimeout': '40',
  'roleType': '1',
};
