__Bibliophone__ users can record audio, store it in azure cloud and interact with it.
One could use it to build an vocal lingustic corpus
One could also trigger a transcription model and display the output in the app like below :

![](bibliophone.png)

# inspirations
- [LIG-Aikuma](https://lig-aikuma.imag.fr/index.html) a recording application for language documentation
- [Lingua Libre](https://en.wikipedia.org/wiki/Lingua_Libre) an online collaborative tool to build a  multilingual, audiovisual speech corpus under a free license

# features 
- record audio and upload it to azure
- allow user to cancel upload
- audio can be played/recorded when offline
- handle unsent files and allow user to send them later

# roadmap
- speech-to-text demo : show how to call [microsoft api](https://learn.microsoft.com/en-us/azure/ai-services/speech-service/speech-to-text) from the app to infer the audio

# set-up  
- create azure blob
- create container in azure blob
- create azure blob key with add, read, list permission
- azure permissions : set a role with blob contributor
- network & security -> copy connexion string and share it to your device (e.g. mail, message) 
- __in flutter app__ go to settings and paste the connexion string

# caveat
- only compatible with azure yet, but adaptable
- you will only see a user folder if they have sent at least one audio
- drag and drop your content/output in user folder
- user will need to update view to see the ready to download transcription

# backlog
## support needed
- split UI and logic to make it easier to maintain
- split azure from UI to make it possible to use other cloud providers
- add more languages in locals to make this universal
- check performance for x100 files and update accordingly
- catch up on dart-azblob, it has added new functionnalities since 2023 that could be useful (e.g. delete content in blob)

## niceToHave
- notification 
- UI - use bin animation when deleting from mobile lockTimer
- UI - display syncing progress
- UI - while playing display audio waves 
  - [voice_message_package](https://pub.dev/packages/voice_message_package) yielded unsatisfying result
    - check : 
    - see in for_later/amplitude.dart
    - https://pub.dev/packages/audio_waveforms
    - https://github.com/ryanheise/just_waveform
    - https://pub.dev/packages/flutter_audio_waveforms
- UI - while recording display audio amplitude using a [gauge chart](https://github.com/GeekyAnts/GaugesFlutter)
- UX - set a max duration to prevent users from uploading endless empty files
- UX - while playing be able to move audio cursor
- codeCourtesy - stick to audioplayers instead of just_audio + audioplayers ?

- provide optionnal params to set in azure :
	- <Content-Encoding />
	- <Content-Language />


# Dependencies
The project forked ruthlessly these projects : 

- [audio-chat](https://github.com/thecodepapaya/audio-chat) - Initial animation and audio rec
- [dart-azblob](https://github.com/kkazuo/dart-azblob) - To send/receive audio on/from azure, rewrote bits to pass http client and handle exception when user cancels upload/download

The project uses the following open source packages :

- [xml](https://pub.dev/packages/xml) - Parse azure blob info
- [connectivity_plus](https://pub.dev/packages/connectivity_plus) - check connectivity
- [internet_connection_checker](https://pub.dev/packages/internet_connection_checker) - check if internet is actually available

And these other open source packages, already used in audio-chat :

- [just_audio](https://pub.dev/packages/just_audio) - To interact with audio files from application document storage.
- [font_awesome_flutter](https://pub.dev/packages/font_awesome_flutter) - Font Awesome provides a great set of Icon to use in your application.
- [permission_handler](https://pub.dev/packages/permission_handler) - A package to handle audio/storage permissions from the user.
- [path_provider](https://pub.dev/packages/path_provider) - path_provider provides path to application document and cache storage directories to store application specific data.
- [record](https://pub.dev/packages/record) - Audio recorder from microphone to a given file path with multiple codecs, bit rate and sampling rate options.
- [flutter_vibrate](https://pub.dev/packages/flutter_vibrate) - A simple plugin to control haptic feedback on iOS and android.
- [lottie](https://pub.dev/packages/lottie) - To add lottie animation to the application.

# archive
## build helper
### build helper android
> build.gradle
minSdkVersion 21
 
> in manifest add
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.VIBRATE" />

> ([to avoid error "No signature of method:"](https://stackoverflow.com/questions/76067863/no-signature-of-method-in-flutter-project))
> in .pub-cache/hosted/pub.dev/audioplayers_android-3.0.2/android/build.gradle
> comment line 48-50 
    //lint {
    //    disable 'InvalidPackage'
    //}

### build helper ios
> Runner.entitlements
<key>com.apple.security.device.audio-input</key>
<true/>
<key>com.apple.security.network.client</key>
<true/>
<key>com.apple.security.files.user-selected.read-write</key>
<true/>
<key>com.apple.security.files.downloads.read-write</key>
<true/>

> info.plist
NSMicrophoneUsageDescription

### build helper macos
Disclaimer mic permission in macos sometimes fail

> podfile
platform :osx, '10.15'

> info.plist
> macos/Runner/Release.entitlements
<key>com.apple.security.device.audio-input</key>
<true/>
<key>com.apple.security.network.client</key>
<true/>
<key>com.apple.security.files.user-selected.read-write</key>
<true/>
<key>com.apple.security.files.downloads.read-write</key>
<true/>


# fork & custom

Update below with your own info
```dart
  VocalMessagesConfig.setAzureAudioConfig = AzureBlobConfig(
      containerName: 'myOwnContainer', userFolderName: 'myOwnUserName');
```

- azure file formats : only upload .wav audio file
- azureFolderFullPath = container + folderPath + direction, ex : 
	- /bernard/userName/userAudio // where app-user's audios are saved
	- /bernard/userName/transcription // where admin should save vocal message replies (.wav)
- tip download azure blob storage GUI : https://azure.microsoft.com/en-us/products/storage/storage-explorer/