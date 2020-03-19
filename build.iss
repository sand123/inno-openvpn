[Setup]
AppId=openvpn_s3ru_repack
AppName=OpenVPN S3RU Repack
AppComments=OpenVPN repacked by soho-service.ru support team
AppVersion=1.0.0.0
AppCopyright=Copyright (C) 2020 Sokho-Service LLC
AppPublisher=Sokho-Service LLC
AppPublisherURL=https://soho-service.ru
AllowCancelDuringInstall=no
DefaultDirName={commonpf}\soho-service.ru\repacks\openvpn
AllowNoIcons=yes
UninstallDisplayIcon={app}\icon.ico
ChangesAssociations=yes
CloseApplications=yes
DirExistsWarning=no
DisableDirPage=yes
DisableFinishedPage=yes
DisableProgramGroupPage=yes
FlatComponentsList=yes
OutputBaseFilename=openvpn_2.4.8_s3ru_repack.exe
OutputDir=..
SetupLogging=yes
SourceDir=source
SetupIconFile=icon.ico
ShowLanguageDialog=no
WizardStyle=modern

[Types]
Name: "compact"; Description: "Быстрая установка"

[Components]
Name: "program"; Description: "Файлы программы и библиотеки"; Types: compact; Flags: fixed

[Files]
Source: "*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs; Components: program 

[Icons]
Name: "{group}\Менеджер сертификатов"; Filename: "{app}\cert-man.hta"

;[Dirs]
;Name: "{app}"; Permissions: everyone-modify

[Languages]
Name: "ru"; MessagesFile: "compiler:Languages\Russian.isl"

[Run]
Filename: "{src}\openvpn-install-2.4.8-I602-Win10.exe"; Parameters: "/q /norestart"; WorkingDir: {src}; Check: Not IsFramework35Installed;  StatusMsg: Установка OpenVPN клиента... 

[Tasks]

[Code]
Function IsFramework35Installed : boolean;
  var installed : cardinal;
      success: boolean;
  Begin
    success := RegQueryDWordValue(HKLM, 'Software\Microsoft\NET Framework Setup\NDP\v3.5', 'Install', installed);
    result := success and (installed = 1);
  End;