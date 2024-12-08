$theme = "https://raw.githubusercontent.com/varshithno1/configs/master/powershell/omp/varshith.omp.json"

$scriptRoot = $PSScriptRoot
[System.Environment]::SetEnvironmentVariable("configLoc", $scriptRoot, "User")

# Verify the environment variable is set
$configLocVar = [System.Environment]::GetEnvironmentVariable("configLoc", "User")

. "$configLocVar\powershell\scripts\checkWrapper.ps1"

Write-Host "Config Location is set to: $configLocVar"

# Setting Global Theme
while($true)
{
    $userInput = Read-Host "Do you want to change Global Theme to default? (""y"" [Yes]/ ""n"" [No])"
    if($userInput -eq "y")
    {
        [System.Environment]::SetEnvironmentVariable("ompThemeG", "$theme", "User")
        break
    }
    elseif ($userInput -eq "n")
    {
        $themeG = [System.Environment]::GetEnvironmentVariable("ompThemeG", "User")
        if(-not ($themeG))
        {
            $userInputSet = Read-Host "What would you like to set it to"
            [System.Environment]::SetEnvironmentVariable("ompThemeG", "$userInputSet", "User")
        }
        else
        {
            while($true)
            {
                $userInputChange = Read-Host "Do you want to change Global Theme? (""y"" [Yes]/ ""n"" [No])"
                if($userInputChange -eq "y")
                {
                    $userInputSet = Read-Host "What would you like to set it to"
                    [System.Environment]::SetEnvironmentVariable("ompThemeG", "$userInputSet", "User")
                    break
                }
                elseif($userInputChange -eq "n")
                {
                    break
                }
                else
                {
                    Write-Host "Invalid Input"
                    continue
                }
            }
        }

        break
    }
    else
    {
        Write-Host "Invalid Input"
        continue
    }
}

# Setting Local Theme
while($true)
{
    $userInput = Read-Host "Do you want to change Local Theme to default? (""y"" [Yes]/ ""n"" [No])"
    if($userInput -eq "y")
    {
        [System.Environment]::SetEnvironmentVariable("ompThemeL", "$configLocVar\powershell\omp\varshith.omp.json", "User")
        break
    }
    elseif ($userInput -eq "n")
    {
        $themeL = [System.Environment]::GetEnvironmentVariable("ompThemeL", "User")
        if(-not ($themeL))
        {
            $userInputSet = Read-Host "What would you like to set it to"
            [System.Environment]::SetEnvironmentVariable("ompThemeL", "$userInputSet", "User")
        }
        else
        {
            while($true)
            {
                $userInputChange = Read-Host "Do you want to change Local Theme? (""y"" [Yes]/ ""n"" [No])"
                if($userInputChange -eq "y")
                {
                    $userInputSet = Read-Host "What would you like to set it to"
                    [System.Environment]::SetEnvironmentVariable("ompThemeL", "$userInputSet", "User")
                    break
                }
                elseif($userInputChange -eq "n")
                {
                    break
                }
                else
                {
                    Write-Host "Invalid Input"
                    continue
                }
            }
        }

        break
    }
    else
    {
        Write-Host "Invalid Input"
        continue
    }
}

$setupCommands = "`$configLocVar = [System.Environment]::GetEnvironmentVariable(`"configLoc`", `"User`")`n. `"`$configLocVar\powershell\scripts\main.ps1`""
$setupCommands | Set-Clipboard

Write-Host "Try pasting the setup commands in your Main Powershell Script (You can access it by typing 'notepad `$PROFILE') : "