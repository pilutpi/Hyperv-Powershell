# Pastikan Anda menjalankan skrip ini dengan hak administratif

$vms = Get-VM

$vmData = @()

$maxDiskCount = $vms | ForEach-Object {
    (Get-VMHardDiskDrive -VMName $_.Name).Count
} | Measure-Object -Maximum
$maxDiskCount = $maxDiskCount.Maximum

$maxAdapterCount = $vms | ForEach-Object {
    (Get-VMNetworkAdapter -VMName $_.Name).Count
} | Measure-Object -Maximum
$maxAdapterCount = $maxAdapterCount.Maximum

foreach ($vm in $vms) {
    $vmName = $vm.Name
    $cpuCount = (Get-VMProcessor -VMName $vm.Name).Count
    $memoryAssigned = (Get-VMMemory -VMName $vm.Name).Startup / 1MB
    $memoryMin = (Get-VMMemory -VMName $vm.Name).Minimum / 1MB
    $memoryMax = (Get-VMMemory -VMName $vm.Name).Maximum / 1MB
    $diskInfo = Get-VMHardDiskDrive -VMName $vm.Name
    $networkAdapters = Get-VMNetworkAdapter -VMName $vm.Name

    $vmObject = [ordered]@{
        VMName         = $vmName
        CPUCount       = $cpuCount
        MemoryAssigned = "$memoryAssigned MB"
        MemoryRange    = "$memoryMin MB - $memoryMax MB"
    }

    for ($i = 0; $i -lt $maxDiskCount; $i++) {
        if ($i -lt $diskInfo.Count) {
            $vmObject["Harddisk$($i+1)Path"] = $diskInfo[$i].Path
            $vmObject["Harddisk$($i+1)Size"] = if (Test-Path $diskInfo[$i].Path) {
                "{0:N2} GB" -f ((Get-Item $diskInfo[$i].Path).Length / 1GB)
            } else { "N/A" }
        } else {
            $vmObject["Harddisk$($i+1)Path"] = "N/A"
            $vmObject["Harddisk$($i+1)Size"] = "N/A"
        }
    }

    for ($i = 0; $i -lt $maxAdapterCount; $i++) {
        if ($i -lt $networkAdapters.Count) {
            $adapter = $networkAdapters[$i]
            $ipv4Addresses = $adapter.IPAddresses | Where-Object { $_ -match '\b\d{1,3}(\.\d{1,3}){3}\b' } # Hanya IPv4
            $vmObject["Adapter$($i+1)MAC"] = $adapter.MacAddress
            $vmObject["Adapter$($i+1)Switch"] = $adapter.SwitchName
            $vmObject["Adapter$($i+1)VLAN"] = if ($adapter.VlanSetting.Enabled -eq $true) { $adapter.VlanSetting.AccessVlanId } else { "N/A" }
            $vmObject["Adapter$($i+1)IPv4"] = $ipv4Addresses -join ", "
        } else {
            $vmObject["Adapter$($i+1)MAC"] = "N/A"
            $vmObject["Adapter$($i+1)Switch"] = "N/A"
            $vmObject["Adapter$($i+1)VLAN"] = "N/A"
            $vmObject["Adapter$($i+1)IPv4"] = "N/A"
        }
    }

    $vmData += [PSCustomObject]$vmObject
}

$csvPath = "C:\VM_Specifications_with_Disk_and_Network.csv"
$vmData | Export-Csv -Path $csvPath -NoTypeInformation -Encoding UTF8

Write-Host "Data spesifikasi VM dengan Disk dan Network Adapter telah berhasil didata dan disimpan ke $csvPath."
