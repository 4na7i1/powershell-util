# Proxy
$proxy = "http://34.146.64.228:3128"

# UserAgent
$userAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/107.0.0.0 Safari/537.36"

# Source URL
$url = "http://ifconfig.me/ip"

# Destation file
# $dest = "$((Get-Location).Path)\test.html"

# Download the file (Method1)
(Invoke-WebRequest -Uri $url -SkipCertificateCheck -Proxy $proxy -UserAgent $userAgent).Content

# # Download the file (Method2)
# Start-BitsTransfer -Source $url -Destination $dest -Asynchronous -Priority normal
# # Complete the BitsTransfer
# Get-BitsTransfer | Complete-BitsTransfer