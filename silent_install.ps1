$PSScript = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
Import-module "$PSScript\AutoItX.psd1"
Initialize-AU3
Foreach ($arg in $args)
{
$files = Get-ChildItem $arg
ForEach ($file in $files)
{
    If (($file.Name).EndsWith('exe'))
    {
        Write-Host "Reading file `"$($file.Name)`""
        Invoke-AU3Run -Program "`"$PSScript\PEiD.exe`" -hard `"$($file.FullName)`"" -ShowFlag 0
        Wait-AU3Win -Title "PEiD v0.95" -Timeout 3
        $text = ""
        $text = Get-AU3ControlText -Title "PEiD v0.95" -Control "[CLASS:Edit; INSTANCE:2]"
        If (($text -eq "Scanning...") -or ($text -eq ""))
        {
            Do
            {
                $text = Get-AU3ControlText -Title "PEiD v0.95" -Control "[CLASS:Edit; INSTANCE:2]"
            }
            Until (($text -ne "Scanning...") -and ($text -ne ""))
        }
        Close-AU3Win -Title "PEiD v0.95" -Force
        $foundsomething = 'n'
        If (($text -like "*Inno Setup*") -or ($text -like "*Delphi*"))
        {
            $foundsomething = 'y'
            echo "`"$($file.FullName)`" /VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SP-" | Out-File "$env:DESKTOP\silent.txt" -Append
        }
        ElseIf ($text -like "*Wise*")
        {
            $foundsomething = 'y'
            echo "`"$($file.FullName)`" /s" | Out-File "$env:DESKTOP\silent.txt" -Append
        }
        ElseIf ($text -like "*Nullsoft*")
        {
            $foundsomething = 'y'
            echo "`"$($file.FullName)`" /S" | Out-File "$env:DESKTOP\silent.txt" -Append
        }
        ElseIf ($text -like "*Installshield 2003*")
        {
            $foundsomething = 'y'
            echo "`"$($file.FullName) /s /v`"/qb`"" | Out-File "$env:DESKTOP\silent.txt" -Append
        }
        Else
        {
        }
    }
    Elseif (($file.Name).EndsWith('msi'))
    {
        echo "msiexec /i `"$($file.FullName)`" /qb" | Out-file "$env:DESKTOP\silent.txt" -Append
    }
    Else
    {
    }
}
}