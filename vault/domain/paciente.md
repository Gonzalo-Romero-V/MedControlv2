---
status: draft
type: domain
layer: H2
created: 2026-06-14
related: [[medicamento]], [[recordatorio]], [[base-de-conocimiento]]
code_path: app/lib/domain/entities/patient_profile.dart
---

# Paciente & Cuidador

## Personas del sistema

### Paciente autónomo
Gestiona su propia medicación. Puede tener limitaciones (visual, auditiva, cognitiva) pero mantiene capacidad de interacción tecnológica. Usa el flujo completo: registra medicamentos, revisa interpretaciones de IA, confirma horarios, marca tomas.

### Paciente asistido
No puede o no quiere configurar el sistema. El cuidador configura todo. El paciente accede únicamente a la vista simplificada "qué tomar ahora" — una pantalla de consumo sin opciones de configuración.

### Cuidador
Configura medicamentos para uno o más pacientes. Revisa adherencia. Opera con mayor capacidad técnica. En el MVP comparte dispositivo con el paciente; en fases futuras puede tener su propio panel.

---

## Entidad: Paciente

| Campo | Tipo | Notas |
|---|---|---|
| `id` | UUID | PK |
| `nombre` | string | |
| `fecha_nacimiento` | date? | Opcional — útil para contexto clínico futuro |
| `foto_perfil` | path? | Opcional |
| `tipo_perfil` | enum | `autonomo`, `asistido` |
| `es_activo` | boolean | Perfil actualmente seleccionado en el dispositivo |
| `configuracion_accesibilidad` | JSON | Ver estructura abajo |
| `hora_desayuno` | time | Default: 07:00 — usada por el motor de inferencia para "después de comer" |
| `hora_almuerzo` | time | Default: 13:00 |
| `hora_cena` | time | Default: 19:00 |
| `hora_dormir` | time | Default: 21:00 — usada para "antes de dormir" |
| `created_at` | timestamp | |

### Configuración de accesibilidad

```json
{
  "tamano_fuente": "normal | grande | muy_grande",
  "alto_contraste": false,
  "targets_grandes": true,
  "reducir_animaciones": false
}
```

Las horas de comida y sueño son entradas del motor de inferencia — no solo preferencias de UI. Si el usuario las personaliza, los horarios sugeridos se recalculan automáticamente.

---

## Modelo multi-paciente

El modelo de datos soporta N pacientes por dispositivo desde el inicio. El MVP expone un único paciente activo en la UI, seleccionable mediante un selector de perfil. La migración a "multi-paciente visible simultáneamente" es extensión de UI, no refactor de datos.

```
Dispositivo
  └── Paciente A (activo)  ← selector de perfil
  └── Paciente B
  └── Paciente C
```

Todas las entidades (`tratamiento`, `recordatorio`, `toma`) tienen `patient_id` — ninguna consulta omite ese filtro.

---

## Vista según tipo de perfil

### Paciente autónomo — flujo completo
- Registrar medicamentos (OCR + revisión + confirmación)
- Ver recordatorios del día
- Marcar tomas
- Ver historial

### Paciente asistido — solo consumo
Una sola pantalla: medicamentos del día con hora, nombre, dosis y foto de la caja. Dos botones únicamente: `Tomé` y `No pude`. Sin navegación adicional. Sin acceso a configuración.

El cuidador activa este modo desde la configuración del perfil. Puede desactivarlo con PIN o sin restricción según lo decida al configurarlo.

---

## Accesibilidad — restricciones de diseño

Aplican a toda la app, no solo a la vista de paciente asistido:

- **Texto**: respetar el tamaño de fuente del sistema operativo como base; la app ofrece escala propia adicional
- **Contraste**: modo alto contraste disponible (texto negro sobre blanco o inverso puro)
- **Targets táctiles**: mínimo 48×48dp en todos los elementos interactivos
- **Flujo cognitivo**: una acción principal por pantalla; no más de 3 opciones visibles simultáneamente en pantallas críticas
- **Feedback**: toda acción tiene confirmación visual inmediata (no solo haptic)
- **Lenguaje**: español simple, sin términos técnicos farmacológicos en la UI del paciente

TalkBack / VoiceOver: contemplado en el diseño (semántica de widgets Flutter) pero validación formal queda para fase 2.

---

## Decisiones pendientes

- [ ] PIN para alternar entre modo asistido y modo configuración — ¿MVP o fase 2?
- [ ] ¿El cuidador tiene su propio perfil en el dispositivo o solo accede por configuración?
- [ ] Notificaciones: si hay múltiples pacientes, ¿cómo se distinguen en la notificación?

## Implementación (Fase 2)
Subconjunto del perfil relevante para el motor de inferencia implementado en `app/lib/domain/entities/patient_profile.dart`:

```dart
class PatientProfile {
  final MedTime breakfastTime;  // hora_desayuno (default 07:00)
  final MedTime lunchTime;      // hora_almuerzo (default 13:00)
  final MedTime dinnerTime;     // hora_cena     (default 19:00)
  final MedTime sleepTime;      // hora_dormir   (default 21:00)
  static const PatientProfile defaults = ...;
  List<MedTime> get mealTimes => [breakfastTime, lunchTime, dinnerTime];
}
```

