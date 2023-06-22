# push_notification

A new Flutter project.

## App configuration for firebase push notification:
- Create firebase  Project for individual project

- set up and change (optional) package name : The package name will be available in the ./android/app/build.gradle file of your Flutter project.

- After register:  google-services.json file which will link our Flutter app to Firebase Google services. We need to download the file and move it to the ./android/app directory of our Flutter project.

- Add Firebase Configurations to Native Files in your Flutter Project: root-level (project-level) Gradle file (android/build.gradle), we need to add rules to include the Google Services Gradle plugin.
```
buildscript {
    repositories {
        // Check that you have the following line (if not, add it):
        google()  // Google's Maven repository
    }
    dependencies {
    ...
        // Add this line
        classpath 'com.google.gms:google-services:4.3.4'
    }
    }
    allprojects {
        ...
        repositories {
        // Check that you have the following line (if not, add it):
        google()  // Google's Maven repository
        ...
    }
}
```
- (app-level) Gradle file (android/app/build.gradle), we need to apply the Google Services Gradle plugin.
```
// Add the following line:
  **apply plugin: 'com.google.gms.google-services'**  // Google Services plugin
```

- Integrate Firebase Messaging with Flutter: add the firebase-messaging dependency to the ./android/app/build.gardle file.
```
dependencies {
    //add this line
    implementation platform('com.google.firebase:firebase-bom:32.1.0')
    implementation 'com.google.firebase:firebase-analytics-ktx'
    implementation "org.jetbrains.kotlin:kotlin-stdlib-jdk7:$kotlin_version"
}
root level build.gradle
    dependencies {
    //add this
    classpath 'com.google.gms:google-services:4.3.15'
}
```

- minsdkversion should be 19

- these permissions need to be there in android manifest file
```
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.WAKE_LOCK" />
```

- for building default notification channel this should be inside android manifest
```
<meta-data
android:name="com.google.firebase.messaging.default_notification_channel_id"
android:value="high_importance_channel" />
```

- for giving icon to push notification ./android/app/src/main/res inside that extract icon and put it in res folder and it is responsible for giving icon to push notification

## Functionality package provide:
- request permission
- getDeviceToken
- tokenRefesh if expire
- foreground notification
- background notification
- Interact with notification after click switch to some page
- subscribe notification related to particular topic
- unsubscribe from topic
- customising banner of push notification


## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.