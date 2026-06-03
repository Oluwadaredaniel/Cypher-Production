; CYPHER Professional Windows Installer
; Script generated for Inno Setup 6+

[Setup]
AppId={{C7895A2B-1234-4567-8901-ABCDEF123456}
AppName=Cypher
AppVersion=1.0.0
DefaultDirName={autopf}\Cypher
DefaultGroupName=Cypher
AllowNoIcons=yes
OutputDir=setup_output
OutputBaseFilename=Cypher_Setup_v1
Compression=lzma
SolidCompression=yes
WizardStyle=modern
PrivilegesRequired=admin

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
; Flutter Build Artifacts (Assuming you have run 'flutter build windows --release')
Source: "build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
; Note: We will add the Python backend executable here after compiling with PyInstaller

[Icons]
Name: "{group}\Cypher"; Filename: "{app}\cypher_pc.exe"
Name: "{autodesktop}\Cypher"; Filename: "{app}\cypher_pc.exe"; Tasks: desktopicon

[Run]
Filename: "{app}\cypher_pc.exe"; Description: "{cm:LaunchProgram,Cypher}"; Flags: nowait postinstall skipifsilent
