$repoUrl = "https://github.com/addreeh/InitAPH/archive/refs/heads/main.zip"
$downloadPath = "$env:TEMP\InitAPH.zip"
$baseExtractPath = "$env:TEMP\InitAPH"
$scriptToRun = "InitAPH.ps1"

Write-Output "El script se está ejecutando desde: $PSScriptRoot"

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
