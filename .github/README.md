# .github Directory

This directory contains GitHub-specific configuration files and templates for the MAID AI Reader project.

## 📁 Contents

### ISSUE_TEMPLATE/

Contains templates for creating standardized GitHub issues:

#### feature_request.md
Template for proposing new features. Includes:
- Description section
- Tasks checklist
- Acceptance criteria
- Labels guidance
- Additional context

**Usage:** When creating a new issue, select "Feature Request" from the template options.

#### bug_report.md
Template for reporting bugs. Includes:
- Bug description
- Steps to reproduce
- Expected vs. actual behavior
- Screenshots section
- Environment details

**Usage:** When creating a new issue, select "Bug Report" from the template options.

#### config.yml
Configuration file for issue templates that:
- Disables blank issues (forces template use)
- Provides links to documentation
- Links to contributing guide

## 🎯 Purpose

These templates help maintain consistency in:
- Issue descriptions
- Required information
- Project organization
- Team communication

## 📝 Creating Issues

### Using Templates

1. Go to the repository's Issues tab
2. Click "New Issue"
3. Select appropriate template
4. Fill in the required fields
5. Submit the issue

### Template Fields

**Feature Request:**
- **Description:** What feature do you want?
- **Tasks:** List of implementation tasks
- **Acceptance Criteria:** Definition of done
- **Labels:** Suggested labels for categorization

**Bug Report:**
- **Description:** What's wrong?
- **Steps to Reproduce:** How to trigger the bug
- **Expected Behavior:** What should happen
- **Actual Behavior:** What actually happens
- **Environment:** Device, OS, app version

## 🔗 Related Documentation

- **All Issues:** See [GITHUB_ISSUES.md](../GITHUB_ISSUES.md)
- **Creation Guide:** See [HOW_TO_CREATE_ISSUES.md](../HOW_TO_CREATE_ISSUES.md)
- **Contributing:** See [CONTRIBUTING.md](../CONTRIBUTING.md)

## 🏷️ Label Guidelines

Use consistent labels across issues:

**Type:**
- `feature` - New features
- `bug` - Something isn't working
- `enhancement` - Improvements to existing features

**Component:**
- `pdf` - PDF-related
- `ai` - AI features
- `notes` - Note-taking
- `translation` - Translation features
- `ui` - User interface

**Meta:**
- `documentation` - Documentation improvements
- `testing` - Test coverage
- `architecture` - Architecture changes
- `good first issue` - Good for newcomers

**Priority:**
- `critical` - Must be fixed ASAP
- `high` - Should be addressed soon
- `medium` - Normal priority
- `low` - Nice to have

**Status:**
- `help wanted` - Need assistance
- `in progress` - Being worked on
- `blocked` - Cannot proceed

## 💡 Best Practices

### For Issue Creators

1. **Use Templates:** Always use provided templates
2. **Be Specific:** Provide clear, detailed descriptions
3. **Add Labels:** Apply relevant labels
4. **Link References:** Link to related issues/PRs
5. **Update Status:** Keep issue updated as work progresses

### For Issue Reviewers

1. **Validate:** Ensure all required fields are filled
2. **Clarify:** Ask questions if description is unclear
3. **Assign:** Assign to appropriate team member
4. **Label:** Add or correct labels as needed
5. **Milestone:** Add to appropriate milestone

### For Repository Maintainers

1. **Review Templates:** Update templates as project evolves
2. **Update Labels:** Keep label list current
3. **Close Duplicates:** Link and close duplicate issues
4. **Maintain Order:** Keep issues organized
5. **Archive Old:** Archive or close outdated issues

## 🔄 Workflow

Typical issue lifecycle:

```
1. Created     → Issue submitted with template
2. Triaged     → Reviewed, labeled, assigned
3. In Progress → Work begins
4. PR Created  → Pull request references issue
5. Reviewed    → Code review
6. Merged      → PR merged to main
7. Closed      → Issue automatically closed
```

## 📊 Issue Statistics

Track these metrics:
- Open vs. Closed issues
- Issues by label
- Average time to close
- Issues per milestone
- Issues per assignee

## 🛠️ Customization

To modify templates:

1. Edit files in `ISSUE_TEMPLATE/`
2. Test changes in a draft issue
3. Commit and push changes
4. Templates update automatically

## 📚 Resources

- [GitHub Issue Documentation](https://docs.github.com/en/issues)
- [Issue Template Syntax](https://docs.github.com/en/communities/using-templates-to-encourage-useful-issues-and-pull-requests)
- [Managing Labels](https://docs.github.com/en/issues/using-labels-and-milestones-to-track-work)

---

**Questions?** See our [Contributing Guide](../CONTRIBUTING.md) or open an issue!
