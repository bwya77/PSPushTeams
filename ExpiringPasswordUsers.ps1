$SendMessage = $null
#Get all users whose password expires in X days and less, this sets the days
$LessThan = 7
#Teams web hook URL
$uri = "INSET WEBHOOK URL"

$ItemImage = 'https://img.icons8.com/color/1600/circled-user-male-skin-type-1-2.png'

$PWExpiringTable = New-Object 'System.Collections.Generic.List[System.Object]'
$ArrayTable = New-Object 'System.Collections.Generic.List[System.Object]'

$maxPasswordAge = ((Get-ADDefaultDomainPasswordPolicy).MaxPasswordAge).Days
#Get all users and store in a variable named $Users
Get-Aduser -filter * -properties * | ForEach-Object{
	
	
	if ((($_.PasswordNeverExpires) -eq $False) -and (($_.Enabled) -ne $false))
	{
		
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
				}
				
				$PWExpiringTable.Add($obj)
				
				
			}
		}
	}
}

#Sort the table so the Teams message shows expiring soonest to latest
$PWExpiringTable = $PWExpiringTable | sort-Object DaysUntil

$PWExpiringTable | ForEach-Object{
	
	If ($_.DaysUntil -eq "Password is Expired")
	{
		$Section = @{
			activityTitle = "$($_.Name)"
			activitySubtitle = "$($_.EmailAddress)"
			activityText  = "$($_.Name)'s password has already expired!"
			activityImage = $ItemImage
			
			
			facts		  = @(
				@{
					name  = 'Days Until Password Expires:'
					value = $_.DaysUntil
				},
				@{
					name  = 'Password Last Set:'
					value = $_.LastSet
				},
				@{
					name  = 'Locked Out'
					value = $_.LockedOut
				}
			)
		}
	}
	Else
	{
		$Section = @{
			activityTitle = "$($_.Name)"
			activitySubtitle = "$($_.EmailAddress)"
			activityText  = "$($_.Name) needs to change their password in $($_.DaysUntil) days"
			activityImage = $ItemImage
			
			
			facts		  = @(
				@{
					name  = 'Days Until Password Expires:'
					value = $_.DaysUntil
				},
				@{
					name  = 'Password Last Set:'
					value = $_.LastSet
				},
				@{
					name  = 'Locked Out'
					value = $_.LockedOut
				}
			)
		}
	}
	
	$ArrayTable.add($section)
	
}




$body = ConvertTo-Json -Depth 8 @{
	title = 'Users With Password Expiring - Notification'
	text  = "There are $($ArrayTable.Count) users that have passwords expiring in $($LessThan) days or less"
	sections = $ArrayTable
	
}

$SendMessage = Invoke-RestMethod -uri $uri -Method Post -body $body -ContentType 'application/json'
If ($SendMessage -eq 1)
{
	Write-Host "Successfuly sent the message to Teams" -ForegroundColor Green
}
