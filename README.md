# CWCoreData

[![CI Status](http://img.shields.io/travis/Chris Wunsch/CWCoreData.svg?style=flat)](https://travis-ci.org/Chris Wunsch/CWCoreData)
[![Version](https://img.shields.io/cocoapods/v/CWCoreData.svg?style=flat)](http://cocoapods.org/pods/CWCoreData)
[![License](https://img.shields.io/cocoapods/l/CWCoreData.svg?style=flat)](http://cocoapods.org/pods/CWCoreData)
[![Platform](https://img.shields.io/cocoapods/p/CWCoreData.svg?style=flat)](http://cocoapods.org/pods/CWCoreData)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

This library requires to following:

<ul>
<li>Xcode 5.0+</li>
<li>iOS 7.0+</li>
<li>Arc must be enabled.</li>
</ul>

## Installation

CWCoreData is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "CWCoreData"
```

## Author

Minty Water Ltd

Chris Wunsch, chris@mintywater.co.uk

## License

CWCoreData is available under the MIT license. See the LICENSE file for more info.

## Contribute

We accept pull requests!

## Usage

The library is very easy to use, the only setup code you need is to tell it what the name of your xcdatamodeld is, if you are using cocoapods you must also import the module, see the sample code below:

```swift
/// If using CocoaPods
import CWCoreData

/// Tell the framework what your xcdatamodeld is called, if you forgot this the framework will raise an exception:
CoreDataStack.defaultStack.dataBaseName = "YOU_DATABASE_NAME"

```