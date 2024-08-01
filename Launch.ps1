$repoUrl = "https://github.com/addreeh/InitAPH/archive/refs/heads/main.zip"
$downloadPath = "$env:TEMP\InitAPH.zip"
$extractPath = "$env:TEMP\InitAPH"
$scriptToRun = "InitAPH.ps1"

if (Test-Path -Path $downloadPath) {
    Remove-Item -Path $downloadPath -Force
}

if (Test-Path -Path $extractPath) {
    Remove-Item -Path $extractPath -Recurse -Force
}

if (-Not (Test-Path -Path $extractPath)) {
    New-Item -ItemType Directory -Path $extractPath
}

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
