Import-Module Hyper-V

# Lokasi file Daftar VM yang inign dimigrasi
$csvPath = "C:\Path\To\Your\VMsToMigrate.csv"
$vmList = Import-Csv -Path $csvPath

foreach ($vm in $vmList) {
    $vmName          = $vm.VMName
    $destHost        = $vm.DestinationHost
    $destDirectory   = $vm.DestinationDirectory
    $migrationMethod = $vm.MigrationMethod
    
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
    }
    catch {
        Write-Output "Migrasi VM $vmName gagal. Pesan Error: $($_.Exception.Message)"
    }
    
    Write-Output "--------------------------------------------------"
}

Write-Output "Seluruh proses migrasi VM telah selesai."
