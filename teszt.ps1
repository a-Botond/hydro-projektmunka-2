function WriteFile($folder, $filename, $text, $append) {
    # .ex 1. WriteFile temp hehe "bla bla" 
    # .ex 3. WriteFile temp hehe "bla bla" 1
    $TARGETDIR = "$PSScriptRoot\$folder"
    if (!(Test-Path -Path $TARGETDIR )) {
        New-Item -ItemType directory -Path $TARGETDIR
    }
    if (!$append) {
        $text | Out-File -FilePath $TARGETDIR\$filename.txt
    }
    else {
        Add-Content $TARGETDIR\$filename.txt "$text"
    }
}

function Teszt-Net {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateScript({
          $Port = '53','80'
          if ($_ -in $Port) { return $true } 
          throw "'$_' is not a valid Port number. Please try one of the following: '$($port -join ',')'"
        })]
        [string]$Portno,
        [Parameter()]
        [ValidateNotNullOrEmpty()] 
        [string]$Cmpname
    )
  
    Test-NetConnection -Port $Portno -InformationLevel Detailed
    Test-NetConnection -ComputerName $Cmpname -traceRoute -InformationLevel Detailed 
   <#
        .SYNOPSIS
        Project work II

        .DESCRIPTION
        This is our second project at Óbuda University. 
        This project is about: Automatic testing of client network settings. 
        Data acquisition and analysis then creating understandable output for the users with Powershell.

        .PARAMETER Name
        Teszt-Net

        .EXAMPLE
        Teszt-Net [80] [www.google.com]

        .LINK
        Github: https://github.com/a-Botond/projektmunka-2
    #>
}

function Teszt-Net
{
  # Check default route
    echo 'Default route elerheto?' 
    Test-Connection -ComputerName (Get-NetRoute -DestinationPrefix 0.0.0.0/0 | Select-Object -ExpandProperty NextHop) -Quiet

  # Check existing external DNS
    echo 'Nameserver elerheto?'
    Test-Connection 1.1.1.1 -Quiet
  
  # Check resolve domains
    Resolve-DnsName -Name gmail.com -Type A

  # Check own dns settings. 
  # Error if not ip addr in the record(s)
  # Output => valid IPs => log/DNS_Addr.txt
    echo 'DNS elerheto?'
    Teszt-DNS
}
   <#
        .SYNOPSIS
        Project work II
        .DESCRIPTION
        This is our second project at Obuda University. 
        This project is about: Automatic testing of client network settings. 
        Data acquisition and analysis then creating understandable output for the users with Powershell.
        .PARAMETER Name
        Teszt-Net
        .EXAMPLE
         Teszt-Net
        .LINK
        Github: https://github.com/a-Botond/projektmunka-2
    #>


function Teszt-DNS {
    [cmdletbinding()]
    param (
        [parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [string[]] $ComputerName = $env:computername
    )

    begin {}
    process {
        foreach ($Computer in $ComputerName) {
            # Echo "Working on $Computer"
            # Echo "Working on $ComputerName"
            if (Test-Connection -ComputerName $Computer -Count 1 -ea 0) {
			
                try {
                    $Networks = Get-WmiObject -Class Win32_NetworkAdapterConfiguration `
                        -Filter IPEnabled=TRUE `
                        -ComputerName $Computer `
                        -ErrorAction Stop

                    # echo $Networks
                }
                catch {
                    Echo "Failed to Query $Computer. Error details: $_"
                    continue
                }
                foreach ($Network in $Networks) {
                    $DNSServers = $Network.DNSServerSearchOrder
                    $NetworkName = $Network.Description
                    If (!$DNSServers) {
                        $PrimaryDNSServer = "Notset"
                        $SecondaryDNSServer = "Notset"
                    }
                    elseif ($DNSServers.count -eq 1) {
                        $PrimaryDNSServer = $DNSServers[0]
                        $SecondaryDNSServer = "Notset"
                    }
                    else {
                        $PrimaryDNSServer = $DNSServers[0]
                        $SecondaryDNSServer = $DNSServers[1]
                    }
                    If ($network.DHCPEnabled) {
                        $IsDHCPEnabled = $true
                    }
				
                    $OutputObj = New-Object -Type PSObject
                    $OutputObj | Add-Member -MemberType NoteProperty -Name ComputerName -Value $Computer.ToUpper()
                    $OutputObj | Add-Member -MemberType NoteProperty -Name PrimaryDNSServers -Value $PrimaryDNSServer
                    $OutputObj | Add-Member -MemberType NoteProperty -Name SecondaryDNSServers -Value $SecondaryDNSServer
                    $OutputObj | Add-Member -MemberType NoteProperty -Name IsDHCPEnabled -Value $IsDHCPEnabled
                    $OutputObj | Add-Member -MemberType NoteProperty -Name NetworkName -Value $NetworkName
                    # $OutputObj
                    # echo $PrimaryDNSServer
                    $valid_IP_list = New-Object Collections.Generic.List[string]
                    foreach ($dnsIP in $PrimaryDNSServer) {
                      if((Test-IPaddress -IPAddress $dnsIP) -eq 1) {
                        $valid_IP_list.Add($dnsIP)
                      }
                    }
                    foreach ($dnsIP in $SecondaryDNSServer) {
                      if((Test-IPaddress -IPAddress $dnsIP) -eq 1) {
                        $valid_IP_list.Add($dnsIP)
                      }
                    }

                    # $valid_IP_list;
                    # write to file
                    WriteFile log DNS_Addr $valid_IP_list 

                    # $HeloObj = New-Object -Type PSObject
                    # $HeloObj | Add-Member -MemberType NoteProperty -Name PrimaryDNSServers -Value $PrimaryDNSServer
                    # $HeloObj | Add-Member -MemberType NoteProperty -Name SecondaryDNSServers -Value $SecondaryDNSServer
                    # $HeloObj

                    # write to file
                    # WriteFile log DNS_Addr $HeloObj 
                    # WriteFile log DNS_Addr $OutputObj 1
                }
            }
            else {
                echo "$Computer not reachable"
            }
        }
    }

    end {}
} 

function Test-IPaddress {
  [CmdletBinding()]
  Param
  (
    [Parameter(Mandatory = $true,
      ValueFromPipelineByPropertyName = $true,
      Position = 0)]
    # [ValidateScript({ $_ -match [IPAddress]$_ })]  
    [string]
    $IPAddress
  )

  Begin {
  }
  Process {
    Try {
      if ($IPAddress -ne "Notset") {
        $IP_Check = [ipaddress]$IPAddress
        return 1
      }
    }
    Catch{
      return 0
    }
  }
  End {
  }
}
