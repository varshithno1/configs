# Define the module names and executables
$modules = @("PSReadLine")
$executables = @("oh-my-posh.exe")

# Function to check internet connectivity
function Test-InternetConnection {
    try {
        Test-Connection -ComputerName "google.com" -Count 1 -Quiet
        return $true
    } catch {
        return $false
    }
}

# Function to check and install modules or executables if necessary
function Check-And-InstallModules {
    $output = @()

    # Check for modules first (e.g., PSReadLine)
    foreach ($module in $modules) {
        if (-not (Get-InstalledModule -Name $module -ErrorAction SilentlyContinue)) {
            $output += "$module is not installed."

            if (Test-InternetConnection) {
                $output += "Installing $module..."
                try {
                    Install-Module -Name $module -Scope CurrentUser -Force -SkipPublisherCheck
                } catch {
                    $errorMessage = $_.Exception.Message
                    $output += "Failed to install $module : $errorMessage"
                    return ,$false, $output
                }
            } else {
                $output += "No internet connection."
                return ,$false, $output
            }
        } else {
            $output += "$module is already installed."
        }
    }

    # Check for executables (e.g., oh-my-posh.exe)
    foreach ($exe in $executables) {
        if (-not (Get-Command -Name $exe -ErrorAction SilentlyContinue)) {
            $output += "$exe is not installed."

            if (Test-InternetConnection) {
                $output += "Installing $exe..."
                try {
                    if ($exe -eq "oh-my-posh.exe") {
                        Start-Process -FilePath "winget" -ArgumentList "install JanDeDobbeleer.OhMyPosh -s winget --force" -Wait
                    }
                } catch {
                    $errorMessage = $_.Exception.Message
                    $output += "Failed to install $exe : $errorMessage"
                    return ,$false, $output
                }
            } else {
                $output += "No internet connection."
                return ,$false, $output
            }
        } else {
            $output += "$exe is already installed."
        }
    }

    return ,$true, $output
}

$modulesInstalled, $outputMessages = Check-And-InstallModules
$outputMessages | ForEach-Object { Write-Output $_ }

if (-not $modulesInstalled) {
    Write-Output "Module and executable installation failed."
    exit
}

# If all modules and executables are installed, run the main script
$mainScriptPath = "$env:USERPROFILE\Documents\configs\powershell\scripts\main.ps1"
if ($modulesInstalled -and (Test-Path $mainScriptPath) -and $mainScriptPath.EndsWith(".ps1")) {
    Write-Output "Running main script..."
    . $mainScriptPath
} else {
    Write-Output "Failed to load main script."
}

