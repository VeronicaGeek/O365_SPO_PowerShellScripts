﻿<#
.Synopsis
   This script will ADD a second Site Collection Admin (SCA) on each users' Onedrive For Business in Office 365.
.DESCRIPTION
   Script will add a second Site Collection Admin (SCA) on each users' ODFB in O365.
   Script will NOT override other SCA on user's ODFB - simply add the SCA mentioned under "$SecondAdmin" parameter.

   +++ IMPORTANT +++   The .CSV file needs to contain a column with header titled "OneDriveUrl"

.EXAMPLE
   .\Add-SiteCollectionAdminInODFB.ps1 -TenantName <Name_of_the_O365_Tenant> -AdminAcct <O365_AdminAccount> -SecondAdmin <2nd_SCA_acct> -ODFBCsvFile <File_containing_the_ODFB_Urls.csv>
.EXAMPLE
   .\Add-SiteCollectionAdminInODFB.ps1 (if no parameters are entered, you will be prompted for them)

==========================================
Author: Veronique Lengelle (@VeronicaGeek)
Date: 02 Jan 2017 
Version: 1.0
==========================================
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory=$true,HelpMessage="This is the name of the O365 tenant",Position=1)] 
    [string]$TenantName,    
    [Parameter(Mandatory=$true,HelpMessage="This is the O365 Admin account to log into the tenant",Position=2)] 
    [string]$AdminAcct,
    [Parameter(Mandatory=$true,HelpMessage="This is the account to ADD on each ODFB",Position=3)] 
    [string]$SecondAdmin,
    [Parameter(Mandatory=$true,HelpMessage="This is the CSV file containing the ODFB Urls",Position=4)] 
    [string]$ODFBCsvFile    
)
# URL for your organization's SPO admin service
$AdminURI = "https://$TenantName-admin.sharepoint.com"

#Import Urls
$UrlLocation = Import-Csv $ODFBCsvFile

#Connect to SPO
Connect-SPOService -Url $AdminURI -Credential $AdminAcct
Write-Host "Connected to SharePoint Online" -f Green

foreach($Url in $UrlLocation){
    $CorrectSitePath = ($Url.OneDriveUrl).trimend("/")
    Set-SPOUser -Site $CorrectSitePath -LoginName $SecondAdmin -IsSiteCollectionAdmin $true 
}

Write-Host "Account $SecondAdmin added." -f Green
