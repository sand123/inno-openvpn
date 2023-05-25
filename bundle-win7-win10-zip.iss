[Setup]
AppId=openvpn_s3ru_repack
DisableWelcomePage=no
AppName=OpenVPN S3RU Repack
AppComments=OpenVPN repacked by soho-service.ru support team
AppVersion=2.6.4.20230525
AppCopyright=Copyright (C) 2021 Sokho-Service LLC
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
OutputBaseFilename=openvpn-bundle-{#SetupSetting("AppVersion")}-x64
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
Source: "{tmp}\OpenVPN-2.6.4-I001-amd64.msi"; DestDir: "{app}"; Flags: external

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
Filename: "msiexec.exe"; Parameters: "/i ""{app}\OpenVPN-2.6.4-I001-amd64.msi"" /l*v ""{app}\OpenVPN-2.6.4-I001-amd64.log"" /passive ADDLOCAL=OpenVPN.Service,OpenVPN.GUI,OpenVPN,Drivers,Drivers.TAPWindows6 ALLUSERS=1 SELECT_OPENVPNGUI=1 SELECT_SHORTCUTS=1 SELECT_ASSOCIATIONS=0 SELECT_OPENSSL_UTILITIES=0 SELECT_EASYRSA=0 SELECT_OPENSSLDLLS=1 SELECT_LZODLLS=1 SELECT_PKCS11DLLS=1"; WorkingDir: {app}; Check: IsWin1X And IsDesktop;  StatusMsg: Установка системных компонентов ...; AfterInstall: SetElevationBit 
Filename: "{app}\utils\unzip.exe"; Parameters: "-o -qq {tmp}\{code:GetCertArchiveName}"; WorkingDir:"c:\Program Files\OpenVPN\Config"; BeforeInstall: ClearProfileConfig

[Code]

var ProfileArchiveFilePage: TInputFileWizardPage;
    DownloadPage: TDownloadWizardPage;
    ProfileArchiveLocation: String;
    ProfileName: String;

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

function IsProfileSelected: Boolean;
var selectedFile: String;
begin
  selectedFile := ProfileArchiveFilePage.Values[0]
  Result := (Pos('.zip', selectedFile) > 0)
end;

function NextButtonClick(CurPageID: Integer): Boolean;
begin
  if (CurPageID = ProfileArchiveFilePage.ID) AND (IsProfileSelected = False) then
  begin
    MsgBox('Выберите архив с настройками', mbError, MB_OK);
    Result := False;
    Exit;
  end;
  if CurPageID = wpReady then 
  begin
    DownloadPage.Clear; 
    DownloadPage.Add('https://swupdate.openvpn.org/community/releases/OpenVPN-2.6.4-I001-amd64.msi', 'OpenVPN-2.6.4-I001-amd64.msi', '');    
    DownloadPage.Show;
    try
      try
        DownloadPage.Download; // This downloads the files to {tmp}
        Result := True;
      except
        if DownloadPage.AbortedByUser then
          Log('dl aborted by user.')
        else
          SuppressibleMsgBox(AddPeriod(GetExceptionMessage), mbCriticalError, MB_OK, IDOK);
        Result := False;
      end;
    finally
      DownloadPage.Hide;
    end;
  end else    
  Result := True;
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