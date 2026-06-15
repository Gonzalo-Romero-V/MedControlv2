# MedControlv2

App móvil **local-first** para gestión de medicamentos con IA y base de conocimiento explícita.
Interpreta recetas fotográficas, infiere horarios con un motor de reglas trazable y programa
recordatorios locales confirmados por el usuario.

Proyecto académico — materia **Base de Conocimiento**.

---

## Stack

| Capa | Tecnología |
|---|---|
| Mobile | Flutter 3.33+ · Dart 3 |
| Estado | Riverpod 2 |
| Persistencia | Drift (SQLite) — offline-first |
| Notificaciones | flutter\_local\_notifications 18 + timezone |
| OCR online | Google Cloud Vision API |
| OCR offline | ML Kit on-device (fallback sin conexión) |
| Parser IA | OpenAI GPT-4o / Gemini 2.0 Flash |
| Motor de inferencia | Dart puro — 13 reglas, 0 dependencias externas |

---

## Arquitectura

```
Presentation  ──►  Domain  ──►  Data / Infrastructure
  Riverpod          Use Cases     Drift DAOs
  Widgets           Entities      Cloud APIs
  Screens           InferenceEngine (R01–R13)
```

El `InferenceEngine` es la pieza central del componente académico: una clase Dart pura con
13 reglas de producción (forward chaining) que razona sobre hechos del tratamiento y produce
horarios con traza explicable.

```
Foto de receta
  → Cloud Vision OCR
  → OpenAI / Gemini parser  →  ParsedPrescription
  → InferenceEngine         →  SuggestedTimes + InferenceTraces
  → Revisión humana ← invariante de seguridad: ningún recordatorio se crea sin aprobación
  → SQLite + Notificaciones locales
```

**Reglas del motor** (R01–R13): distribución por intervalo, anclaje a comidas/sueño del perfil,
ayunas, posposición estándar y crítica, conflicto por principio activo, cierre automático por
duración/cantidad, tratamiento indefinido.

---

## Requisitos

- Flutter SDK ≥ 3.33 (`flutter --version`)
- Android SDK 26+ (Android 8.0) o iOS 13+ para correr en dispositivo o emulador
- Python 3.8+ para el engine del vault (opcional — solo para `/sync`)

---

## Setup

```bash
# 1. Variables de entorno
cp app/.env.example app/.env
# Editar app/.env — ver sección Variables más abajo

# 2. Dependencias Flutter
cd app
flutter pub get

# 3. Correr en dispositivo/emulador conectado
flutter run

# 4. Tests
flutter test
```

> **Regenerar código generado** (solo si se modifican tablas Drift o providers anotados):
> ```bash
> dart run build_runner build --delete-conflicting-outputs
> ```

---

## Variables de entorno (`app/.env`)

```env
AI_PROVIDER=openai                        # openai | gemini
AI_API_KEY=sk-...                         # clave del proveedor elegido
AI_MODEL=gpt-4o                           # opcional
VISION_CREDENTIALS_PATH=medcontrolv2-xxxx.json   # service account Cloud Vision OCR
```

Sin `VISION_CREDENTIALS_PATH` el sistema usa ML Kit on-device como fallback OCR.
El archivo de credenciales **no se commitea** — está en `.gitignore`.

---

## Estructura relevante

```
app/
├── lib/
│   ├── domain/
│   │   ├── entities/          # MedTime, TreatmentFacts, PatientProfile, AccessibilityConfig
│   │   ├── services/          # InferenceEngine (R01–R13)
│   │   └── use_cases/         # un use case por operación de dominio
│   ├── infrastructure/
│   │   ├── database/          # Drift: tablas, DAOs, app_database.dart
│   │   └── notifications/     # NotificationService singleton
│   └── presentation/
│       ├── app.dart           # MedControlApp + _MainShell (NavigationBar)
│       ├── features/          # today_reminders / historial / knowledge_base / assisted_mode
│       ├── screens/           # prescription flow / profile settings
│       └── providers/         # Riverpod: database / reminder / patient / historial
vault/                         # Fuente de verdad semántica (Obsidian)
```

---

## Documentación interna

- `AGENTS.md` — protocolo para agentes IA (pre-flight, flujo de trabajo, reglas inviolables)
- `vault/INDEX.md` — mapa del vault y tabla tarea → notas obligatorias
- `vault/domain/base-de-conocimiento.md` — especificación formal de R01–R13
- `USAGE.md` — manual del sistema vault-sync
