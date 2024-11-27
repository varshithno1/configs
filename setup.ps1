# $configLoc = (Get-ItemProperty -Path "HKCU:\Environment").configLoc
# $main = $configLoc + "\powershell\scripts\main.ps1"

# $mainFileExists = Test-Path $main

# if( -not ($mainFileExists))
# {
#     Write-Host " The location of the config is not corectly defined " -BackgroundColor Red
# }

# $scriptFolderPath = $PSScriptRoot

# [System.Environment]::SetEnvironmentVariable("configLoc", "$scriptFolderPath", "User")

# $userInput = Read-Host "Do you want to continue? (""y"" [Yes]/ ""n"" [No])"

