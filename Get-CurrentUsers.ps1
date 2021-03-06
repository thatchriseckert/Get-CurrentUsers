<######################################################################
.SCRIPT           Get-CurrentUsers.ps1

.DESCRIPTION
    Script to remotely pull a list of all currently logged on users on a 
    Windows system.  Rather than hunting for logs indicating authentication, 
    it makes WMI calls to pull processes such as explorer.exe running under
    a user's context, make it much more accurate.

.USAGE
    Script is meant to be added to Powershell profile, and will be run
    under current user's context.  Rights are assumed to be across both local
    and remote systems.

.REQUIREMENTS
    Version 2.0+

.AUTHOR
    Chris Eckert 2015 - @thatchriseckert

#######################################################################>

function global:Get-CurrentUsers {
           
[CmdletBinding()]            
 Param             
   (                       
    [Parameter(Mandatory=$true,
               Position=0,                          
               ValueFromPipeline=$true,            
               ValueFromPipelineByPropertyName=$true)]            
    [String[]]$ComputerName
   )#End Param

Begin            
{            
 Write-Host "`n Checking for users. . . "
 $i = 0            
}          
Process            
{
    $ComputerName | Foreach-object {
    $Computer = $_
    try
        {
            $processinfo = @(Get-WmiObject -class win32_process -ComputerName $Computer -EA "Stop")
                if ($processinfo)
                {    
                    $processinfo | Foreach-Object {$_.GetOwner().User} | 
                    Where-Object {$_ -ne "NETWORK SERVICE" -and $_ -ne "LOCAL SERVICE" -and $_ -ne "SYSTEM"} |
                    Sort-Object -Unique |
                    ForEach-Object { New-Object psobject -Property @{Computer=$Computer;LoggedOn=$_} } | 
                    Select-Object Computer,LoggedOn
                }#If
        }
    catch
        {
            "Cannot find any processes running on $computer" | Out-Host
        }
     }#Forech-object(ComputerName)       
            
}
End
{

}

}
