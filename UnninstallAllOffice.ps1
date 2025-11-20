#generado por perplexity 11/2025

    # Detener procesos de Office para evitar conflictos
$officeProcesses = "WINWORD","EXCEL","POWERPNT","OUTLOOK","MSACCESS","LYNC","ONENOTE","MSPUB","VISIO"
foreach ($proc in $officeProcesses) {
    Get-Process -Name $proc -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
}

# Función para ejecutar comando de desinstalación silenciosa
function Uninstall-OfficeFromString($UninstallString) {
    if ($UninstallString) {
        # Extraer ejecutable y argumentos
        if ($UninstallString -match '\"([^"]+)\"(.*)') {
            $exe = $matches[1]
            $args = $matches[2].Trim() + " /quiet /qn /norestart"
            Write-Host "Ejecutando desinstalación: $exe $args"
            Start-Process -FilePath $exe -ArgumentList $args -Wait -NoNewWindow
        } else {
            Write-Host "Cadena de desinstalación en formato inesperado: $UninstallString"
        }
    }
}

# Buscar en registro desinstaladores MSI y Click-to-Run (32 y 64 bits)
$registryPaths = @(
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
)

$officeUninstallStrings = @()

foreach ($path in $registryPaths) {
    $apps = Get-ItemProperty $path -ErrorAction SilentlyContinue | Where-Object {
        $_.DisplayName -match "Office" -and $_.UninstallString
    }
    foreach ($app in $apps) {
        $officeUninstallStrings += $app.UninstallString
    }
}

# Ejecutar desinstalación para cada desinstalador encontrado
foreach ($uninstallString in $officeUninstallStrings | Sort-Object -Unique) {
    Uninstall-OfficeFromString -UninstallString $uninstallString
}

# Desinstalar Microsoft 365 instalado desde Microsoft Store (Appx)
$storeApps = @(
    "Microsoft.Office.Desktop",
    "Microsoft.Office.OneNote",
    "Microsoft.Office.Lync",
    "Microsoft.Office.Outlook"
)

foreach ($appName in $storeApps) {
    $appPackage = Get-AppxPackage -Name $appName -ErrorAction SilentlyContinue
    if ($appPackage) {
        Write-Host "Desinstalando aplicación Store: $appName"
        Remove-AppxPackage -Package $appPackage.PackageFullName -ErrorAction SilentlyContinue
    }
}

Write-Host "Proceso de desinstalación completado. Se recomienda reiniciar el equipo."
