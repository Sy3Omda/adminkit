<#
.SYNOPSIS
    This script sets up a TCP and/or UDP listener on specified ports.

.DESCRIPTION
    The Port-listener function allows you to listen for incoming TCP and UDP connections
    on specified ports. It will print a message each time a new connection is established.

.PARAMETERS
    -TCPPort
        Specifies the TCP port to listen on.
        Type: Integer
        Position: Named
        Default value: None
        Accept pipeline input: False
        Accept wildcard characters: False

    -UDPPort
        Specifies the UDP port to listen on.
        Type: Integer
        Position: Named
        Default value: None
        Accept pipeline input: False
        Accept wildcard characters: False

.EXAMPLES
    # Example of running the function with only a TCP port
    Port-listener -TCPPort 4444

    # Example of running the function with only a UDP port
    Port-listener -UDPPort 4444
#>

function Port-listener {
    [CmdletBinding(DefaultParameterSetName = 'All')]
    [Alias("PL", "NetListener")]
    [OutputType([void])]
    param (
        [parameter(Mandatory = $false, HelpMessage = "Enter the TCP port you want to use to listen on, for example 4444", parameterSetName = "TCP")]
        [ValidatePattern('^[0-9]+$')]
        [ValidateRange(0, 65535)]
        [int]$TCPPort,

        [parameter(Mandatory = $false, HelpMessage = "Enter the UDP port you want to use to listen on, for example 4444", parameterSetName = "UDP")]
        [ValidatePattern('^[0-9]+$')]
        [ValidateRange(0, 65535)]
        [int]$UDPPort
    )

    # Test if TCP port is already listening before starting listener
    if ($TCPPort) {
        $Global:ProgressPreference = 'SilentlyContinue' # Hide GUI output

        try {
            $testtcpport = Test-NetConnection -ComputerName localhost -Port $TCPPort -WarningAction SilentlyContinue -ErrorAction Stop
            if ($testtcpport.TcpTestSucceeded -ne $True) {
                Write-Host ("TCP port {0} is available, continuing..." -f $TCPPort) -ForegroundColor Green
            } else {
                Write-Warning ("TCP Port {0} is already listening, aborting..." -f $TCPPort)
                return
            }

            # Start TCP Server
            $ipendpoint = [System.Net.IPEndPoint]::new([ipaddress]::Any, $TCPPort)
            $listener = [System.Net.Sockets.TcpListener]::new($ipendpoint)
            $listener.Start()
            Write-Host ("Now listening on TCP port {0}, press Escape to stop listening" -f $TCPPort) -ForegroundColor Green

            while ($true) {
                if ($listener.Pending()) {
                    $client = $listener.AcceptTcpClient()
                    $remoteEndpoint = $client.Client.RemoteEndPoint
                    Write-Host "$($remoteEndpoint.Address):$($remoteEndpoint.Port) connected to TCP port $TCPPort"
                    $client.Close()
                }

                if ($host.ui.RawUi.KeyAvailable) {
                    $key = $host.ui.RawUI.ReadKey("NoEcho,IncludeKeyUp,IncludeKeyDown")
                    if ($key.VirtualKeyCode -eq 27) {
                        $listener.Stop()
                        Write-Host ("Stopped listening on TCP port {0}" -f $TCPPort) -ForegroundColor Green
                        return
                    }
                }
            }
        } catch {
            Write-Error $_.Exception.Message
        } finally {
            if ($listener) {
                $listener.Stop()
            }
        }
    }

    # Test if UDP port is already listening before starting listener
    if ($UDPPort) {
        try {
            # Create a UDP client object
            $UdpObject = [System.Net.Sockets.UdpClient]::new($UDPPort)
            $computername = "localhost"
            $UdpObject.Connect($computername, $UDPPort)
        
            # Send data to server
            $ASCIIEncoding = [System.Text.ASCIIEncoding]::new()
            $Bytes = $ASCIIEncoding.GetBytes("$(Get-Date -UFormat "%Y-%m-%d %T")")
            [void]$UdpObject.Send($Bytes, $Bytes.Length)
        
            # Cleanup
            $UdpObject.Close()
            Write-Host ("UDP port {0} is available, continuing..." -f $UDPPort) -ForegroundColor Green
        } catch {
            Write-Warning ("UDP Port {0} is already listening, aborting..." -f $UDPPort)
            return
        }

        try {
            # Start UDP Server
            $endpoint = [System.Net.IPEndPoint]::new([IPAddress]::Any, $UDPPort)
            $udpclient = [System.Net.Sockets.UdpClient]::new($UDPPort)
            Write-Host ("Now listening on UDP port {0}, press Escape to stop listening" -f $UDPPort) -ForegroundColor Green

            # Track processed endpoints
            $processedEndpoints = @{}

            while ($true) {
                if ($host.ui.RawUi.KeyAvailable) {
                    $key = $host.ui.RawUI.ReadKey("NoEcho,IncludeKeyUp,IncludeKeyDown")
                    if ($key.VirtualKeyCode -eq 27) {
                        $udpclient.Close()
                        Write-Host ("Stopped listening on UDP port {0}" -f $UDPPort) -ForegroundColor Green
                        return
                    }
                }

                if ($udpclient.Available) {
                    $content = $udpclient.Receive([ref]$endpoint)
                    $endpointKey = "$($endpoint.Address.IPAddressToString):$($endpoint.Port)"
                    if (-not $processedEndpoints.ContainsKey($endpointKey)) {
                        Write-Host "$($endpoint.Address.IPAddressToString):$($endpoint.Port) connected to UDP port $UDPPort"
                        $processedEndpoints[$endpointKey] = $true
                    }
                }
            }
        } catch {
            Write-Error $_.Exception.Message
        } finally {
            if ($udpclient) {
                $udpclient.Close()
            }
        }
    }
}