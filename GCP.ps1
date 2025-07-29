# ==================== CONFIGURACION ====================
$ErrorActionPreference = "Stop"

# URLs de descarga
$chromeUrl = "https://dl.google.com/chrome/install/latest/chrome_installer.exe"
$zipUrl = "https://github.com/WICardozo/GCPW/archive/refs/heads/main.zip"  # <-- Tu .zip que contiene el .exe

# Rutas temporales
$chromePath = "C:\Windows\Temp\ChromeSetup.exe"
$zipFilePath = "C:\Temp\GCPW.zip"
$extractPath = "C:\Temp\GCPW"
$logPath = "C:\Temp\gcpw_install_log.txt"

# ==================== VERIFICAR ADMIN ====================
If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "`n Este script debe ejecutarse como administrador." -ForegroundColor Red
    Exit 1
}

# ==================== INSTALAR CHROME ====================
Write-Host "`n Iniciando instalacion automatica de Google Chrome y GCPW..." -ForegroundColor Cyan

if ((Test-Path "C:\Program Files\Google\Chrome\Application\chrome.exe") -or (Test-Path "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe")) {
    Write-Host "Google Chrome ya está instalado."
} else {
    Write-Host "`n Descargando Google Chrome..."
    try {
        Invoke-WebRequest -Uri $chromeUrl -OutFile $chromePath -UseBasicParsing
        Write-Host " Instalando Chrome..."
        Start-Process -FilePath $chromePath -ArgumentList "/silent" -Wait
    } catch {
        Write-Host " Error al descargar o instalar Chrome: $_" -ForegroundColor Red
    }
}

# ==================== DESCARGAR ZIP ====================
Write-Host "`n Descargando ZIP de GCPW desde GitHub..."
try {
    Invoke-WebRequest -Uri $zipUrl -OutFile $zipFilePath -UseBasicParsing
    Write-Host " ZIP descargado correctamente."
} catch {
    Write-Host " Error al descargar el ZIP: $_" -ForegroundColor Red
    Exit 1
}

# ==================== EXTRAER ZIP ====================
if (Test-Path $extractPath) {
    Remove-Item -Path $extractPath -Recurse -Force
    Write-Host "Carpeta vieja eliminada."
}

try {
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::ExtractToDirectory($zipFilePath, $extractPath)
    Write-Host "Archivo ZIP descomprimido correctamente."
} catch {
    Write-Host " Error al descomprimir el ZIP: $_" -ForegroundColor Red
    Exit 1
}

# ==================== BUSCAR E INSTALAR EXE ====================
$gcpwExePath = Get-ChildItem -Path $extractPath -Recurse -Filter "GCPWInstaller.exe" -ErrorAction SilentlyContinue | Select-Object -First 1 | ForEach-Object { $_.FullName }

if (-Not (Test-Path $gcpwExePath)) {
    Write-Host "No se encontró GCPWInstaller.exe en el ZIP descomprimido." -ForegroundColor Red
    Exit 1
}

try {
    Write-Host "Instalando GCPW sin token..."
    Start-Process -FilePath $gcpwExePath -ArgumentList "/silent" -Wait -RedirectStandardOutput $logPath -RedirectStandardError $logPath
} catch {
    Write-Host " Error al instalar GCPW: $_" -ForegroundColor Red
    Exit 1
}

# ==================== VERIFICACION ====================
if (Test-Path "C:\Program Files\Google\GCPW\gcp_setup.exe") {
    Write-Host "GCPW instalado correctamente." -ForegroundColor Green
} else {
    Write-Host " GCPW no se instaló correctamente. Revisar el log en $logPath" -ForegroundColor Yellow
}
