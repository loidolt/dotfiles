# Windows initial setup - installs bare minimum for Nix via WSL2
# This script sets up WSL2 and guides you to run the Linux setup inside WSL

#Requires -RunAsAdministrator

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "=== Windows Initial Setup ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "This script will prepare Windows for the dotfiles by setting up WSL2." -ForegroundColor Blue
Write-Host "Nix does not run natively on Windows - it requires WSL2 (Windows Subsystem for Linux)." -ForegroundColor Yellow
Write-Host ""

# Function to write colored output
function Write-Info {
    param([string]$Message)
    Write-Host "i $Message" -ForegroundColor Blue
}

function Write-Success {
    param([string]$Message)
    Write-Host "✓ $Message" -ForegroundColor Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "! $Message" -ForegroundColor Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "✗ $Message" -ForegroundColor Red
}

function Write-Section {
    param([string]$Message)
    Write-Host ""
    Write-Host "=== $Message ===" -ForegroundColor Magenta
    Write-Host ""
}

# Check if running as Administrator
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "This script must be run as Administrator"
    Write-Info "Right-click PowerShell and select 'Run as Administrator'"
    exit 1
}

# Check Windows version (WSL2 requires Windows 10 version 2004 or higher)
Write-Section "Checking Windows Version"
$osVersion = [System.Environment]::OSVersion.Version
$build = $osVersion.Build

if ($build -lt 19041) {
    Write-Error "WSL2 requires Windows 10 version 2004 (build 19041) or higher"
    Write-Info "Current build: $build"
    Write-Info "Please update Windows before proceeding"
    exit 1
}

Write-Success "Windows version is compatible (build $build)"

# Check if WSL is already installed
Write-Section "Checking WSL Installation"

$wslInstalled = $false
try {
    $wslVersion = wsl --version 2>&1
    if ($LASTEXITCODE -eq 0) {
        $wslInstalled = $true
        Write-Success "WSL is already installed"
        wsl --version
    }
} catch {
    $wslInstalled = $false
}

if (-not $wslInstalled) {
    Write-Info "WSL is not installed. Installing WSL2..."
    
    # Install WSL2 (this works on Windows 10 2004+ and Windows 11)
    Write-Info "This will install WSL2 and Ubuntu by default"
    Write-Info "A system restart will be required after installation"
    
    $response = Read-Host "Install WSL2 now? (Y/n)"
    if ($response -eq "" -or $response -eq "Y" -or $response -eq "y") {
        try {
            # Modern installation method (Windows 10 2004+ / Windows 11)
            wsl --install
            
            Write-Success "WSL2 installation initiated"
            Write-Warning "You MUST restart your computer to complete WSL installation"
            Write-Info "After restart, run this script again to continue setup"
            
            $restart = Read-Host "Restart now? (Y/n)"
            if ($restart -eq "" -or $restart -eq "Y" -or $restart -eq "y") {
                Restart-Computer
            }
            exit 0
        } catch {
            Write-Error "WSL installation failed: $_"
            Write-Info "Try installing manually:"
            Write-Info "  1. Open PowerShell as Administrator"
            Write-Info "  2. Run: wsl --install"
            Write-Info "  3. Restart your computer"
            exit 1
        }
    } else {
        Write-Warning "Skipping WSL installation"
        Write-Info "To install manually, run: wsl --install"
        exit 0
    }
}

# Check if a WSL distribution is installed
Write-Section "Checking WSL Distributions"

$wslList = wsl --list --quiet
if ($null -eq $wslList -or $wslList.Count -eq 0) {
    Write-Warning "No WSL distributions installed"
    Write-Info "Installing Ubuntu (default distribution)..."
    
    $response = Read-Host "Install Ubuntu? (Y/n)"
    if ($response -eq "" -or $response -eq "Y" -or $response -eq "y") {
        wsl --install -d Ubuntu
        Write-Success "Ubuntu installation initiated"
        Write-Info "Please complete the Ubuntu setup (username/password) when prompted"
        Write-Info "Then re-run this script"
        exit 0
    } else {
        Write-Warning "You can install a distribution manually:"
        Write-Info "  wsl --install -d Ubuntu"
        Write-Info "  wsl --install -d Debian"
        exit 0
    }
}

Write-Success "WSL distributions installed:"
wsl --list --verbose

# Check WSL version
Write-Section "Checking WSL Version"

$wslDefaultVersion = wsl --status | Select-String "Default Version"
if ($wslDefaultVersion -match "2") {
    Write-Success "WSL default version is 2"
} else {
    Write-Warning "Setting WSL default version to 2..."
    wsl --set-default-version 2
    Write-Success "WSL default version set to 2"
}

# Instructions for running the Linux setup inside WSL
Write-Section "Next Steps"

Write-Success "WSL2 setup complete!"
Write-Host ""
Write-Info "Now you need to run the Linux setup inside WSL:"
Write-Host ""
Write-Host "  1. Open WSL terminal:" -ForegroundColor Yellow
Write-Host "     wsl" -ForegroundColor White
Write-Host ""
Write-Host "  2. Update the package manager:" -ForegroundColor Yellow
Write-Host "     sudo apt update" -ForegroundColor White
Write-Host ""
Write-Host "  3. Clone the dotfiles repository:" -ForegroundColor Yellow
Write-Host "     git clone https://github.com/YOUR_USERNAME/dotfiles.git ~/dotfiles" -ForegroundColor White
Write-Host ""
Write-Host "  4. Run the initial setup script:" -ForegroundColor Yellow
Write-Host "     bash ~/dotfiles/scripts/initial-setup.sh" -ForegroundColor White
Write-Host ""
Write-Info "The initial-setup.sh script will detect your WSL distribution and install Nix"
Write-Host ""

# Offer to open WSL
$openWSL = Read-Host "Open WSL terminal now? (Y/n)"
if ($openWSL -eq "" -or $openWSL -eq "Y" -or $openWSL -eq "y") {
    wsl
}
