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
