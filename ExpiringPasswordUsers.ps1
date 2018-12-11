$SendMessage = $null
#Get all users whose password expires in X days and less, this sets the days
$LessThan = 7
#Teams web hook URL
$uri = "[INSERT WEBHOOK URI]"

$ItemImage = 'https://img.icons8.com/color/1600/circled-user-male-skin-type-1-2.png'

$PWExpiringTable = New-Object 'System.Collections.Generic.List[System.Object]'
$ArrayTable = New-Object 'System.Collections.Generic.List[System.Object]'
$ArrayTableExpired = New-Object 'System.Collections.Generic.List[System.Object]'

$ExpiringUsers = 0
$ExpiredUsers = 0

$maxPasswordAge = ((Get-ADDefaultDomainPasswordPolicy).MaxPasswordAge).Days
#Get all users and store in a variable named $Users
get-aduser -filter { (PasswordNeverExpires -eq $false) -and (enabled -eq $true) } -properties * | ForEach-Object{
	Write-Host "Working on $($_.Name)" -ForegroundColor White
	
	
	#Get Password last set date
	$passwordSetDate = ($_.PasswordLastSet)
	
	if ($null -eq $passwordSetDate)
	{
		#0x1 = Never Logged On
		$daystoexpire = "0x1"
	}
	
	else
	{
		
		#Check for Fine Grained Passwords
		$PasswordPol = (Get-ADUserResultantPasswordPolicy -Identity $_.objectGUID -ErrorAction SilentlyContinue)
		
		if ($Null -ne ($PasswordPol))
		{
			
			$maxPasswordAge = ($PasswordPol).MaxPasswordAge
		}
		
		$expireson = $passwordsetdate.AddDays($maxPasswordAge)
		$today = (Get-Date)
		
		#Gets the count on how many days until the password expires and stores it in the $daystoexpire var
		$daystoexpire = (New-TimeSpan -Start $today -End $Expireson).Days
		If ($daystoexpire -lt ($LessThan + 1))
		{
			write-host "$($_.Name) will be added to table" -ForegroundColor red
			If ($daystoexpire -lt 0)
			{
				#0x2 = Password has been expired
				$daystoexpire = "Password is Expired"
			}
			$obj = [PSCustomObject]@{
				
				'Name' = $_.name
				'DaysUntil' = $daystoexpire
				'EmailAddress' = $_.emailaddress
				'LastSet' = $_.PasswordLastSet.ToShortDateString()
				'LockedOut' = $_.LockedOut
				'UPN'  = $_.UserPrincipalName
				'Enabled' = $_.Enabled
				'PasswordNeverExpires' = $_.PasswordNeverExpires
			}
			
			$PWExpiringTable.Add($obj)
		}
		Else
		{
			write-host "$($_.Name)'s account is compliant" -ForegroundColor Green
		}
	}
}

#Sort the table so the Teams message shows expiring soonest to latest
$PWExpiringTable = $PWExpiringTable | sort-Object DaysUntil

$PWExpiringTable | ForEach-Object{
	
	If ($_.DaysUntil -eq "Password is Expired")
	{
		write-host "$($_.name) is expired" -ForegroundColor DarkRed
		$ExpiredUsers++
		$SectionExpired = @{
			activityTitle = "$($_.Name)"
			activitySubtitle = "$($_.EmailAddress)"
			activityText  = "$($_.Name)'s password has already expired!"
			activityImage = $ItemImage
		}
		$ArrayTableExpired.add($SectionExpired)
	}
	Else
	{
		write-host "$($_.name) is expiring" -ForegroundColor DarkYellow
		$ExpiringUsers++
		$Section = @{
			activityTitle = "$($_.Name)"
			activitySubtitle = "$($_.EmailAddress)"
			activityText  = "$($_.Name) needs to change their password in $($_.DaysUntil) days"
			activityImage = $ItemImage
		}
		
		$ArrayTable.add($Section)
		
	}
}


Write-Host "Expired Accounts: $($($ExpiredUsers).count)" -ForegroundColor Yellow
write-Host "Expiring Accounts: $($($ExpiringUsers).count)" -ForegroundColor Yellow




$body = ConvertTo-Json -Depth 8 @{
	title = 'Users With Password Expiring - Notification'
	text  = "There are $($ArrayTable.Count) users that have passwords expiring in $($LessThan) days or less"
	sections = $ArrayTable
	
}
Write-Host "Sending expiring users notification" -ForegroundColor Green
Invoke-RestMethod -uri $uri -Method Post -body $body -ContentType 'application/json'


$body2 = ConvertTo-Json -Depth 8 @{
	title = 'Users With Password Expired - Notification'
	text  = "There are $($ArrayTableExpired.Count) users that have passwords that have expired already"
	sections = $ArrayTableExpired
	
}
Write-Host "Sending expired users notification" -ForegroundColor Green
Invoke-RestMethod -uri $uri -Method Post -body $body2 -ContentType 'application/json'
