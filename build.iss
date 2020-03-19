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
PrivilegesRequired=lowest

[Files]
Source: "*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\Менеджер сертификатов"; Filename: "{app}\cert-man.hta"

[Messages]
WelcomeLabel1=Установка программы для доступа к корпоративной сети
WelcomeLabel2=Для подключения Вам понадобится архив с настройками вида ivanov.tar.gz - заранее получите его через заявку в Техподдержке или у ответственного сотрудника в офисе
ClickNext=

;[Dirs]
;Name: "{app}"; Permissions: everyone-modify

[Languages]
Name: "ru"; MessagesFile: "compiler:Languages\Russian.isl"

[Run]
Filename: "{src}\openvpn-install-2.4.8-I602-Win10.exe"; Parameters: "/q /norestart"; WorkingDir: {src}; Check: Not IsFramework35Installed;  StatusMsg: Установка OpenVPN клиента... 
Filename: "{src}\cert-wiz.hta"; Flags: postinstall nowait skipifsilent runasoriginaluser shellexec

[Tasks]

[Code]
Function IsFramework35Installed : boolean;
var installed : cardinal;
    success: boolean;
Begin
  success := RegQueryDWordValue(HKLM, 'Software\Microsoft\NET Framework Setup\NDP\v3.5', 'Install', installed);
  result := success and (installed = 1);
End;

Function InitializeSetup(): Boolean;
begin
Result := True;
if (GetWindowsVersion >= $05010000) and IsAdmin then
  begin
    MsgBox('Не запускайте установку от имени Администратора - запустите просто двойным кликом', mbError, MB_OK);
    Result := False;
  end;
end;

Procedure InitializeWizard();
begin
  WizardForm.WelcomeLabel2.Font.Style := [fsBold]; //жирный текст в окне приветствия
  WizardForm.WelcomeLabel2.Font.Color := clRed; // красный
  WizardForm.WelcomeLabel2.Font.Size := 14; // красный
end;

procedure RunImportCertificatesWizard(Sender: TObject);
var
  ErrorCode: Integer;
begin
  ShellExecAsOriginalUser('open', 'https://jrsoftware.org/isdonate.php', '', '', SW_SHOWNORMAL, ewNoWait, ErrorCode);
end;