# Upload files using GitHub Contents API
$token = "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"
$owner = "omribuchman"
$repo = "my-awesome-project"
$branch = "main"
$baseUrl = "https://api.github.com/repos/$owner/$repo/contents"

$headers = @{
    Authorization = "token $token"
    Accept = "application/vnd.github.v3+json"
}

$files = @(
    "index.html",
    "israeli_stocks.html", 
    "protein_folding.html",
    "README.md",
    ".gitignore"
)

foreach ($file in $files) {
    if (Test-Path $file) {
        Write-Host "Uploading $file..." -ForegroundColor Yellow
        
        $content = Get-Content $file -Raw -Encoding UTF8
        $bytes = [System.Text.Encoding]::UTF8.GetBytes($content)
        $base64Content = [Convert]::ToBase64String($bytes)
        
        $body = @{
            message = "Add $file"
            content = $base64Content
            branch = $branch
        } | ConvertTo-Json
        
        try {
            $result = Invoke-RestMethod -Uri "$baseUrl/$file" -Headers $headers -Method Put -Body $body -ContentType "application/json"
            Write-Host "  Successfully uploaded $file" -ForegroundColor Green
        } catch {
            $errorMsg = $_.Exception.Message
            Write-Host "  Error uploading $file : $errorMsg" -ForegroundColor Red
            $errorDetails = $_.ErrorDetails.Message
            if ($errorDetails) {
                Write-Host "  Details: $errorDetails" -ForegroundColor Red
            }
        }
    } else {
        Write-Host "File not found: $file" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "Done! View repository: https://github.com/$owner/$repo" -ForegroundColor Cyan

