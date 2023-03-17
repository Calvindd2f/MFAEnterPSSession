@{
    ModuleVersion = '1.0'
    GUID = 'your-module-guid' # Generate a GUID using New-Guid in PowerShell
    Author = 'your-name'
    CompanyName = 'your-company'
    Copyright = 'your-copyright'
    Description = 'Custom MFA Module'
    PowerShellVersion = '5.1'
    FunctionsToExport = @('Get-OTP', 'Send-OTP', 'Verify-OTP')
}
