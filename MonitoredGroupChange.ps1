<#	
	.NOTES
	===========================================================================
	 Created on:   	12/13/2018 3:57 PM
	 Created by:   	Bradley Wyatt
	 Filename:     	PSPush_GroupChange.ps1
	===========================================================================
	.DESCRIPTION
		Sends a Teams notification via webhook when a monitored group membership changes. Set up a scheduled task to trigger on event ID 4728. 
#>

$Groups2Monitor = @(
	"Domain Admins"
	"Enterprise Admins"
	"Accounting"
)

#Teams webhook url
$uri = "https://outlook.office.com/webhook/eee030b9-93ef-4fae-add9-17bf369d1101@6438b2c9-54e9-4fce-9851-f00c24b5dc1f/IncomingWebhook/c1ff36cab2a04ce3837a5c2e027d2ba9/5bcffade-2afd-48a2-8096-390a9090555c"

#Image on the left hand side, here I have a regular user picture
$ItemImage = 'https://www.merrimack.edu/live/image/gid/162/width/808/height/808/19902_user-plus-circle_2.rev.1548946186.png'

$ArrayTable = New-Object 'System.Collections.Generic.List[System.Object]'

$event = Get-EventLog -LogName Security -InstanceId 4728 | Select-object -First 1
$GroupSID = $Event | Select-Object -Expand Message | Select-String '(?<=group:\s+security id:\s+)\S+' | Select-Object -Expand Matches | Select-Object -Expand Value
$UserAdded = $Event | Select-Object -Expand Message | Select-String '(?<=member:\s+security id:\s+)\S+' | Select-Object -Expand Matches | Select-Object -Expand Value


If (($Groups2Monitor.Contains((Get-ADGroup -Identity $GroupSID).Name)) -eq $True)
{
	$AddedUser = Get-ADUser -Identity $UserAdded -Properties *
	$GroupChange = Get-ADGroup -Identity $GroupSID -Properties *
	$Section = @{
		activityTitle = "$($GroupChange.Name)"
		activitySubtitle = "$($GroupChange.Description)"
		activityText  = "The Account, '$($AddedUser.Name)' was added to the group, '$($GroupChange.Name)' "
		activityImage = $ItemImage
		facts		  = @(
			@{
				name  = 'Last Modified'
				value = $GroupChange.whenChanged
			},
			@{
				name  = 'New User:'
				value = $AddedUser.UserPrincipalName
			},
			@{
				name  = 'Group Type:'
				value = [string]($GroupChange.GroupCategory)
			},
			@{
				name  = 'Group Scope:'
				value = [string]($GroupChange.GroupScope)
			}
		)
	}
	$ArrayTable.add($section)
}


$body = ConvertTo-Json -Depth 8 @{
	title = "Monitored Group Change - Notification"
	text  = "A new user was added to $($GroupChange.Name)"
	sections = $ArrayTable
	
}
Write-Host "Sending notification POST" -ForegroundColor Green
Invoke-RestMethod -uri $uri -Method Post -body $body -ContentType 'application/json'
