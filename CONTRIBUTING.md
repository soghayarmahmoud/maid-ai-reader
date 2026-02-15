# Contributing to MAID AI Reader

Thank you for considering contributing to MAID AI Reader! This document provides guidelines and instructions for contributing.

## Code of Conduct

- Be respectful and inclusive
- Provide constructive feedback
- Focus on what is best for the community
- Show empathy towards other contributors

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check existing issues to avoid duplicates. When creating a bug report, include:

- **Clear title and description**
- **Steps to reproduce** the issue
- **Expected behavior** vs actual behavior
- **Screenshots** if applicable
- **Environment details** (Flutter version, OS, device)

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion, include:

- **Use a clear and descriptive title**
- **Detailed description** of the proposed feature
- **Explain why** this enhancement would be useful
- **Provide examples** of how it would work

### Pull Requests

1. **Fork the repository** and create your branch from `main`
2. **Follow the coding style** used throughout the project
3. **Write clear commit messages**
4. **Add tests** for new features
5. **Update documentation** as needed
6. **Ensure all tests pass** before submitting

## Development Setup

1. **Clone your fork:**
   ```bash
   git clone https://github.com/YOUR_USERNAME/maid-ai-reader.git
   cd maid-ai-reader
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run the app:**
   ```bash
   flutter run
   ```

4. **Run tests:**
   ```bash
   flutter test
   ```

## Coding Guidelines

### Dart Style

- Follow the [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Use `flutter format` to format code
- Use `flutter analyze` to check for issues

### Architecture

- Follow **Clean Architecture** principles
- Keep features **modular and independent**
- Separate **UI, business logic, and data layers**

### File Organization

```
feature_name/
├── data/
│   ├── models/
│   ├── repositories/
│   └── sources/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
└── presentation/
    ├── pages/
    ├── widgets/
    └── bloc/ (or viewmodel/)
```

### Naming Conventions

- **Files:** `snake_case.dart`
- **Classes:** `PascalCase`
- **Variables:** `camelCase`
- **Constants:** `camelCase` or `SCREAMING_SNAKE_CASE` for compile-time constants
- **Private members:** prefix with `_`

### Testing

- Write **unit tests** for business logic
- Write **widget tests** for UI components
- Write **integration tests** for critical user flows
- Aim for **high test coverage** (>80%)

### Documentation

- Add **doc comments** for public APIs
- Use **clear and concise** language
- Include **code examples** where helpful
- Keep **README.md** up to date

## Commit Message Guidelines

Use clear and meaningful commit messages:

```
type(scope): subject

body

footer
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

**Examples:**
```
feat(pdf): add zoom controls to PDF viewer
fix(notes): resolve crash when deleting notes
docs(readme): update installation instructions
```

## Feature Implementation Checklist

When implementing a new feature:

- [ ] Create feature branch from `main`
- [ ] Implement the feature following architecture guidelines
- [ ] Add unit tests
- [ ] Add widget tests if applicable
- [ ] Update documentation
- [ ] Test on multiple devices/platforms
- [ ] Create pull request with clear description
- [ ] Respond to code review feedback

## Priority Areas for Contribution

1. **AI Service Integration**
   - Implement OpenAI integration
   - Implement Google Gemini integration
   - Add support for other AI services

2. **Persistent Storage**
   - Implement Hive storage for notes
   - Add search and filtering for notes
   - Implement note categories/tags

3. **PDF Features**
   - Add annotation tools
   - Implement bookmarks
   - Add highlight colors

4. **Testing**
   - Increase test coverage
   - Add integration tests
   - Add performance tests

5. **UI/UX Improvements**
   - Improve accessibility
   - Add animations
   - Enhance error messages

## Questions?

Feel free to open an issue with the `question` label if you need help!

## License

By contributing, you agree that your contributions will be licensed under the project's MIT License.
