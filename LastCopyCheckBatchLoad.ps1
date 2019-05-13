#Set Variables for Your Institution
$BarcodeListFile = "Text file of barcodes for upload"
$MMSIdListFile = "Location to store CSV of MMS IDs"
$OutputFile = "Location to store final CSV of output"
$Item_Barcode_APIKey = "Your Item Barcode API key"
$Primo_Search_APIKey = "Your Primo Search API key"
$vid = "Code for your Primo VID"
$tab = "Name of your Primo tab"
$scope = "Name of your Primo scope"

#Load List of Barcodes
$BarcodeList = Get-Content $BarcodeListFile -ErrorAction SilentlyContinue

#Set up Item_Barcode API
Set-Variable -Name "string1" -Value "https://api-na.hosted.exlibrisgroup.com/almaws/v1/items?apikey="
Set-Variable -Name "string2" -Value $Item_Barcode_APIKey
Set-Variable -Name "string3" -Value "&item_barcode="

#Run Item_Barcode API to Fetch MMS_IDs
foreach ($Barcode in $BarcodeList) {
$url_barcode = $string1 + $string2 + $string3 + $Barcode
[xml]$xml_barcode = (New-Object System.Net.WebClient).DownloadString("$url_barcode")
$mms_id = $xml_barcode.item.bib_data.mms_id

#Print List of MMS_IDs and Barcodes to File
[pscustomobject]@{
	MMSID = $mms_id
	Barcode = $Barcode
} | Export-Csv -notype $MMSIdListFile -Append
}

#Load List of MMS_IDs and Barcodes
$MMSIdList = Get-Content $MMSIdListFile -ErrorAction SilentlyContinue | Select-Object -Skip 1

#Set up Primo_Search API
Set-Variable -Name "string4" -Value "https://api-na.hosted.exlibrisgroup.com/primo/v1/search?"
Set-Variable -Name "string5" -Value "vid="
Set-Variable -Name "string6" -Value "&tab="
Set-Variable -Name "string7" -Value "&scope="
Set-Variable -Name "string8" -Value "&q=any,exact,"
Set-Variable -Name "string9" -Value "&lang=eng&offset=0&limit=1000&sort=rank&apikey="
Set-Variable -Name "string10" -Value $Primo_Search_APIKey

#Run Primo_Search API to Fetch Title, AlmaID, and AlmaIDCount
foreach ($Entry in $MMSIdList) {
$mms_id,$Barcode = $Entry.split(',')
$url_primoSearch = $string4 + $string5 + $vid + $string6 + $tab + $string7 + $scope + $string8 + $mms_id + $string9 + $string10
$primoSearchResults = Invoke-WebRequest -Uri $url_primoSearch | ConvertFrom-Json

$title = $primoSearchResults.docs.pnx.display.title[0]
$AlmaID = $primoSearchResults.docs.pnx.control.almaid
$AlmaIDCount = $primoSearchResults.docs.pnx.control.almaid | Measure-Object | Select-Object -Exp Count

#Print All Results to File
[pscustomobject]@{
	Barcode = $Barcode.Trim('"')
	MMSID = $mms_id.Trim('"')
    Title = $title
    AlmaID = ($AlmaID -join '|')
    AlmaIDCount = $AlmaIDCount
} | Export-Csv -notype $OutputFile -Append
}

Write-Host "Press any key to continue ..."
$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
