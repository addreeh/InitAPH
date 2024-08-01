$repoUrl = "https://github.com/addreeh/InitAPH/archive/refs/heads/main.zip"
$downloadPath = "$env:TEMP\InitAPH.zip"
$baseExtractPath = "$env:TEMP\InitAPH"
$scriptToRun = "InitAPH.ps1"

# Función para verificar si se está utilizando PowerShell 7
function Is-PowerShell7 {
    return $PSVersionTable.PSVersion.Major -ge 7
}

# Función para descargar e instalar PowerShell 7
function Install-PowerShell7 {
    $installerUrl = "https://github.com/PowerShell/PowerShell/releases/download/v7.3.4/PowerShell-7.3.4-win-x64.msi" # Asegúrate de que esta URL apunta a la última versión
    $installerPath = "$env:TEMP\PowerShell-7.3.4-win-x64.msi"

    Write-Output "Descargando PowerShell 7 desde $installerUrl..."
    Invoke-WebRequest -Uri $installerUrl -OutFile $installerPath

    Write-Output "Instalando PowerShell 7..."
    Start-Process msiexec.exe -ArgumentList "/i", $installerPath, "/quiet", "/norestart" -NoNewWindow -Wait

    Write-Output "PowerShell 7 instalado."
}

# Función para ejecutar el script con PowerShell 7
function Run-With-PowerShell7 {
    $pwshPath = "$env:ProgramFiles\PowerShell\7\pwsh.exe"
    $scriptPath = "$PSScriptRoot\$scriptToRun"

    if (Test-Path $pwshPath) {
        Write-Output "Ejecutando el script con PowerShell 7..."
        Start-Process -FilePath $pwshPath -ArgumentList "-File $scriptPath" -NoNewWindow -Wait
    } else {
        Write-Output "PowerShell 7 no se encontró en la ruta esperada."
    }
}

Write-Output "El script se esta ejecutando desde $PSScriptRoot"

# Verificar si PowerShell 7 está instalado en el sistema
$pwshPath = "$env:ProgramFiles\PowerShell\7\pwsh.exe"

if (-not (Is-PowerShell7) -and -not (Test-Path $pwshPath)) {
    Write-Output "PowerShell 7 no está instalado o no se está utilizando. Procediendo con la instalación..."
    Install-PowerShell7

    Write-Output "Reiniciando el script con PowerShell 7..."
    Run-With-PowerShell7
    exit
} elseif (-not (Is-PowerShell7) -and (Test-Path $pwshPath)) {
    Write-Output "PowerShell 7 está instalado pero no se está utilizando. Reiniciando el script con PowerShell 7..."
    Run-With-PowerShell7
    exit
}

# Continuar con la descarga y ejecución del script
if (Test-Path -Path $downloadPath) {
    Write-Host "El archivo ZIP ya existe, eliminando..."
    Remove-Item -Path $downloadPath -Force
}

$extractPath = $baseExtractPath
$index = 1

while (Test-Path -Path $extractPath) {
    $extractPath = "${baseExtractPath}_$index"
    $index++
}

Write-Output "Creando el directorio: $extractPath..."
New-Item -ItemType Directory -Path $extractPath -Force

Write-Output "Descargando el repositorio desde $repoUrl..."
Invoke-WebRequest -Uri $repoUrl -OutFile $downloadPath

Write-Output "Descomprimiendo el archivo en $extractPath..."
Expand-Archive -Path $downloadPath -DestinationPath $extractPath

$repoFolder = Get-ChildItem -Path $extractPath | Where-Object { $_.PSIsContainer } | Select-Object -First 1
$scriptPath = Join-Path -Path $repoFolder.FullName -ChildPath $scriptToRun

if (Test-Path -Path $scriptPath) {
    Write-Output "Ejecutando el script $scriptPath..."
    & $scriptPath
} else {
    Write-Output "El script $scriptToRun no se encontró en el repositorio descomprimido."
}

Write-Output "Proceso completado."
