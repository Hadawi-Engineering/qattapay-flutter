# Publishing `qattapay_flutter`

## Prerequisites

1. [pub.dev](https://pub.dev) publisher account under Hadawi / QattaPay
2. Public GitHub repo: `Hadawi-Engineering/qattapay-flutter`
3. `pubspec.yaml` homepage / repository URLs point at that repo

## Release checklist

1. Bump `version` in `pubspec.yaml` and update `CHANGELOG.md`
2. Run analyzer + tests:

```bash
dart pub get
dart analyze
dart test
```

3. Dry-run publish:

```bash
dart pub publish --dry-run
```

4. Tag and push:

```bash
git tag v1.0.0
git push origin main --tags
```

5. Publish:

```bash
dart pub publish
```

## Notes

- Do not commit secrets. Example apps should use placeholders.
- Mobile apps must never embed merchant API keys — document that in every release note if the surface changes.
