# The Forge - Flutter Base Template

Production-ready Flutter starter with scalable architecture, environment flavors, and quality gates for team development.

## Why this project exists

This repository is a practical foundation for building Flutter apps in real teams. It includes structure, scripts, and guardrails so features can ship consistently across development, staging, and production.

## Key capabilities

- BLoC-based state management with shared base patterns
- Multi-flavor setup: `development`, `staging`, `production`
- Firebase Cloud Messaging integration support
- Theme management and modular UI organization
- Route handling with GoRouter
- Environment-driven configuration
- Git hooks for commit quality and message conventions
- CI/CD workflows for validation and release builds

## Tech stack

- Flutter
- Dart
- BLoC / Cubit
- GoRouter
- Firebase Cloud Messaging
- GitHub Actions

## Repository structure

```text
lib/
├── core/              # Base classes, shared abstractions, cross-cutting concerns
├── modules/           # Feature modules (UI + state + domain logic)
├── routes/            # App navigation setup
├── services/          # External services (notifications, storage, etc.)
├── utils/             # Config, theming, helpers, networking utilities
└── main.dart          # Application entry point
```

## Prerequisites

- Flutter SDK installed and configured
- Dart SDK (bundled with Flutter)
- Android Studio or VS Code
- Firebase project (if using push notifications)
- ImageMagick (for flavor icon generation)

## Quick start

1. Clone the repository:

```bash
git clone https://github.com/yourusername/flutter_base_template.git
cd flutter_base_template
```

2. Install dependencies:

```bash
flutter pub get
```

3. Create environment files:

```bash
cp .env.example .env.development
cp .env.example .env.staging
cp .env.example .env.production
```

4. Generate flavor-specific app icons:

```bash
chmod +x scripts/generate_icons.sh
./scripts/generate_icons.sh
```

5. Run the app:

```bash
chmod +x scripts/run.sh
./scripts/run.sh development
```

Replace `development` with `staging` or `production` when needed.

## Run by flavor

```bash
./scripts/run.sh development
./scripts/run.sh staging
./scripts/run.sh production
```

Each flavor can have different:

- app name
- app icon
- runtime environment values
- visual indicators (non-production banners)

## Environment management

Expected files:

- `.env.development`
- `.env.staging`
- `.env.production`

Use `scripts/setup-env.sh` to validate environment configuration and required variables before running builds.

## Scripts

- `scripts/run.sh`: run app by flavor
- `scripts/generate_icons.sh`: create flavor-branded launcher icons
- `scripts/setup-env.sh`: validate flavor environment configuration
- `scripts/git_hooks.sh`: install/test local Git hooks

## Architecture overview

### State management

The app uses BLoC/Cubit with base abstractions to standardize:

- event/state flow
- error handling
- logging behavior

### Navigation

Routing is managed through GoRouter, enabling centralized route configuration and maintainable navigation patterns.

### Services layer

The services layer isolates integrations (notifications, storage, and other platform/data services) from UI modules.

## Quality gates

### Local checks

Pre-commit hooks enforce baseline quality:

- block large/binary files
- run `flutter analyze`
- run `flutter test`

Install hooks:

```bash
chmod +x scripts/git_hooks.sh
./scripts/git_hooks.sh setup-symlinks .
```

Optional hook test:

```bash
./scripts/git_hooks.sh test .
```

### CI/CD

GitHub workflows in `.github/workflows`:

- `flutter-ci.yml`: validation pipeline (analysis, tests, configuration checks)
- `flutter-cd.yml`: build pipeline for flavor-based release artifacts

Run workflows from GitHub Actions by selecting flavor and optional environment input.

## Commit message convention

Commits follow Conventional Commits format (emoji optional):

```text
[optional emoji] <type>(<optional scope>): <description>
```

Examples:

```bash
feat(auth): add token refresh flow
fix(login): handle empty password edge case
docs: update setup instructions
:sparkles: feat: add onboarding screens
```

## Troubleshooting

- Install ImageMagick if icon generation fails:

  ```bash
  # macOS
  brew install imagemagick

  # Ubuntu/Debian
  sudo apt-get install imagemagick
  ```

- Ensure scripts are executable:

  ```bash
  chmod +x scripts/*.sh
  ```

- Re-run dependency install:

  ```bash
  flutter pub get
  ```

- Verify Flutter environment:

  ```bash
  flutter doctor
  ```

## Recommended team workflow

1. Branch from `main`
2. Keep PRs focused and small
3. Ensure `flutter analyze` and tests pass locally
4. Use descriptive conventional commit messages
5. Open PR with clear scope and verification steps

## Contribution

1. Fork repository
2. Create a branch (`git checkout -b feature/your-feature`)
3. Implement changes and add tests when applicable
4. Run quality checks
5. Open a pull request

## Roadmap

- Expand automated test coverage
- Add richer documentation and examples
- Improve analytics and observability setup
- Strengthen offline support strategy

## Credits

This project uses theme and design inspiration from [Nylo](https://github.com/nylo-core/nylo). Thanks to the Nylo team for open-source contributions.

## License

Licensed under MIT. See [LICENSE](LICENSE).
