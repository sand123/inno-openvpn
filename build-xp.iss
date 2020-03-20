[Setup]
AppId=openvpn_s3ru_repack
DisableWelcomePage=no
AppName=OpenVPN S3RU Repack
AppComments=OpenVPN repacked by soho-service.ru support team
AppVersion=1.0.0.2
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
OutputBaseFilename=openvpn_2.4.8_winxp_s3ru_repack
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
WelcomeLabel1=��������� ��������� ��� ������� � ������������� ����
WelcomeLabel2=��� ����������� ��� ����������� ����� � ����������� ���� ivanov.tar.gz ��� ivanov.zip - ������� �������� ��� ����� ������ � ������������ ��� � �������������� ���������� � �����%n%n���������� ��������� ������ ����� ��������� ������
ClickNext=
FinishedLabelNoIcons=��������� ���������. ����� ������������ �� ������� ������������ - �������� �������� �� �������� ������
ClickFinish=��� ����������� ����������� ���� ����� � ������ ��� ����� � ������� ���������. ������ � ��� �� ������� ����� - ���������� �� �� �� �������� �����
FinishedRestartLabel=��� ���������� ����� ��������������� - ����� ����� ��� ����������� ����������� ���� ����� � ������ ��� ����� � ������� ���������. ������ � ��� �� ������� ����� - ���������� �� �� �� �������� �����

[Languages]
Name: "ru"; MessagesFile: "compiler:Languages\Russian.isl"

[Run]

Filename: "{app}\openvpn-install-2.3.18-I001-i686-WinXP.exe"; Parameters: "/SELECT_SHORTCUTS=1 /SELECT_OPENVPN=1 /SELECT_SERVICE=0 /SELECT_TAP=1 /SELECT_OPENVPNGUI=1 /SELECT_ASSOCIATIONS=0 /SELECT_OPENSSL_UTILITIES=0 /SELECT_EASYRSA=0 /SELECT_OPENSSLDLLS=1 /SELECT_LZODLLS=1 /SELECT_PKCS11DLLS=1 /S"; WorkingDir: {app}; Check: IsWinXP And IsDesktop;  StatusMsg: ��������� ��������� ����������� ...;
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

  WizardForm.WelcomeLabel2.Font.Style := [fsBold]; //������ ����� � ���� �����������
  WizardForm.WelcomeLabel2.Font.Color := clRed; // �������
  WizardForm.WelcomeLabel2.Font.Size := 12; // �������

  WizardForm.FinishedLabel.Caption := '������������� ��������� � ���������� ������������';

  ProfileArchiveFilePage :=
    CreateInputFilePage(
      wpWelcome,
      '�������� ����',      
      '����� � ����������� ���� ivanov.tar.gz ��� ivanov.zip. �������� ���� � ������� �����',
      ''
    );

  ProfileArchiveFilePage.Add(
    '����� � �����������:',         
    '������ *.zip *.tar.gz|*.*', 
    ''
  );  
  
  ProfileArchiveFilePage.SubCaptionLabel.Font.Size := 12;
  ProfileArchiveFilePage.SubCaptionLabel.Font.Color := clRed;
  ProfileArchiveFilePage.SubCaptionLabel.Font.Style := [fsBold];
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