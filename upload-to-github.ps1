# Script to upload files to GitHub
# Run this script: .\upload-to-github.ps1

Write-Host "Starting GitHub upload process..." -ForegroundColor Cyan
Write-Host ""

# Check if Git is installed
Write-Host "Checking Git installation..." -ForegroundColor Yellow
$null = git --version 2>&1
if ($LASTEXITCODE -eq 0) {
    $gitVersion = git --version
    Write-Host "Git is installed: $gitVersion" -ForegroundColor Green
} else {
    Write-Host "Git is not installed!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please install Git from: https://git-scm.com/download/win" -ForegroundColor Yellow
    Write-Host "After installation, restart PowerShell and run this script again." -ForegroundColor Yellow
    Read-Host "Press Enter to close"
    exit 1
}

Write-Host ""

# Check if Git repository already exists
if (Test-Path .git) {
    Write-Host "Git repository already exists" -ForegroundColor Yellow
} else {
    Write-Host "Initializing new Git repository..." -ForegroundColor Yellow
    git init
    Write-Host "Git repository created successfully" -ForegroundColor Green
}

Write-Host ""

# Add all files
Write-Host "Adding files to Git..." -ForegroundColor Yellow
git add .
$status = git status --short
if ($status) {
    Write-Host "Files added:" -ForegroundColor Cyan
    Write-Host $status
} else {
    Write-Host "No new files to add" -ForegroundColor Yellow
}

Write-Host ""

# Check if there are changes to commit
$changes = git status --porcelain
if (-not $changes) {
    Write-Host "No new changes to commit" -ForegroundColor Yellow
    
    # Check if remote already exists
    $null = git remote get-url origin 2>&1
    if ($LASTEXITCODE -eq 0) {
        $remote = git remote get-url origin
        Write-Host "Remote already configured: $remote" -ForegroundColor Green
        Write-Host ""
        Write-Host "Do you want to push existing changes? (y/n)" -ForegroundColor Cyan
        $push = Read-Host
        if ($push -eq "y" -or $push -eq "Y") {
            Write-Host "Pushing changes to GitHub..." -ForegroundColor Yellow
            git push -u origin main
            if ($LASTEXITCODE -eq 0) {
                Write-Host "Files uploaded successfully to GitHub!" -ForegroundColor Green
            } else {
                Write-Host "Error pushing to GitHub" -ForegroundColor Red
            }
        }
    } else {
        Write-Host "Remote not configured" -ForegroundColor Yellow
    }
    Read-Host "Press Enter to close"
    exit 0
}

# Create commit
Write-Host "Creating commit..." -ForegroundColor Yellow
$commitMessage = "Initial commit: Add interactive web projects"
git commit -m $commitMessage

if ($LASTEXITCODE -eq 0) {
    Write-Host "Commit created successfully" -ForegroundColor Green
} else {
    Write-Host "Error creating commit" -ForegroundColor Red
    Read-Host "Press Enter to close"
    exit 1
}

Write-Host ""

# Check if remote already exists
$null = git remote get-url origin 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "Adding GitHub remote..." -ForegroundColor Yellow
    git remote add origin https://github.com/omribuchman/my-awesome-project.git
    Write-Host "Remote added successfully" -ForegroundColor Green
} else {
    $remote = git remote get-url origin
    Write-Host "Remote already configured: $remote" -ForegroundColor Green
}

Write-Host ""

# Change branch name to main if needed
Write-Host "Checking branch name..." -ForegroundColor Yellow
$currentBranch = git branch --show-current
if ($currentBranch -ne "main") {
    Write-Host "Renaming branch from $currentBranch to main..." -ForegroundColor Yellow
    git branch -M main
    Write-Host "Branch renamed to main" -ForegroundColor Green
} else {
    Write-Host "Branch is already named main" -ForegroundColor Green
}

Write-Host ""

# Push to GitHub
Write-Host "Pushing changes to GitHub..." -ForegroundColor Yellow
Write-Host "If prompted for credentials:" -ForegroundColor Yellow
Write-Host "   - Username: omribuchman" -ForegroundColor Cyan
Write-Host "   - Password: Use Personal Access Token (not GitHub password)" -ForegroundColor Cyan
Write-Host "   - Create Token: https://github.com/settings/tokens" -ForegroundColor Cyan
Write-Host ""

git push -u origin main

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "Files uploaded successfully to GitHub!" -ForegroundColor Green
    Write-Host "View project: https://github.com/omribuchman/my-awesome-project" -ForegroundColor Cyan
} else {
    Write-Host ""
    Write-Host "Error pushing to GitHub" -ForegroundColor Red
    Write-Host ""
    Write-Host "Solutions:" -ForegroundColor Yellow
    Write-Host "1. Make sure you have a Personal Access Token from GitHub" -ForegroundColor Cyan
    Write-Host "2. Try running manually: git push -u origin main" -ForegroundColor Cyan
    Write-Host "3. Upload files manually through GitHub website" -ForegroundColor Cyan
}

Write-Host ""
Read-Host "Press Enter to close"
