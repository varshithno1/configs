clear

try {
    $connectionTest = Test-Connection -ComputerName 8.8.8.8 -Count 1 -Quiet -ErrorAction Stop
}
catch {
    $connectionTest = $false
}

if($connectionTest) {
    # If there is an internet connection, load the internet config
    oh-my-posh init pwsh --config (Get-ItemProperty -Path "HKCU:\Environment").ompThemeG | Invoke-Expression
    Write-Host "Loaded Global Path"
} else {
    # If there is no internet connection, load the local config
    oh-my-posh init pwsh --config (Get-ItemProperty -Path "HKCU:\Environment").ompThemeL | Invoke-Expression
    Write-Host "Loaded Local Path"
}



# Show PSReadLine history in a list view
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView


# Defining a function for exiting the shell
function exitF{
    exit
}

# Defining a function for copying current directory
function pwdCopy {
    "$PWD" | Set-Clipboard
    $PWD
}

# Defining a function for making next project
function createNext {
    npx create-next-app@latest .
}

# Defining a function for running npm project with dev
function runDev {
    npm run dev
}

# Defining a function for restarting terminal
function restartTerminal {
    . $PROFILE
}

# Defining a function for opening profile
function openProfile {
    code $PROFILE
}

# Defining a function for small fzf
function smallFZF {
    param (
        [Parameter(ValueFromPipeline = $true)]
        $input
    )
    begin {
        $items = @()
    }
    process {
        $items += $input
    }
    end {
        $items | fzf --height=60% --layout=reverse --border --margin=1 --padding=1
    }
}

# Defining a function for copying contents of the file
function copyBat {
    param (
        [Parameter(Mandatory = $true)]
        [string]$FilePath
    )

    if (Test-Path -Path $FilePath) {
        Get-Content -Path $FilePath -Raw | Set-Clipboard
        Write-Host "'$FilePath' has been copied."
        
        & "bat" $FilePath
    } else {
        Write-Host "Error: File '$FilePath' does not exist."
    }
}

# Defining a function for copying line of the file with fzf
function copyLine {
    param (
        [Parameter(Mandatory = $true)]
        [string]$FilePath
    )

    if (Test-Path -Path $FilePath) {
        $lines = Get-Content -Path $FilePath
        $selectedLine = $lines | smallFZF

        if ($selectedLine) {
            $selectedLine | Set-Clipboard
            Write-Host "Line has been copied."
        } else {
            Write-Host "No line selected."
        }
    } else {
        Write-Host "Error: File '$FilePath' does not exist."
    }
}


# Defining a function for puling the latest configurations from the repo
function UpdateLocalConfigs {
    if (-not $configPathL) {
        Write-Error "Error: $configPathL is not defined or empty."
        return
    }

    # Get the repository path
    $repoPath = Split-Path -Path $configPathL -Parent

    if (-not (Test-Path $repoPath)) {
        Write-Error "Error: The derived repository path `$repoPath` does not exist."
        return
    }

    try {
        # Run git pull in the background
        Start-Process git -ArgumentList "pull" -WorkingDirectory $repoPath -NoNewWindow -Wait
        Write-Host "Git pull completed successfully in $repoPath."
    } catch {
        Write-Error "Error: Failed to execute git pull. Details: $_"
    }
}

# Defining a function for setting local git config
function setGitConfig {
    param(
        [string]$Email,
        [string]$Name
    )

    git config user.email $Email
    git config user.name $Name
}

# function for checking pakages
function checkWrapper {
    . "$env:USERPROFILE\Documents\configs\powershell\scripts\checkWrapper.ps1"
}

# Defining a function that sets the global theme
function setThemeG {
    param (
        [Parameter(Mandatory = $true)]
        [string]$theme
    )
    
    [System.Environment]::SetEnvironmentVariable("ompThemeG", "$theme", "User")

    
    . $PROFILE
}

# Defining a function that sets the local theme
function setThemeL {
    param (
        [Parameter(Mandatory = $true)]
        [string]$theme
    )
    
    [System.Environment]::SetEnvironmentVariable("ompThemeL", "$theme", "User")

    
    . $PROFILE
}

$test = "https://raw.githubusercontent.com/varshithno1/configs/master/powershell/omp/varshith.omp.json"

# Creating an alias for the exit function
Set-Alias e exitF

# Creating an alias for the clear command
Set-Alias c clear

# Creating an alias for the path copy function
Set-Alias pw pwdCopy

# Creating an alias for the create next project function
Set-Alias cnxt createNext

# Creating an alias for the run dev function
Set-Alias rdev runDev

# Creating an alias for updating my config changes
Set-Alias uomp UpdateLocalConfigs

# Creating an alias for zoxide
Set-Alias z zoxide.exe

# Creating an alias for restarting terminal
Set-Alias rs restartTerminal
Set-Alias z zoxide.exe

# Creating an alias for opening profile
Set-Alias op openProfile

# Creating an alias for small fzf
Set-Alias fsf smallFZF

# Creating an alias for copy bat
Set-Alias cbat copyBat

# Creating an alias for copy bat line
Set-Alias cl copyLine

# Creating an alias for setting local git config
Set-Alias gcl setGitConfig

# Creating an alias for checking pakages
Set-Alias womp checkWrapper

# Creating an alias for setting global theme
Set-Alias sompg setThemeG

# Creating an alias for setting local theme
Set-Alias sompl setThemeL

# Shows the powershell version
"" + $PSVersionTable.PSVersion.Major + "." + $PSVersionTable.PSVersion.Minor
