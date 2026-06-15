---
status: draft
type: domain
layer: H2
created: 2026-06-14
related: [[recordatorio]], [[base-de-conocimiento]], [[paciente]]
code_path: app/lib/domain/entities/treatment_facts.dart
---

# Medicamento & Tratamiento

## Separación conceptual

- **Medicamento**: el fármaco en sí — nombre, presentación, foto de la caja. Reutilizable entre tratamientos.
- **Tratamiento**: una prescripción concreta — dosis, frecuencia, criterio de fin, horarios. Es la entidad operativa.

Un mismo medicamento puede tener múltiples tratamientos en momentos distintos (no simultáneos sin alerta — ver conflictos).

---

## Entidad: Medicamento

| Campo | Tipo | Notas |
|---|---|---|
| `id` | UUID | PK |
| `patient_id` | FK | |
| `nombre` | string | Comercial o genérico |
| `principio_activo` | string? | Extraído por IA si disponible |
| `presentacion` | enum | `tableta`, `capsula`, `jarabe`, `inyectable`, `topico`, `gotas`, `inhalador`, `otro` |
| `foto_caja` | path? | Foto del empaque registrada por usuario |
| `created_at` | timestamp | |

---

## Entidad: Tratamiento

| Campo | Tipo | Notas |
|---|---|---|
| `id` | UUID | PK |
| `medicamento_id` | FK | |
| `patient_id` | FK | |
| `dosis_cantidad` | decimal | Ej: 1, 0.5, 2 |
| `dosis_unidad` | enum | `tabletas`, `ml`, `mg`, `gotas`, `puff`, `aplicacion` |
| `frecuencia_tipo` | enum | `cada_n_horas`, `n_veces_dia`, `a_demanda`, `pauta_reduccion` |
| `frecuencia_valor` | integer? | N en "cada N horas" o "N veces al día" |
| `via_administracion` | enum | `oral`, `topica`, `inhalatoria`, `sublingual`, `rectal`, `otro` |
| `instrucciones_especiales` | string? | "con comida", "antes de dormir", etc. |
| `criterio_fin_tipo` | enum | `por_duracion`, `por_cantidad`, `indefinido`, `a_demanda` |
| `duracion_dias` | integer? | Solo si `por_duracion` |
| `cantidad_total_dosis` | integer? | Solo si `por_cantidad` |
| `fecha_inicio` | date | |
| `fecha_fin_calculada` | date? | Calculada automáticamente si aplica |
| `es_critico` | boolean | Flag para medicamentos de administración especial (anticonvulsivos, anticoagulantes, insulina). Activa reglas de ventana estricta en [[recordatorio]]. |
| `estado` | enum | Ver estados |
| `origen` | enum | `ocr_ia`, `manual` |
| `receta_imagen` | path? | Foto de la receta original |
| `receta_texto_ocr` | text? | Texto crudo del OCR — preservado como fuente |
| `notas` | text? | Notas libres |
| `created_at` | timestamp | |
| `ended_at` | timestamp? | Cuándo finalizó (manual o automático) |

---

## Estados del tratamiento

```
activo ──────────────────────────────► completado
  │                                    (criterio de fin alcanzado)
  ├──► suspendido ──► activo
  │    (pausa temporal, indicación médica)
  ├──► abandonado
  │    (usuario/cuidador terminó antes del fin)
  └──► vencido
       (fecha calculada pasó sin acción — sistema alerta)
```

| Estado | Lo establece | Descripción |
|---|---|---|
| `activo` | Sistema al confirmar | En curso |
| `completado` | Sistema automático | Criterio de fin alcanzado |
| `suspendido` | Usuario/cuidador | Pausa temporal |
| `abandonado` | Usuario/cuidador | Terminado antes del criterio |
| `vencido` | Sistema automático | `fecha_fin_calculada` pasó sin cierre explícito → alerta al usuario para confirmar qué ocurrió |

---

## Tipos de tratamiento

