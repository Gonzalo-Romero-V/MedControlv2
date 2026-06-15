---
status: draft
type: domain
layer: H2
created: 2026-06-14
related: [[medicamento]], [[base-de-conocimiento]]
code_path: app/lib/domain/entities/inference_result.dart
---

# Recordatorio & Toma

## Separación conceptual

- **Recordatorio**: instancia programada de una dosis — cuándo debe tomarse según el tratamiento. Generado por el motor de inferencia.
- **Toma**: el registro histórico del resultado de ese recordatorio — qué hizo el usuario y cuándo.

Un recordatorio genera exactamente una toma (aunque sea omitida). La toma es inmutable una vez registrada.

---

## Entidad: Recordatorio

| Campo | Tipo | Notas |
|---|---|---|
| `id` | UUID | PK |
| `tratamiento_id` | FK | |
| `patient_id` | FK | |
| `hora_programada` | datetime | Calculada por el motor de inferencia |
| `hora_limite` | datetime | `hora_programada + ventana_posposicion` — calculada al crear |
| `estado` | enum | Ver estados |
| `regla_origen` | string | Traza de la regla de inferencia que generó este horario. Ej: `"cada_12h → 2 tomas → 08:00 y 20:00"` |
| `created_at` | timestamp | |

---

## Entidad: Toma

| Campo | Tipo | Notas |
|---|---|---|
| `id` | UUID | PK |
| `recordatorio_id` | FK | |
| `resultado` | enum | `tomada`, `tomada_tarde`, `omitida`, `pospuesta_expirada` |
| `hora_real` | datetime? | Hora efectiva en que el usuario la tomó (si aplica) |
| `minutos_tarde` | integer? | Calculado si `tomada_tarde` |
| `created_at` | timestamp | Momento en que se registró la acción |

---

## Estados del recordatorio

```
pendiente
  → [hora_programada llega] → disparado
      → usuario toma          → tomado     → Toma: tomada
      → usuario pospone       → pospuesto
          → [+20min] → disparado nuevamente
          → (máx según ventana calculada)
          → [hora_limite alcanzado] → expirado → Toma: omitida / tomada_tarde
      → usuario omite explícitamente → cerrado → Toma: omitida
```

| Estado | Descripción |
|---|---|
| `pendiente` | Programado, aún no llega la hora |
| `disparado` | Alarma activa, esperando acción del usuario |
| `pospuesto` | Usuario pospuso, temporizador activo para re-disparar |
| `tomado` | Confirmado tomado antes de `hora_limite` |
| `expirado` | `hora_limite` alcanzado sin acción — se cierra automáticamente |
| `cerrado` | Usuario marcó explícitamente "omitir" |

---

## Ventana de posposición (regla médica aplicada)

La ventana máxima segura sigue la **regla de la mitad del intervalo**: tomar una dosis tardía es seguro mientras quede más de la mitad del intervalo hasta la siguiente dosis.

### Medicamentos estándar (es_critico = false)

`ventana = intervalo_horas / 2`

| Frecuencia | Intervalo | Ventana máxima |
|---|---|---|
| Cada 4h | 4h | 2h |
| Cada 6h | 6h | 3h |
| Cada 8h | 8h | 4h |
| Cada 12h | 12h | 6h |
| Cada 24h | 24h | 12h |

Dentro de esa ventana: 3 posposiciones distribuidas uniformemente (`ventana / 3` cada una).

Ejemplo — cada 12h, ventana 6h:
```
08:00 → alarma inicial
10:00 → snooze 1 (+2h)
12:00 → snooze 2 (+2h)
14:00 → snooze 3 (+2h) — último aviso:
        "Han pasado 6 horas. Para este medicamento es más
         seguro esperar la siguiente dosis que tomarlo ahora."
→ Toma registrada como: omitida
```

### Medicamentos críticos (es_critico = true)

Ventana fija de **30 minutos**, sin posposición — solo "tomé" o "no tomé".

Aplica a: anticonvulsivos, anticoagulantes (warfarina), insulina, inmunosupresores, medicamentos con ventana terapéutica estrecha.

