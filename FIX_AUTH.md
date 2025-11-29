# Fix HuggingFace Authentication Error

## The Problem
You're getting: "You are not authorized to push to this repo"

This means your token either:
- Doesn't have WRITE permissions
- Is expired
- Is invalid

## Solution: Get a New Token

### Step 1: Create a New Token
1. Go to: https://huggingface.co/settings/tokens
2. Click **"New token"**
3. **IMPORTANT:** Select **"Write"** permissions (not just Read)
4. Name it: "TDS_2_Deploy" (or any name)
5. Click **"Generate token"**
6. **Copy the token immediately** (you won't see it again!)

### Step 2: Update Git Remote with New Token

Run this command (replace `YOUR_NEW_TOKEN` with the token you just copied):

```powershell
git remote set-url origin https://ManipatiHarry:YOUR_NEW_TOKEN@huggingface.co/spaces/ManipatiHarry/TDS_2
```

### Step 3: Verify and Push

```powershell
# Check the remote is updated
git remote -v

# Now push
git push
```

## Alternative: Use Git Credential Helper

If you prefer not to put the token in the URL:

```powershell
# Remove token from URL
git remote set-url origin https://huggingface.co/spaces/ManipatiHarry/TDS_2

# Configure git credential helper
git config --global credential.helper store

# When you push, it will ask for:
# Username: ManipatiHarry
# Password: (paste your token here)
git push
```

## Quick Fix Command

Once you have your new token, run:

```powershell
git remote set-url origin https://ManipatiHarry:YOUR_NEW_TOKEN@huggingface.co/spaces/ManipatiHarry/TDS_2
git push
```


