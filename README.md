
# react-native-camera-roll-media

## Getting started

`$ npm install react-native-camera-roll-media --save`

### Mostly automatic installation

`$ react-native link react-native-camera-roll-media`

### Manual installation


#### iOS

1. In XCode, in the project navigator, right click `Libraries` ➜ `Add Files to [your project's name]`
2. Go to `node_modules` ➜ `react-native-camera-roll-media` and add `RNCameraRollMedia.xcodeproj`
3. In XCode, in the project navigator, select your project. Add `libRNCameraRollMedia.a` to your project's `Build Phases` ➜ `Link Binary With Libraries`
4. Run your project (`Cmd+R`)<

#### Android

1. Open up `android/app/src/main/java/[...]/MainActivity.java`
  - Add `import com.reactlibrary.RNCameraRollMediaPackage;` to the imports at the top of the file
  - Add `new RNCameraRollMediaPackage()` to the list returned by the `getPackages()` method
2. Append the following lines to `android/settings.gradle`:
  	```
  	include ':react-native-camera-roll-media'
  	project(':react-native-camera-roll-media').projectDir = new File(rootProject.projectDir, 	'../node_modules/react-native-camera-roll-media/android')
  	```
3. Insert the following lines inside the dependencies block in `android/app/build.gradle`:
  	```
      compile project(':react-native-camera-roll-media')
  	```

#### Windows
[Read it! :D](https://github.com/ReactWindows/react-native)

1. In Visual Studio add the `RNCameraRollMedia.sln` in `node_modules/react-native-camera-roll-media/windows/RNCameraRollMedia.sln` folder to their solution, reference from their app.
2. Open up your `MainPage.cs` app
  - Add `using Camera.Roll.Media.RNCameraRollMedia;` to the usings at the top of the file
  - Add `new RNCameraRollMediaPackage()` to the `List<IReactPackage>` returned by the `Packages` method


## Usage
```javascript
import RNCameraRollMedia from 'react-native-camera-roll-media';

// TODO: What to do with the module?
RNCameraRollMedia;
```
  