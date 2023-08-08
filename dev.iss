// править старые файлы конфигов https://gitea.ad.local/soho/vpn/issues/10
#define CONFIG_UPDATE_CIPHERS "1"

[Setup]
AllowCancelDuringInstall=no
AllowNoIcons=yes
AlwaysRestart=yes
AppComments=InnoSetup dev pkg
AppCopyright=Copyright (C) 2023 Sokho-Service LLC
AppId=innosetup_dev
AppName=InnoSetup Dev package
AppPublisher=Sokho-Service LLC
AppPublisherURL=https://soho-service.ru
AppVersion=2023.01.01
ChangesAssociations=yes
CloseApplications=yes
DefaultDirName={win}\soho-service.ru\repacks\dev
DirExistsWarning=no
DisableDirPage=yes
DisableProgramGroupPage=yes
DisableWelcomePage=no
FlatComponentsList=yes
OutputBaseFilename=inno-dev-x64
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

[Code]
// настройка опций шифрования для совместимости со старым
// только если CONFIG_UPDATE_CIPHERS = 1
const UnpackedConfigFile = 'c:\windows\soho-service.ru\tmp\_ovpn\demo.ovpn';

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
    Log(GetExceptionMessage);
    Log('workstation is standalone');
  end;  
end;

procedure UpdateConfigCiphers;
var
  IsUpdated: Boolean;
  Lines: TStringList;  
begin
  Lines := TStringList.Create;
  Log('check if legacy config *.ovpn - add ciphers, see /vpn/issues/10');
  IsUpdated := False;
  try
    Lines.LoadFromFile(UnpackedConfigFile);
    Log('total config lines: ' + IntToStr(Lines.Count)); 
    if Lines.Count > 50  then begin     
      exit;
    end;
    If (Lines.IndexOf('cipher AES-256-CBC') > -1) OR (Lines.IndexOf('cipher BF-CBC') > -1) then
    begin
       Log('found legacy cipher');
       If Lines.IndexOf('tls-cipher "DEFAULT:@SECLEVEL=0"') = -1 then 
       begin 
            IsUpdated := True;
            Log('add config file param tls-cipher');
            Lines.Add('tls-cipher "DEFAULT:@SECLEVEL=0"');
       end;
       If Lines.IndexOf('tls-version-min 1.0') = -1 then 
       begin
            IsUpdated := True;
            Log('add config file param tls-version-min');
            Lines.Add('tls-version-min 1.0');
       end;
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

procedure CurStepChanged(CurStep: TSetupStep);
begin
  if CurStep = ssPostInstall then
  begin
    Log('Post install');
    IsDomainMember
    if '{#CONFIG_UPDATE_CIPHERS}' = '1' Then
    begin
      UpdateConfigCiphers;
    end;
  end;
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