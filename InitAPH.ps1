# URL del archivo DLL que deseas descargar
$downloadUrl = "https://github.com/addreeh/InitAPH/raw/main/Wpf.Ui.dll"

# Ruta temporal para guardar el archivo DLL
$tempDllPath = "$ENV:temp\Wpf.Ui.dll"

# Descargar el archivo DLL
Invoke-WebRequest -Uri $downloadUrl -OutFile $tempDllPath

Add-Type -AssemblyName PresentationFramework
# Add-Type -LiteralPath "./Wpf.Ui.dll"
Add-Type -LiteralPath $tempDllPath

# XAML string
$xaml = @"
<ui:FluentWindow xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" 
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" 
    xmlns:ui="http://schemas.lepo.co/wpfui/2022/xaml"
    ExtendsContentIntoTitleBar="True"
    WindowCornerPreference="Round"
    WindowStartupLocation="CenterScreen"
    ResizeMode="NoResize"
    x:Name="Window" Height="750" Width="400" Title="InitAPH">
    <ui:FluentWindow.Resources>
        <ResourceDictionary>
            <ResourceDictionary.MergedDictionaries>
                <ui:ThemesDictionary Theme="Dark"/>
                <ui:ControlsDictionary/>
            </ResourceDictionary.MergedDictionaries>
        </ResourceDictionary>
    </ui:FluentWindow.Resources>
    <Grid>
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="*"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
        </Grid.RowDefinitions>
        <ui:TitleBar Title="InitAPH"/>
        <ui:InfoBar
            x:Name="LongInfoBar"
            Title="Alerta"
            Grid.Row="0"
            Margin="20,45,20,0"
            IsOpen="True"
            Message="Crea un punto de restauración."
            Severity="Warning" />
        <ScrollViewer Grid.Row="1" VerticalScrollBarVisibility="Auto" Margin="30,5,0,0">
            <StackPanel x:Name="CheckBoxPanel"/>
        </ScrollViewer>
        <Grid Grid.Row="2">
            <Grid.ColumnDefinitions>
                <ColumnDefinition Width="Auto"/>
                <ColumnDefinition Width="*"/>
                <ColumnDefinition Width="Auto"/>
            </Grid.ColumnDefinitions>
            <Button Grid.Column="0" Margin="30,0,0,20" Content="Select All" x:Name="SelectAll" HorizontalAlignment="Left"/>
            <Button Grid.Column="2" Margin="0,0,30,20" Content="Install" x:Name="Install" HorizontalAlignment="Right" IsEnabled="False"/>
        </Grid>
    </Grid>
</ui:FluentWindow>
"@

# Load the XAML
[xml]$xamlXml = $xaml
$reader = (New-Object System.Xml.XmlNodeReader $xamlXml)
$window = [Windows.Markup.XamlReader]::Load($reader)

# Packages
$packages = @{
    "webdev" = @{
        "name" = "Web Dev"
        "apps" = @(
            @{ "id" = "Microsoft.VisualStudioCode"; "name" = "Visual Studio Code"; "winget" = $true },
            @{ "id" = "VSCodium"; "name" = "Visual Studio Codium"; "winget" = $true },
            @{ "id" = "OpenJS"; "name" = "NodeJS"; "winget" = $true },
            @{ "id" = "pnpm"; "name" = "pnpm"; "winget" = $true },
            @{ "id" = "Git"; "name" = "Git"; "winget" = $true }
        )
    };
    "daily"  = @{
        "name" = "Daily Use"
        "apps" = @(
            @{ "id" = "Brave"; "name" = "Brave Browser"; "winget" = $true },
            @{ "id" = "7zip"; "name" = "7zip"; "winget" = $true },
            @{ "id" = "Discord"; "name" = "Discord"; "winget" = $true },
            @{ "id" = "voidtools.Everything.Alpha"; "name" = "Everything"; "winget" = $true }
        )
    };
    "hackie" = @{
        "name" = "Hackie"
        "apps" = @(
            @{ "id" = "Vencord"; "name" = "Vencord"; "winget" = $false; "publisher" = "Vendicated"; "homepage" = "https://vencord.dev/"; "image" = "https://vencord.dev" },
            @{ "id" = "SpotX"; "name" = "SpotX"; "winget" = $false; "publisher" = "amd64fox"; "homepage" = "https://github.com/SpotX-Official/SpotX"; "image" = "https://spotify.com" },
            @{ "id" = "OOSU10"; "name" = "OOSU10"; "winget" = $false; "publisher" = "OO Software"; "homepage" = "https://www.oo-software.com/en/shutup10"; "image" = "https://www.oo-software.com/en/shutup10" },
            @{ "id" = "MassGrave"; "name" = "MassGrave"; "winget" = $false; "publisher" = "WindowsAddict"; "homepage" = "https://massgrave.dev/"; "image" = "https://massgrave.dev/" }
        )
    };
    "lenovo" = @{
        "name" = "Lenovo"
        "apps" = @(
            @{ "id" = "BartoszCichecki"; "name" = "Lenovo Legion Toolkit"; "winget" = $true }
        )
    }
}

