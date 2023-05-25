#define OVPN_DL_ROOT_URL        "https://swupdate.openvpn.org/community/releases/"
#define OVPN_LATEST_BUILD       "OpenVPN-2.6.4-I001-amd64"
#define OVPN_INSTALL_DIR        "c:\Program Files\OpenVPN"
#define OVPN_CONFIG_DIR         "c:\Program Files\OpenVPN\config"
#define OVPN_INSTALL_COMPONENTS "OpenVPN.Service,OpenVPN.GUI,OpenVPN,Drivers,Drivers.TAPWindows6"
#define PACKAGE_VERSION         "2.6.4.20230525"

[Setup]
AllowCancelDuringInstall=no
AllowNoIcons=yes
AppComments=OpenVPN repacked by soho-service.ru support team
AppCopyright=Copyright (C) 2023 Sokho-Service LLC
AppId=openvpn_s3ru_repack
AppName=OpenVPN S3RU Repack
AppPublisher=Sokho-Service LLC
AppPublisherURL=https://soho-service.ru
AppVersion={#PACKAGE_VERSION}
ChangesAssociations=yes
CloseApplications=yes
DefaultDirName={win}\soho-service.ru\apps\repacks\openvpn
DirExistsWarning=no
DisableDirPage=yes
DisableProgramGroupPage=yes
DisableWelcomePage=no
FlatComponentsList=yes
OutputBaseFilename=openvpn-bundle-{#SetupSetting("AppVersion")}-x64
OutputDir=..
PrivilegesRequired=admin
SetupIconFile=icon.ico
SetupLogging=yes
ShowLanguageDialog=no
SourceDir=source
UninstallDisplayIcon={app}\icon.ico
WizardImageFile=banner.bmp
WizardStyle=modern

[Files]
Source: "*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "{code:GetCertArchivePath}"; DestDir: "{tmp}"; Flags: external deleteafterinstall
Source: "{tmp}\{#OVPN_LATEST_BUILD}.msi"; DestDir: "{app}"; Flags: external

[Messages]
WelcomeLabel1=Установка программы для доступа к корпоративной сети
WelcomeLabel2=Для подключения Вам понадобится архив с настройками вида ivanov.zip - заранее получите его через заявку в Техподдержке или у ответственного сотрудника в офисе%n%nПродолжите установку только после получения архива
ClickNext=
FinishedLabelNoIcons=Установка выполнена. После перезагрузки Вы сможете подключиться - обратите внимание на картинку рядом
ClickFinish=Для подключения используйте свой логин и пароль для входа в рабочий компьютер. Иконка у Вас на рабочем столе - посмотрите на неё на картинке
FinishedRestartLabel=Для завершения нужно перезагрузиться - после этого для подключения используйте свой логин и пароль для входа в рабочий компьютер. Иконка у Вас на рабочем столе - посмотрите на неё на картинке слева

[Languages]
Name: "ru"; MessagesFile: "compiler:Languages\Russian.isl"

[Run]
Filename: "msiexec.exe"; Parameters: "/i ""{app}\{#OVPN_LATEST_BUILD}.msi"" /l*v ""{app}\{#OVPN_LATEST_BUILD}.log"" /passive ADDLOCAL={#OVPN_INSTALL_COMPONENTS} ALLUSERS=1 SELECT_OPENVPNGUI=1 SELECT_SHORTCUTS=1 SELECT_ASSOCIATIONS=0 SELECT_OPENSSL_UTILITIES=0 SELECT_EASYRSA=0 SELECT_OPENSSLDLLS=1 SELECT_LZODLLS=1 SELECT_PKCS11DLLS=1"; WorkingDir: {app}; Check: IsWin1X And IsDesktop;  StatusMsg: Установка системных компонентов ...; AfterInstall: SetElevationBit 

[Code]
const
  SHCONTCH_NOPROGRESSBOX = 4;
  SHCONTCH_RESPONDYESTOALL = 16;  

var ProfileArchiveFilePage: TInputFileWizardPage;
    DownloadPage: TDownloadWizardPage;
    ProfileArchiveLocation: String;
    ProfileName: String;

function IsProfileSelected: Boolean;
var selectedFile: String;
begin
  selectedFile := ProfileArchiveFilePage.Values[0]
  Result := (Pos('.zip', selectedFile) > 0)
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
  if Not DirExists('{#OVPN_INSTALL_DIR}') Then 
  begin
    Log('create dir {#OVPN_INSTALL_DIR}');
    CreateDir('{#OVPN_INSTALL_DIR}')
  end;
  if DirExists('{#OVPN_CONFIG_DIR}') Then 
  begin
    Log('clear dir ' + '{#OVPN_CONFIG_DIR}');
    DelTree('{#OVPN_CONFIG_DIR}\*', False, True, True);
  end;
  if Not DirExists('{#OVPN_CONFIG_DIR}') Then 
  begin
    Log('create dir {#OVPN_CONFIG_DIR}');
    CreateDir('{#OVPN_CONFIG_DIR}')
  end;
end;

function GetCertArchiveName(Value: string): String;
begin
  Result := ExtractFileName(ProfileArchiveLocation);
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

function IsWin1X: Boolean;
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
  try
	Stream := TFileStream.Create(FileName, fmOpenReadWrite);
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

procedure UnZip(ZipPath, TargetPath: string); 
var
  Shell: Variant;
  ZipFile: Variant;
  TargetFolder: Variant;
begin
  Shell := CreateOleObject('Shell.Application');

  ZipFile := Shell.NameSpace(ZipPath);
  if VarIsClear(ZipFile) then
    RaiseException(
      Format('Архив с настройками "%s" не может поврежден - запросите новую версию в техподдержке', [ZipPath]));

  TargetFolder := Shell.NameSpace(TargetPath);
  if VarIsClear(TargetFolder) then
    RaiseException(Format('Путь "%s" не найден', [TargetPath]));

  TargetFolder.CopyHere(ZipFile.Items, SHCONTCH_NOPROGRESSBOX or SHCONTCH_RESPONDYESTOALL);
end;

Function OnDownloadProgress(const Url, FileName: String; const Progress, ProgressMax: Int64): Boolean;
begin
  if Progress = ProgressMax then
    Log(Format('successfully downloaded file to {tmp}: %s', [FileName]));
  Result := True;
end;    

Procedure InitializeWizard();
begin
  ProfileName:= '';

  WizardForm.WelcomeLabel2.Font.Style := [fsBold]; //жирный текст в окне приветствия
  WizardForm.WelcomeLabel2.Font.Color := clRed; // красный
  WizardForm.WelcomeLabel2.Font.Size := 14; // красный

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
    'архивы *.zip|*.zip', 
    ''
  );  
  
  ProfileArchiveFilePage.SubCaptionLabel.Font.Size := 12;
  ProfileArchiveFilePage.SubCaptionLabel.Font.Color := clRed;
  ProfileArchiveFilePage.SubCaptionLabel.Font.Style := [fsBold];

  DownloadPage := CreateDownloadPage(SetupMessage(msgWizardPreparing), SetupMessage(msgPreparingDesc), @OnDownloadProgress);
end;

function NextButtonClick(CurPageID: Integer): Boolean;
begin
  Result := True;
  if (CurPageID = ProfileArchiveFilePage.ID) AND (IsProfileSelected = False) then
  begin
    MsgBox('Выберите архив с настройками', mbError, MB_OK);
    Result := False;
    Exit;
  end;
  if CurPageID = wpReady then 
    begin     
      DownloadPage.Clear; 
      DownloadPage.Add('{#OVPN_DL_ROOT_URL}{#OVPN_LATEST_BUILD}.msi', '{#OVPN_LATEST_BUILD}.msi', '');    
      DownloadPage.Show;
      try
        try
          DownloadPage.Download;
        except
          if DownloadPage.AbortedByUser then
            Log('dl aborted by user.')
          else
            begin
            SuppressibleMsgBox(AddPeriod(GetExceptionMessage), mbCriticalError, MB_OK, IDOK);
            Result := False;
            Exit;
            end
        end;
      finally
        DownloadPage.Hide;
      end;
      if Result = True then
      begin
        ClearProfileConfig();
        UnZip(GetCertArchivePath(''), '{#OVPN_CONFIG_DIR}');
      end;
    end
end;