La entidad completa (accesibilidad, `tipo_perfil`, etc.) está en `app/lib/infrastructure/database/tables/patients_table.dart`. La conversión entre tabla y `PatientProfile` queda en el use case de la Fase 5.

## Implementación — Fase 6
Implementación completa del perfil de paciente en `782c2ea`.

### Entidades y use cases (H4)

| Artefacto | Descripción |
|---|---|
| `AccessibilityConfig` | Value object — deserializa `accessibility_config` JSON; calcula `fontSizeFactor` (`1.1`/`1.3`/`1.5`) |
| `UpdatePatientUseCase` | Persiste nombre, `profileType`, horarios de comida/sueño y configuración de accesibilidad |
| `PatientDao.watchActivePatient()` | Stream Drift — emite cada vez que el paciente activo cambia en SQLite |

### Providers reactivos (H5)

```
activePatientProvider  (StreamProvider)  — stream del paciente activo
patientProfileProvider (Provider)        — MedTime derivados; alimenta el motor de inferencia
accessibilityConfigProvider (Provider)   — AccessibilityConfig actual
isAssistedModeProvider  (Provider<bool>) — true si profileType == 'assisted'
appThemeProvider        (Provider<ThemeData>) — ThemeData reactivo (escala fuente, alto contraste)
```

`appThemeProvider` reemplaza el `ThemeData` estático de `app.dart` — el tema se actualiza en tiempo real al guardar configuración.

### Vistas (H5)

| Pantalla | Descripción |
|---|---|
| `ProfileSettingsScreen` | Nombre, tipo de perfil (RadioGroup), 4 time pickers para reglas R02–R05, sección accesibilidad completa |
| `AssistedModeScreen` | Solo medicamentos pendientes + completados, botones "Tomé" / "No pude" inline — sin FAB ni navegación |

`app.dart` enruta a `AssistedModeScreen` cuando `isAssistedModeProvider == true`; al cambiar a 'autónomo' se vuelve a `TodayRemindersScreen` automáticamente sin restart.

### Nota sobre reglas de inferencia

`PrescriptionFlowNotifier` ahora recibe `patientProfileProvider` en lugar de `PatientProfile.defaults`. Las reglas R02–R05 (horarios de comida/sueño) usan los tiempos configurados por el paciente.

### Code paths

```
app/lib/domain/entities/accessibility_config.dart
app/lib/domain/use_cases/update_patient_use_case.dart
app/lib/presentation/providers/patient_providers.dart
app/lib/presentation/screens/settings/profile_settings_screen.dart
app/lib/presentation/features/assisted_mode/assisted_mode_screen.dart
```

## Implementación — Fase 8
Polish de accesibilidad y UX en `62e8577`.

### reduceAnimations — soporte real

`appThemeProvider` ahora incluye `PageTransitionsTheme` condicional:
- `reduceAnimations = true` → `_InstantPageTransitionsBuilder` en Android e iOS: transiciones de página instantáneas (sin animación)
- `MaterialApp.themeAnimationDuration = Duration.zero` cuando activo

Las cuatro opciones de accesibilidad (`fontSize`, `highContrast`, `largeTargets`, `reduceAnimations`) están completamente implementadas y reactivas.

### Estado de primer lanzamiento

`TodayRemindersContent` observa `activePatientProvider`. Si el stream resuelve a `null` (no hay fila de paciente en SQLite — primer uso), muestra `_FirstLaunchState` con:
- Bienvenida al sistema
- Botón "Registrar primera receta" → navega directamente a `PrescriptionFlowScreen`

Esta diferenciación evita mostrar el estado vacío genérico antes de que el usuario haya configurado algo.

### Semántica de accesibilidad

`Semantics(label, value)` agregado a todos los `LinearProgressIndicator` de adherencia:
- `HistorialContent._TreatmentCard`
- `TreatmentDetailScreen._AdherenceCard`

Etiqueta: *"Adherencia al tratamiento"* — valor: *"X por ciento"*. Compatible con TalkBack / VoiceOver.

### Code paths

```
app/lib/presentation/providers/patient_providers.dart  — _InstantPageTransitionsBuilder + reduceAnimationsProvider
app/lib/presentation/app.dart                          — themeAnimationDuration reactivo
app/lib/presentation/features/today_reminders/today_reminders_screen.dart  — _FirstLaunchState + RefreshIndicator
app/lib/presentation/features/historial/historial_screen.dart              — RefreshIndicator + Semantics
app/lib/presentation/features/historial/treatment_detail_screen.dart       — Semantics adherencia
```

## Corrección nota Fase 6 — routing real
La sección 'Implementación Fase 6' menciona: "al cambiar a 'autónomo' se vuelve a `TodayRemindersScreen` automáticamente". Incorrecto desde Fase 7: `TodayRemindersScreen` fue renombrado a `TodayRemindersContent` y ya no es el `home`. El home en modo autónomo es `_MainShell` (ver `architecture.md` Fase 7 para la corrección canónica). El routing reactivo por `profileType` sigue igual — solo cambia el widget raíz.