$global:PackageInfo = @{}


foreach ($package in $packages.GetEnumerator()) {
    $packageName = $package.Value.name
    $apps = $package.Value.apps
    foreach ($app in $apps) {
        if ($app.winget -eq $true) {
            $info = Get-WingetPackageInfo $app.id
            # Write-Host "INFO $info"
            $app.publisher = $info.Publisher
            $app.version = $info.LatestVersion
            $app.description = $info.Description
            $app.homepage = $info.HomePage
        }
    }
}

    
# foreach ($entry in $global:PackageInfo.GetEnumerator()) {
#     $packageId = $entry.Key
#     $packageInfo = $entry.Value

#     Write-Host "Package ID: $packageId"
#     Write-Host "Name: $($packageInfo.Name)"
#     Write-Host "Publisher: $($packageInfo.Publisher)"
#     Write-Host "Latest Version: $($packageInfo.LatestVersion.Version)"
#     Write-Host "Description: $($packageInfo.Description)"
#     Write-Host "-------------"
# }

function Get-WingetPackageInfo {
    param (
        [string]$packageId
    )

    $apiUrl = "https://api.winget.run/v2/packages/$packageId"

    if ($packageId -eq "Microsoft.VisualStudioCode") {
        $apiUrl = "https://api.winget.run/v2/packages/Microsoft/VisualStudioCode"
    }
    elseif ($packageId -eq "voidtools.Everything.Alpha") {
        $apiUrl = "https://api.winget.run/v2/packages/voidtools/Everything.Alpha"
    }
    
    try {
        $response = Invoke-RestMethod -Uri $apiUrl -Method Get -ContentType "application/json"
 
        if ($response -is [string]) {
            $response = $response | ConvertFrom-Json -AsHashtable
        }

        $packageInfo = @()
        
        
        if ($packageId -eq "Microsoft.VisualStudioCode" -or $packageId -eq "voidtools.Everything.Alpha") {
            $package = $response.Package
        }
        else {
            $package = $response.Packages[0]
        }
        
        $latestVersion = $package.Versions | Select-Object -First 1
            
        $packageInfo = [PSCustomObject]@{
            ID            = $packageId
            Name          = $package.Latest.Name
            Publisher     = $package.Latest.Publisher
            LatestVersion = $latestVersion
            Description   = $package.Latest.Description
            HomePage      = $package.Latest.Homepage
        }

        # Write-Host $packageInfo
        
        # Guardar la información en la variable global
        # $global:PackageInfo[$packageId] = $packageInfo
        
        return $packageInfo
    }
    catch {
        Write-Host "Error al obtener información para el paquete $packageId : $_"
        return $null
    }
}