### Por duración
`fecha_fin_calculada = fecha_inicio + duracion_dias`. Recordatorios hasta esa fecha. Al llegar: "¿Completaste el tratamiento?" → `completado` o `abandonado`.

### Por cantidad
Conteo de dosis tomadas. Al alcanzar `cantidad_total_dosis`: misma notificación de cierre.

### Indefinido / crónico
Sin `fecha_fin_calculada`. Solo termina por acción manual. La IA debe detectar la indicación "indefinido" o "de por vida" en la receta; si no está claro, pregunta antes de confirmar.

### A demanda (PRN)
Sin recordatorios programados. El usuario registra cada toma manualmente. El sistema valida contra límite diario si fue especificado. Flujo de UI independiente.

### Con pauta de reducción (tapering)
Múltiples fases enlazadas, cada una con su propia dosis y duración (ej: corticoides). Modelado como lista de sub-tratamientos. **Fuera del MVP** por complejidad — contemplado en el modelo de datos pero no expuesto en UI inicial.

---

## Campos críticos (bloquean la confirmación si faltan)

- `dosis_cantidad` + `dosis_unidad`
- `frecuencia_tipo` (y `frecuencia_valor` si aplica)
- `fecha_inicio`
- `criterio_fin_tipo`

Si la IA no extrajo alguno → campo marcado como pendiente en la pantalla de revisión. No se pueden crear recordatorios con campos críticos vacíos.

---

## Conflicto por medicamento duplicado

Si el usuario intenta registrar un tratamiento activo para un medicamento que ya tiene tratamiento `activo` o `suspendido`:

1. Sistema bloquea el registro
2. Alerta: *"Ya tenés un tratamiento activo de [nombre]. Tomar dos tratamientos del mismo medicamento puede ser peligroso. Esta decisión debe tomarla tu médico."*
3. Checkbox de confirmación explícita: *"Entiendo el riesgo y mi médico lo indicó expresamente"*
4. Solo entonces se registra, con ambos tratamientos visibles y diferenciados en el historial

**Interacciones entre distintos medicamentos**: fuera de alcance del MVP. Requiere base farmacológica externa. Si se implementa en el futuro, es capa de advertencia consultiva — nunca bloqueo automático.

---

## Historial (append-only)

Cada tratamiento conserva permanentemente:
- Receta original (imagen + texto OCR)
- Todos los recordatorios generados y sus resultados
- Registro de cada toma: a tiempo / tarde / omitida / pospuesta
- Adherencia: % dosis tomadas sobre total esperado
- Cambios de estado con timestamp y motivo

El historial no se edita, solo se agrega.

## Pipeline de parseo OCR → IA (Fase 3)
La receta física se convierte en un `Tratamiento` en tres pasos:

```
Imagen
  └─► ParsePrescriptionUseCase
        ├─► Ruta 1 (online):  CloudVisionOcrService → GeminiParserService → ParsedPrescription
        └─► Ruta 2 (offline): MlKitOcrService → formulario manual
```

### Entidad intermedia: `ParsedPrescription`

Output tipado del pipeline OCR → IA. Contiene todos los campos de `Tratamiento` en forma nullable, más:
- `rawOcrText` — texto crudo preservado como fuente
- `rawAiResponse` — JSON crudo del modelo (trazabilidad)
- `source: PrescriptionSource` — `cloudVisionGemini` | `mlkitManual`
- `hasCriticalFields` — getter: bloquea confirmación si faltan campos críticos
- `toTreatmentFacts()` — bridge hacia [[base-de-conocimiento]] para inferencia

### Resultado del use case: `ParsePrescriptionResult` (sealed)

| Caso | Tipo | Qué ocurre |
|------|------|------------|
| Online exitoso | `FullParse(prescription)` | Pantalla de revisión con todos los campos |
| Solo OCR disponible | `OcrOnly(rawText)` | Formulario manual pre-poblado con texto |
| Todo falló | `ParseFailure(message)` | Formulario manual vacío + mensaje de error |

