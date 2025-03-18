# Path Direktori VM 
$vmPath = "D:\VM"

# Path untuk Output CSV
$outputCsv = "D:\VM_Sizes.csv"

$data = @()

$directories = Get-ChildItem -Path $vmPath -Directory

foreach ($dir in $directories) {
    try {
        $sizeBytes = (Get-ChildItem -Path $dir.FullName -Recurse -File -ErrorAction Stop | Measure-Object -Property Length -Sum).Sum
        $sizeGB = [math]::Round($sizeBytes / 1GB, 2)
        $data += [PSCustomObject]@{
            DirectoryName = $dir.Name
            SizeInGB      = "$sizeGB GB"
            ErrorMessage  = ""
        }
    } catch {
        $errorMessage = "Gagal memproses direktori '$($dir.Name)' dengan pesan error : $($_.Exception.Message)"
        Write-Output $errorMessage

        $data += [PSCustomObject]@{
            DirectoryName = $dir.Name
            SizeInGB      = "N/A"
            ErrorMessage  = $errorMessage
        }
    }
}

# Ekspor data ke CSV
try {
    $data | Export-Csv -Path $outputCsv -NoTypeInformation -Encoding UTF8
    Write-Output "Data telah diekspor ke file CSV: $outputCsv"
} catch {
    $errorMessage = "Gagal memproess informasi direktori ke CSV. Pesan Error: $($_.Exception.Message)"
    Write-Output $errorMessage
}
