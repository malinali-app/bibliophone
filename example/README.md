# voc_up

create a secret.dart file and declare
final azureBlobConnectionString = '',

in main.dart
set with your own 
  VocalMessagesConfig.setAzureAudioConfig = AzureBlobConfig(
      containerName: 'audio', userFolderName: 'test');