Code paths:
```
app/lib/domain/entities/parsed_prescription.dart
app/lib/domain/use_cases/parse_prescription_use_case.dart
```

## Confirmación y persistencia (Fase 4)
`ConfirmPrescriptionUseCase` es el punto de cierre del flujo de registro:
1. Garantiza que existe un paciente activo (crea "Paciente principal" si no hay ninguno — bootstrap Phase 6).
2. Crea una fila en `medications` con nombre, principio activo y presentación.
3. Crea una fila en `treatments` con dosis, frecuencia, criterio de fin, fecha de inicio y origen (`ocr_ai` | `manual`).
4. **No** crea recordatorios — eso es Phase 5.

Code path: `app/lib/domain/use_cases/confirm_prescription_use_case.dart`

## Implementación — Fase 7
Historial de tratamientos con adherencia implementado en `c9913dd`.

### Use case: `GetTreatmentHistoryUseCase`

Carga todos los tratamientos del paciente activo enriquecidos con:
- `medicationName` (join con `MedicationDao.getById`)
- `remindersTotal` — total de recordatorios creados para el tratamiento (proxy de dosis esperadas)
- `intakesTaken` — dosis confirmadas (`IntakeDao.countTaken`, cuenta `taken` + `taken_late`)
- `adherence` — getter derivado: `intakesTaken / remindersTotal`

Orden: activos primero, luego por `startDate` descendente.

### ViewModel

```dart
class TreatmentHistoryViewModel {
  final TreatmentsTableData treatment;
  final String medicationName;
  final int remindersTotal;
  final int intakesTaken;
  double get adherence => remindersTotal > 0 ? intakesTaken / remindersTotal : 0;
}
```

### Pantallas (H5)

| Pantalla | Descripción |
|---|---|
| `HistorialContent` | Lista de todos los tratamientos (tab 2 del `_MainShell`), card con `LinearProgressIndicator` de adherencia |
| `TreatmentDetailScreen` | Detalle pushed vía Navigator: info del tratamiento, card de adherencia, listado de recordatorios con resultado de toma |

### Code paths

```
app/lib/domain/use_cases/get_treatment_history_use_case.dart
app/lib/presentation/providers/historial_providers.dart
app/lib/presentation/features/historial/historial_screen.dart
app/lib/presentation/features/historial/treatment_detail_screen.dart
```

## Detección de duplicados — Fase 9 (352d507)
### Regla de negocio

Un paciente no puede tener dos tratamientos **activos** o **suspendidos** para el mismo medicamento simultáneamente. El sistema detecta duplicados por nombre (case-insensitive, `.toLowerCase().trim()`) o por principio activo compartido.

### Flujo de detección

```
ConfirmPrescriptionUseCase.execute(forceOverride: false)
  ├─ MedicationDao.findDuplicate(patientId, name, activeIngredient)
  │    └─ coincidencia case-insensitive por nombre O principio activo
  ├─ TreatmentDao.getConflicting(medicationId)  ← estados active/suspended
  └─ throws DuplicateMedicationException(medicationName)
       └─ PrescriptionFlowProvider catch
            → estado PrescriptionFlowDuplicateConflict
                 → PrescriptionFlowScreen._showDuplicateDialog()
                      ├─ checkbox obligatorio: el usuario confirma que asume el riesgo
                      └─ si acepta → confirmAndSave(forceOverride: true)
```

**forceOverride=true**: reutiliza el `medicamento.id` existente (evita duplicar la tabla) pero crea un `Tratamiento` nuevo. El tratamiento anterior permanece activo hasta que el usuario lo cierre.

### Code paths — Fase 9

```
app/lib/domain/use_cases/confirm_prescription_use_case.dart            ← DuplicateMedicationException
app/lib/infrastructure/database/daos/medication_dao.dart               ← findDuplicate()
app/lib/presentation/providers/prescription_flow_provider.dart         ← PrescriptionFlowDuplicateConflict
app/lib/presentation/screens/prescription/prescription_flow_screen.dart ← dialog + checkbox
```
