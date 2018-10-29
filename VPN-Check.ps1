# The first run of this will create a new Log Source as below
# Because you're going to restart services, this needs to be run as administrator
# Be conscious of $Attempts and $WaitBetweenAttempts when choosing how often to run this

###### User Config ######

$LogName = 'Application'    # This script will only work with built-in Log Names out of the box
$LogSource = 'VPN-Check'    # Whatever You like the name of

$EndNode = '10.1.0.1'       # Suggest remote VPN gateway
$Attempts = 3               # Number of attempts before action is taken
$WaitBetweenAttempts = 30   # Number of seconds between attempts

## End of User Config ##

Try {
    $log_check = Get-EventLog -Source $LogSource -LogName $LogName -ErrorAction Stop
}
Catch {
    try {
        write-output "Creating Event Viewer source ($LogSource) on first run"
        New-EventLog -Source $LogSource -LogName $LogName
        Write-EventLog -LogName $LogName -Source $LogSource -EventId 100 -EntryType Information -Message "$LogSource Log Source Installed" 
        Write-Output "$LogSource created in $LogName without issue"
    }
    catch {
        Write-Output "$LogSource could not be created in $LogName"
        Exit
    }
}

Remove-Variable $log_check
$Connected = "Unknown"
$Attempt = 1

Do {
    if ($Attempt -ge ($Attempts + 1)) {
        #Hard Fail
        Write-EventLog -LogName $LogName -Source $LogSource -EventId 9 -EntryType Error -Message "VPN Hard Down after $Attempts attempts. Will retry on next scheduled run"
        $Connected = "no"
        break
    }
    if (Test-Connection -computername $EndNode -Quiet -Count 3) {
        #Success
        Write-EventLog -LogName $LogName -Source $LogSource -EventId 0 -EntryType Information -Message "VPN Up at attempt $Attempt"
        $Connected = "yes"
    }
    else {
        #Soft Fail
        Write-EventLog -LogName $LogName -Source $LogSource -EventId 1 -EntryType Warning -Message "VPN Down at attempt $Attempt, restarting service, will retry in 15s"
        Restart-Service OpenVPNAccessClient
        Start-Sleep $WaitBetweenAttempts
        $Attempt++
    }
} while ($Connected -eq "Unknown")