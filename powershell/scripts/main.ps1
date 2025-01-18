clear

$configLoc = (Get-ItemProperty -Path "HKCU:\Environment").configLoc
$main = $configLoc + "\powershell\scripts\main.ps1"

$mainFileExists = Test-Path $main


try {
    $connectionTest = Test-Connection -ComputerName 8.8.8.8 -Count 1 -Quiet -ErrorAction Stop
}
catch {
    $connectionTest = $false
}

if($connectionTest) {
    # If there is an internet connection, load the internet config
    oh-my-posh init pwsh --config (Get-ItemProperty -Path "HKCU:\Environment").ompThemeG | Invoke-Expression
    Write-Host "Loaded " -NoNewline; Write-Host " Global Path " -BackgroundColor Green -ForegroundColor Black
} else {
    # If there is no internet connection, load the local config
    oh-my-posh init pwsh --config (Get-ItemProperty -Path "HKCU:\Environment").ompThemeL | Invoke-Expression
    Write-Host "Loaded " -NoNewline; Write-Host " Local Path " -BackgroundColor Blue -ForegroundColor Black
}



# Show PSReadLine history in a list view
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView

function ERROR {
    param (
        [Parameter(Mandatory = $true)]
        [string]$text
    )

    Write-Host " $text " -BackgroundColor red
}

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

# Defining a function for opening main profile
function openProfileMain {
    if( -not ($mainFileExists))
    {
        ERROR "Location of config not correctly defined!!"
        return
    }
    
    code $main
}

# Defining a function for opening links on the desktop
function startApplication {
    param (
        [Parameter(Mandatory=$true)]
        [string]$app,

        [string]$link
    )

    $desktopPath = "$env:USERPROFILE\Desktop"
    
    if (-not (Test-Path $desktopPath)) {
        ERROR "Desktop Location is invalid - $desktopPath"
        return
    }

    $shortcut = Get-ChildItem -Path $desktopPath -Filter "$app.lnk" -ErrorAction SilentlyContinue

    if (-not $shortcut) {
        ERROR "Shortcut '$app.lnk' not found on the Desktop."
        return
    }

    if ($PSCmdlet.MyInvocation.BoundParameters['link']) {
        Start-Process $shortcut.FullName $link
    } else {
        Start-Process $shortcut.FullName
    }
}

# Defining a function for copying location after printing it
function copyLocation {
    Get-Location | Set-Clipboard
    Get-Location
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

    # Get the repository path
    $repoPath = (Get-ItemProperty -Path "HKCU:\Environment").configLoc

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
    . (Get-ItemProperty -Path "HKCU:\Environment").ompThemeG + "powershell\scripts\checkWrapper.ps1"
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

# Define the function to compile, run and delete C++ files
function CompileRunDeleteCpp {
    param (
        [string]$cppFilePath
    )

    # Check if the provided C++ file exists
    if (Test-Path $cppFilePath) {
        try {
            # Get the file name without extension
            $fileName = [System.IO.Path]::GetFileNameWithoutExtension($cppFilePath)
            
            # Compile the C++ file using g++
            $compileCommand = "g++ -o $fileName.exe $cppFilePath"
            Write-Host "Compiling $cppFilePath..."
            $compileResult = Invoke-Expression $compileCommand

            if ($LASTEXITCODE -eq 0) {
                Write-Host "Compilation successful."
                
                # Check if the executable exists
                if (Test-Path ".\$fileName.exe") {
                    Write-Host "Running the program...`n"
                    
                    clear

                    # Run the compiled executable interactively in the same window
                    # Use cmd.exe to run the program, which allows input to go to the interactive console
                    cmd /c ".\$fileName.exe"

                    # After the program finishes, remove the compiled executable
                    Remove-Item ".\$fileName.exe"
                    Write-Host "`n`nDeleted the compiled executable: $fileName.exe"
                } else {
                    Write-Host "Executable was not created."
                }
            } else {
                Write-Host "Compilation failed with exit code: $LASTEXITCODE"
            }
        } catch {
            Write-Host "An error occurred: $_"
        }
    } else {
        Write-Host "File not found: $cppFilePath"
    }
}

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

# Creating an alias for zoxide
Set-Alias z zoxide.exe

# Creating an alias for opening profile
Set-Alias op openProfile

# Creating an alias for opening main profile
Set-Alias opm openProfileMain

# Creating an alias for opening links on the desktop
Set-Alias s startApplication

# Creating an alias for copying location
Set-Alias pwc copyLocation

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

# Creating an alias for running C++ files
Set-Alias gpp CompileRunDeleteCpp

# Shows the powershell version
Write-Host ("v{0}{1}{2}" -f ($PSVersionTable.PSVersion.Major, ".", $PSVersionTable.PSVersion.Minor)) -ForegroundColor Green