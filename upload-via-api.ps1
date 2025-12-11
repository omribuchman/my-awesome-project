# Upload files to GitHub using API
$token = "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"
$owner = "omribuchman"
$repo = "my-awesome-project"
$branch = "main"
$baseUrl = "https://api.github.com/repos/$owner/$repo"

$headers = @{
    Authorization = "token $token"
    Accept = "application/vnd.github.v3+json"
}

# Get current commit SHA
Write-Host "Getting repository info..." -ForegroundColor Yellow
try {
    $repoInfo = Invoke-RestMethod -Uri "$baseUrl" -Headers $headers -Method Get
    Write-Host "Repository found: $($repoInfo.full_name)" -ForegroundColor Green
} catch {
    Write-Host "Error accessing repository: $_" -ForegroundColor Red
    exit 1
}

# Get current branch SHA
try {
    $branchInfo = Invoke-RestMethod -Uri "$baseUrl/git/ref/heads/$branch" -Headers $headers -Method Get
    $baseTreeSha = $branchInfo.object.sha
    Write-Host "Found branch $branch at commit: $baseTreeSha" -ForegroundColor Green
} catch {
    # Branch might not exist, try to get default branch
    try {
        $defaultBranch = $repoInfo.default_branch
        $branchInfo = Invoke-RestMethod -Uri "$baseUrl/git/ref/heads/$defaultBranch" -Headers $headers -Method Get
        $baseTreeSha = $branchInfo.object.sha
        Write-Host "Using default branch $defaultBranch at commit: $baseTreeSha" -ForegroundColor Yellow
    } catch {
        Write-Host "Repository is empty, creating initial commit..." -ForegroundColor Yellow
        $baseTreeSha = $null
    }
}

# Get base commit tree SHA if we have a commit
$baseCommitTreeSha = $null
if ($baseTreeSha) {
    try {
        $commitInfo = Invoke-RestMethod -Uri "$baseUrl/git/commits/$baseTreeSha" -Headers $headers -Method Get
        $baseCommitTreeSha = $commitInfo.tree.sha
        Write-Host "Base tree SHA: $baseCommitTreeSha" -ForegroundColor Green
    } catch {
        Write-Host "Could not get commit tree, will create new one" -ForegroundColor Yellow
    }
}

# Prepare files to upload
$files = @(
    "index.html",
    "israeli_stocks.html", 
    "protein_folding.html",
    "README.md",
    ".gitignore"
)

$treeItems = @()

foreach ($file in $files) {
    if (Test-Path $file) {
        Write-Host "Reading $file..." -ForegroundColor Yellow
        $content = Get-Content $file -Raw -Encoding UTF8
        $bytes = [System.Text.Encoding]::UTF8.GetBytes($content)
        $base64Content = [Convert]::ToBase64String($bytes)
        
        $treeItems += @{
            path = $file
            mode = "100644"
            type = "blob"
            content = $content
        }
        Write-Host "  Added $file" -ForegroundColor Green
    } else {
        Write-Host "  File not found: $file" -ForegroundColor Red
    }
}

if ($treeItems.Count -eq 0) {
    Write-Host "No files to upload!" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Creating blobs..." -ForegroundColor Yellow

# Create blobs for each file
$blobs = @()
foreach ($item in $treeItems) {
    # Convert content to base64
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($item.content)
    $base64Content = [Convert]::ToBase64String($bytes)
    
    $blobBody = @{
        content = $base64Content
        encoding = "base64"
    } | ConvertTo-Json
    
    try {
        $blob = Invoke-RestMethod -Uri "$baseUrl/git/blobs" -Headers $headers -Method Post -Body $blobBody -ContentType "application/json"
        $blobs += @{
            path = $item.path
            sha = $blob.sha
            mode = $item.mode
            type = $item.type
        }
        Write-Host "  Created blob for $($item.path)" -ForegroundColor Green
    } catch {
        Write-Host "  Error creating blob for $($item.path): $_" -ForegroundColor Red
        $errorDetails = $_.ErrorDetails.Message
        Write-Host "  Details: $errorDetails" -ForegroundColor Red
        exit 1
    }
}

Write-Host ""
Write-Host "Creating tree..." -ForegroundColor Yellow

# Create tree
$treeBody = @{
    base_tree = $baseCommitTreeSha
    tree = $blobs | ForEach-Object {
        @{
            path = $_.path
            mode = $_.mode
            type = $_.type
            sha = $_.sha
        }
    }
} | ConvertTo-Json -Depth 10

try {
    $tree = Invoke-RestMethod -Uri "$baseUrl/git/trees" -Headers $headers -Method Post -Body $treeBody -ContentType "application/json"
    Write-Host "Tree created: $($tree.sha)" -ForegroundColor Green
} catch {
    Write-Host "Error creating tree: $_" -ForegroundColor Red
    Write-Host "Response: $($_.Exception.Response)" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Creating commit..." -ForegroundColor Yellow

# Create commit
$commitBody = @{
    message = "Initial commit: Add interactive web projects"
    tree = $tree.sha
    parents = @()
} | ConvertTo-Json

if ($baseTreeSha) {
    $commitBody = @{
        message = "Initial commit: Add interactive web projects"
        tree = $tree.sha
        parents = @($baseTreeSha)
    } | ConvertTo-Json
}

try {
    $commit = Invoke-RestMethod -Uri "$baseUrl/git/commits" -Headers $headers -Method Post -Body $commitBody -ContentType "application/json"
    Write-Host "Commit created: $($commit.sha)" -ForegroundColor Green
} catch {
    Write-Host "Error creating commit: $_" -ForegroundColor Red
    Write-Host "Response: $($_.Exception.Response)" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Updating branch reference..." -ForegroundColor Yellow

# Update branch reference
$refBody = @{
    sha = $commit.sha
} | ConvertTo-Json

try {
    if ($baseTreeSha) {
        # Update existing branch
        $ref = Invoke-RestMethod -Uri "$baseUrl/git/refs/heads/$branch" -Headers $headers -Method Patch -Body $refBody -ContentType "application/json"
    } else {
        # Create new branch
        $ref = Invoke-RestMethod -Uri "$baseUrl/git/refs" -Headers $headers -Method Post -Body (@{
            ref = "refs/heads/$branch"
            sha = $commit.sha
        } | ConvertTo-Json) -ContentType "application/json"
    }
    Write-Host "Branch updated successfully!" -ForegroundColor Green
} catch {
    Write-Host "Error updating branch: $_" -ForegroundColor Red
    Write-Host "Response: $($_.Exception.Response)" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "SUCCESS! Files uploaded to GitHub!" -ForegroundColor Green
Write-Host "View your repository: https://github.com/$owner/$repo" -ForegroundColor Cyan