Al dispararse:
```
Hora programada → alarma con aviso especial:
  "Este medicamento requiere tomarse a la hora exacta.
   Tomarlo muy tarde o saltarlo puede tener consecuencias
   graves. Si no podés tomarlo ahora, consultá a tu médico."

→ Solo 2 opciones: Tomé / No puedo tomarlo
→ Sin posposición
→ Ventana: 30 minutos
→ Si expira: Toma: omitida + alerta de seguimiento
```

---

## Resultados posibles de una toma

| Resultado | Cuándo | Descripción |
|---|---|---|
| `tomada` | Antes de `hora_programada + ventana/3` | Tomada a tiempo o casi |
| `tomada_tarde` | Entre `hora_programada + ventana/3` y `hora_limite` | Tomada dentro de la ventana pero tarde |
| `omitida` | `hora_limite` expiró sin acción **o** usuario eligió "no puedo tomarlo" | No se tomó en la ventana segura |
| `pospuesta_expirada` | Ciclo de posposiciones agotado sin confirmación | Equivalente a omitida — el sistema la cierra |

---

## Pantalla "qué tomar hoy"

Vista principal del paciente. Muestra los recordatorios del día agrupados por estado:

- **Próximos**: pendientes ordenados por hora
- **Activos**: disparados esperando acción (los más urgentes)
- **Completados**: tomados o cerrados hoy
- **Omitidos**: los que expiraron sin tomarse

Cada ítem muestra: nombre del medicamento, dosis, hora programada, foto de la caja (si fue registrada), y la explicación de por qué fue asignado ese horario (traza de regla).

---

## Adherencia

Calculada por tratamiento:
- `adherencia = tomas_tomadas / total_esperadas * 100`
- `tomas_tomadas` incluye `tomada` y `tomada_tarde`
- Visible en el historial del tratamiento
- No mostrada de forma prominente al paciente (puede generar ansiedad) — sí visible para el cuidador

## Implementación — Fase 5
El ciclo de vida completo de recordatorio + toma está implementado en `4dab5b2`.

### Use cases (H4)

| Use Case | Responsabilidad |
|---|---|
| `ScheduleRemindersUseCase` | Crea filas en `RemindersTable` + programa notificaciones diarias repetidas |
| `GetTodayRemindersUseCase` | Lee recordatorios del día, enriquece con nombre de medicamento e `isCritical` → `ReminderViewModel` |
| `RecordIntakeUseCase` | Crea fila en `IntakesTable`, actualiza estado del recordatorio, cancela notificación |
| `SnoozeReminderUseCase` | Pospone 30 min (fijo MVP), máx 3 postposiciones; bloqueado para medicamentos críticos |

### NotificationService (Infrastructure)

Singleton `NotificationService.instance` inicializado en `main()`. Dos métodos:
- `scheduleDaily()` — notificación que se repite diariamente a la misma hora (`matchDateTimeComponents: time`)
- `scheduleOnce()` — disparo único para snooze

Timezone hardcodeada a `America/Argentina/Buenos_Aires` (MVP); Phase 6 detecta timezone del dispositivo.

### Diferencias con el spec del vault

- Ventana de posposición MVP: **30 min fija** para todos los medicamentos (no `intervalo/2`). La variante dinámica requiere calcular el intervalo del tratamiento; pendiente para Phase 6.
- Snooze máx: 3 para no-críticos; 0 para críticos (alineado con el spec).
- `minutesLate > 15` → resultado `taken_late`; ≤ 15 min → `taken` (umbral pragmático MVP).

### Code paths

```
app/lib/domain/use_cases/schedule_reminders_use_case.dart
app/lib/domain/use_cases/get_today_reminders_use_case.dart
app/lib/domain/use_cases/record_intake_use_case.dart
app/lib/domain/use_cases/snooze_reminder_use_case.dart
app/lib/infrastructure/notifications/notification_service.dart
app/lib/presentation/features/today_reminders/today_reminders_screen.dart
app/lib/presentation/providers/reminder_providers.dart
```

