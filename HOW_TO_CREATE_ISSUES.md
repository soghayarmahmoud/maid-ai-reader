# How to Create GitHub Issues - Step by Step Guide

This guide shows you how to create the 11 documented issues in your GitHub repository.

## 📋 Quick Overview

You have **three options** to create issues:
1. **Automated** - Use the provided script (fastest)
2. **Manual** - Copy-paste from GITHUB_ISSUES.md
3. **API** - Use GitHub REST API

---

## Option 1: Automated Creation (Recommended) 🚀

### Step 1: Install GitHub CLI

**macOS:**
```bash
brew install gh
```

**Windows (using winget):**
```bash
winget install --id GitHub.cli
```

**Linux (Debian/Ubuntu):**
```bash
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update
sudo apt install gh
```

**Other platforms:** Visit https://cli.github.com/

### Step 2: Authenticate

```bash
gh auth login
```

Follow the prompts to authenticate with GitHub.

### Step 3: Navigate to Repository

```bash
cd /path/to/maid-ai-reader
```

### Step 4: Run the Script

```bash
./scripts/create_issues.sh
```

### Step 5: Verify

Check your GitHub repository's Issues tab:
```bash
gh issue list
```

Or visit: https://github.com/soghayarmahmoud/maid-ai-reader/issues

**Done!** All 11 issues are now in your repository.

---

## Option 2: Manual Creation 📝

### Step 1: Open GITHUB_ISSUES.md

Open the file `GITHUB_ISSUES.md` in this repository.

### Step 2: Navigate to GitHub

Go to: https://github.com/soghayarmahmoud/maid-ai-reader/issues

### Step 3: Click "New Issue"

Click the green "New Issue" button.

### Step 4: Copy Issue Content

From `GITHUB_ISSUES.md`, copy the content for Issue #1:

**Title:**
```
Setup Clean Architecture Base
```

**Description:** (Copy everything under Issue #1)
```markdown
## Description
Create the base project structure following Clean Architecture...

## Tasks
- [x] Create core, features, assets folders
...

## Acceptance Criteria
...

## Status
✅ Complete
```

### Step 5: Add Labels

Click "Labels" on the right sidebar and add:
- `feature`
- `architecture`
- `good first issue`

### Step 6: Create Issue

Click "Submit new issue"

### Step 7: Repeat

Repeat steps 3-6 for all remaining issues (#2-#11).

---

## Option 3: Using GitHub API 🔧

### Prerequisites

- GitHub Personal Access Token with `repo` scope
- `curl` or similar HTTP client

### Step 1: Get Access Token

1. Go to https://github.com/settings/tokens
2. Click "Generate new token"
3. Select scope: `repo`
4. Generate and copy the token

### Step 2: Set Environment Variable

```bash
export GITHUB_TOKEN="your_token_here"
```

### Step 3: Create Issue via API

Example for Issue #1:

```bash
curl -X POST \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer $GITHUB_TOKEN" \
  https://api.github.com/repos/soghayarmahmoud/maid-ai-reader/issues \
  -d '{
    "title": "Setup Clean Architecture Base",
    "body": "## Description\nCreate the base project structure...",
    "labels": ["feature", "architecture", "good first issue"]
  }'
```

### Step 4: Repeat for All Issues

Use the content from `GITHUB_ISSUES.md` for each issue.

---

## 🎯 What You'll Get

After creating the issues, you'll have:

### EPIC: Project Setup (2 issues)
- #1 Setup Clean Architecture Base
- #2 Global Theme & Constants

### EPIC: PDF Reader (3 issues)
- #3 Implement PDF Viewer
- #4 PDF Page Navigation
- #5 Search Inside PDF

### EPIC: AI Search (2 issues)
- #6 AI Service Integration
- #7 Ask Questions About PDF

### EPIC: Smart Notes (2 issues)
- #8 Create Smart Notes
- #9 AI Summarized Notes

### EPIC: Translator (1 issue)
- #10 Translate Selected Text

### EPIC: Testing (1 issue)
- #11 Unit Tests for Core Features

---

## 📊 Issue Organization

### By Label

**Features:** 10 issues
- All issues except #11

**Architecture:** 1 issue
- #1

**UI:** 3 issues
- #2, #4, #7

**PDF:** 5 issues
- #3, #4, #5, #7

**AI:** 4 issues
- #6, #7, #9, #10

**Notes:** 2 issues
- #8, #9

**Translation:** 1 issue
- #10

**Testing:** 1 issue
- #11

### By Status

**✅ Complete:** 11 issues (100%)
- All basic functionality and UI implemented

**🔄 Needs Integration:** 5 issues
- #6, #7, #8, #9, #10 need AI service or persistence

---

## 💡 Tips

### For Project Management

1. **Create Milestones:**
   - Milestone 1: Core Features (Issues #1-5)
   - Milestone 2: AI Integration (Issues #6-7, #9-10)
   - Milestone 3: Notes & Testing (Issues #8, #11)

2. **Use Projects:**
   - Create a GitHub Project board
   - Move issues through: Todo → In Progress → Done

3. **Link PRs:**
   - Reference issues in commits: "Fixes #1"
   - GitHub will auto-link and close issues

### For Team Collaboration

1. **Assign Issues:**
   - Assign team members to specific issues
   - Use "good first issue" for newcomers

2. **Add Comments:**
   - Discuss implementation details in issue comments
   - Link to relevant documentation

3. **Track Progress:**
   - Use issue checklists to track subtasks
   - Update issue descriptions as work progresses

---

## 🔍 Verification

After creating issues, verify with:

```bash
# List all issues
gh issue list

# Filter by label
gh issue list --label "feature"

# View specific issue
gh issue view 1
```

Or check the GitHub web interface:
https://github.com/soghayarmahmoud/maid-ai-reader/issues

---

## 🆘 Troubleshooting

### Script fails: "gh: command not found"

**Solution:** Install GitHub CLI (see Step 1 in Option 1)

### Script fails: "Not authenticated"

**Solution:** Run `gh auth login` and follow prompts

### API returns "Not Found"

**Solution:** Check repository name is correct: `soghayarmahmoud/maid-ai-reader`

### API returns "Bad credentials"

**Solution:** Generate a new token with correct permissions

### Issues already exist

**Solution:** Issues can be updated or closed if you need to recreate them

---

## 📚 Additional Resources

- **GitHub Issues Docs:** https://docs.github.com/en/issues
- **GitHub CLI Docs:** https://cli.github.com/manual/
- **GitHub API Docs:** https://docs.github.com/en/rest/issues
- **Project Documentation:** See README.md, CONTRIBUTING.md

---

## ✅ Checklist

Before you start:
- [ ] Choose your method (Automated, Manual, or API)
- [ ] Have GitHub access to the repository
- [ ] Reviewed GITHUB_ISSUES.md
- [ ] Ready to create 11 issues

After creation:
- [ ] Verify all 11 issues are created
- [ ] Check labels are applied correctly
- [ ] Confirm issue descriptions are complete
- [ ] Optionally: Create milestones
- [ ] Optionally: Set up project board
- [ ] Share with team members

---

**Good luck! 🎉**

If you encounter any issues, refer to GITHUB_ISSUES.md for the complete issue content.
