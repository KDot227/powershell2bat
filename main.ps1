$convert_code_string = 'iex ([System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String((Get-Content "test.ps1" -raw -split "`n" | Where-Object {$_ -match "::KDOT::"}).Split("::KDOT::")[1])))'
$batch_code = @'
@echo off
setlocal

powershell -exec bypass -C "iex ([Text.Encoding]::UTF8.GetString([Convert]::FromBase64String((Get-Content '%~f0' -raw | Select-String (':' + ':KDOT::(.*)')).Matches.Groups[1].Value)))"

::KDOT::REPLACE_ME

endlocal
exit /b
'@

function main {
    $code_location = Read-Host "Enter the location of the ps1 file -> "

    if (Test-Path $code_location) {
        $code = Get-Content $code_location -raw
    } else {
        Write-Host "File does not exist"
        return
    }

    $code_bytes = [System.Text.Encoding]::UTF8.GetBytes($code)

    $code_base64 = [System.Convert]::ToBase64String($code_bytes)

    $batch_code = $batch_code -replace "REPLACE_ME", $code_base64

    Set-Content "out.bat" $batch_code -Force

    Write-Host "Batch file created successfully"
}

main