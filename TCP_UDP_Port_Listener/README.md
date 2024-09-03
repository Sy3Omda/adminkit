# TCP_UDP_Port_listener

Script **TCP_UDP_Port_listener.ps1** has been [taken](https://github.com/HarmVeenstra/Powershellisfun/blob/main/Create%20TCP%20or%20UDP%20listener/New-Portlistener.ps1) :) and altered to meet my requirements.

## Installation

```powershell
iex (irm "https://raw.githubusercontent.com/Sy3Omda/adminkit/main/TCP_UDP_Port_Listener/TCP_UDP_Port_Listener.ps1")
```


- Listen for specific UDP port
```sh
Port-listener -UDPPort 4444 -Verbose
```
OR
```sh
PL -TCPPort 4445 -Verbose`
```

- Test connection to specific port
```powershell
portqry -n 10.0.0.10 -e 4444 -p UDP
```

```powershell
portqry -n 10.0.0.10 -e 4445 -p TCP
```

download **PortQryV2.exe** from Microsoft  [PortQry](https://www.microsoft.com/en-us/download/confirmation.aspx?id=17148)