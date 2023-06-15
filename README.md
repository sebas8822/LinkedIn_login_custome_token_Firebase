# Flutter LinkedIn Authentication with Firebase

This is a Flutter project that demonstrates how to integrate LinkedIn authentication with Firebase in a Flutter app. It allows users to sign in with their LinkedIn accounts and saves their profile information in Firebase.

## Getting Started

To get started with this project, follow the steps below.

### Prerequisites

- Flutter SDK: Follow the [Flutter installation guide](https://flutter.dev/docs/get-started/install) to set up Flutter on your machine.
- LinkedIn Developer Account: Create a developer account on [LinkedIn Developers](https://www.linkedin.com/developers/) and create a new app to obtain the necessary credentials.
- Firebase Project: Set up a project on [Firebase](https://firebase.google.com/) and configure the necessary services (Firebase Authentication and Cloud Firestore).

### Installation

1. Clone the repository:

   ```bash
   git clone https://github.com/your-username/flutter-linkedin-auth-firebase.git

 2. Configure LinkedIn API credentials:
    - Create a new app on LinkedIn Developers.
    - Obtain the following credentials from your LinkedIn app page:
      - Client ID
      - Client Secret
      - Authorized redirect URLs for your app
    - Replace YOUR_CLIENT_ID, YOUR_CLIENT_SECRET, and YOUR_REDIRECT_URI with the obtained credentials.
    - The YOUR_REDIRECT_URI should be a URL where LinkedIn will redirect the user after authentication. For local development, you can use http://localhost:52138/auth.html.
        Configure auth.html in the web directory of your Flutter project to handle the callback. link: https://learn.microsoft.com/en-us/linkedin/shared/authentication/client-credentials-flow?context=linkedin%2Fcontext / Link: https://learn.microsoft.com/en-us/linkedin/shared/authentication/authorization-code-flow?context=linkedin%2Fcontext&tabs=HTTPS1 

  3. Configure OAuth 2.0 Scopes:
      - Decide which permissions (scopes) your app needs from the user's LinkedIn account.
      - Refer to the LinkedIn API documentation for available scopes and their descriptions. 

  5. Configure Firebase credentials:
      - Set up a project on Firebase if you haven't already.
      - Enable Firebase Authentication and Cloud Firestore services for your project.
      - Follow the Firebase documentation to obtain the necessary credentials, such as the google-services.json file.
      - Place the google-services.json file in the android/app directory of your Flutter project. Link: https://firebase.google.com/docs/auth/admin/create-custom-tokens

  6. Configure IAM Service Account Credentials API:
    - Enable the IAM Service Account Credentials API for your Firebase project:
      - Go to the Google Cloud Console.
      - Select your Firebase project.
      - Search for "IAM Service Account Credentials API" and enable it.

  7. Deploy Functions to Create Custom Token:
      - Follow the Firebase documentation on creating custom tokens using the Admin SDK.
      - Choose the appropriate method for your use case, such as letting the Admin SDK discover a service account and allowing unauthenticated calls.
      - If you need authenticated calls, ensure that you make HTTP calls with authentication.
      - Deploy function custom_token_generation_cloud_function.py Google cloud or fuctions firebase an allow unautenticated calls, if you require authenticated call you need to do additionals steps to do it check google cloud documentation.

## Usage
Launch the app on your device or emulator.
Tap the "Login with LinkedIn" button on the screen.
You will be redirected to the LinkedIn authorization page. Enter your LinkedIn credentials and grant access to the app.
After successful authentication, your LinkedIn profile information will be displayed on the screen.

## Troubleshooting

If you encounter any issues during the setup or while running the app, make sure you have followed all the steps correctly and check the Auth Flow frm Linkedin Auth 2.0 and Auth firebase or don't hesitate to reach me

## Data Flow and Pictures
![Alt Text](https://lh3.googleusercontent.com/pw/AJFCJaUHJVHAm71WooHE2WJojBqayVw7jTccRHMIGbzCVEoruhg1gVIuRRGL_wDSpPhYBrCzfoVYXdkefbI3TiB6R6-yjgVzZAKENOK7GFpgpfT5o9rw2oTbDNqKc6k6g28uuDwIC-nhv1TmK4GQWxo6sDcxaA=w1090-h886-s-no?authuser=0)
![Alt Text](https://lh3.googleusercontent.com/pw/AJFCJaXU3owKMkoxnGP2ZNQN24s8-Na_q9y3mVVepSGnl44nD4Pw6Q9OcvcF0_BpCZHodc_dFz2wiYRlYeUvtoXX_dCibqwHQ2cNx6niQenz538nPaFr-8i37GT0avOvouqC2aAHACY0YzjFOQozHlG0IdltMg=w1570-h695-s-no?authuser=0)
![Alt Text](https://lh3.googleusercontent.com/pw/AJFCJaWvGEvAQ-wu2GLN-v8MZHJhEuPIUBV7YxKTNs8XXRsJaCIYbM6O8WusAI7hPxdRfIu5t59AUbei7trQkKnrO1wgUR8WDiqxM69r6gmPRYzxvdeynPrqtCIQ13BjyciF6ILZ_WN0Eey6nCV-0_mLzC0Hhw=w1378-h803-s-no?authuser=0)


