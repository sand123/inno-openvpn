[Setup]
AppId=openvpn_s3ru_repack
DisableWelcomePage=no
AppName=OpenVPN S3RU Repack
AppComments=OpenVPN repacked by soho-service.ru support team
AppVersion=1.0.0.4
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
OutputBaseFilename=openvpn_2.3.18_winxp_{#SetupSetting("AppVersion")}
OutputDir=..
SetupLogging=yes
SourceDir=source-xp
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
WelcomeLabel2=Для подключения Вам понадобится архив с настройками вида ivanov.tar.gz или ivanov.zip - заранее получите его через заявку в Техподдержке или у ответственного сотрудника в офисе%n%nПродолжите установку только после получения архива
ClickNext=
FinishedLabelNoIcons=Установка выполнена. После перезагрузки Вы сможете подключиться - обратите внимание на картинку справа
ClickFinish=Для подключения используйте свой логин и пароль для входа в рабочий компьютер. Иконка у Вас на рабочем столе - посмотрите на неё на картинке слева
FinishedRestartLabel=Для завершения нужно перезагрузиться - после этого для подключения используйте свой логин и пароль для входа в рабочий компьютер. Иконка у Вас на рабочем столе - посмотрите на неё на картинке слева

[Languages]
Name: "ru"; MessagesFile: "compiler:Languages\Russian.isl"

[Run]

Filename: "{app}\openvpn-install-2.3.18-I001-i686-WinXP.exe"; Parameters: "/SELECT_SHORTCUTS=1 /SELECT_OPENVPN=1 /SELECT_SERVICE=0 /SELECT_TAP=1 /SELECT_OPENVPNGUI=1 /SELECT_ASSOCIATIONS=0 /SELECT_OPENSSL_UTILITIES=0 /SELECT_EASYRSA=0 /SELECT_OPENSSLDLLS=1 /SELECT_LZODLLS=1 /SELECT_PKCS11DLLS=1 /S"; WorkingDir: {app}; Check: IsWinXP And IsDesktop;  StatusMsg: Установка системных компонентов ...;
Filename: "{app}\utils\gzip.exe"; Parameters: "--decompress --force --quiet {tmp}\{code:GetCertArchiveName}"; WorkingDir:"{tmp}"; Check:isTarProfile;
Filename: "{app}\utils\tar.exe"; Parameters: "--extract --file={tmp}\{code:GetCertArchiveName2}"; WorkingDir:"c:\Program Files\OpenVPN\Config"; Check:isTarProfile; BeforeInstall: ClearProfileConfig 
Filename: "{app}\utils\unzip.exe"; Parameters: "-o -qq {tmp}\{code:GetCertArchiveName}"; WorkingDir:"c:\Program Files\OpenVPN\Config"; Check:not isTarProfile; BeforeInstall: ClearProfileConfig

[Code]

var ProfileArchiveFilePage: TInputFileWizardPage;
    ProfileArchiveLocation: String;
    ProfileName: String;    

Procedure InitializeWizard();
begin
  ProfileName:= '';

  WizardForm.WelcomeLabel2.Font.Style := [fsBold]; //жирный текст в окне приветствия
  WizardForm.WelcomeLabel2.Font.Color := clRed; // красный
  WizardForm.WelcomeLabel2.Font.Size := 12; // красный

  WizardForm.FinishedLabel.Caption := 'Перезагрузите компьютер и попробуйте подключиться';

  ProfileArchiveFilePage :=
    CreateInputFilePage(
      wpWelcome,
      'Выберите файл',      
      'Архив с настройками вида ivanov.tar.gz или ivanov.zip. Выберите файл и нажмите ДАЛЕЕ',
      ''
    );

  ProfileArchiveFilePage.Add(
    'Архив с настройками:',         
    'архивы *.zip *.tar.gz|*.*', 
    ''
  );  
  
  ProfileArchiveFilePage.SubCaptionLabel.Font.Size := 12;
  ProfileArchiveFilePage.SubCaptionLabel.Font.Color := clRed;
  ProfileArchiveFilePage.SubCaptionLabel.Font.Style := [fsBold];
end;

function IsProfileSelected: Boolean;
var selectedFile: String;
begin
  selectedFile := ProfileArchiveFilePage.Values[0]
  Result := (Pos('.tar.gz', selectedFile) > 0) Or (Pos('.zip', selectedFile) > 0)
end;

function NextButtonClick(CurPageID: Integer): Boolean;
begin
  if (CurPageID = ProfileArchiveFilePage.ID) AND (IsProfileSelected = False) then
  begin
    MsgBox('Выберите архив с настройками', mbError, MB_OK);
    Result := False;
    Exit;
  end;
  Result := True;
end;

function IsTarProfile: Boolean;
begin
  Result := Pos('.tar.gz', ProfileArchiveLocation) > 0;
end;

function GetCertArchivePath(Param: string): string;
begin
  ProfileArchiveLocation := ProfileArchiveFilePage.Values[0];
  Result := ProfileArchiveLocation
end;

Procedure ClearProfileConfig();
var fileExt: String;
    fileName: String;
begin
  
  if ProfileName <> '' Then 
  begin
    Exit;
  end;

  fileName := ExtractFileName(ProfileArchiveLocation);
  fileExt := ExtractFileExt(ProfileArchiveLocation);
  StringChangeEx(fileName,fileExt,'', True);
  ProfileName := fileName
  Log('extract profile name ' + ProfileName);
  if DirExists('c:\Program Files\OpenVPN\Config') Then 
  begin
    Log('clear dir c:\Program Files\OpenVPN\Config');
    DelTree('c:\Program Files\OpenVPN\Config\*', False, True, True);
  end;
  if Not DirExists('c:\Program Files\OpenVPN\Config') Then 
  begin
    Log('create dir c:\Program Files\OpenVPN\Config');
    CreateDir('c:\Program Files\OpenVPN\Config')
  end;
end;

function GetCertArchiveName(Value: string): String;
begin
  Result := ExtractFileName(ProfileArchiveLocation);
end;

function GetCertArchiveName2(Value: string): String;
var s: String;
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