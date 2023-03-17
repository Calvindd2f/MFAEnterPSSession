# mfa_sh-ll

```powershell
Import-Module CustomMFA
$OTP = Get-OTP
Send-OTP -OTP $OTP
$userInput = Read-Host "Enter the OTP received"
if (Verify-OTP -OTP $OTP -UserInput $userInput) {
    Write-Host "OTP verification successful."
} else {
    Write-Host "Invalid OTP."
}

```
