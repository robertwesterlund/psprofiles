$host.ui.RawUI.BackgroundColor = 'Black'
$host.ui.RawUI.ForegroundColor = 'Gray'
Enter-GitPrompt
cls
# Chocolatey profile
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}
