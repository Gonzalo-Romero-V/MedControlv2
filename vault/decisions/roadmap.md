---
status: draft
type: decision
layer: H3
created: 2026-06-14
related: [[vision]], [[medicamento]], [[recordatorio]], [[paciente]], [[base-de-conocimiento]]
---

# Roadmap de desarrollo — MedControlv2

## Principio de construcción

Construir de adentro hacia afuera: primero la capa de datos y dominio (invisible),
luego la lógica de negocio (testeable sin UI), luego la UI encima.
Cada fase termina con algo ejecutable o testeable — nunca código muerto esperando a la siguiente fase.

---

## Fase 0 — Fundación ✅ (completada)

**Qué se construyó:**
- Vault con todas las notas de dominio y decisiones
- Flutter scaffold con Clean Architecture
- pubspec.yaml con todas las dependencias
- minSdk 26, env modular para AI provider

**Entregable:** repo compilable con `flutter run` (counter app de Flutter)

---

## Fase 1 — Persistencia & dominio (en curso)

**Qué se construye:**
- Schema SQLite completo con Drift (`patient_id` en todas las tablas)
- Entidades Dart puras (Patient, Medication, Treatment, Reminder, Intake)
- DAOs por entidad (queries tipadas)
- Repository interfaces en domain/
- Implementaciones concretas en data/repositories/
- Providers Riverpod de repositorios

**Entregable:** tests unitarios que crean un paciente, un tratamiento y consultan
la DB. Sin UI. Confirma que el modelo de datos es correcto antes de construir
encima.

**Archivos clave:**
```
lib/infrastructure/database/app_database.dart  ← schema Drift
lib/infrastructure/database/daos/
lib/domain/entities/
lib/domain/repositories/   ← interfaces
lib/data/repositories/     ← implementaciones SQLite
lib/presentation/providers/database_providers.dart
```

---

## Fase 2 — Motor de inferencia (Base de Conocimiento)

**Qué se construye:**
- `InferenceEngine` — clase Dart pura, 0 dependencias Flutter
- Reglas R01–R13 implementadas como funciones con ID canónico
- `InferenceResult` con lista de `SuggestedTime` + `InferenceTrace`
- Generador de texto de explicación en español
- Detección de conflicto por medicamento duplicado (R10)
- Cálculo de ventana de posposición (R08 dinámica, R09 fija crítico)

**Entregable:** test suite del motor de inferencia. Dado un set de hechos,
produce horarios con trazas correctas. Defendible académicamente como
"sistema de producción con forward chaining".

**Archivos clave:**
```
lib/domain/use_cases/infer_schedule_use_case.dart
lib/domain/services/inference_engine.dart   ← motor puro
lib/domain/entities/inference_result.dart
test/domain/inference_engine_test.dart
```

---

## Fase 3 — Pipeline IA / OCR (Ruta 1 — Online) ⭐ CORE

**Qué se construye:**

### 3a — Interfaces y plumbing
- `AiParserService` interface (domain)
- `OcrService` interface (domain)
- `ParsedPrescription` entity — output tipado del AI parser
- Connectivity checker (detecta si hay internet)

### 3b — Implementación Cloud (Ruta 1 principal)
- `CloudVisionOcrService` — llama a Google Cloud Vision `DOCUMENT_TEXT_DETECTION`
- `GeminiParserService` — envía texto OCR a Gemini con prompt estructurado
  - Prompt diseñado para extraer: nombre, dosis, frecuencia, vía, instrucciones, duración
  - Respuesta en JSON con schema validado
  - Manejo de campos faltantes → `null` en lugar de inventar
- `OpenAiParserService` — misma interfaz, provider alternativo (parámetro `AI_PROVIDER`)
- Provider Riverpod que inyecta la implementación según `.env`

### 3c — Implementación local (Ruta 2 — fallback offline)
- `MlKitOcrService` — on-device, sin internet
- Sin AI parser local — el texto OCR prellenará el formulario manual

### 3d — Orquestador
- `ParsePrescriptionUseCase` — decide qué ruta tomar según conectividad,
  llama OCR → AI parser, devuelve `ParsedPrescription` o `OcrTextOnly`

**Entregable:** dado una imagen de receta con internet activo → objeto
`ParsedPrescription` con los campos extraídos. Testeable con imagen real.

**Archivos clave:**
```
lib/domain/services/ai_parser_service.dart      ← interface
lib/domain/services/ocr_service.dart            ← interface
lib/domain/entities/parsed_prescription.dart
lib/data/services/cloud_vision_ocr_service.dart
lib/data/services/gemini_parser_service.dart
lib/data/services/openai_parser_service.dart
lib/data/services/mlkit_ocr_service.dart
lib/domain/use_cases/parse_prescription_use_case.dart
lib/presentation/providers/ai_providers.dart
```

---

## Fase 4 — Flujo de registro (UI)

**Qué se construye:**

### 4a — Captura de imagen
- Pantalla de captura: cámara o galería via `image_picker`
- Preview de la imagen capturada
- Botón "procesar receta" + botón "ingresar manualmente"
- Indicador de conectividad visible

### 4b — Pantalla de revisión (INVARIANTE CRÍTICA)
La pantalla más importante del sistema. El usuario SIEMPRE llega aquí antes
de crear recordatorios.

Muestra para cada campo extraído:
- Valor detectado (editable inline)
- Indicador de confianza (extraído por IA / inferido / pendiente)
- Para los horarios sugeridos: la explicación en lenguaje natural de la regla

Estados de los campos:
- ✅ Extraído por IA con confianza
- ⚠️ Inferido (no explícito en la receta) — resaltado para revisión
- ❌ No detectado — campo obligatorio vacío, no se puede confirmar

