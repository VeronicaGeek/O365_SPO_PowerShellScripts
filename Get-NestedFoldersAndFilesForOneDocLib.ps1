<#
.SYNOPSIS
    Export info from a SharePoint site.
.DESCRIPTION
    This script will loop through the specific document library & export the number of nested folders, files count, folder size (and more).
.EXAMPLE
    PS C:\> .\Get-NestedFoldersAndFilesForOneDocLib.ps1
.INPUTS
    Inputs (if any)
.OUTPUTS
    System.Object[]
.NOTES
    How to use this script is available on my blog at:
    https://veronicageek.com/sharepoint/sharepoint-2013/get-nested-folders-files-count-folder-size-and-more-in-spo-document-libraries-using-powershell-pnp/2019/09/
#>
#Connect to SPO -- Change to your tenant name and site
Connect-PnPOnline -Url "https://<TENANT-NAME>.sharepoint.com/sites/<YOUR-SITE>"

#Target a specific lists -- Change to YOUR OWN LIST NAME
$myList = "/Shared Documents"  

#Store the results
$results = @()

foreach ($row in $myList) {
    $allItems = Get-PnPListItem -List $myList -Fields "FileLeafRef", "SMTotalFileStreamSize", "FileDirRef", "FolderChildCount", "ItemChildCount"
    
    foreach ($item in $allItems) {
        
        #Narrow down to folder type only
        if (($item.FileSystemObjectType) -eq "Folder") {
            $results += New-Object psobject -Property @{
                FileType          = $item.FileSystemObjectType  #This will return a column with "Folder"
                RootFolder        = $item["FileDirRef"] 
                LibraryName       = $myList
                FolderName        = $item["FileLeafRef"]
                FullPath          = $item["FileRef"]
                FolderSizeInMB    = ($item["SMTotalFileStreamSize"] / 1MB).ToString("N")
                NbOfNestedFolders = $item["FolderChildCount"]
                NbOfFiles         = $item["ItemChildCount"]
            }
        }
    }
}
#Export the results
$results | Export-Csv -Path "C:\Users\$env:USERNAME\Desktop\NestedFoldersForONEdoclib.csv" -NoTypeInformation
