---
status: draft
type: decision
layer: H3
created: 2026-06-14
---

# Arquitectura — MedControlv2

## Patrón arquitectónico

**Clean Architecture / Layered** adaptada a Flutter:

```
Presentation (UI Widgets + ViewModels/Blocs)
     ↓
Domain (Entities, Use Cases, interfaces de repositorios)
     ↓
Data (Repositorios concretos: SQLite, AI service, OCR service)
     ↓
Infrastructure (flutter_local_notifications, sqflite, APIs externas)
```

El motor de inferencia y la base de conocimiento son parte de la capa **Domain** — son agnósticos de Flutter, testeables en puro Dart.

## Flujo principal del sistema

```
Receta (imagen / texto manual)
  → OCR service           [Data layer — extrae texto]
  → AI parser service     [Data layer — llama a API externa con internet]
  → Entidades candidatas  [Domain — Medicamento, Dosis, Frecuencia, etc.]
  → Motor de inferencia   [Domain — aplica reglas, genera horarios sugeridos]
  → Pantalla de revisión  [Presentation — INVARIANTE: confirmación humana]
  → Aprobación usuario
  → KnowledgeBaseRepository.save(hechos)   [Data → SQLite]
  → ReminderRepository.schedule(horarios)  [Infrastructure → notificaciones locales]
```

## Base de conocimiento

La BC es la capa de razonamiento central. Está compuesta por:

**Hechos** (almacenados en SQLite, extraídos de la receta):
- `medicamento`: nombre, presentación, foto (opcional)
- `dosis`: cantidad + unidad
- `frecuencia`: cada N horas / N veces por día / instrucción textual
- `via_administracion`: oral, tópico, etc.
- `instrucciones_especiales`: "con comida", "antes de dormir", "con agua abundante"
- `duracion_tratamiento`: N días / hasta agotar / indefinido
- `horarios_confirmados`: lista de DateTime aprobados por el usuario

**Reglas de inferencia** (motor en Domain layer):
- `cada 8h → sugerir 3 tomas: 08:00, 16:00, 00:00`
- `cada 12h → sugerir 2 tomas: 08:00, 20:00`
- `cada 24h → sugerir 1 toma: 08:00`
- `después de comer → asociar con comidas principales (desayuno, almuerzo, cena)`
- `antes de dormir → sugerir horario nocturno (21:00–22:00)`
- `si falta campo crítico → pedir confirmación manual (no inferir)`

**Explicabilidad**: cada horario sugerido lleva una traza de la regla que lo generó. La UI muestra esta traza al usuario en la pantalla de revisión.

## Separación de responsabilidades

- **Widgets**: solo presentación. No acceden a repositorios directamente.
- **ViewModels / Blocs**: orquestan casos de uso. No contienen lógica de negocio.
- **Use Cases**: una responsabilidad cada uno (`InterpretarRecetaUseCase`, `InferirHorariosUseCase`, `ConfirmarMedicamentoUseCase`, etc.).
- **Motor de inferencia**: clase pura Dart, sin dependencias de Flutter. Recibe hechos, devuelve sugerencias con trazas de reglas.
- **Repositorios**: interfaces en Domain, implementaciones concretas en Data.
- **AI/OCR services**: detrás de interfaces — se pueden mockear para tests o reemplazar el provider sin tocar Domain.

## Estrategia de conectividad

| Fase | Internet requerido | Fallback sin internet |
|---|---|---|
| OCR + AI parsing | Sí (preferido) | Ingreso manual de datos |
| Motor de inferencia | No | — (corre localmente) |
| Confirmación y guardado | No | — |
| Disparar recordatorios | No | — |
| Backup / sync futuro | Sí | App funciona sin él |

## Accesibilidad (restricción de diseño)

La GUI debe soportar usuarios con dificultades visuales, auditivas y cognitivas:
- Texto escalable (respetar preferencias del sistema)
- Alto contraste como opción
- Targets táctiles mínimos 48×48dp
- Flujos sin sobrecarga cognitiva: una acción principal por pantalla
- Pantalla simplificada "qué tomar ahora" para pacientes que no configuran

<!-- TODO: definir si se soporta TalkBack / VoiceOver desde el MVP -->

## Convenciones de naming (Dart/Flutter)

- Archivos: `snake_case.dart`
- Clases: `PascalCase`
- Variables/funciones: `camelCase`
- Constantes: `kConstantName` o `SCREAMING_SNAKE` según contexto Flutter
- Tablas SQLite: `plural_snake_case` (`medications`, `knowledge_facts`, `scheduled_reminders`)
- Campos DB: `snake_case`

## Gestión de errores

- Errores de OCR/IA: nunca ocultos al usuario. Se muestra qué no pudo interpretarse y se ofrece completar manualmente.
- Errores de DB: críticos — loguear + mostrar mensaje claro. No silenciar.
- Conectividad: detectar antes de llamar a servicios externos; mostrar estado y habilitar flujo manual.

## Multi-paciente

