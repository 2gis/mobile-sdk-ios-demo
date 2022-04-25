# iOS SDK

iOS SDK allows you to add a [2GIS map](https://2gis.ae/) to your iOS application. It can be used to display the map in your layout, add custom markers to it, draw geometric shapes, calculate and display routes, get information about map objects, control the camera movement, and so on.

You can find usage examples in the [Examples](/en/ios/sdk/examples) section. For a detailed description of all classes and methods, see [API Reference](/en/ios/sdk/reference).

Geodata complies with [OGC standards](https://en.wikipedia.org/wiki/Open_Geospatial_Consortium).

## Getting API keys

Usage of this SDK requires an API key to connect to 2GIS servers and retrieve the geographical data. This API key is unique to the SDK and cannot be used with other 2GIS SDKs.

Additionally, if you plan to draw routes on the map or get extra information about map objects, you will need a separate key - a Directory API key.

To obtain either of these API keys, fill in the form at [dev.2gis.com](https://dev.2gis.com/order/).

## System requirements

- Xcode 12+
- iOS 13.0+ / iPadOS 13.0+ (this SDK uses [SwiftUI](https://developer.apple.com/documentation/swiftui))

You can also use [xcframework](https://github.com/2gis/mobile-sdk-map-swift-package/blob/master/Package.swift) to build your project for iOS 12.

## Installation

To install this SDK, you need to add a package dependency to your project. See the [official documentation](https://developer.apple.com/documentation/swift_packages/adding_package_dependencies_to_your_app) for more information on using Swift packages.

iOS SDK is distributed in two versions: full and lite. The lite version does not include the routes and navigation functionality.

Specify one of the following URLs when adding a dependency to install the SDK:

- `https://github.com/2gis/mobile-sdk-map-swift-package` - to get the lite version.
- `https://github.com/2gis/mobile-sdk-full-swift-package` - to get the full version.

## Demo project

You can find a demo app with the source code in our [GitHub repository](https://github.com/2gis/mobile-sdk-ios-demo/).
