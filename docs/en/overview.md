# iOS SDK

> **Warning**  
> **iOS SDK is under development.** It is not ready for production usage.

iOS SDK allows you to add a [2GIS map](https://2gis.ae/) to your iOS application. It can be used to display the map in your layout, add custom markers to it, draw geometric shapes, calculate and display routes, get information about map objects, control the camera movement, and so on.

You can find usage examples in the [Examples](/en/ios/sdk/examples) section. For a detailed description of all classes and methods, see [API Reference](/en/ios/sdk/reference).

## Getting API keys

Usage of this SDK requires an API key to connect to 2GIS servers and retrieve the geographical data. This API key is unique to the SDK and cannot be used with other 2GIS SDKs.

Additionally, if you plan to draw routes on the map or get extra information about map objects, you will need a separate key - a Directory API key.

To obtain either of these API keys, fill in the form at [dev.2gis.com](https://dev.2gis.com/order/).

## System requirements

- Xcode 12+
- iOS 13.0+ / iPadOS 13.0+ (this SDK uses [SwiftUI](https://developer.apple.com/documentation/swiftui))

You can also use [xcframework](https://github.com/2gis/native-sdk-ios-swift-package/blob/master/Package.swift) to build your project for iOS 12.

## Installation

To install this SDK, add a package dependency to your project, specifying `https://github.com/2gis/native-sdk-ios-swift-package` as the URL.

You can find more information about using Swift packages in the [official documentation]((https://developer.apple.com/documentation/swift_packages/adding_package_dependencies_to_your_app)).

## Demo project

You can find a demo app with the source code in our [GitHub repository](https://github.com/2gis/native-sdk-ios-demo/).