El modelo de datos se diseña desde el inicio para soportar N pacientes por dispositivo (caso: cuidador con varios pacientes). El MVP puede exponer solo 1 paciente activo en la UI, pero el schema SQLite incluye `patient_id` en todas las tablas relevantes desde el día 1. Escalar la UI para multi-paciente es una extensión, no un refactor.

## Riverpod — convenciones de uso

- **`Provider`**: dependencias estáticas (repositorios, servicios, config)
- **`FutureProvider`**: datos async de una sola carga (ej: lista de tratamientos activos)
- **`StateNotifierProvider`**: estado mutable con lógica (ej: flujo de registro de receta, estado de confirmación)
- **`StreamProvider`**: recordatorios en tiempo real si aplica
- Los providers de repositorios e infraestructura van en `lib/providers/`; los de UI en el feature correspondiente
- Nunca leer repositorios directamente desde widgets — siempre a través de un provider

## Decisiones pendientes

- [ ] TalkBack / VoiceOver: ¿MVP o fase 2?
- [ ] Estrategia de backup local: export a archivo vs sync cloud futuro
- [ ] UI multi-paciente: ¿selector de perfil activo o tabs simultáneos?

## Flujo principal — estado Fase 4
El flujo documentado arriba está implementado en `b016c00`. La pantalla de revisión es el invariante central — sin ella no se guarda nada.

### State machine: `PrescriptionFlowNotifier`

```
idle
  └─► parsing          (ParsePrescriptionUseCase corriendo)
        ├─► reviewPrescription   (FullParse → form pre-poblado con badges IA)
        │     ├─► reviewSchedule (InferenceEngine → horarios + trazas visibles)
        │     │     ├─► saving
        │     │     │     └─► saved  (ConfirmPrescriptionUseCase → DB)
        │     │     └─► back → reviewPrescription
        │     └─► (botón deshabilitado si faltan campos críticos)
        ├─► reviewPrescription   (OcrOnly → form manual pre-poblado con texto OCR)
        └─► error               (ParseFailure → mensaje + opción manual)
```

Escape hatch: `backToReviewPrescription()` permite corregir datos desde la pantalla de horarios.

### Pantalla de revisión — invariante de UI

- Badge "IA" por campo con valor extraído automáticamente
- Campos críticos faltantes: borde rojo + texto "Campo requerido"
- Botón "Calcular horarios" gateado por `ParsedPrescription.hasCriticalFields`
- El usuario puede editar cualquier campo antes de continuar

### Pantalla de horarios — explicabilidad

- Cada `SuggestedTime` muestra `InferenceTrace.explanation` en lenguaje natural
- Cada horario es ajustable con TimePicker nativo
- `ConflictAlert` (R10) visible prominentemente antes de confirmar
- Política de posposición (R08/R09) indicada al pie

### Nota sobre Phase 5

`confirmAndSave()` persiste Medicamento + Tratamiento pero **no** crea filas en `RemindersTable`. La programación de notificaciones locales es Phase 5.

Code paths:
```
app/lib/presentation/providers/prescription_flow_provider.dart  — PrescriptionFlowNotifier
app/lib/domain/use_cases/confirm_prescription_use_case.dart     — persistencia H4
app/lib/presentation/screens/prescription/                      — 4 screens H5
app/lib/presentation/providers/database_providers.dart          — Riverpod DB wiring
```

## Flujo principal — estado Fase 5
La nota anterior ('Fase 4') decía que `confirmAndSave()` no creaba filas en `RemindersTable`. En `4dab5b2` esto quedó resuelto.

### Extensión del flujo post-confirmación

```
confirmAndSave(startDate, confirmedTimes)
  └─► ConfirmPrescriptionUseCase.execute()   → (treatmentId, patientId)
  └─► ScheduleRemindersUseCase.execute()
         ├─► RemindersTable.insertAll()        → filas en SQLite
         └─► NotificationService.scheduleDaily() × N   → notificaciones locales
  └─► state = PrescriptionFlowSaved(treatmentId)
```

### TodayRemindersScreen — arquitectura

- `todayRemindersProvider: FutureProvider<List<ReminderViewModel>>` — se invalida tras cada acción
- `ReminderViewModel` = `RemindersTableData` + `medicationName` + `isCritical`
- Action sheet → `RecordIntakeUseCase` o `SnoozeReminderUseCase` → `ref.invalidate(todayRemindersProvider)`

### NotificationService

Singleton en `infrastructure/notifications/`. Inicializado antes de `runApp()` en `main.dart`.
No es un Riverpod `FutureProvider` para evitar complejidad de async en la cadena de dependencias — la inicialización es síncrona a efectos prácticos (< 50ms).

Code paths:
```
app/lib/infrastructure/notifications/notification_service.dart
app/lib/presentation/providers/reminder_providers.dart
app/lib/main.dart  — NotificationService.instance.initialize()
```

## Flujo principal — estado Fase 6
### Tema reactivo

