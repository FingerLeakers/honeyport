<# 
Author: John Hoyt

Purpose: This script idea was based off of the PaulDotCom Security Podcast episode # 203.
It opens up a tcp port on the host, and when a connection is established,
it adds a local firewall rule to block the host from further connections.  

Usage: It can be run manually from the command line, but I've found it works
best to run it from the Windows Task Scheduler.

 - Manuall: "powershell.exe honeyport.ps1 3333"  
   
   - Where 3333 is the port you choose. 

 - From Task Scheduler 
 
   - Create a new task,and use the following settings for the Actions tab.

    Program / script
 
    C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe
 
    Add arguments
 
    -windowstyle hidden -Command "& c:\scripts\honeyport.ps1 3333"

#>

$port = $args[0] #grabs the command line argument for port.

if ($port -ne "") {
    $endpoint = new-object System.Net.IPEndPoint([system.net.ipaddress]::any, $port)
    $listener = new-object System.Net.Sockets.TcpListener $endpoint
    $listener.start()
    $client = $listener.AcceptTcpClient() 
    $IP = $client.Client.RemoteEndPoint
    $IP = $IP.tostring()
    $IP = $IP.split(':')
    $IP = $IP[0]
    write-host "The following host attempted to connect: $IP"

    #Add firewall rule to block inbound scanner.
    $firewall = New-Object -ComObject hnetcfg.fwpolicy2
    $rule = New-Object -ComObject HNetCfg.FWRule
    $rule.Name="Block scanner"
    $rule.Description = "Blocking IP"
    $rule.RemoteAddresses = $IP
    $rule.Action = 0
    #$rule.Direction = '1'
    $rule.Protocol = 6
    #$rule.RemotePorts = "*"
    $rule.Enabled = $True
    $firewall.Rules.Add($rule)
    write-host "Host has been blocked."

    $client.Close()
    $listener.stop()
    Write-host "Connection closed"
}
