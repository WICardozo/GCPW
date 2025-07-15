@echo off
:: Lanza PowerShell como administrador y ejecuta el script con RemoteSigned temporal

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
 "Set-ExecutionPolicy RemoteSigned -Scope Process -Force; ^
  & 'C:\Users\July\Desktop\GCP.ps1'"

pause