`app.dart` ya no tiene `ThemeData` estático. Lee `appThemeProvider` que deriva de `accessibilityConfigProvider → activePatientProvider`. Cuando el usuario guarda configuración de accesibilidad, el tema cambia sin rebuild del árbol completo.

### Routing por tipo de perfil

```dart
// app.dart
home: isAssisted ? const AssistedModeScreen() : const TodayRemindersScreen()
```

El switch ocurre reactivamente al cambiar `profileType` en la DB. No hay Navigator push/pop — es un swap de `home`.

### Eliminación de _HomeScreen

`_HomeScreen` era un shell Scaffold que envolvía `TodayRemindersScreen` para darle el FAB. En Fase 6 se eliminó: el FAB y el botón de perfil viven en `TodayRemindersScreen.appBar.actions` y `floatingActionButton`.

### Accesibilidad → ThemeData

| Config | Efecto en ThemeData |
|---|---|
| `fontSize: large/veryLarge` | `textTheme.apply(fontSizeFactor: 1.3/1.5)` |
| `highContrast: true` | `ColorScheme.light` con primary=black, surface=white |
| `largeTargets: true` | `materialTapTargetSize: padded` |
| `reduceAnimations` | Sin efecto en ThemeData MVP — Phase 7 puede desactivar animaciones con `AnimationController.duration = 0` |

## Flujo principal — estado Fase 7
### _MainShell con NavigationBar

En `c9913dd`, `TodayRemindersScreen` dejó de ser el `home` directo en modo autónomo. El nuevo shell es `_MainShell` (`ConsumerStatefulWidget` en `app.dart`).

```dart
// app.dart — Fase 7
home: isAssisted ? const AssistedModeScreen() : const _MainShell()
```

`_MainShell` provee:
- `Scaffold` con `NavigationBar` de 3 destinos
- `IndexedStack` con `TodayRemindersContent` / `HistorialContent` / `KnowledgeBaseContent`
- FAB ("Registrar receta" → `PrescriptionFlowScreen`) visible solo en tab 0
- AppBar con acciones (refresh + perfil) visibles solo en tab 0

`TodayRemindersScreen` se renombró a `TodayRemindersContent` y ya no incluye Scaffold. Esto evita anidar Scaffolds y centraliza la navegación principal.

### Corrección nota Fase 6

La sección "Routing por tipo de perfil — Fase 6" decía `home: ... const TodayRemindersScreen()`. El estado correcto desde Fase 7 es `const _MainShell()`. El comportamiento reactivo de routing por `profileType` se mantiene igual.

### Providers de historial

```
treatmentHistoryProvider  FutureProvider<List<TreatmentHistoryViewModel>>
activeFactsProvider       FutureProvider<List<ActiveTreatmentFact>>   — para KnowledgeBaseContent
remindersByTreatmentProvider  FutureProvider.family<List<RemindersTableData>, String>
intakesByTreatmentProvider    FutureProvider.family<List<IntakesTableData>, String>
```

## Flujo principal — estado Fase 8
### Pull-to-refresh

`TodayRemindersContent` y `HistorialContent` envuelven su contenido en `RefreshIndicator`. El patrón usado:

```dart
onRefresh: () {
  ref.invalidate(provider);
  return ref.read(provider.future); // RefreshIndicator espera a que resuelva
}
```

Para estados vacíos (no-scrollable), se usa `LayoutBuilder` → `ListView(AlwaysScrollableScrollPhysics)` → `SizedBox(height: constraints.maxHeight)` para que el pull siga funcionando.

### reduceAnimations en ThemeData

```dart
pageTransitionsTheme: config.reduceAnimations
    ? PageTransitionsTheme(builders: {
        android: _InstantPageTransitionsBuilder(),
        ios: _InstantPageTransitionsBuilder(),
      })
    : const PageTransitionsTheme()
```

Combinado con `themeAnimationDuration: reduceAnimations ? Duration.zero : 200ms` en `MaterialApp`, cubre tanto transiciones de ruta como animaciones de tema.

### Estado de primer uso

El routing del `_MainShell` no cambia. Dentro de `TodayRemindersContent`, si `activePatientProvider.hasValue && activePatientProvider.value == null` → se muestra el estado de bienvenida. El paciente se crea en `ConfirmPrescriptionUseCase` al confirmar la primera receta — a partir de ese momento el estado de bienvenida nunca vuelve a aparecer.

## TalkBack / VoiceOver — estado Fase 8
La decisión pendiente '¿MVP o fase 2?' está parcialmente resuelta:

- **Implementado en MVP**: `Semantics(label, value)` en todos los `LinearProgressIndicator` de adherencia (`HistorialContent._TreatmentCard` y `TreatmentDetailScreen._AdherenceCard`). Anunciado a TalkBack / VoiceOver con etiqueta legible (*'Adherencia al tratamiento — X por ciento'*).
- **Post-MVP**: validación formal con lector de pantalla real en el resto de la app; navegación semántica completa entre secciones.
