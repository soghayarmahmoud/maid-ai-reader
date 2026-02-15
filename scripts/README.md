# Scripts Directory

This directory contains utility scripts for the MAID AI Reader project.

## Available Scripts

### create_issues.sh

**Purpose:** Automatically create all 11 GitHub issues using the GitHub CLI.

**Prerequisites:**
- GitHub CLI (`gh`) installed ([Install Guide](https://cli.github.com/))
- Authenticated with GitHub (`gh auth login`)

**Usage:**
```bash
./scripts/create_issues.sh
```

**What it does:**
- Creates 11 GitHub issues based on the EPICs
- Adds appropriate labels to each issue
- Includes full descriptions, tasks, and acceptance criteria
- Marks completed items with checkboxes

**Issues Created:**
1. Setup Clean Architecture Base
2. Global Theme & Constants
3. Implement PDF Viewer
4. PDF Page Navigation
5. Search Inside PDF
6. AI Service Integration
7. Ask Questions About PDF
8. Create Smart Notes
9. AI Summarized Notes
10. Translate Selected Text
11. Unit Tests for Core Features

**Labels Used:**
- `feature` - New features
- `architecture` - Architecture changes
- `ui` - User interface work
- `pdf` - PDF-related features
- `ai` - AI integration
- `notes` - Note-taking features
- `translation` - Translation features
- `testing` - Test coverage
- `enhancement` - Improvements
- `good first issue` - Good for new contributors
- `quality` - Code quality improvements

## Alternative Methods

### Manual Creation
See `GITHUB_ISSUES.md` for copy-paste ready issue descriptions.

### GitHub API
You can also use the GitHub REST API to create issues programmatically:

```bash
curl -X POST \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  https://api.github.com/repos/soghayarmahmoud/maid-ai-reader/issues \
  -d '{"title":"Issue Title","body":"Issue description","labels":["feature"]}'
```

## Notes

- All issues are documented in `GITHUB_ISSUES.md`
- Issues reflect the current state of implementation
- Most features have UI complete but need integration (AI services, persistence)
- See `TODO.md` for future enhancements

## Troubleshooting

### "gh: command not found"
Install GitHub CLI:
- macOS: `brew install gh`
- Windows: `winget install --id GitHub.cli`
- Linux: See https://github.com/cli/cli/blob/trunk/docs/install_linux.md

### "gh auth status failed"
Authenticate with GitHub:
```bash
gh auth login
```

### "Resource not accessible by integration"
Make sure you have write access to the repository.

## Contributing

If you create additional scripts, please:
1. Add them to this directory
2. Make them executable: `chmod +x script_name.sh`
3. Document them in this README
4. Include a help message in the script