Botón "Confirmar y crear recordatorios" — solo habilitado cuando todos los
campos críticos están completos.

### 4c — Formulario manual
Misma pantalla de revisión pero sin datos prellenados por IA (o prellenada
con texto OCR crudo si se usó ML Kit). Flujo para registro sin receta o
sin internet.

### 4d — Confirmación y guardado
- `ConfirmTreatmentUseCase`: guarda hechos en SQLite, programa recordatorios
- Detección de duplicado → alerta R10 antes de guardar
- Pantalla de éxito con resumen

**Entregable:** flujo completo end-to-end: foto → revisión → confirmar →
recordatorios programados en el dispositivo.

---

## Fase 5 — Recordatorios y tomas

**Qué se construye:**

### 5a — Infraestructura de notificaciones
- Setup `flutter_local_notifications` con canales Android
  - Canal estándar: recordatorios normales
  - Canal crítico: medicamentos con `is_critical = true` (máxima prioridad)
- `ReminderScheduler` service — programa/cancela notificaciones nativas
- Inicialización en `main.dart` con timezone setup

### 5b — Pantalla "Hoy" (home principal)
- Lista de recordatorios del día agrupados: próximos / activos / completados / omitidos
- Cada ítem: nombre, dosis, hora, foto de caja, traza de regla (colapsable)
- Acciones: Tomé / Posponer / No pude tomarlo

### 5c — Lógica de posposición
- `SnoozeReminderUseCase`: calcula siguiente alarma según ventana dinámica
- Contador de posposiciones (máx 3 dentro de la ventana)
- Ventana expirada → notificación final "mejor esperar la siguiente dosis"
- Medicamento crítico → sin posposición, ventana 30min, alerta especial

### 5d — Registro de toma
- `RecordIntakeUseCase`: guarda resultado en `intakes`
- Resultado: `taken` / `taken_late` / `skipped` / `snooze_expired`
- Cierre automático de tratamientos por duración o cantidad

**Entregable:** flujo completo: notificación llega → usuario abre app →
marca como tomada → historial actualizado.

---

## Fase 6 — Perfiles de paciente

**Qué se construye:**
- Pantalla de gestión de pacientes (crear, editar, seleccionar)
- Selector de perfil activo
- Configuración de accesibilidad por perfil (fuente, contraste)
- Configuración de horas de comida/sueño (input del motor de inferencia)
- Modo asistido: vista simplificada "qué tomar ahora" con solo 2 botones

**Entregable:** cuidador puede tener 2+ pacientes, alternar entre ellos, y
cada paciente ve su propia pantalla adaptada.

---

## Fase 7 — Historial y base de conocimiento visible

**Qué se construye:**

### 7a — Historial de tratamientos
- Lista de tratamientos activos / pasados por paciente
- Detalle de tratamiento: campos, horarios, imagen de receta
- Adherencia calculada con visualización simple (% + timeline)
- Gestión de estado: suspender, abandonar, completar manualmente

### 7b — Vista de base de conocimiento (componente académico)
- Pantalla "Hechos activos": lista de hechos almacenados del tratamiento activo
- Pantalla "Reglas del sistema": catálogo R01–R13 con descripción legible
- Pantalla "Por qué este horario": para cada recordatorio, despliega la
  cadena de reglas que lo generó (forward chaining trazado)

Esta pantalla es el argumento académico principal: el sistema no solo
"agenda alarmas", sino que razona sobre hechos con reglas explícitas
y puede mostrar su razonamiento.

**Entregable:** demo completo para defensa: mostrar que dado una receta,
el sistema extrae hechos, aplica reglas, infiere horarios, y puede explicar
cada decisión en pantalla.

---

## Resumen de rutas

```
RUTA 1 — Online (principal):
  Imagen → Cloud Vision API → texto OCR
         → Gemini API → ParsedPrescription (JSON)
         → InferenceEngine → horarios con trazas
         → Pantalla revisión → confirmación
         → SQLite + notificaciones locales

RUTA 2 — Offline (fallback):
  Imagen → ML Kit on-device → texto OCR crudo
         → Formulario manual prellenado
         → InferenceEngine → horarios con trazas
         → Pantalla revisión → confirmación
         → SQLite + notificaciones locales

  Sin imagen:
         → Formulario manual vacío
         → [mismo flujo desde formulario]
```

## Dependencias entre fases

```
Fase 0 (✅) → Fase 1 → Fase 2 → Fase 4b (revisión)
                              ↗
              Fase 3 (pipeline IA)
                              ↘
                         Fase 4 (UI registro)
                              ↓
                         Fase 5 (recordatorios)
                              ↓
              Fase 6 (perfiles) ← puede ir en paralelo con Fase 5
                              ↓
                         Fase 7 (historial + BC visible)
```

Fase 2 (motor de inferencia) puede desarrollarse en paralelo con Fase 3
(pipeline IA) porque son puro dominio sin UI ni DB.

---

## Estado actual

| Fase | Estado |
|---|---|
| 0 — Fundación | ✅ Completa |
| 1 — Persistencia & dominio | 🔄 En curso (schema SQLite next) |
| 2 — Motor de inferencia | ⬜ Pendiente |
| 3 — Pipeline IA / OCR | ⬜ Pendiente |
| 4 — Flujo de registro UI | ⬜ Pendiente |
| 5 — Recordatorios y tomas | ⬜ Pendiente |
| 6 — Perfiles de paciente | ⬜ Pendiente |
| 7 — Historial y BC visible | ⬜ Pendiente |
