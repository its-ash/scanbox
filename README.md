# Scanbox

Turn your camera into an offline document scanner.

**[Website](https://scanbox.itsash.in)** · **[Download APK](https://github.com/its-ash/scanbox/releases/latest/download/scanbox.apk)** · Get it in **[Ash Store](https://store.itsash.in)**

## Features

- **Camera capture** with automatic edge detection and perspective correction (Google ML Kit Document Scanner)
- **Images to PDF**: pick photos from your gallery and turn them into a PDF (no storage permission needed)
- **Filters**: Original, Magic Color, Black & White, Grayscale, Strong Contrast
- **Manual rotate** and page reordering
- **Multi-page documents**: scan, add, reorder or delete pages before export
- **OCR**: on-device text extraction (Google ML Kit Text Recognition)
- **PDF export**: A4, Letter or Legal page size
- **Password protection**: AES-256 encryption on exported PDFs
- **Share & print** straight from the document viewer
- **Home / History / Settings** tabs
- **Dark mode**, fully offline, no accounts

## Install

- **Ash Store**: install [Ash Store](https://store.itsash.in) once, then install and update Scanbox from it.
- **APK**: download the [latest APK](https://github.com/its-ash/scanbox/releases/latest/download/scanbox.apk) on your phone and open it. Allow your browser to install unknown apps if Android asks.

Requires Android 6.0 (API 23) or later.

## Develop

Needs Flutter ≥ 3.44, Dart ≥ 3.12 and the shared theme package.

```bash
make run      # flutter run
make build    # release APK
make deploy   # bump version, build, tag, push, GitHub release (see store.mk)
```

## Release

`make deploy` follows the Ash Store kit (`store.mk`, `store.json`): it bumps the
version in `pubspec.yaml`, builds, commits, tags `vX.Y.Z`, pushes, and publishes
a GitHub release with `scanbox.apk`. Ash Store and the website pick up the new
version from that release.

## Project layout

Clean Architecture, three layers under `lib/`:

```
lib/
├── domain/         # entities (ScanDocument, ScanPage) and the DocumentRepository interface
├── data/           # datasources for scanner, OCR, image processing, PDF, storage + repository
├── presentation/   # Riverpod providers, screens, shared widgets
└── core/           # constants, typed exceptions, app router
```

| Component | Package |
|---|---|
| Camera / scanning | `camera`, `google_mlkit_document_scanner` |
| OCR | `google_mlkit_text_recognition` |
| Image processing | `image` |
| PDF generation | `pdf`, `printing`, `syncfusion_flutter_pdf` |
| State management | `flutter_riverpod` |
| Storage | `path_provider`, `shared_preferences` |
| Sharing | `share_plus` |

See [.github/copilot-instructions.md](.github/copilot-instructions.md) for full conventions.

## License

No license file is included yet.

Built by [itsash.in](https://itsash.in).
