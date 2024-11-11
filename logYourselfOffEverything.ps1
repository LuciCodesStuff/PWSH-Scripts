#list the OUs where servers or workstations you wish to target live
$OUs = @(
	#'OU=Servers,DC=Company,DC=local',
	#'OU=Domain Controllers,DC=Company,DC=local'
)
$hostname = hostname #Leave this alone please
$username = $env:USERNAME #Replace with the username (no domain) you want to log off, use $env:USERNAME for current scoped user
Write-Host Logging $env:USERNAME off of all found servers excluding $hostname

ForEach ($OU in $OUs) {
	Get-ADComputer -filter * -SearchBase $ou | select name | % {
		$serverName = $_.name
		Write-Host Processing $serverName
		if (Test-Connection $serverName -Count 1 -ErrorAction SilentlyContinue -WarningAction SilentlyContinue) {
			$query = (query user /server:$serverName) -split "\n" -replace '\s\s+', ';' | convertfrom-csv -Delimiter ';' | % {
				if ($serverName -ne $hostname -and $_.username -eq $username) {
					Write-Host Logging off $username from $serverName
					Invoke-RDUserLogoff -Force -Hostserver $serverName -UnifiedSessionID $_.SESSIONNAME -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
					Invoke-RDUserLogoff -Force -Hostserver $serverName -UnifiedSessionID $_.ID -ErrorAction SilentlyContinue -WarningAction SilentlyContinue				}
			}
		}
		else {
			Write-Host $serverName did not respond. Skipping.
		}
	}	
}