## Timezone detection — resuelta (14ad78d)
La sección 'Implementación Fase 5' decía: "Phase 6 detecta timezone del dispositivo". La detección real se implementó en `14ad78d` (posterior a Fase 6): `flutter_timezone ^5.1.0` → `FlutterTimezone.getLocalTimezone().identifier` → `tz.setLocalLocation()`. Fallback a `America/Argentina/Buenos_Aires` si el platform channel falla.

## Modos de alerta — Fase 9 (352d507)
### Arquitectura dual: ACTIVO vs DISCRETO

El `NotificationMode` del perfil del paciente controla cómo se entrega cada recordatorio:

| Modo | Canal Android | Comportamiento |
|------|--------------|----------------|
| `active` | `med_control_alert` | `fullScreenIntent=true`, sin botones en notificación. Lanza `AlarmScreen`. |
| `subtle` | `med_control_subtle` | Notificación estándar con botones de acción. Handler en background. |

### Modo ACTIVO — AlarmScreen

`AlarmScreen` es una pantalla Flutter a pantalla completa que emerge sobre la pantalla de bloqueo y, en Android 14+ con permiso `USE_FULL_SCREEN_INTENT` concedido, sobre cualquier app en primer plano.

Acciones disponibles:
- **Tomé el medicamento** → `RecordIntakeUseCase(taken: true)` → cierra pantalla
- **Posponer 30 min** (solo no-críticos) → `SnoozeReminderUseCase` → nueva alarma activa
- **No puedo tomarlo** (solo críticos) → `RecordIntakeUseCase(taken: false)` → cierra pantalla
- **Cerrar sin acción** (escape hatch) → diálogo de confirmación antes de cerrar

`PopScope(canPop: false)` impide cierre accidental por back button.

### Modo DISCRETO — background handler

Notificación estándar con botones de acción. El handler `_onNotificationBackgroundAction` (anotado `@pragma('vm:entry-point')`) corre en isolate separado cuando la app está muerta.

Botones: **Tomé ✓** / **Posponer 30 min** / **No puedo tomarlo** (críticos).
Los dos primeros tienen `showsUserInterface: false` → no abren la app.

### pendingAlarmNotifier — bridge callbacks → widget tree

`ValueNotifier<NotificationResponse?>` global en `pending_alarm_notifier.dart`.

Flujos que lo populan:
1. **App muerta + alarma ACTIVO**: `main()` llama `getNotificationLaunchDetails()` → setea el notifier antes de `runApp()`.
2. **App viva + alarma ACTIVO**: `_onNotificationForegroundAction()` lo setea al recibir el callback.

`_MainShellState` escucha el notifier en `initState` y navega a `AlarmScreen` en el primer frame disponible (`addPostFrameCallback`).

### Payload extendido (4 campos)

Formato: `reminderId||medicationName||isCritical||isAlertMode`

`isAlertMode` se propaga a través de `SnoozeReminderUseCase.execute(isAlertMode:...)` para que los recordatorios pospuestos hereden el modo del original.

### USE_FULL_SCREEN_INTENT — comportamiento por versión Android

| Situación | Android ≤ 13 | Android 14+ sin permiso | Android 14+ con permiso |
|---|---|---|---|
| Pantalla bloqueada | ✅ AlarmScreen automática | ❌ Heads-up notification | ✅ AlarmScreen automática |
| Usando otra app | ❌ Heads-up notification | ❌ Notificación pequeña | ✅ AlarmScreen automática |

`NotificationService.requestFullScreenIntentPermission()` abre la pantalla de sistema si el permiso no está concedido (no-op en Android ≤ 13). El banner en `ProfileSettingsScreen` guía al usuario cuando selecciona modo ACTIVO.

### Code paths — Fase 9

```
app/lib/infrastructure/notifications/notification_service.dart     ← dual-mode, payload 4 campos
app/lib/infrastructure/notifications/pending_alarm_notifier.dart   ← bridge global
app/lib/presentation/features/alarm/alarm_screen.dart             ← pantalla de alarma
app/lib/main.dart                                                   ← foreground/background handlers
app/lib/presentation/app.dart                                       ← listener en _MainShell
app/lib/presentation/screens/settings/profile_settings_screen.dart ← banner permiso FSI
```
