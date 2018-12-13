# PSPushTeams
Collection of scripts used to push notifications to Microsoft Teams

Microsoft Teams has many connectors available including Incoming Webhook.This provides an easy solution to post notifications / messages from any scripting language through JSON formatted web service call.

### Table of Contents
* [Users Expiring Passwords](https://github.com/bwya77/PSPushTeams/blob/master/README.md#post-users-with-expiring-passwords-as-microsoft-teams-message-with-powershell)
* [Inactive User Accounts](https://github.com/bwya77/PSPushTeams/blob/master/README.md#post-inactive-user-accounts-as-a-microsoft-teams-message-with-powershell)
* [Locked Out Accounts](https://github.com/bwya77/PSPushTeams/blob/master/README.md#post-locked-out-ad-user-accounts-to-microsoft-teams-message-with-powershell)

## Post Users with Expiring Passwords as Microsoft Teams Message with PowerShell 
Send a Microsoft Teams message containing all of your Active Directory user accounts that have passwords expiring in 7 days or less. (number is configurable)

* [Blog Writeup](https://thelazyadministrator.com/2018/12/07/post-users-with-expiring-passwords-as-team-message-with-powershell/)
* [Download Script](https://github.com/bwya77/PSPushTeams/blob/master/ExpiringPasswordUsers.ps1)

![Post Message](https://thelazyadministrator.com/wp-content/uploads/2018/12/notification-1.png)


____

## Post Inactive User Accounts as a Microsoft Teams Message with PowerShell
Send a Microsoft Teams message containing all of your Active Directory user accounts have not logged on in 90 days or more. (number is configurable)

* [Blog Writeup](https://thelazyadministrator.com/2018/12/11/post-inactive-users-as-a-microsoft-teams-message-with-powershell/)
* [Download Script](https://github.com/bwya77/PSPushTeams/blob/master/InactiveUsers.ps1)

![Post Message](https://thelazyadministrator.com/wp-content/uploads/2018/12/Inactive-Users.png)


____
## Post Locked Out AD User Accounts to Microsoft Teams Message with PowerShell
Send a Microsoft Teams message the moment one of your Active Directory users gets locked out

* [Blog Writeup](https://thelazyadministrator.com/2018/12/13/get-a-teams-notification-the-moment-an-active-directory-user-gets-locked-out-with-powershell-using-webhooks/)
* [Download Script](https://github.com/bwya77/PSPushTeams/blob/master/LockedOutUser.ps1)

![Post Message](https://thelazyadministrator.com/wp-content/uploads/2018/12/lockout.png)
