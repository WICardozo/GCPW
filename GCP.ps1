# Requiere ejecución como administrador
if (-not ([Security.Principal.WindowsPrincipal] `
    [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "Este script debe ejecutarse como administrador." -ForegroundColor Red
    exit 1
}

# Verifica si Chrome está instalado
function Chrome-Instalado {
    $paths = @(
        "$env:ProgramFiles\Google\Chrome\Application\chrome.exe",
        "$env:ProgramFiles(x86)\Google\Chrome\Application\chrome.exe"
    )
    return $paths | Where-Object { Test-Path $_ } | Measure-Object | Select-Object -ExpandProperty Count
}

# Verifica si GCPW está instalado
function GCPW-Instalado {
    $path = "$env:ProgramFiles\Google\GCPW\gcp_setup.exe"
    return Test-Path $path
}

# Instalar archivo .exe o .msi de forma silenciosa
function Instalar-Archivo ($path, $tipo) {
    $nombre = Split-Path $path -Leaf
    Write-Host "Instalando $nombre de forma silenciosa..."
    if ($tipo -eq "exe") {
        Start-Process -FilePath $path -ArgumentList "/silent", "/install" -Wait
    } elseif ($tipo -eq "msi") {
        Start-Process -FilePath "msiexec.exe" -ArgumentList "/i", "`"$path`"", "/qn" -Wait
    }
}

# Iniciar un servicio
function Iniciar-Servicio ($nombre) {
    Write-Host "Iniciando servicio '$nombre'..."
    Start-Service -Name $nombre -ErrorAction SilentlyContinue
}

# ---------------------
# Lógica principal
# ---------------------

$chromePath = "C:\Windows\Temp\ChromeSetup.exe"
$gcpwPath   = "C:\Windows\Temp\GCPWInstaller.msi"

# Instalar Chrome
if (Chrome-Instalado -gt 0) {
    Write-Host "Google Chrome ya está instalado."
} else {
    Write-Host "Instalando Google Chrome..."
    $chromeUrl = "https://dl.google.com/chrome/install/latest/chrome_installer.exe"
    Invoke-WebRequest -Uri $chromeUrl -OutFile $chromePath
    Instalar-Archivo -path $chromePath -tipo "exe"
}

# Instalar GCPW
if (GCPW-Instalado) {
    Write-Host "GCPW ya está instalado."
} else {
    Write-Host "Instalando GCPW desde GitHub..."
    $gcpwUrl = "https://github.com/WICardozo/GCPW/raw/main/GCPWInstaller.msi"
    Invoke-WebRequest -Uri $gcpwUrl -OutFile $gcpwPath
    Instalar-Archivo -path $gcpwPath -tipo "msi"
}

# Iniciar servicio de actualización
Iniciar-Servicio -nombre "gupdate"

# Limpiar instaladores
try {
    if (Test-Path $chromePath) { Remove-Item $chromePath -Force }
    if (Test-Path $gcpwPath)    { Remove-Item $gcpwPath -Force }
    Write-Host "Instaladores eliminados de C:\Windows\Temp."
} catch {
    Write-Host "No se pudieron eliminar todos los archivos: $_"
}

Write-Host "`nProceso finalizado correctamente." -ForegroundColor Green
