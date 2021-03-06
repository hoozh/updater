; example1.nsi
;
; This script is perhaps one of the simplest NSIs you can make. All of the
; optional settings are left to their default settings. The installer simply 
; prompts the user asking them where to install, and drops a copy of example1.nsi
; there. 

;--------------------------------

!include FileFunc.nsh
!include LogicLib.nsh
!include WordFunc.nsh
!include MUI.nsh

!define RESOURCE_FOLDER           ".\res"
!define MUI_ICON                  "${RESOURCE_FOLDER}\icon.ico"    ; icon

;Languages 
!insertmacro MUI_LANGUAGE "English"
!insertmacro MUI_LANGUAGE "SimpChinese"

LangString STR_ERR_DOWNLOAD_FAILED            ${LANG_ENGLISH}     "ERROR: Failed to download file: "
LangString STR_ERR_DOWNLOAD_FAILED            ${LANG_SIMPCHINESE} "错误: 下载文件失败: "

LangString STR_ERR_VERSION_EMPTY              ${LANG_ENGLISH}     "ERROR: Remote version is empty"
LangString STR_ERR_VERSION_EMPTY              ${LANG_SIMPCHINESE} "错误: 远程版本号为空"

LangString STR_ERR_APP_UPDATE                 ${LANG_ENGLISH}     "The application is up to date"
LangString STR_ERR_APP_UPDATE                 ${LANG_SIMPCHINESE} "应用程序已经是最新版本"

LangString STR_ERR_FILENAME_EMPTY             ${LANG_ENGLISH}     "ERROR: Remote file name is empty"
LangString STR_ERR_FILENAME_EMPTY             ${LANG_SIMPCHINESE} "错误: 远程文件名为空"

LangString STR_ERR_MD5_EMPTY                  ${LANG_ENGLISH}     "ERROR: Remote MD5 value is empty"
LangString STR_ERR_MD5_EMPTY                  ${LANG_SIMPCHINESE} "错误: 远程 MD5 值为空"

LangString STR_DOWNLOAD                       ${LANG_ENGLISH}     "Download"
LangString STR_DOWNLOAD                       ${LANG_SIMPCHINESE} "下载"

LangString STR_SUCCESSFULLY                   ${LANG_ENGLISH}     "successfully"
LangString STR_SUCCESSFULLY                   ${LANG_SIMPCHINESE} "成功"

LangString STR_CALCU_MD5                      ${LANG_ENGLISH}     "Calculating MD5 value"
LangString STR_CALCU_MD5                      ${LANG_SIMPCHINESE} "正在计算 MD5 值"

LangString STR_MD5_VALUE                      ${LANG_ENGLISH}     "MD5 value: "
LangString STR_MD5_VALUE                      ${LANG_SIMPCHINESE} "MD5 值: "

LangString STR_ERR_MD5_NOT_MATCH              ${LANG_ENGLISH}     "ERROR: MD5 not match"
LangString STR_ERR_MD5_NOT_MATCH              ${LANG_SIMPCHINESE} "错误: MD5 值校验失败"

LangString STR_NEW_VERSION_READY              ${LANG_ENGLISH}     "New version of the software is ready, click OK to start installation."
LangString STR_NEW_VERSION_READY              ${LANG_SIMPCHINESE} "新版本软件已经准备好，点击 确定 开始安装"

; The name of the installer
Name "Auto Update"

; The file to write
OutFile "..\bin\updater.exe"

; The default installation directory
;InstallDir $DESKTOP\Example1

; Request application privileges for Windows Vista
RequestExecutionLevel user

;--------------------------------

; Pages

;Page directory
;Page instfiles

; 服务端的地址，包括目录名，如 http://www.company.com/s-eye
Var ArgServerURL

; 服务器端的 ini 文件名称
Var ArgIniName

; 当前的软件版本，由本机软件传递过来，用于跟服务器端的版本做计较
Var ArgVersion

; 无需更新时，是否提示
Var ArgPrompt


; Ini 文件中读出的文件名
Var IniFileName
Var IniMD5



; 下载的 Ini 文件路径
Var LocalIni

; 下载的安装包件路径
Var LocalSetupPath


;--------------------------------

; The stuff to install
Section "" ;No components page, name is not important

SetDetailsView show

${GetParameters} $R0

${GetOptions} $R0 "-URL=" $ArgServerURL
${GetOptions} $R0 "-INI=" $ArgIniName
${GetOptions} $R0 "-VER=" $ArgVersion
${GetOptions} $R0 "-PRT=" $ArgPrompt
;DetailPrint "-INI= $ArgServerURL"
;DetailPrint "-EXE= $ArgIniName"
;DetailPrint "-VER= $ArgVersion"


${If} $ArgServerURL == ""
${OrIf} $ArgIniName == ""
${OrIf} $ArgVersion == ""
  MessageBox MB_OK "ERROR: Wrong options"
  Quit
${EndIf}

;
StrCpy $LocalIni $TEMP\$ArgIniName
NSISdl::download $ArgServerURL/$ArgIniName $LocalIni

Pop $0 ;Get the return value
  StrCmp $0 success success
  MessageBox MB_OK $(STR_ERR_DOWNLOAD_FAILED)$0
  Quit
success:
  ReadINIStr $R0 $LocalIni "Information" "Version"
  ${If} $R0 == ""
    MessageBox MB_OK $(STR_ERR_VERSION_EMPTY)
    Quit
  ${EndIf}
  
  ${VersionCompare} $R0 $ArgVersion $0
  ${If} $0 == 0
  ${OrIf} $0 == 2
    ${If} $ArgPrompt == "true"
        MessageBox MB_OK $(STR_ERR_APP_UPDATE)
    ${EndIf}
    Quit
  ${EndIf}
  
  ReadINIStr $IniFileName $LocalIni "Information" "Filename"
  ${If} $IniFileName == ""
    MessageBox MB_OK $(STR_ERR_FILENAME_EMPTY)
    Quit
  ${EndIf}
  
  ReadINIStr $IniMD5 $LocalIni "Information" "MD5"
  ${If} $IniMD5 == ""
    MessageBox MB_OK $(STR_ERR_MD5_EMPTY)
    Quit
  ${EndIf}
  
  
  StrCpy $LocalSetupPath $TEMP\$IniFileName
  
  NSISdl::download $ArgServerURL/$IniFileName $LocalSetupPath
  Pop $0 ;Get the return value
   StrCmp $0 success success1
   MessageBox MB_OK $(STR_ERR_DOWNLOAD_FAILED)$0
   Quit
 success1:
   DetailPrint "$(STR_DOWNLOAD) $LocalSetupPath $(STR_SUCCESSFULLY)"
   DetailPrint $(STR_CALCU_MD5)
   md5dll::GetMD5File $LocalSetupPath
   Pop $0
   DetailPrint $(STR_MD5_VALUE)$0
   ${If} $0 != $IniMD5
     MessageBox MB_OK $(STR_ERR_MD5_NOT_MATCH)
     Quit
   ${EndIf}
   
   MessageBox MB_OKCANCEL $(STR_NEW_VERSION_READY) IDCANCEL lbl_QUIT
   Exec $LocalSetupPath
   
lbl_QUIT:
   Delete $LocalSetupPath
   Quit
SectionEnd ; end the section