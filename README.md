# akwarium

## Skaner AI

Skaner wysyła zdjęcie do serwerowego endpointu, dzięki czemu klucz dostawcy AI
nie znajduje się w aplikacji mobilnej. Endpoint powinien przyjąć JSON:
`image_base64`, `mime_type` i `system_prompt`, a zwrócić wymagany JSON gatunku
(opcjonalnie opakowany w pole `result`). Dla nierozpoznanego gatunku zwraca `422`.

Domyślnie, gdy endpoint nie jest ustawiony albo jest niedostępny, aplikacja
korzysta z `MockAiScannerService`, aby można było testować cały widok wyniku.
Wynik jest oznaczony w UI jako demonstracyjny. Mock można wyłączyć w buildzie
produkcyjnym przez `AI_SCANNER_ALLOW_MOCK=false`.

Konfiguracja znajduje się w `AiScannerService` i korzysta z `String.fromEnvironment`.
Uruchomienie z własnym endpointem:

```text
flutter run --dart-define=AI_SCANNER_ENDPOINT=https://example.com/api/aquarium-scan --dart-define=AI_SCANNER_ALLOW_MOCK=false
```

Asystent glonów korzysta z analogicznych zmiennych:
`ALGAE_ASSISTANT_ENDPOINT` i `ALGAE_ASSISTANT_ALLOW_MOCK`. Endpoint otrzymuje
parametry `NO3`, `PO4`, `Fe`, `pH`, `KH`, światło, CO2, podłoże oraz opcjonalne
`image_base64`. Zwraca JSON z polami `glon`, `przyczyna` i tablicą
`plan_dzialania`. Przykładowe uruchomienie produkcyjne:

```text
flutter run --dart-define=ALGAE_ASSISTANT_ENDPOINT=https://example.com/api/algae-diagnosis --dart-define=ALGAE_ASSISTANT_ALLOW_MOCK=false
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
