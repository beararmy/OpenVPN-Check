## OpenVPN-Check
Powershell based scheduled task to check on OpenVPNClient status and take some action if needed to try and bring back up

Once added as a scheduled task this will Test Connectivity to $EndNode for $Attempts times waiting for $WaitBetweenAttempts between tries.

It will create a Log Source inside $LogName called $LogSource.

Event ID's are;
```
100     # Created Log
0       # Connection is up, quitting
1       # Connection is down, we tried restarting the client and will try again $Attempts times
9       # Connection is down and we've already tried to restart client
```

In practice this is what you see in Event Viewer;
![EventLog-Screenshot.PNG](https://raw.githubusercontent.com/beararmy/OpenVPN-Check/master/EventLog-Screenshot.PNG)