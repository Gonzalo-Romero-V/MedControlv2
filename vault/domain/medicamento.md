---
status: draft
type: domain
layer: H2
created: 2026-06-14
related: [[recordatorio]], [[base-de-conocimiento]], [[paciente]]
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
