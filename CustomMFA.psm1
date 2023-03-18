function Get-OTP {
    param(
        [string]$Secret
    )

    # Use the TOTP algorithm from the OTPCredentialProvider module
    $otp = New-Totp -Secret $Secret -AsPlainText
    return $otp
}


function Send-OTP([int]$OTP, [string]$Destination) {
    # Add your logic for sending the OTP to the user. You can use email, SMS, or a push notification, depending on the MFA provider.
    # In this example, we still print the OTP to the console for demonstration purposes.
    # You can replace this with your actual OTP sending logic.
    Write-Host "Sending OTP: $OTP to destination: $Destination"
}

function Verify-OTP([int]$OTP, [int]$UserInput, [string]$Secret) {
    # Verify the OTP provided by the user using the TOTP algorithm from the OTPCredentialProvider module
    $generatedOTP = Get-OTP -Secret $Secret
    return ($generatedOTP -eq $UserInput)
}