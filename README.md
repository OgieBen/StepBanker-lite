# step_banker_lite

This is a demo Flutter application that allows a user to track daily steps using the Flutter Pedometer plugin (https://pub.dev/packages/pedometer).

## How to run the app
Open the project in Android Studio then run the command below to install project dependencies.

```bash
  flutter pub get
```

After installing the dependencies you can now run in Android studio.dependencies

## Using the app.

To test this app you will need an Android device. Using an Android device is the most convenient way of
if you do not have an apple developer account.

Connect the device to Android studio, run the app, grant the required permission then try to take some steps away from your initial position.
You will see the app update the button at the center of the screen with your latest step count for the day.

![App Screenshot](/images/app_screenshot.png)

Click the button at the center of the screen to save you steps.

After clicking the button on the screen to bank the steps, you can find the list of the stored records here by calling this API: https://step-banker-lite.herokuapp.com/api/v1/users/steps