Add-PSSnapin "Microsoft.SharePoint.PowerShell" 

# get out new data, e.g. wifi password.
$newpasswordreq = Invoke-WebRequest -Uri http://data.company.org/wifipassword.html
$newpassword = $newpasswordreq.Content

# connect to sharepoint
$site = New-Object Microsoft.SharePoint.SPSite("http://sharepoint.company.org")
$web = $site.RootWeb

# open page, for publishing pages
$pWeb = [Microsoft.SharePoint.Publishing.PublishingWeb]::GetPublishingWeb($web)
$page = $pWeb.GetPublishingPages() | ? {$_.Name -eq "default.aspx"}
$page.CheckOut()

# open page, for non-publishing pages
#$page = $web.GetFile("Pages/default.aspx")
#$page.CheckOut()

# find a specific web part, e.g. Wifi password CEWP.
$webPartManager = $web.GetLimitedWebPartManager($page.url, [System.Web.UI.WebControls.WebParts.PersonalizationScope]::Shared)
$webPart = $webPartManager.WebParts | ? {$_.Title -eq "Guest Wifi Password"}

# create CEWP content
$newcontent = "<p><span class='ms-rteFontFace-10 ms-rteFontSize-4'></span><span class='ms-rteFontFace-10 ms-rteFontSize-4'>$newdata</span><br/></p>"
# create XMP and populate with content
$xmlDoc = New-Object xml;
$newXmlElement = $xmlDoc.CreateElement("Content");
$newXmlElement.InnerText = $newcontent;

# push and save CEWP
$webPart.Content = $newXmlElement;
$webPartManager.SaveChanges($webPart); 

# check in for publishing
$page.CheckIn("WiFi Password Update")  
$page.ListItem.File.Publish("WiFi Password Update")
# publish for non publishing
#$page.Publish("WiFi Password Update")

# trash left over stuff
$web.Dispose()
$site.Dispose()
