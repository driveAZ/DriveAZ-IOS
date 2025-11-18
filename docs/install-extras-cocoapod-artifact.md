# Install b2v-ios-extras as a Cocoapod artifact
2023-04-17T18:57:11Z

## Overview
Valtech Detroit maintains an online jFrog Artifactory at `b2v.jfrog.io` for distribution of our Android libraries and iOS libraries.

## Summary
This document describes the process to set up your local machine to access b2v-ios-extras from the jFrog Artifactory for your Xcode projects, so you don't have to expend energy maintaining a local Extras repo, or using git submodules, or worrying about Extras branches and such.

The process is this:
1. Install Cocoapod and the cocoapod-art plugin (only need do this once).
1. Install the Extras .specs file from artifactory (only need to do this once*).
1. Make your Xcode project aware of Extras (only need to do this once*).
1. Install the actual Extras binary and header files for Xcode to use.

*When new versions of Extras are deployed to artifactory, you'll need to update the .specs(local version cache)


## Install cocoapods and jFrog's cocoapods-art plugin
Artifactory uses some slightly nonstandard cocopods stuff, so it needs it's own module.

You will need to install `cocoapods` and the `cocoapods-art` plugin.
```
gem install cocoapods cocoapods-art
```


## Add the b2v-ios-extras repository to your local machine
Cocoapods maintains a list of repos in `~/.cocoapods/`
Cocoapods stores `.spec` files for each package in the repo so you know what versions of a package are available.

To add the b2v-ios-extras repo to your local repo list, run:
```
pod repo-art add b2v-ios-extras https://b2v.jfrog.io/artifactory/api/pods/b2v-ios-extras
```
(Optional) Confirm b2v-ios-extras has been added by running: `pod repo-art list`


### Update local version cache
When a new version is published, your local cocoapods won't know about it and you must update your local cache of .spec files:
```
pod repo-art update b2v-ios-extras --prune

```
`--prune` will make things deleted from artifactory go away, by default `pod repo-art update` is an accumulative operation, meaning that it does not remove entries which do not exist in the Artifactory backend in order to preserve entries that were created with the `--local-only` flag.


### Remove repo
This removes Extras cocoapods repo from your local computer.
This affects **all** projects that rely on b2v-ios-extras.
```
pod repo-art remove b2v-ios-extras
pod repo remove b2v-ios-extras
```



## Make your Xcode project use b2v-ios-extras
In this section we will create the Podfile, and add info so cocoapod can find the actual b2v-ios-extras library code.

1. In the Xcode project's directory, run `pod init`
  This will create and populate a file named `Podfile`.
2. Edit `Podfile` and insert this line at the top:
  ```
  plugin 'cocoapods-art', :sources => [
    'b2v-ios-extras'
    ]
  ```
In the section `target 'your-project-name-here' do`, insert this line:
  ```
  pod 'b2v-ios-extras', '= 0.0.1'
  ```
  Change the version to match whatever version you want.
  See this [cocoapod guide](https://guides.cocoapods.org/using/the-podfile.html) for version syntax.

Here's an example Podfile with comments added for clarity.
```
# Podfile for an Xcode project called "Testy"
# Cocoapod generates the boilerplace when 'pod init' is run.

# This alerts cocoapod that we're using Extras from a jFrog Artifactory
plugin 'cocoapods-art', :sources => ['b2v-ios-extras']

# Uncomment the next line to define a global platform for your project
platform :ios, '12.0'

target 'Testy' do
  # Pods for Testy

  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # This tells cocoapod we're using the highest available Extras version,
  # up to and including v0.0.1.
  # Reference: https://guides.cocoapods.org/using/the-podfile.html
  pod 'b2v-ios-extras', '<= 0.0.1'

  target 'TestyTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'TestyUITests' do
    # Pods for testing
  end

end
```

## Install the b2v-ios-extras binary and headers for your project
Up to now, no code has been added to your project directory, just specifying what version to get.
To actually install the dependencies, run
```
pod install
```

When the installation is successful for the first time, an .xcworkspace file is created, and you will see this message scroll by:
```
[!] Please close any current Xcode sessions and use 'your-projec-name.xcworkspace' for this project from now on.
```

The .xcworkspace file contains information about the Extras Cocoapod, and any additional Cocoapods you you have installed in the project.
If you inadvertently load the .xcodeproj into Xcode in the future, you may be confused and saddened by the numerous errors and warnings.
Just exit Xcode and load the .xcworkspace file.


## Further reading
* Cocapod installation reference: [https://guides.cocoapods.org/using/getting-started.html](https://guides.cocoapods.org/using/getting-started.html)
* Specifying different b2v-ios-extras versions in Podfile: [https://guides.cocoapods.org/using/the-podfile.html](https://guides.cocoapods.org/using/the-podfile.html)
* Ruby installation info: [https://mac.install.guide/ruby/index.html](https://mac.install.guide/ruby/index.html)
* This [reference](https://mac.install.guide/faq/do-not-use-mac-system-ruby/index.html) discourages the use of the Mac system Ruby for the tasks in this document, and suggests installing another Ruby and gem for development purposes.

