@echo off
SETLOCAL

:: Nombre del script PowerShell
set SCRIPT=GCP.ps1

:: Verificar si el script existe en el mismo directorio
if not exist "%~dp0%SCRIPT%" (
    echo No se encuentra el script: %SCRIPT%
    pause
    exit /b 1
)

:: Ejecutar como administrador
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "Start-Process PowerShell -ArgumentList '-ExecutionPolicy Bypass -NoProfile -File \"%~dp0%SCRIPT%\"' -Verb RunAs"

ENDLOCAL
