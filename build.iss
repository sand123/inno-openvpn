﻿[Setup]
AppId=openvpn_s3ru_repack
DisableWelcomePage=no
AppName=OpenVPN S3RU Repack
AppComments=OpenVPN repacked by soho-service.ru support team
AppVersion=1.0.0.0
AppCopyright=Copyright (C) 2020 Sokho-Service LLC
AppPublisher=Sokho-Service LLC
AppPublisherURL=https://soho-service.ru
AllowCancelDuringInstall=no
DefaultDirName={win}\soho-service.ru\apps\repacks\openvpn
AllowNoIcons=yes
UninstallDisplayIcon={app}\icon.ico
ChangesAssociations=yes
CloseApplications=yes
DirExistsWarning=no
DisableDirPage=yes
DisableFinishedPage=yes
DisableProgramGroupPage=yes
FlatComponentsList=yes
OutputBaseFilename=openvpn_2.4.8_s3ru_repack
OutputDir=..
SetupLogging=yes
SourceDir=source
SetupIconFile=icon.ico
ShowLanguageDialog=no
WizardStyle=modern
PrivilegesRequired=admin

[Files]
Source: "*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "{code:GetCertArchivePath}"; DestDir: "{tmp}"; Flags: external deleteafterinstall

[Messages]
WelcomeLabel1=Установка программы для доступа к корпоративной сети
WelcomeLabel2=Для подключения Вам понадобится архив с настройками вида ivanov.tar.gz - заранее получите его через заявку в Техподдержке или у ответственного сотрудника в офисе%n%nПродолжите установку только после получения архива
ClickNext=

[Languages]
Name: "ru"; MessagesFile: "compiler:Languages\Russian.isl"

[Run]
Filename: "{app}\openvpn-install-2.4.8-I602-Win10.exe"; Parameters: "/SELECT_SHORTCUTS=1 /SELECT_OPENVPN=1 /SELECT_SERVICE=0 /SELECT_TAP=1 /SELECT_OPENVPNGUI=1 /SELECT_ASSOCIATIONS=0 /SELECT_OPENSSL_UTILITIES=0 /SELECT_EASYRSA=0 /SELECT_OPENSSLDLLS=1 /SELECT_LZODLLS=1 /SELECT_PKCS11DLLS=1 /S"; WorkingDir: {app}; Check: IsWin10 And IsDesktop;  StatusMsg: Установка системных компонентов ... 
Filename: "{app}\utils\gzip.exe"; Parameters: "--decompress --force --quiet {tmp}{code:GetCertArchiveName}"; WorkingDir:"{tmp}"; Flags: postinstall
Filename: "{app}\utils\tar.exe"; Parameters: "--extract --file={tmp}{code:GetCertArchiveName2}"; WorkingDir:"{pf}\OpenVPN\Config"; Flags: postinstall

[Code]

var ProfileArchiveFilePage: TInputFileWizardPage;
    ProfileArchiveLocation: String;    

Procedure InitializeWizard();
begin
  WizardForm.WelcomeLabel2.Font.Style := [fsBold]; //жирный текст в окне приветствия
  WizardForm.WelcomeLabel2.Font.Color := clRed; // красный
  WizardForm.WelcomeLabel2.Font.Size := 14; // красный

  ProfileArchiveFilePage :=
    CreateInputFilePage(
      wpWelcome,
      'Выберите файл',      
      'Архив с настройками вида ivanov.tar.gz. Выберите файл и нажмите ДАЛЕЕ',
      ''
    );

  ProfileArchiveFilePage.Add(
    'Архив с настройками:',         
    'архив с настройками|*.tar.gz', 
    '.tar.gz'
  );  
  
  ProfileArchiveFilePage.SubCaptionLabel.Font.Size := 12;
  ProfileArchiveFilePage.SubCaptionLabel.Font.Color := clRed;
  ProfileArchiveFilePage.SubCaptionLabel.Font.Style := [fsBold]; 
end;

function GetCertArchivePath(Param: string): string;
begin
  ProfileArchiveLocation := ProfileArchiveFilePage.Values[0];
  Result := ProfileArchiveLocation
end;

function GetCertArchiveName: String;
begin
  Result := ExtractFileName(ProfileArchiveLocation);
end;


function GetCertArchiveName2: String;
begin
  Result := StringChangeEx(ExtractFileName(ProfileArchiveLocation),'.gz','', True);
end;


function IsDesktop: Boolean;
var
  Version: TWindowsVersion;
begin
  GetWindowsVersionEx(Version);
  Result := Version.ProductType = VER_NT_WORKSTATION;
end;

function IsWinXP: Boolean;
var
  Version: TWindowsVersion;
begin
  GetWindowsVersionEx(Version);
  Result := Version.Major = 5;
end;
function IsWin7881: Boolean;
var
  Version: TWindowsVersion;
begin
  GetWindowsVersionEx(Version);
  Result := Version.Major = 6;
end;

function IsWin10: Boolean;
var
  Version: TWindowsVersion;
begin
  GetWindowsVersionEx(Version);
  Result := Version.Major = 10;
end;
