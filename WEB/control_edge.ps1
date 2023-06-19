$url = "https://duckduckgo.com"

# selenium driver (https://www.nuget.org/packages/Selenium.WebDriver)
$selDriver = Join-Path (Get-Location) "webDriver/WebDriver.dll"
Add-Type -Path $selDriver

# msedgedriver.exe
$edgePath = Join-Path -Path ${env:ProgramFiles(x86)} -ChildPath 'Microsoft\Edge\Application'
if(!($edgeVersion= Get-ChildItem -Name $edgePath | Where-Object { $_ -NotMatch "[a-zA-Z]+" })){Write-Error "No found Edge."}
$svc = [OpenQA.Selenium.Edge.EdgeDriverService]::CreateDefaultService((Join-Path (Get-Location) ".\edgeDriver"),("msedgedriver_$edgeVersion.exe"))

# options (https://www.selenium.dev/selenium/docs/api/java/org/openqa/selenium/edge/EdgeOptions.html)
#$options.BinaryLocation = (Join-Path -Path ${env:ProgramFiles(x86)} -ChildPath 'Microsoft\Edge\Application\msedge.exe')
$options = New-Object OpenQA.Selenium.Edge.EdgeOptions
$options.AddArgument("headless")
$options.AddArgument("disable-gpu")
# $options.AddArgument('proxy-pac-url="http://www.cybersyndrome.net/pac.cgi?rl=a&a=a&rd=r&ru=a"')

$driver = New-Object OpenQA.Selenium.Edge.EdgeDriver($svc, $options)
$driver.Manage().Timeouts().ImplicitWait = [System.TimeSpan]::FromSeconds(4) #Implicit waiting time

# goto URL
try {
    Write-Host "GO >> $url"
    $driver.Navigate().GoToUrl($url)
}
finally {
    pause
    $driver.quit() # quit driver control
}

