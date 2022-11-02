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
echo 'Default route elerheto?' 
Test-Connection -ComputerName (Get-NetRoute -DestinationPrefix 0.0.0.0/0 | Select-Object -ExpandProperty NextHop) -Quiet
echo 'Nameserver elerheto?'
Test-Connection 1.1.1.1 -Quiet
Resolve-DnsName -Name gmail.com
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
