@echo off
setlocal EnableExtensions DisableDelayedExpansion
for /F "skip=2 tokens=1,2*" %%N in ('%SystemRoot%\System32\reg.exe query "HKEY_CURRENT_USER\Environment" /v "Path" 2^>nul') do (
    if /I "%%N" == "Path" (
        set "UserPath=%%P"
        if defined UserPath goto CheckPath
    )
)

set "UseSetx=1"
if not "%CD:~1024,1%" == "" set "UseSetx="
if not exist %SystemRoot%\System32\setx.exe set "UseSetx="
if defined UseSetx (
    %SystemRoot%\System32\setx.exe Path "%CD%" >nul
) else (
    %SystemRoot%\System32\reg.exe ADD "HKCU\Environment" /f /v Path /t REG_SZ /d "%CD%" >nul
)

endlocal
goto :EOF

:CheckPath
setlocal EnableDelayedExpansion
set "Separator="
if not "!UserPath:~-1!" == ";" set "Separator=;"
set "PathCheck=!UserPath!%Separator%"
if "!PathCheck:%CD%;=!" == "!PathCheck!" (
    set "PathToSet=!UserPath!%Separator%%CD%"
    set "UseSetx=1"
    if not "!PathToSet:~1024,1!" == "" set "UseSetx="
    if not exist %SystemRoot%\System32\setx.exe set "UseSetx="
    if defined UseSetx (
        %SystemRoot%\System32\setx.exe Path "!PathToSet!" >nul
    ) else (
        set "ValueType=REG_EXPAND_SZ"
        if "!PathToSet:%%=!" == "!PathToSet!" set "ValueType=REG_SZ"
        %SystemRoot%\System32\reg.exe ADD "HKCU\Environment" /f /v Path /t !ValueType! /d "!PathToSet!" >nul
    )
)
endlocal
endlocal
