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
- **OCR**: <!-- TODO: decidir → Google ML Kit on-device (sin internet, sin costo) vs Google Cloud Vision API (mejor precisión, requiere internet) -->
- **IA / parser semántico**: <!-- TODO: decidir → Claude API / Gemini / GPT-4 Vision para interpretar recetas en texto → entidades estructuradas. Requiere internet solo en este paso. -->
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

## Herramientas de desarrollo

<!-- TODO: completar conforme se definan -->
- Lenguaje: Dart
- Versión Flutter: por definir (estable actual al momento de inicio)
- Tests: flutter_test + integration_test
- Lint: `flutter_lints`
- CI: por definir

## Decisiones pendientes

- [ ] OCR: on-device (ML Kit, sin internet) vs cloud (mejor precisión, requiere conexión en registro)
- [ ] AI provider: Claude API, Gemini, GPT-4 Vision — afecta costo, privacidad y latencia
- [ ] Versión mínima Android/iOS objetivo
- [ ] Gestión de múltiples pacientes en un mismo dispositivo (cuidador que maneja N pacientes)