function Show-PackageInfoById {
    param (
        [Parameter(Mandatory = $true)]
        [string]$packageId
    )

    Write-Host "ID DENTRO $packageId"
    
    # Verifica si la información del paquete está disponible en $global:PackageInfo
    if ($global:PackageInfo.ContainsKey($packageId)) {
        $packageInfo = $global:PackageInfo[$packageId]
        
        # Muestra la información del paquete
        Write-Host "Package ID: $packageId"
        Write-Host "Name: $($packageInfo.Name)"
        Write-Host "Publisher: $($packageInfo.Publisher)"
        Write-Host "Latest Version: $($packageInfo.LatestVersion.Version)"
        Write-Host "Description: $($packageInfo.Description)"
        Write-Host "-------------"
    }
    else {
        Write-Host "No information available for package ID: $packageId"
    }
}
function New-CustomTooltip {
    param (
        [Parameter(Mandatory = $true)]
        [string]$ImagePath,
        
        [Parameter(Mandatory = $true)]
        [string]$Field1,
        
        [Parameter(Mandatory = $true)]
        [string]$Field2,
        
        [Parameter(Mandatory = $true)]
        [string]$Field3
    )

    $escapedImagePath = [System.Web.HttpUtility]::HtmlEncode($ImagePath)
    $escapedField1 = [System.Web.HttpUtility]::HtmlEncode($Field1)
    $escapedField2 = [System.Web.HttpUtility]::HtmlEncode($Field2)
    $escapedField3 = [System.Web.HttpUtility]::HtmlEncode($Field3)

    $xaml = @"
    <ToolTip xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" 
        xmlns:ui="http://schemas.lepo.co/wpfui/2022/xaml"
        Width="1000">
    <Grid>
        <Grid.ColumnDefinitions>
            <ColumnDefinition Width="Auto"/>
            <ColumnDefinition Width="*"/>
        </Grid.ColumnDefinitions>

        <ui:Image Source="$escapedImagePath" CornerRadius="4" BorderBrush="#33000000" Width="50" Height="50" Margin="0,0,10,0" Grid.Column="0"/>

        <StackPanel Grid.Column="1">
            <TextBlock Text="$escapedField1" Margin="0,0,0,5"/>
            <TextBlock Text="$escapedField2" Margin="0,0,0,5"/>
            <TextBlock Text="$escapedField3" Margin="0,0,0,5"/>
        </StackPanel>
    </Grid>
</ToolTip>
"@

    $reader = [System.Xml.XmlReader]::Create([System.IO.StringReader]::new($xaml))
    return [System.Windows.Markup.XamlReader]::Load($reader)
}

# Get the StackPanel where CheckBoxes will be added
$CheckBoxPanel = $window.FindName("CheckBoxPanel")

$selectAllCheckBoxes = @{}

