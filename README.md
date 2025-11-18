# README #

DriveAZ-IOS

### What is this repository for? ###
 
DriveAZ-IOS is an iOS application for logging iPhone location/time/acceleration and other parameters in the .tsm format.
The app can automatically detect when the user is moving at different speeds and infer the user is walking/bicycling/in a car, based on that speed.  
Because iOS is incapable of transmitting and receiving a Personal Safety Message (PSM) using Bluetooth LE technology, the app will be enhanced in the future to send PSMs by LTE.

### How do I get set up? ###

1. cp `DriveAZ/sample.xcconfig` to `DriveAZ/config.xcconfig` and update tokens and passwords
1. `sudo gem install cocoapods`
1. `gem install cocoapods-art`
1. `pod repo-art add b2v-ios-extras https://b2v.jfrog.io/artifactory/api/pods/b2v-ios-extras`
1. `pod repo-art add b2v-ios-extras-swift https://b2v.jfrog.io/artifactory/api/pods/b2v-ios-extras-swift`
1. Create/Update `~/.netrc` to contain the following
```
machine b2v.jfrog.io
login <ARTIFACTORY_USERNAME_OR_SERVICE_USER>
  password <ARTIFACTORY_API_TOKEN>
```
5: `pod install` 
5.1: If `pod install` fails, you may need to first comment out lines 15-20 of the Podfile (lines related to `b2v-ios-extras`) and run `pod install` once before adding those lines back and running `pod install` again

* Configuration  
The app code is pre-configured.
* Dependencies  
DriveAZ-IOS uses a number of cocoapods, listed in `DriveAZ/Podfile`

### Testing
There are a number of tests for the app in `DriveAZ/DriveAZTests` and `DriveAZ/DriveAZUITests`

### Who do I talk to? ###

ben.willshire@valtech.com is the original author; rich.rarey@valtech.com is the nominal owner
