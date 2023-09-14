#define OVPN_DL_ROOT_URL        "https://swupdate.openvpn.org/community/releases/"
#define OVPN_LATEST_BUILD       "OpenVPN-2.6.4-I001-amd64"
#define OVPN_INSTALL_DIR        "c:\Program Files\OpenVPN"
#define OVPN_CONFIG_DIR         "c:\Program Files\OpenVPN\config"
#define OVPN_AUTOCONFIG_DIR     "c:\Program Files\OpenVPN\config-auto"
#define OVPN_INSTALL_COMPONENTS "OpenVPN.Service,OpenVPN.GUI,OpenVPN,Drivers,Drivers.TAPWindows6"

// внутренняя версия сборки = оригинальный_релиз.дата_сборки
#define PACKAGE_VERSION         "2.6.4.20230914"
// ярлык OpenVPN GUI добавить флаг Запускать с правами администратора
#define CONFIG_SET_RUN_AS_ADMIN "0"
// править старые файлы конфигов https://gitea.ad.local/soho/vpn/issues/10
#define CONFIG_UPDATE_CIPHERS "1"

[Setup]
AllowCancelDuringInstall=no
AllowNoIcons=yes
AlwaysRestart=yes
AppComments=OpenVPN repacked by soho-service.ru support team
AppCopyright=Copyright (C) 2023 Sokho-Service LLC
AppId=openvpn_s3ru_repack
AppName=OpenVPN SohoSupport Installer
AppPublisher=Sokho-Service LLC
AppPublisherURL=https://soho-service.ru
AppVersion={#PACKAGE_VERSION}
ChangesAssociations=yes
CloseApplications=yes
DefaultDirName={win}\soho-service.ru\repacks\openvpn
DirExistsWarning=no
DisableDirPage=yes
DisableProgramGroupPage=yes
DisableWelcomePage=no
FlatComponentsList=yes
OutputBaseFilename=openvpn-installer-{#SetupSetting("AppVersion")}-x64
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
Source: "*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs; BeforeInstall: UnpackConfig;
Source: "{code:GetCertArchivePath}"; DestDir: "{tmp}"; Flags: external deleteafterinstall;
Source: "{tmp}\{#OVPN_LATEST_BUILD}.msi"; DestDir: "{app}"; Flags: external;

[Messages]
WelcomeLabel1=Установка программы для доступа к корпоративной сети
WelcomeLabel2=Для подключения Вам понадобится архив с настройками вида ivanov.zip или comp100.zip - заранее получите его через заявку в Техподдержке или у ответственного сотрудника в офисе%n%nПродолжите установку только после получения архива
ClickNext=
FinishedLabelNoIcons=Установка выполнена. После перезагрузки Вы сможете подключиться - обратите внимание на картинку рядом

[Languages]
Name: "ru"; MessagesFile: "compiler:Languages\Russian.isl"

[Run]
Filename: "msiexec.exe"; Parameters: "/i ""{app}\{#OVPN_LATEST_BUILD}.msi"" /l*v ""{app}\{#OVPN_LATEST_BUILD}.log"" /passive ADDLOCAL={#OVPN_INSTALL_COMPONENTS} ALLUSERS=1 SELECT_OPENVPNGUI=1 SELECT_SHORTCUTS=1 SELECT_ASSOCIATIONS=0 SELECT_OPENSSL_UTILITIES=0 SELECT_EASYRSA=0 SELECT_OPENSSLDLLS=1 SELECT_LZODLLS=1 SELECT_PKCS11DLLS=1"; WorkingDir: {app}; Check: IsWinSupported And IsDesktop And IsConfigFound;  StatusMsg: Установка системных компонентов ...; AfterInstall: AfterMSIInstall;
Filename: "xcopy.exe"; Parameters: """{tmp}\unpacked"" ""{code:GetTargetConfigPath}"" /C /R /Y"; Flags:runhidden; Check: IsWinSupported And IsDesktop And IsConfigFound; BeforeInstall: ClearConfigOrCreatePath

[Code]
const
  SHCONTCH_NOPROGRESSBOX = 4;
  SHCONTCH_RESPONDYESTOALL = 16;   
  UNIX_LF = #10; 

var ProfileArchiveFilePage: TInputFileWizardPage;
    DownloadPage: TDownloadWizardPage;
    ProfileArchiveLocation: String;
    ProfileArchiveName: String;
    ProfileName: String;
    UnpackedConfigPath: String;
    UnpackedConfigFile: String;
    ConfigIsAlreadyUnpacked: Boolean;

function IsProfileSelected: Boolean;
var selectedFile: String;
begin
  selectedFile := ProfileArchiveFilePage.Values[0]
  Result := (Pos('.zip', selectedFile) > 0)
end;

function GetCertArchivePath(Param: string): string;
var fileExt: String;
    fileName: String;
begin
  ProfileArchiveLocation := ProfileArchiveFilePage.Values[0];  
  Result := ProfileArchiveLocation

  if ProfileArchiveLocation <> '' Then
  begin
    fileName := ExtractFileName(ProfileArchiveLocation);
    fileExt := ExtractFileExt(ProfileArchiveLocation);
    StringChangeEx(fileName,fileExt,'', True);
    ProfileName := fileName
    ProfileArchiveName := ExtractFileName(ProfileArchiveLocation);
  end;
end;

function IsDomainMember: Boolean;
var
  ADSInfo: Variant;  
begin
  try
    Log('checking if domain member');
    ADSInfo := CreateOleObject('AdSystemInfo');
    Result := ADSinfo.DomainDNSName <> '';
    Log('workstation is domain member');
  except
    Result := False;
    Log('workstation is standalone');
  end;  
end;

function GetTargetConfigPath(Param: String): String;  
begin
    Result:= '{#OVPN_AUTOCONFIG_DIR}\';
    Log('initial config destination is ' + Result);
    if (Pos('$', UnpackedConfigFile) = 0) AND (IsDomainMember = False) Then
    begin        
        Result:= '{#OVPN_CONFIG_DIR}\';
        Log('set destination to ' + Result);
    end;
end;

function GetUnpackedConfigPath(Param: String): String;
begin
    Result:= UnpackedConfigPath;
end;

function GetUnpackedConfigFile(Param: String): String;
begin
    Result:= UnpackedConfigFile;
end;

function IsConfigFound: Boolean;
begin  
  Result := (Pos('.ovpn', UnpackedConfigFile) > 0)
end;

function StringListHasSubstring(const S: String; StringList: TStringList): Boolean;
var
  CurrentString: Integer;
begin
  Result := False;
CurrentString := 1;
Repeat
  if (Pos( S, StringList.Strings[CurrentString]) > 0) then begin
    Result := True;
    Break;
  end;
  CurrentString := CurrentString + 1;
Until CurrentString > (StringList.Count - 1 );
end;

Procedure ClearConfigOrCreatePath();
begin                      
  if IsConfigFound = False Then 
  begin
    Exit;
  end;
  Log('try clear config or create path');    
  if DirExists('{#OVPN_CONFIG_DIR}') Then 
  begin
    Log('clear dir ' + '{#OVPN_CONFIG_DIR}');
    DelTree('{#OVPN_CONFIG_DIR}', True, True, True);
  end;
  if Not DirExists('{#OVPN_CONFIG_DIR}') Then 
  begin
    Log('create dir {#OVPN_CONFIG_DIR}');
    CreateDir('{#OVPN_CONFIG_DIR}')
  end;
  if DirExists('{#OVPN_AUTOCONFIG_DIR}') Then 
  begin
    Log('clear dir ' + '{#OVPN_AUTOCONFIG_DIR}');
    DelTree('{#OVPN_AUTOCONFIG_DIR}', True, True, True);
  end;
  if Not DirExists('{#OVPN_AUTOCONFIG_DIR}') Then 
  begin
    Log('create dir {#OVPN_AUTOCONFIG_DIR}');
    CreateDir('{#OVPN_AUTOCONFIG_DIR}')
  end;
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

function IsWin1x: Boolean;
var
  Version: TWindowsVersion;
begin
  GetWindowsVersionEx(Version);
  Result := Version.Major = 10;
end;

function IsWinSupported: Boolean;
begin  
  Result := IsWin7881 Or IsWin1x;
end;

// установка флага ярлыка на рабочем столе - Запускать от администратора
// только если  CONFIG_SET_RUN_AS_ADMIN = 1
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
    Log('success');
  except
    Log('failed');
  finally
    Stream.Free;
  end;
end;

// настройка опций шифрования для совместимости со старым
// только если CONFIG_UPDATE_CIPHERS = 1
procedure UpdateConfigCiphers;
var
  IsUpdated: Boolean;
  IsKostyl: Boolean;
  Lines: TStringList;  
begin
  Lines := TStringList.Create;
  Log('check if legacy config *.ovpn - add ciphers, see /vpn/issues/10');
  IsUpdated := False;
  try
    Lines.LoadFromFile(UnpackedConfigFile);
    Log('total config lines: ' + IntToStr(Lines.Count)); 
    //IsKostyl := StringListHasSubstring('pavlov', Lines);       
    IsKostyl := Lines.IndexOf('MIIEcDCCA1igAwIBAgIJAPl9iP/O1JfxMA0GCSqGSIb3DQEBBQUAMIGAMQswCQYD') > -1;     
    If (IsKostyl = False) AND (Lines.Count > 50) then begin     
      exit;
    end;
    If ((IsKostyl = True) OR (Lines.IndexOf('cipher AES-256-CBC') > -1) OR (Lines.IndexOf('cipher BF-CBC') > -1)) then
    begin
       Log('found legacy cipher');
       If Lines.IndexOf('tls-cipher "DEFAULT:@SECLEVEL=0"') = -1 then 
       begin 
            IsUpdated := True;
            Log('add config file param tls-cipher');
            Lines.Add('tls-cipher "DEFAULT:@SECLEVEL=0"');
       end;
       // его выставляет compat-mode
       //If Lines.IndexOf('tls-version-min 1.0') = -1 then 
       //begin
       //     IsUpdated := True;
       //     Log('add config file param tls-version-min');
       //     Lines.Add('tls-version-min 1.0');
       //end;
       If Lines.IndexOf('compat-mode 2.3.6') = -1 then 
       begin
            IsUpdated := True;
            Log('add config file param compat-mode');
            Lines.Add('compat-mode 2.3.6');
       end;  
    end;
    If Lines.IndexOf('cipher BF-CBC') > -1 then
    begin
       If Lines.IndexOf('providers legacy default') = -1 then 
       begin 
            IsUpdated := True;
            Log('add config file param providers');
            Lines.Add('providers legacy default');
       end;       
    end;
    If IsUpdated = True Then
    begin
      Log('UPDATE config file!!!'); 
      Lines.SaveToFile(UnpackedConfigFile);
    end;
    Log('success');
  except
    Log('failed');
  finally
    Lines.Free;
  end;
end;

// распаковка архива встроенными средствами Windows 
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
      Format('Архив с настройками "%s" не удалось распаковать - запросите новую версию в техподдержке', [ZipPath]));

  TargetFolder := Shell.NameSpace(TargetPath);
  if VarIsClear(TargetFolder) then
    RaiseException(Format('Путь "%s" не найден', [TargetPath]));

  TargetFolder.CopyHere(ZipFile.Items, SHCONTCH_NOPROGRESSBOX or SHCONTCH_RESPONDYESTOALL); 
end;

// распаковка
procedure UnpackConfig();
var 
  unpacked: String;
  IsFound: Boolean;
  fileRec: TFindRec;
begin  
  if ConfigIsAlreadyUnpacked = True Then
  begin
    Log('config archive is already unpacked');
    exit;
  end;
  ConfigIsAlreadyUnpacked := True;
  IsFound := False; 
  unpacked := ExpandConstant('{tmp}\unpacked');  
  Log('creating temp unpacked ' + unpacked);
  CreateDir(unpacked);
  Log('created');
  Log('unzip  '+ ProfileArchiveLocation + ' to ' + unpacked + ' ...');
  UnZip(ProfileArchiveLocation, unpacked);
  Log('unzip completed');
  Log('lookup config file')
  if FindFirst(ExpandConstant(unpacked + '\*.ovpn'), fileRec) then
  try
      UnpackedConfigFile := unpacked + '\' + fileRec.Name;
      UnpackedConfigPath := unpacked; 
      Log('set UnpackedConfigPath=' + UnpackedConfigPath);
      IsFound := True;
  finally
    FindClose(fileRec);
  end;

  if IsFound = False Then
  begin
      MsgBox('Выбранный Вами архив с настройками не содержит файлов конфигурации OpenVPN - запросите новую версию в техподдержке', mbError, MB_OK);
      Log('FAILED: *.ovpn file not found in ZIP');      
      Exit;
  end;
  Log('found ' + UnpackedConfigFile);
  Log('unpacking config completed - ready to copy to destination');
end;


// задачи после установки MSI
procedure AfterMSIInstall();
begin
  if '{#CONFIG_SET_RUN_AS_ADMIN}' = '1' Then
  begin
    SetElevationBit;
  end;  
  if '{#CONFIG_UPDATE_CIPHERS}' = '1' Then
  begin
    UpdateConfigCiphers;
  end;
end;

// обновление индикатора загрузки на форме
Function OnDownloadProgress(const Url, FileName: String; const Progress, ProgressMax: Int64): Boolean;
begin
  if Progress = ProgressMax then
    Log(Format('successfully downloaded file to {tmp}: %s', [FileName]));
  Result := True;
end;    

// служебный код - инициализация мастера
Procedure InitializeWizard();
begin
  ProfileName:= '';

  //WizardForm.WelcomeLabel2.Font.Style := [fsBold]; //жирный текст в окне приветствия
  WizardForm.WelcomeLabel2.Font.Color := clRed; // красный
  WizardForm.WelcomeLabel2.Font.Size := 14; // красный

  ProfileArchiveFilePage :=
    CreateInputFilePage(
      wpWelcome,
      'Выберите файл',      
      'Архив с настройками вида ivanov.zip или comp100.zip. Выберите файл и нажмите ДАЛЕЕ',
      ''
    );

  ProfileArchiveFilePage.Add(
    'Архив с настройками:',         
    'архивы *.zip|*.zip', 
    ''
  );  
  
  ProfileArchiveFilePage.SubCaptionLabel.Font.Size := 10;
  ProfileArchiveFilePage.SubCaptionLabel.Font.Color := clRed;
  ProfileArchiveFilePage.SubCaptionLabel.Font.Style := [fsBold];

  DownloadPage := CreateDownloadPage(SetupMessage(msgWizardPreparing), SetupMessage(msgPreparingDesc), @OnDownloadProgress);
end;

// https://jrsoftware.org/ishelp/index.php?topic=scriptevents&anchor=CurPageChanged
procedure CurPageChanged(CurPageID: Integer);
begin
    if (CurPageID = wpFinished) then
    begin
      WizardForm.FinishedLabel.Caption := 'Если при подключении программа запросит пароль - укажите тот же, что и для входа в рабочий компьютер. Иконка у Вас на рабочем столе - посмотрите на неё на картинке слева';
    end
end;

// служебный код - обработчик перехода по экранам
function NextButtonClick(CurPageID: Integer): Boolean;
begin
  Result := True;
  // окно выбора архива с сертификатом
  if (CurPageID = ProfileArchiveFilePage.ID) AND (IsProfileSelected = False) then
  begin
    MsgBox('Выберите архив с настройками', mbError, MB_OK);
    Result := False;
    Exit;
  end;
  if CurPageID = wpReady then 
  // все готово к установке - скачиваем релиз и запускаем
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
            SuppressibleMsgBox('Не удалось загрузить программу для установки - проверьте доступ к сети Интернет и попробуйте позже', mbCriticalError, MB_OK, IDOK);
            Log('download FAILED: ' + GetExceptionMessage)
            Result := False;
            Exit;
            end
        end;
      finally
        DownloadPage.Hide;
      end;      
    end
end;

// дальше общесистемные функции - можно не смотреть

function GetAppID():string;
begin
  result := ExpandConstant('{#SetupSetting("AppID")}');     
end;

function GetAppUninstallRegKey():string;
begin
  result := ExpandConstant('Software\Microsoft\Windows\CurrentVersion\Uninstall\' + GetAppID + '_is1'); //Get the Uninstall search path from the Registry
end;

function IsAppInstalled():boolean;
var Key : string;          //Registry path to details about the current installation (uninstall info)
begin                            
  Key := GetAppUninstallRegKey;
  result := RegValueExists(HKEY_LOCAL_MACHINE, Key, 'UninstallString');
end;

//Return the install path used by the existing installation.
function GetInstalledPath():string;
var Key : string;
begin
  Key := GetAppUninstallRegKey;
  RegQueryStringValue(HKEY_LOCAL_MACHINE, Key, 'InstallLocation', result);
end;               

function MoveLogfileToLogDir():boolean;
var
  logfilepathname, logfilename, newfilepathname: string;
begin
  logfilepathname := expandconstant('{log}');

  //If logfile is disabled then logfilepathname is empty
  if logfilepathname = '' then begin
     result := false;
     exit;
  end;

  logfilename := ExtractFileName(logfilepathname);
  try
    //Get the install path by first checking for existing installation thereafter by GUI settings
    if IsAppInstalled then
       newfilepathname := GetInstalledPath + '\'
    else
       newfilepathname := expandconstant('{app}\');
  except
    //This exception is raised if {app} is invalid i.e. if canceled is pressed on the Welcome page
        try
          newfilepathname := WizardDirValue + '\'; 
        except
          //This exception is raised if WizardDirValue i s invalid i.e. if canceled is pressed on the Mutex check message dialog.
          result := false;
        end;
  end;  
  result := ForceDirectories(newfilepathname); //Make sure the destination path exists.
  newfilepathname := newfilepathname + logfilename; //Add filename

  //if copy successful then delete logfilepathname 
  result := filecopy(logfilepathname, newfilepathname, false);

  if result then
     result := DeleteFile(logfilepathname);
end;

//Called just before Setup terminates. Note that this function is called even if the user exits Setup before anything is installed.
procedure DeinitializeSetup();
begin
  MoveLogfileToLogDir;
end;