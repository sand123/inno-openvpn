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
const UnpackedConfigFile = 'p:\Downloads\_ovpn\demo.ovpn';

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
    end;
    If Lines.IndexOf('cipher BF-CBC') > -1 then
    begin
       If Lines.IndexOf('providers legacy default') = -1 then 
       begin 
            IsUpdated := True;
            Log('add config file param providers');
            Lines.Add('providers legacy default');
       end;
       If Lines.IndexOf('compat-mode 2.3.6') = -1 then 
       begin
            IsUpdated := True;
            Log('add config file param compat-mode');
            Lines.Add('compat-mode 2.3.6');
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
    UpdateConfigCiphers();
  end;
end;