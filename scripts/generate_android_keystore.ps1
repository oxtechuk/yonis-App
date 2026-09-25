# Step 4: Generate Production Android Keystore
# Run this script on a machine with JDK installed (keytool available)
# Requires: Java JDK 17+

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = Split-Path -Parent $ScriptDir
$KeystoreName = Join-Path $RepoRoot "younis_release.keystore"
$Alias = "younis_key"
$Validity = 10000
$KeyAlg = "RSA"
$KeySize = 2048

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Younis Android Keystore Generator" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Prompt for credentials
$KeystorePassword = Read-Host "Enter keystore password" -AsSecureString
$KeyPassword = Read-Host "Enter key password" -AsSecureString

# Convert SecureString to plain text for keytool
$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($KeystorePassword)
$KeystorePasswordPlain = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
$BSTR2 = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($KeyPassword)
$KeyPasswordPlain = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR2)

# Generate keystore
$KeytoolPath = "keytool"
$Args = @(
    "-genkey",
    "-v",
    "-keystore", $KeystoreName,
    "-alias", $Alias,
    "-keyalg", $KeyAlg,
    "-keysize", $KeySize,
    "-validity", $Validity,
    "-storepass", $KeystorePasswordPlain,
    "-keypass", $KeyPasswordPlain,
    "-dname", "CN=Younis, OU=Development, O=Younis Almurshid, L=Unknown, ST=Unknown, C=EG"
)

Write-Host "`nGenerating keystore..." -ForegroundColor Yellow
& $KeytoolPath $Args

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Keystore generation failed." -ForegroundColor Red
    exit 1
}

Write-Host "`nKeystore generated successfully: $KeystoreName" -ForegroundColor Green

# Verify keystore
Write-Host "`nVerifying keystore..." -ForegroundColor Yellow
& $KeytoolPath "-list", "-v", "-keystore", $KeystoreName, "-storepass", $KeystorePasswordPlain

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Keystore verification failed." -ForegroundColor Red
    exit 1
}

# Encode keystore to Base64 for Codemagic
Write-Host "`nEncoding keystore to Base64 for Codemagic..." -ForegroundColor Yellow
$Base64Content = [Convert]::ToBase64String([IO.File]::ReadAllBytes($KeystoreName))

$Base64OutputFile = Join-Path $RepoRoot "younis_release_keystore_base64.txt"
$Base64Content | Out-File -FilePath $Base64OutputFile -Encoding UTF8

Write-Host "" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host "  DONE" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host "Keystore file:       $KeystoreName" -ForegroundColor White
Write-Host "Base64 encoded file: $Base64OutputFile" -ForegroundColor White
Write-Host "Alias:               $Alias" -ForegroundColor White
Write-Host "Validity:            $Validity days" -ForegroundColor White
Write-Host "" -ForegroundColor Yellow
Write-Host "Copy the contents of $Base64OutputFile into the CM_KEYSTORE" -ForegroundColor Yellow
Write-Host "environment variable in Codemagic (android_signing group)." -ForegroundColor Yellow
Write-Host "" -ForegroundColor Yellow
Write-Host "IMPORTANT: Securely store the following in your password manager:" -ForegroundColor Red
Write-Host "  - Keystore password" -ForegroundColor Red
Write-Host "  - Key password" -ForegroundColor Red
Write-Host "  - Alias: $Alias" -ForegroundColor Red
Write-Host "  - Keystore file backup" -ForegroundColor Red

# Clean up plain text passwords
[System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($BSTR)
[System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($BSTR2)
