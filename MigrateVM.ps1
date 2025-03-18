Import-Module Hyper-V

# Lokasi file CSV input
$csvPath = "C:\Path\To\Your\VMsToMigrate.csv"

# Lokasi file CSV output 
$migrationResultsFile = "C:\Path\To\Your\MigrationResults.csv"

$vmList = Import-Csv -Path $csvPath

# Inisialisasi array untuk menyimpan hasil migrasi
$migrationResults = @()

foreach ($vm in $vmList) {
    $vmName           = $vm.VMName
    $destHost         = $vm.DestinationHost
    $destDirectory    = $vm.DestinationDirectory
    $migrationMethod  = $vm.MigrationMethod
    
    Write-Output "Mulai migrasi VM: $vmName ke host: $destHost pada direktori: $destDirectory (Metode: $migrationMethod)"

    if (-not (Test-Path -Path $destDirectory)) {
        try {
            New-Item -Path $destDirectory -ItemType Directory -Force -ErrorAction Stop | Out-Null
            Write-Output "Direktori $destDirectory tidak ada dan sudah dibuatkan."
        }
        catch {
            Write-Output "Gagal membuat direktori $destDirectory. Pesan Error: $($_.Exception.Message)"
            continue
        }
    }
    
    $startTime = Get-Date
    
    try {
        if ($migrationMethod -eq "Full") {
            Move-VM -Name $vmName `
                    -DestinationHost $destHost `
                    -DestinationStoragePath $destDirectory `
                    -IncludeStorage `
                    -ErrorAction Stop
        }
        else {
            Move-VM -Name $vmName `
                    -DestinationHost $destHost `
                    -DestinationStoragePath $destDirectory `
                    -ErrorAction Stop
        }
        Write-Output "Migrasi VM $vmName berhasil."
        $status = "Berhasil"
        $errorMessage = ""
    }
    catch {
        Write-Output "Migrasi VM $vmName gagal. Pesan Error: $($_.Exception.Message)"
        $status = "Gagal"
        $errorMessage = $_.Exception.Message
    }

    $endTime = Get-Date
    
    $result = [PSCustomObject]@{
        VMName              = $vmName
        DestinationHost     = $destHost
        DestinationDirectory= $destDirectory
        MigrationMethod     = $migrationMethod
        StartTime           = $startTime
        EndTime             = $endTime
        Status              = $status
        ErrorMessage        = $errorMessage
    }
    $migrationResults += $result
    
    Write-Output "--------------------------------------------------"
}

Write-Output "Seluruh proses migrasi VM telah selesai."

$migrationResults | Export-Csv -Path $migrationResultsFile -NoTypeInformation -Encoding UTF8

Write-Output "Hasil migrasi telah diekspor ke file: $migrationResultsFile"
