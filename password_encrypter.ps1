<# Set and encrypt credentials to file using default method #>
# run this script as the user going to run the script as
$credential = Get-Credential
$credential.Password | ConvertFrom-SecureString | Set-Content .\scriptsencrypted_password.txt

