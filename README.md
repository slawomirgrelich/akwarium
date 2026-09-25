# akwarium

## Skaner AI

Skaner wysyła zdjęcie do serwerowego endpointu, dzięki czemu klucz dostawcy AI
nie znajduje się w aplikacji mobilnej. Endpoint powinien przyjąć JSON:
`image_base64`, `mime_type` i `system_prompt`, a zwrócić wymagany JSON gatunku
(opcjonalnie opakowany w pole `result`). Dla nierozpoznanego gatunku zwraca `422`.

Uruchomienie z własnym endpointem:

```text
flutter run --dart-define=AI_SCANNER_ENDPOINT=https://example.com/api/aquarium-scan
```

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