foreach ($category in $packages.Keys) {
    $categoryData = $packages[$category]
    $categoryName = $categoryData["name"]
    # $categoryDescription = "Category: $category" 
    $apps = $categoryData["apps"]

    # Create "Select All" CheckBox
    $selectAllCheckBox = New-Object Windows.Controls.CheckBox
    $selectAllCheckBox.Content = $categoryName
    $selectAllCheckBox.Tag = $category
    # $selectAllCheckBox.ToolTip = $categoryDescription
    $CheckBoxPanel.Children.Add($selectAllCheckBox)

    $checkBoxes = @()
    foreach ($package in $apps) {
        $packageName = $package["name"]
        $packageId = $package["id"]
        $packagePublisher = $package["publisher"]
        $packageVersion = $package["version"]
        $packageDescription = $package["description"]
        $packageHomepage = $package["homepage"]

        Write-Host $packageName

        if ($packageVersion.Length -eq 0) {
            $packageVersion = "X.X"
        }

        $tag = "$category-$packageId"

        # Show-PackageInfoById -packageId $packageId
        
        $checkBox = New-Object Windows.Controls.CheckBox
        $checkBox.Content = $packageName
        $checkBox.Tag = $tag
        $checkBox.Margin = [Windows.Thickness]::new(24, 0, 0, 0)
        
        # Recuperar la información del paquete desde la variable global $global:PackageInfo
        
        if ($packageInfo -ne $null) {
            $toolTip = New-CustomTooltip -ImagePath "https://www.google.com/s2/favicons?sz=64&domain_url=$packageHomepage" `
                -Field1 "$packageName | v$packageVersion"`
                -Field2 "by $packagePublisher" `
                -Field3 "$packageHomepage"
        
        }
        else {
            $toolTip = "No information available"
        }
        
        $checkBox.ToolTip = $toolTip
        
        $CheckBoxPanel.Children.Add($checkBox)
        $checkBoxes += $checkBox
        
        # Event handlers for individual CheckBox
        $checkBox.Add_Checked({
                param ($sender, $eventArgs)
                UpdateInstallButtonState
                Handle-CheckBox $selectAllCheckBox ($category -replace '\s+', '-')
            })
        $checkBox.Add_Unchecked({
                param ($sender, $eventArgs)
                UpdateInstallButtonState
                Handle-CheckBox $selectAllCheckBox ($category -replace '\s+', '-')
            })
    }
    
    

    $selectAllCheckBoxes[$category] = $checkBoxes

    # Event handlers for "Select All" CheckBox
    $selectAllCheckBox.Add_Checked({
            param ($sender, $eventArgs)
            Handle-SelectAll $sender
        })
    $selectAllCheckBox.Add_Unchecked({
            param ($sender, $eventArgs)
            Handle-UnselectAll $sender
        })
}


function Handle-SelectAll($sender) {
    $checkBoxPanel = $window.FindName("CheckBoxPanel")

    $senderTag = $sender.Tag

    foreach ($child in $checkBoxPanel.Children) {
        if ($child -is [Windows.Controls.CheckBox]) {
            $checkBox = [Windows.Controls.CheckBox]$child
            
            if ($checkBox.Tag -like "$senderTag-*") {
                $checkBox.IsChecked = $true
            }
        }
    }
}

function Handle-UnselectAll($sender) {
    $checkBoxPanel = $window.FindName("CheckBoxPanel")

    $senderTag = $sender.Tag

    foreach ($child in $checkBoxPanel.Children) {
        if ($child -is [Windows.Controls.CheckBox]) {
            $checkBox = [Windows.Controls.CheckBox]$child
            
            if ($checkBox.Tag -like "$senderTag-*") {
                $checkBox.IsChecked = $false
            }
        }
    }
}

function Handle-CheckBox($selectAllCheckBox, $pack) {
    $checkBoxes = $selectAllCheckBoxes[$pack -replace '\s+', '-']
    if (-not $checkBoxes) {
        return
    }

    $allChecked = $true
    $allUnchecked = $true

    foreach ($checkBox in $checkBoxes) {
        if ($checkBox.IsChecked -ne $true) {
            $allChecked = $false
        }
        if ($checkBox.IsChecked -ne $false) {
            $allUnchecked = $false
        }
    }

    if ($allChecked) {
        $selectAllCheckBox.IsChecked = $true
    }
    elseif ($allUnchecked) {
        $selectAllCheckBox.IsChecked = $false
    }
    else {
        $selectAllCheckBox.IsChecked = $null
    }
}

function UpdateInstallButtonState {
    $checkBoxPanel = $window.FindName("CheckBoxPanel")
    $installButton = $window.FindName("Install")
    
    $atLeastOneChecked = $false

    foreach ($child in $checkBoxPanel.Children) {
        if ($child -is [System.Windows.Controls.CheckBox] -and $child.IsChecked -eq $true) {
            $atLeastOneChecked = $true
            break
        }
    }

    if ($atLeastOneChecked) {
        $installButton.IsEnabled = $true
    }
    else {
        $installButton.IsEnabled = $false
    }
}

# Button click event
$SelectAllButton = $window.FindName("SelectAll")
$SelectAllButton.Add_Click({
        foreach ($child in $CheckBoxPanel.Children) {
            if ($child -is [System.Windows.Controls.CheckBox]) {
                $child.IsChecked = $true
            }
        }
    })    

$FlyoutButton = $window.FindName("FlyoutButton")

$installablePackages = New-Object System.Collections.Generic.List[PSObject]
$nonInstallablePackages = New-Object System.Collections.Generic.List[PSObject]

$installXAML = @"
<ui:FluentWindow xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" 
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" 
    xmlns:ui="http://schemas.lepo.co/wpfui/2022/xaml"
    WindowCornerPreference="Round"
    WindowStartupLocation="CenterScreen"
    x:Name="Window" Height="100" Width="100">
    <ui:FluentWindow.Resources>
        <ResourceDictionary>
            <ResourceDictionary.MergedDictionaries>
                <ui:ThemesDictionary Theme="Dark"/>
                <ui:ControlsDictionary/>
            </ResourceDictionary.MergedDictionaries>
        </ResourceDictionary>
    </ui:FluentWindow.Resources>
    <Grid VerticalAlignment="Center" HorizontalAlignment="Center">
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
        </Grid.RowDefinitions>
        <TextBlock x:Name="StatusTextBlock" Grid.Row="0" Text="Instalando Winget" VerticalAlignment="Center" HorizontalAlignment="Center"/>
        <ProgressBar x:Name="ProgressBar" Grid.Row="1" IsIndeterminate="True" Margin="0,40,0,0"/>
    </Grid>
</ui:FluentWindow>
"@

# Load the XAML
[xml]$installXamlXml = $installXAML
$reader = (New-Object System.Xml.XmlNodeReader $installXamlXml)
$installWindow = [Windows.Markup.XamlReader]::Load($reader)

# Find the TextBlock control
$StatusTextBlock = $installWindow.FindName("StatusTextBlock")

# Function to update the TextBlock text
function Update-StatusText {
    param (
        [string]$newText
    )
    $StatusTextBlock.Dispatcher.Invoke([Action] {
            $StatusTextBlock.Text = $newText
        })
}

$InstallButton = $window.FindName("Install")
$InstallButton.Add_Click({
        Write-Host "pepe"
        $installWindow.Show()
        Install-All
    })

function Install-Winget {
    # Check if Winget is installed
    if (!(Get-Command winget -ErrorAction SilentlyContinue)) {
        Write-Host "Winget is not installed. Attempting to install..."

        Update-StatusText -newText "Installing Winget..."
                
        $latestWingetMsixBundleUri = $(Invoke-RestMethod https://api.github.com/repos/microsoft/winget-cli/releases/latest).assets.browser_download_url | Where-Object { $_.EndsWith(".msixbundle") }
        $latestWingetMsixBundle = $latestWingetMsixBundleUri.Split("/")[-1]
                
        Invoke-WebRequest -Uri $latestWingetMsixBundleUri -OutFile "./$latestWingetMsixBundle"
        Add-AppxPackage -Path $latestWingetMsixBundle
                
        Remove-Item $latestWingetMsixBundle    
        if (!(Get-Command winget -ErrorAction SilentlyContinue)) {
            Write-Host "Failed to install Winget. Please install it manually and then run the program again."
            exit
        }
    }
    else {
        Write-Host "Winget ya está instalado"
    }

    Update-StatusText -newText "Winget instalado"
}

function Install-Applications {
    param (
        [array]$applications
    )
    Update-StatusText -newText "Instalando aplicaciones..."

    foreach ($app in $applications) {
        Update-StatusText -newText "Instalando $($app.name)"
        Write-Host "Verificando si $($app.Name) ya está instalado..."

        $isInstalled = winget list --id $app.ID | Select-String $app.ID

        if ($isInstalled) {
            Write-Host "$($app.Name) ya está instalado. Omitiendo."
        }
        else {
            Write-Host "Instalando $($app.Name)..."
            
            # Ejecutar el proceso de instalación y esperar a que termine
            winget install $app.Id --silent
                
            # Verificar el código de salida del proceso
            if ($LASTEXITCODE -eq 0) {
                Write-Host "$($app.Name) instalado correctamente."
            }
            else {
                Write-Host "Error al instalar $($app.Name). Código de salida: $LASTEXITCODE"
            }
        }
    }
}

function Install-Vencord {
    Update-StatusText -newText "Instalando Vencord..."
    
    $urlCliInstaller = "https://github.com/Vencord/Installer/releases/latest/download/VencordInstallerCli.exe"
    
    # Crear una carpeta temporal
    $tempDir = [System.IO.Path]::Combine([System.IO.Path]::GetTempPath(), [System.IO.Path]::GetRandomFileName())
    New-Item -ItemType Directory -Path $tempDir | Out-Null
    
    $cliInstallerPath = [System.IO.Path]::Combine($tempDir, "VencordInstallerCli.exe")

    # Descargar el instalador
    Invoke-WebRequest -Uri $urlCliInstaller -OutFile $cliInstallerPath

    # Comprobar si la descarga fue exitosa
    if (Test-Path $cliInstallerPath) {
        # Intentar ejecutar el instalador con el parámetro --install
        try {
            Start-Process -FilePath $cliInstallerPath -ArgumentList "--branch auto --install" -Wait -NoNewWindow
            Write-Host "Vencord instalado exitosamente."
        }
        catch {
            Write-Host "El instalador no se pudo ejecutar."
        }
        finally {
            # Eliminar el instalador y la carpeta temporal
            Remove-Item -Path $cliInstallerPath -Force
            Remove-Item -Path $tempDir -Force
        }
    }
    else {
        Write-Host "No se pudo descargar el instalador."
    }
}

function Install-SpotX {
    Update-StatusText -newText "Instalando SpotX..."
    
    Invoke-Expression "& { $(Invoke-WebRequest -useb 'https://raw.githubusercontent.com/SpotX-Official/spotx-official.github.io/main/run.ps1') } -confirm_uninstall_ms_spoti -confirm_spoti_recomended_over -podcasts_off -block_update_on -start_spoti -new_theme -adsections_off -lyrics_stat spotify"
}

function Install-OOSU10 {
    Update-StatusText -newText "Instalando OOSU10..."
    
    try {
        $OOSU_filepath = "$ENV:temp\OOSU10.exe"
        Invoke-WebRequest -Uri "https://dl5.oo-software.com/files/ooshutup10/OOSU10.exe" -OutFile $OOSU_filepath
        Write-Host "Starting OO Shutup 10 ..."
        $oosu_config = "$ENV:temp\ooshutup10_recommended.cfg"
        Invoke-WebRequest -Uri "https://raw.githubusercontent.com/ChrisTitusTech/winutil/main/config/ooshutup10_recommended.cfg" -OutFile $oosu_config
        Write-Host "Applying recommended OO Shutup 10 Policies"
        Start-Process $OOSU_filepath -ArgumentList "$oosu_config /quiet" -Wait
    }
    catch {
        Write-Host "Error Downloading and Running OO Shutup 10" -ForegroundColor Red
    }
}

function Install-MassGrave {
    Invoke-RestMethod https://get.activated.win | Invoke-Expression
}

function Install-NonApplications {
    param (
        [array]$applications
    )

    foreach ($app in $applications) {
        Write-Host "APP $($app.Name)"

        # Construir el nombre de la función a llamar
        $functionName = "Install-$($app.Name)"
        
        # Verificar si la función existe antes de llamarla
        if (Get-Command -Name $functionName -CommandType Function -ErrorAction SilentlyContinue) {
            Write-Host "Calling function: $functionName"
            Update-StatusText -newText "Instalando $($app.Name)..."
            & $functionName
        }
        else {
            Write-Host "Function $functionName does not exist."
        }
    }
}

function Install-All {
    Write-Host "DENTRO"
    Update-StatusText -newText "Instalando aplicaciones..."

    foreach ($category in $packages.Keys) {
        foreach ($package in $packages[$category]["apps"]) {
            # Encontrar el CheckBox correspondiente para este paquete
            $checkBox = $CheckBoxPanel.Children | Where-Object { $_.Tag -eq "$category-$($package["id"])" }

            # Verificar si el CheckBox está marcado
            if ($checkBox -and $checkBox.IsChecked -eq $true) {
                # Agregar el paquete al array de paquetes seleccionados
                if ($package["winget"] -eq $true) {
                    $installablePackages.Add([PSCustomObject]@{
                            Name = $package["name"]
                            ID   = $package["id"]
                        })
                }
                else {
                    $nonInstallablePackages.Add([PSCustomObject]@{
                            Name = $package["name"]
                            ID   = $package["id"]
                        })
                }

                # Opcionalmente, puedes imprimir la información
                Write-Host "Selected: $($package["name"]) (ID: $($package["id"]))"
            }
        }
    }

    Install-Winget

    # Llamar a la función de instalación de aplicaciones aquí si es necesario
    Install-Applications $installablePackages
    Install-NonApplications $nonInstallablePackages

    Update-StatusText -newText "Instalación completada"
}

# Mostrar la ventana
$window.ShowDialog() | Out-Null
