; Print Server - Inno Setup Installer Script
; This creates a professional Windows installer (.exe)

#define MyAppName "Print Server"
#define MyAppVersion "1.0.0"
#define MyAppPublisher "Your Company"
#define MyAppURL "http://localhost:9191"
#define MyAppExeName "Start-PrintServer.bat"
#define NodeJSVersion "20.11.0"

[Setup]
AppId={{8D26B5B4-420B-A03F-8202-AFFA9D9D561A}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={autopf}\{#MyAppName}
DefaultGroupName={#MyAppName}
AllowNoIcons=yes
LicenseFile=LICENSE.txt
OutputDir=installer-output
OutputBaseFilename=PrintServer-Setup
SetupIconFile=icon.ico
Compression=lzma
SolidCompression=yes
WizardStyle=modern
PrivilegesRequired=admin
ArchitecturesAllowed=x64
ArchitecturesInstallIn64BitMode=x64

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked
Name: "autostart"; Description: "Start Print Server automatically on Windows startup"; GroupDescription: "Startup Options:"; Flags: checkedonce
Name: "firewall"; Description: "Configure Windows Firewall (allow port 9191)"; GroupDescription: "Network:"; Flags: checkedonce

[Files]
; Application files
Source: "printServer.js"; DestDir: "{app}"; Flags: ignoreversion
Source: "package.json"; DestDir: "{app}"; Flags: ignoreversion
Source: "node_modules\*"; DestDir: "{app}\node_modules"; Flags: ignoreversion recursesubdirs createallsubdirs

; Node.js portable (you need to download and place in nodejs folder)
Source: "nodejs\*"; DestDir: "{app}\nodejs"; Flags: ignoreversion recursesubdirs createallsubdirs

; Launcher scripts
Source: "Start-PrintServer.bat"; DestDir: "{app}"; Flags: ignoreversion
Source: "Stop-PrintServer.bat"; DestDir: "{app}"; Flags: ignoreversion

; Documentation
Source: "README.txt"; DestDir: "{app}"; Flags: ignoreversion isreadme
Source: "HOW_TO_RUN.txt"; DestDir: "{app}"; Flags: ignoreversion

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{group}\Stop Print Server"; Filename: "{app}\Stop-PrintServer.bat"
Name: "{group}\Open Print Server"; Filename: "http://localhost:9191"
Name: "{group}\{cm:UninstallProgram,{#MyAppName}}"; Filename: "{uninstallexe}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
; Configure firewall
Filename: "netsh"; Parameters: "advfirewall firewall add rule name=""Print Server"" dir=in action=allow protocol=TCP localport=9191"; Flags: runhidden; Tasks: firewall
; Start server after installation
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent

[UninstallRun]
; Remove firewall rule
Filename: "netsh"; Parameters: "advfirewall firewall delete rule name=""Print Server"""; Flags: runhidden
; Stop server
Filename: "taskkill"; Parameters: "/F /FI ""WINDOWTITLE eq Print Server*"""; Flags: runhidden

[Registry]
; Auto-start on Windows startup
Root: HKCU; Subkey: "Software\Microsoft\Windows\CurrentVersion\Run"; ValueType: string; ValueName: "PrintServer"; ValueData: """{app}\Start-PrintServer.bat"""; Flags: uninsdeletevalue; Tasks: autostart

[Code]
function InitializeSetup(): Boolean;
begin
  Result := True;
  if not IsAdmin then
  begin
    MsgBox('This installer requires Administrator privileges.', mbError, MB_OK);
    Result := False;
  end;
end;

procedure CurStepChanged(CurStep: TSetupStep);
begin
  if CurStep = ssPostInstall then
  begin
    // Additional post-install tasks can go here
  end;
end;
