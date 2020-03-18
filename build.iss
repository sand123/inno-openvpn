[Setup]
AppName=OpenVPN S3RU Repack
AppComments=OpenVPN repacked by soho-service.ru support team
AppVersion=1.0.0.0
AppCopyright=Copyright (C) 2020 Sokho-Service LLC
AppId=s3ru_repack_openvpn
AppPublisher=Sokho-Service LLC
AppPublisherURL=https://soho-service.ru
AllowCancelDuringInstall=no
DefaultDirName={pf}\soho-service.ru\repacks\openvpn
AllowNoIcons=yes
UninstallDisplayIcon={app}\icon.ico
ChangesAssociations=yes
CloseApplications=yes
DirExistsWarning=no
DisableDirPage=yes
DisableFinishedPage=yes
DisableProgramGroupPage=yes
FlatComponentsList=yes
OutputBaseFilename=openvpn_s3ru_repack.exe
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
Source: "*"; DestDir: "{app}"; Flags: ignoreversion; Components: program 

[Icons]
Name: "{group}\Менеджер сертификатов"; Filename: "{app}\certman.hta"

//[Dirs]
//Name: "{app}"; Permissions: everyone-modify

[Languages]
Name: "ru"; MessagesFile: "compiler:Languages\Russian.isl"

[Run]
Filename: "{src}\openvpn-install-2.4.8-I602-Win10.exe"; Parameters: "/q /norestart"; WorkingDir: {src}; Check: Not IsFramework35Installed;  StatusMsg: Установка OpenVPN клиента... 
//Filename: "{src}\data\vjredist_x64\install.exe"; Parameters: "/q /l ""{%TEMP}\leadcore_vjredist_x64_msi.log"""; WorkingDir: {src}\data\vjredist_x64;  Check: isWin64;  StatusMsg: Установка Microsoft Visual J# Redistributable...
//Filename: "{src}\data\vjredist_x86\install.exe"; Parameters: "/q /l ""{%TEMP}\leadcore_vjredist_x86_msi.log"""; WorkingDir: {src}\data\vjredist_x86;  Check: Not isWin64; StatusMsg: Установка Microsoft Visual J# Redistributable...
//Filename: "msiexec.exe"; Parameters: "/i ""{src}\data\install_1_wire_drivers_x64_v403.msi"" /passive /log {%TEMP}\leadcore_1wire_x64_msi.log"; WorkingDir: {src}\data;  Check: isWin64; StatusMsg: Установка драйверов 1-Wire...
//Filename: "msiexec.exe"; Parameters: "/i ""{src}\data\install_1_wire_drivers_x86_v403.msi"" /passive /log {%TEMP}\leadcore_1wire_x86_msi.log"; WorkingDir: {src}\data;  Check: Not isWin64; StatusMsg: Установка драйверов 1-Wire...
//Filename: "msiexec.exe"; Parameters: "/i ""{src}\data\SSCERuntime_x64-RUS.msi"" /passive  /log {%TEMP}\leadcore_sqlce_x64_msi.log"; WorkingDir: {src}\data;  Check: isWin64; StatusMsg: Установка Microsoft SQL Compact Redistributable...
//Filename: "msiexec.exe"; Parameters: "/i ""{src}\data\SSCERuntime_x86-RUS.msi"" /passive  /log {%TEMP}\leadcore_sqlce_x86_msi.log"; WorkingDir: {src}\data;  Check: Not isWin64; StatusMsg: Установка Microsoft SQL Compact Redistributable...

[Tasks]

[Code]
Function IsFramework35Installed : boolean;
  var installed : cardinal;
      success: boolean;
  Begin
    success := RegQueryDWordValue(HKLM, 'Software\Microsoft\NET Framework Setup\NDP\v3.5', 'Install', installed);
    result := success and (installed = 1);
  End;