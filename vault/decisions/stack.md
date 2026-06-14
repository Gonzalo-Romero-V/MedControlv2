---
status: draft
type: decision
layer: H3
created: 2026-06-14
---

# Stack — MedControlv2

## Stack elegido

- **Frontend móvil**: Flutter (Dart) — Android prioritario, iOS contemplado
- **Persistencia local**: SQLite vía `sqflite` o `drift`
- **Notificaciones**: `flutter_local_notifications` — programadas localmente, sin servidor
- **Cámara / captura**: `image_picker` + `camera`
- **OCR (vía principal)**: Google Cloud Vision API — `DOCUMENT_TEXT_DETECTION`. Requiere internet. Mejor precisión en recetas impresas y difíciles.
- **OCR (vía fallback)**: Google ML Kit Text Recognition — on-device, sin internet, sin costo. Menor precisión.
- **IA / parser semántico (vía principal)**: Gemini (free tier) o equivalente con respuesta JSON estructurada. Requiere internet. Interpreta texto OCR → entidades (medicamento, dosis, frecuencia, instrucciones).
- **Parser fallback offline**: formulario manual simple prellenado con el texto OCR extraído por ML Kit. No se implementa parser basado en reglas en MVP — demasiada complejidad para el gain obtenido. Decisión revisable post-MVP según avance.
- **Backend**: Opcional, fuera del MVP. No requerido para funcionamiento core.
- **Locale**: Español (Colombia / regional), formato DD/MM/YYYY

## Motivación

Flutter fue elegido porque el caso de uso requiere una app móvil real: cámara, permisos, notificaciones locales, almacenamiento en dispositivo y funcionamiento offline. Web/PWA no es la opción correcta para el núcleo — las notificaciones programadas locales y el acceso a cámara son ciudadanos de primera clase en Flutter.

Arquitectura local-first porque el usuario (adulto mayor con posible conectividad limitada) no puede depender del internet para recibir su recordatorio de medicación.

## Alternativas descartadas

- **React Native**: descartado por preferencia de stack del equipo y mejor soporte de plugins nativos en Flutter para el caso de uso específico.
- **Web / PWA**: descartado para el core — no garantiza notificaciones confiables ni acceso a cámara con el mismo nivel de integración. Se contempla como panel complementario futuro para cuidadores.
- **Backend obligatorio**: descartado para el MVP — la app debe funcionar sin servidor. Backend es extensión futura para sync/backup.

## Restricciones derivadas

- **Internet requerido solo en registro**: el flujo OCR → IA → entidades puede requerir conectividad, pero siempre debe existir el fallback de ingreso manual sin internet.
- **Después de confirmación → 100% local**: una vez que el usuario aprueba los datos, todo (base de conocimiento, horarios, recordatorios) vive en el dispositivo.
- **0 dependencias de red en runtime de recordatorios**: `flutter_local_notifications` programa alarmas nativas; no hay llamada a servidor para disparar una notificación.
- **SQLite como única fuente de verdad local**: los hechos de la base de conocimiento y el historial de tomas se persisten en SQLite.

## State management

**Riverpod** (flutter_riverpod). Elegido por menor boilerplate que BLoC, integración natural con Clean Architecture (providers exponiendo repositorios y use cases), y mejor DX para MVPs donde la velocidad importa. Patrón: `Provider` / `FutureProvider` / `StateNotifierProvider` según el caso.

## Versiones objetivo

- **Android mínimo**: 8.0 (API 26) — cubre 95%+ de dispositivos activos, garantiza soporte completo de `flutter_local_notifications`, permisos y cámara
- **iOS mínimo**: 13.0 (por definir al momento de setup Xcode)

## AI provider — diseño modular

El proveedor de IA es **parametrizado por variables de entorno**, nunca hardcodeado. Interfaz abstracta `AiParserService` en la capa Domain; implementaciones concretas intercambiables en Data.

```
Domain:
  abstract class AiParserService {
    Future<ParsedPrescription> parse(String ocrText);
  }

Data/implementations:
  GeminiParserService   implements AiParserService   ← activo por defecto
  OpenAiParserService   implements AiParserService   ← disponible
  // otros a futuro

Configuración (.env):
  AI_PROVIDER=gemini          # gemini | openai
  AI_API_KEY=<key>
  AI_MODEL=gemini-1.5-flash   # modelo específico, override opcional
```

El `AiParserService` activo se inyecta vía Riverpod provider leyendo `AI_PROVIDER` del env al arranque. Cambiar de proveedor = cambiar variable de entorno, sin tocar código.

**Proveedor inicial**: Gemini (free tier, modelo `gemini-1.5-flash`). La API key la provee el usuario vía `.env` cuando se necesite — no hay mock, el flujo manual actúa como fallback natural si no hay key configurada.

## Herramientas de desarrollo

- Lenguaje: Dart
- Versión Flutter: estable actual al momento de inicio
- State management: flutter_riverpod
- Tests: flutter_test + integration_test
- Lint: flutter_lints
- Variables de entorno: `flutter_dotenv`
- CI: por definir

## Decisiones pendientes

- [ ] iOS mínimo: confirmar al momento de setup Xcode
- [ ] Gemini model: `gemini-1.5-flash` (velocidad) vs `gemini-1.5-pro` (precisión) — evaluar con recetas reales
- [ ] Parser fallback offline post-MVP: formulario manual es suficiente para MVP
