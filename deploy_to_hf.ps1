# PowerShell script to deploy to HuggingFace Space
# Run this from your project root directory

Write-Host "🚀 Deploying to HuggingFace Space..." -ForegroundColor Green

# Step 1: Clone the Space (if not already cloned)
if (-not (Test-Path "TDS_2")) {
    Write-Host "📥 Cloning HuggingFace Space..." -ForegroundColor Yellow
    git clone https://huggingface.co/spaces/ManipatiHarry/TDS_2
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Failed to clone. Make sure you have a HuggingFace access token." -ForegroundColor Red
        exit 1
    }
}

# Step 2: Copy files
Write-Host "📋 Copying files..." -ForegroundColor Yellow
Set-Location TDS_2

# Remove any existing TDS_2 subfolder (if accidentally copied)
if (Test-Path "TDS_2") {
    Remove-Item -Path "TDS_2" -Recurse -Force
}

# Copy all files except git, venv, cache, etc.
$excludeItems = @(".git", ".venv", "__pycache__", "LLMFiles", ".env", "TDS_2")
Get-ChildItem -Path ".." -File -Recurse | Where-Object {
    $relativePath = $_.FullName.Replace((Resolve-Path "..").Path + "\", "")
    $shouldExclude = $false
    foreach ($exclude in $excludeItems) {
        if ($relativePath -like "$exclude*") {
            $shouldExclude = $true
            break
        }
    }
    -not $shouldExclude
} | ForEach-Object {
    $destPath = $_.FullName.Replace((Resolve-Path "..").Path, ".")
    $destDir = Split-Path $destPath -Parent
    if (-not (Test-Path $destDir)) {
        New-Item -ItemType Directory -Path $destDir -Force | Out-Null
    }
    Copy-Item $_.FullName -Destination $destPath -Force
}

# Also copy directories
Get-ChildItem -Path ".." -Directory | Where-Object {
    $name = $_.Name
    $name -ne ".git" -and $name -ne ".venv" -and $name -ne "__pycache__" -and $name -ne "LLMFiles" -and $name -ne ".env" -and $name -ne "TDS_2"
} | ForEach-Object {
    $destPath = Join-Path "." $_.Name
    if (-not (Test-Path $destPath)) {
        Copy-Item $_.FullName -Destination $destPath -Recurse -Force
    }
}

# Step 3: Git add and commit
Write-Host "💾 Committing changes..." -ForegroundColor Yellow
git add .
git commit -m "Deploy LLM Analysis Quiz Solver" 2>&1 | Out-Null

# Step 4: Push
Write-Host "⬆️  Pushing to HuggingFace..." -ForegroundColor Yellow
git push

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Deployment successful!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "1. Go to https://huggingface.co/spaces/ManipatiHarry/TDS_2" -ForegroundColor White
    Write-Host "2. Add secrets in Settings → Secrets:" -ForegroundColor White
    Write-Host "   - EMAIL = 23f2001956@ds.study.iitm.ac.in" -ForegroundColor White
    Write-Host "   - SECRET = Harshi@2005" -ForegroundColor White
    Write-Host "   - GOOGLE_API_KEY = (your API key)" -ForegroundColor White
    Write-Host "3. Wait for build to complete" -ForegroundColor White
    Write-Host "4. Your API: https://manipatiharry-tds-2.hf.space/solve" -ForegroundColor White
} else {
    Write-Host "❌ Push failed. Check your HuggingFace access token." -ForegroundColor Red
}

Set-Location ..

