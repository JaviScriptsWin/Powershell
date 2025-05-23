# Lista de tareas crí­ticas que NO deben ser eliminadas
$criticalTasks = @(
    "*Windows*",        # Tareas de Windows
    "*Update*",         # Tareas de actualizaciones
    "*Defender*",       # Antivirus Microsoft Defender
    "*Microsoft*",      # Otras tareas de Microsoft
    "*TaskScheduler*",  # Tareas del propio Task Scheduler
    "*Mozilla*",        # Firefox
    "*NetCfgTask*"      # Red
    "PandaUSBVaccine"   # Panda USB Vaccine 
)

# Lista de patrones de nombres de tareas que se van a deshabilitar
$Disable_Tasks = @(
    "*Google*",   # Navegador Google Chrome
    "*Edge*",     # Navegador Edge
    "*onedrive*"    # OneDrive
)

# Obtener todas las tareas programadas del sistema
$Tasks = Get-ScheduledTask
$Tareas_Deshabilitadas = 0
$Tareas_NoDeshabilitadas = 0
$DisabledTasks = @()
$NotDisabledTasks = @()

$Tareas_Borradas =0
$Tareas_NoBorradas =0
$Tareas_Cri_NoBorradas =0

# ------------------Deshabilitar---------------
foreach ($task in $Tasks) {
    $taskName = $task.TaskName
    foreach ($pattern in $Disable_Tasks) {
        if ($taskName -like $pattern) {
            try {
                Disable-ScheduledTask -TaskName $taskName -TaskPath $task.TaskPath
                $Tareas_Deshabilitadas++
                $DisabledTasks += $taskName
                Write-Host "-> Tarea deshabilitada: $taskName"
            } catch {
                Write-Warning "No se pudo deshabilitar la tarea: $taskName"
                $Tareas_NoDeshabilitadas++
                $NotDisabledTasks += $taskName
            }
            break # Sale del bucle de patrones si ya deshabilitó la tarea
        }
    }
}
# ------------------Borrar---------------
foreach ($task in $tasks) {
    $taskName = $task.TaskName
    $shouldDelete = $true

    # Verificar si el identificador de seguridad está modificado
    try {
        $securityDescriptor = (Get-ScheduledTask -TaskName $taskName).SecurityDescriptor
        if ($securityDescriptor) {
            Write-Host "La tarea: $taskName tiene un identificador de Seguridad modificado. Posible ocultación."
        }
    } catch {
        Write-Warning "No se pudo acceder al identificador de seguridad de la tarea: $taskName. Posible modificación maliciosa."
        # Si no se puede acceder al identificador, podemos marcarla como sospechosa
    }

    # Comparar el nombre de la tarea con las crí­ticas
    foreach ($pattern in $criticalTasks) {
        if ($taskName -like $pattern) {
            Write-Host "Tarea crí­tica detectada: $taskName. No será eliminada."
            $shouldDelete = $false
            $Tareas_Cri_NoBorradas=$Tareas_Cri_NoBorradas+1
            break
        }
    }

    # Eliminar tarea si no está en la lista crí­tica
    if ($shouldDelete) {
        try {
           Unregister-ScheduledTask -TaskName $taskName -Confirm:$false   # ¡¡Borra la tarea !!
         
           $Tareas_Borradas =$Tareas_Borradas +1
           #write-warning ">> ELIMINADAS: $Tareas_Borradas  TAREAS"
           Write-Host "-> Tarea eliminada: $taskName"
        } catch {
            Write-Warning "No se pudo eliminar la tarea: $taskName. Posible manipulación."
            $Tareas_NoBorradas =$Tareas_NoBorradas +1
            $deletedTasks += $taskName
        }
    }
}  # ----------------------------------------------

# Guardar las tareas eliminadas en un archivo de registro
$deletedTasks | Export-Csv -Path "C:\TareasEliminadas.csv" -NoTypeInformation
$NotDisabledTasks  | Export-Csv -Path "C:\TareasDeshabilitadas.csv" -NoTypeInformation
write-warning ">> Tareas ELIMINADAS: $Tareas_Borradas  TAREAS"
write-warning ">> Tareas Criticas no eliminadas: $Tareas_Cri_NoBorradas  TAREAS"
write-warning ">> Tareas no borradas por posible manipulación: $Tareas_NoBorradas  TAREAS"
write-warning ">> Tareas deshabilitadas por cargar el sistema: $Tareas_Deshabilitadas  TAREAS"

Start-Sleep -Seconds 3

# Backup de las tareas programadas 
# Entorno de pruebas para las tareas programadas
# Obtenido de github