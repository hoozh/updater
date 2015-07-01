# update.exe 更新软件使用说明

### 简介
update.exe 软件一个用于从 HTTP 服务器上下载软件安装包并执行安装的程序。 update.exe 是基于 NSIS 开发的。

### 使用说明
update.exe 接受四个命令行参数，可在命令行中直接调用，或者在windows程序中，用CreateProcess构建

#### 参数说明
- -URL: 更新文件所在的HTTP服务器地址以及目录，比如 http://www.domain.com/folder
- -INI: ini 文件名称
- -VER: 待更新的软件版本
- -PRT: 当软件不需要更新时，是否弹出提示。 true： 弹出提示

#### 命令行格式：
    update.exe -url="http://127.0.0.1" -ini=config.ini -ver=1.0 -prt=true

#### CreateProcess 方式：
    TCHAR lpPath[MAX_PATH], lpCmdLine[MAX_PATH];
    _tcscpy(lpCmdLine, TEXT(" -url="));
    _tcscat(lpCmdLine, AUTO_UPDATE_URL);
    _tcscat(lpCmdLine, TEXT(" -ini="));
    _tcscat(lpCmdLine, AUTO_UPDATE_INI_FILE);
    _tcscat(lpCmdLine, TEXT(" -ver="));
    _tcscat(lpCmdLine, APPLICATION_VERSION); //TODO 获取版本号
    _tcscat(lpCmdLine, TEXT(" -prt=true"));
    
    WinKT_GetModulePath(NULL, lpPath, MAX_PATH);
    _tcscat(lpPath, TEXT("update.exe"));
    _tcscat(lpPath, lpCmdLine);
    if (!WinKT_CreateProcess(NULL, lpPath)) {
        MessageBox(_T("启动更新程序失败"));
    }

### ini 文件格式

    [Information]
    ; 服务器上的安装包文件名，必须和本ini文件在同一目录
    Filename = Setup_1.1.exe

    ; 安装包的版本号
    Version  = 1.1

    ; 安装包文件的 MD5 值
    MD5      = 5e02441c7f3fa4da4f4928a2d42a07c3