[Setup]
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
DisableProgramGroupPage=yes
FlatComponentsList=yes
OutputBaseFilename=openvpn_2.4.8_s3ru_repack
OutputDir=..
SetupLogging=yes
SourceDir=source
SetupIconFile=icon.ico
ShowLanguageDialog=no
WizardStyle=modern
WizardImageFile=banner.bmp
PrivilegesRequired=admin

[Files]
Source: "*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "{code:GetCertArchivePath}"; DestDir: "{tmp}"; Flags: external deleteafterinstall

[Messages]
WelcomeLabel1=Установка программы для доступа к корпоративной сети
WelcomeLabel2=Для подключения Вам понадобится архив с настройками вида ivanov.tar.gz - заранее получите его через заявку в Техподдержке или у ответственного сотрудника в офисе%n%nПродолжите установку только после получения архива
ClickNext=
FinishedLabelNoIcons=Установка выполнена. После перезагрузки Вы сможете подключиться - обратите внимание на картинку справа
ClickFinish=Для подключения используйте свой логин и пароль для входа в рабочий компьютер
FinishedRestartLabel=Для завершения нужно перезагрузиться - после этого для подключения используйте свой логин и пароль для входа в рабочий компьютер

[Languages]
Name: "ru"; MessagesFile: "compiler:Languages\Russian.isl"

[Run]
Filename: "{app}\openvpn-install-2.4.8-I602-Win10.exe"; Parameters: "/SELECT_SHORTCUTS=1 /SELECT_OPENVPN=1 /SELECT_SERVICE=0 /SELECT_TAP=1 /SELECT_OPENVPNGUI=1 /SELECT_ASSOCIATIONS=0 /SELECT_OPENSSL_UTILITIES=0 /SELECT_EASYRSA=0 /SELECT_OPENSSLDLLS=1 /SELECT_LZODLLS=1 /SELECT_PKCS11DLLS=1 /S"; WorkingDir: {app}; Check: IsWin10 And IsDesktop;  StatusMsg: Установка системных компонентов ...; AfterInstall: SetElevationBit 
Filename: "{app}\openvpn-install-2.4.8-I602-Win7.exe"; Parameters: "/SELECT_SHORTCUTS=1 /SELECT_OPENVPN=1 /SELECT_SERVICE=0 /SELECT_TAP=1 /SELECT_OPENVPNGUI=1 /SELECT_ASSOCIATIONS=0 /SELECT_OPENSSL_UTILITIES=0 /SELECT_EASYRSA=0 /SELECT_OPENSSLDLLS=1 /SELECT_LZODLLS=1 /SELECT_PKCS11DLLS=1 /S"; WorkingDir: {app}; Check: IsWin7881 And IsDesktop;  StatusMsg: Установка системных компонентов ...; AfterInstall: SetElevationBit 
Filename: "{app}\openvpn-install-2.3.18-I001-i686-WinXP.exe"; Parameters: "/SELECT_SHORTCUTS=1 /SELECT_OPENVPN=1 /SELECT_SERVICE=0 /SELECT_TAP=1 /SELECT_OPENVPNGUI=1 /SELECT_ASSOCIATIONS=0 /SELECT_OPENSSL_UTILITIES=0 /SELECT_EASYRSA=0 /SELECT_OPENSSLDLLS=1 /SELECT_LZODLLS=1 /SELECT_PKCS11DLLS=1 /S"; WorkingDir: {app}; Check: IsWinXP And IsDesktop;  StatusMsg: Установка системных компонентов ...; AfterInstall: SetElevationBit 
Filename: "{app}\utils\gzip.exe"; Parameters: "--decompress --force --quiet {tmp}\{code:GetCertArchiveName}"; WorkingDir:"{tmp}";
Filename: "{app}\utils\tar.exe"; Parameters: "--extract --file={tmp}\{code:GetCertArchiveName2}"; WorkingDir:"c:\Program Files\OpenVPN\Config";

[Code]

var ProfileArchiveFilePage: TInputFileWizardPage;
    ProfileArchiveLocation: String;    

Procedure InitializeWizard();
begin
  WizardForm.WelcomeLabel2.Font.Style := [fsBold]; //жирный текст в окне приветствия
  WizardForm.WelcomeLabel2.Font.Color := clRed; // красный
  WizardForm.WelcomeLabel2.Font.Size := 14; // красный


  WizardForm.FinishedLabel.Caption := 'Перезагрузите компьютер и попробуйте подключиться';

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

function GetCertArchiveName(Value: string): String;
begin
  Result := ExtractFileName(ProfileArchiveLocation);
end;


function GetCertArchiveName2(Value: string): String;
var s: String;
    r: String;
begin
  s := ExtractFileName(ProfileArchiveLocation);
  StringChangeEx(s,'.gz','', True);
  Result := s;
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

procedure SetElevationBit();
var
  Filename: string;
  Buffer: string;
  Stream: TStream;
begin
  Filename := ExpandConstant('{commondesktop}\OpenVPN GUI.lnk');
  Log('setting elevation bit for ' + Filename);

  Stream := TFileStream.Create(FileName, fmOpenReadWrite);
  try
    Stream.Seek(21, soFromBeginning);
    SetLength(Buffer, 1);
    Stream.ReadBuffer(Buffer, 1);
    Buffer[1] := Chr(Ord(Buffer[1]) or $20);
    Stream.Seek(-1, soFromCurrent);
    Stream.WriteBuffer(Buffer, 1);
  finally
    Stream.Free;
  end;
end;