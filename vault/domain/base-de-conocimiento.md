---
status: draft
type: domain
layer: H2
created: 2026-06-14
related: [[medicamento]], [[recordatorio]], [[paciente]]
---

# Base de Conocimiento

## Rol en el sistema

La BC es el componente que diferencia a MedControl de una app de recordatorios convencional. No solo almacena datos — representa conocimiento sobre la medicación y razona sobre él de forma explícita y trazable. Es el argumento académico central del proyecto.

Tres capas:
1. **Hechos**: lo que el sistema sabe sobre la medicación de un paciente (extraído de recetas, confirmado por el usuario)
2. **Reglas**: conocimiento general sobre medicación (independiente del paciente)
3. **Motor de inferencia**: aplica reglas sobre hechos, produce conclusiones con explicación

---

## Capa 1 — Hechos

Los hechos son las instancias confirmadas de los datos de un tratamiento. Se almacenan en SQLite y constituyen la "memoria" del sistema sobre cada paciente.

Hechos que el sistema representa por tratamiento:

```
medicamento(id, nombre, principio_activo, presentacion)
dosis(tratamiento_id, cantidad, unidad)
frecuencia(tratamiento_id, tipo, valor)         # ej: cada_n_horas, 12
via(tratamiento_id, tipo)                        # oral, topica, etc.
instruccion(tratamiento_id, texto)               # "con comida", "antes de dormir"
duracion(tratamiento_id, tipo, valor)            # por_duracion(7), indefinido, etc.
horario_confirmado(tratamiento_id, hora, regla)  # hora sugerida + traza de regla
es_critico(tratamiento_id, bool)                 # ventana terapéutica estrecha
```

Los hechos son inmutables una vez confirmados. Si hay corrección, se registra un nuevo hecho y el anterior queda en historial.

---

## Capa 2 — Reglas

Conocimiento general sobre medicación, implementado como funciones puras en Dart (sin dependencias de Flutter ni de base de datos). Cada regla tiene un identificador canónico que se preserva en la traza de explicación.

### Reglas de inferencia de horario

| ID de regla | Condición | Conclusión |
|---|---|---|
| `R01` | `frecuencia = cada_n_horas(N)` | Generar `24/N` tomas distribuidas a partir de hora de inicio |
| `R02` | `frecuencia = n_veces_dia(N)` | Distribuir N tomas en horas de vigilia (07:00–22:00) con intervalo `(22-7)/N` |
| `R03` | `instruccion contiene "después de comer"` o `"con comida"` | Anclar tomas a `hora_desayuno`, `hora_almuerzo`, `hora_cena` del perfil del paciente |
| `R04` | `instruccion contiene "antes de dormir"` | Asignar `hora_dormir` del perfil del paciente |
| `R05` | `instruccion contiene "en ayunas"` o `"antes del desayuno"` | Asignar `hora_desayuno - 30min` |
| `R06` | `frecuencia = a_demanda` | No generar horarios — registrar tomas manuales |
| `R07` | `falta campo crítico` | No inferir — marcar campo como pendiente, pedir confirmación humana |

### Reglas de ventana de posposición

| ID de regla | Condición | Conclusión |
|---|---|---|
| `R08` | `es_critico = false` AND `frecuencia = cada_n_horas(N)` | `ventana = N/2 horas`, 3 posposiciones en `ventana/3` |
| `R09` | `es_critico = true` | `ventana = 30 min`, sin posposición, alerta especial |

### Reglas de conflicto

| ID de regla | Condición | Conclusión |
|---|---|---|
| `R10` | Existe tratamiento `activo` o `suspendido` del mismo `principio_activo` | Bloquear + alerta + confirmación explícita requerida |

### Reglas de cierre automático

| ID de regla | Condición | Conclusión |
|---|---|---|
| `R11` | `criterio_fin = por_duracion` AND `fecha_actual >= fecha_fin_calculada` | Transición a `vencido` + notificación al usuario |
| `R12` | `criterio_fin = por_cantidad` AND `tomas_tomadas >= cantidad_total_dosis` | Transición a `completado` |
| `R13` | `criterio_fin = indefinido` | Sin cierre automático — solo cierre manual |

---

## Capa 3 — Motor de inferencia

Clase Dart pura (`InferenceEngine`) en la capa Domain. Entrada: un conjunto de hechos de un tratamiento. Salida: lista de horarios sugeridos, cada uno con su traza de explicación.

### Contrato de la función principal

```dart
InferenceResult inferSchedule(TreatmentFacts facts, PatientProfile profile);

class InferenceResult {
  final List<SuggestedTime> suggestions;
  final List<InferenceTrace> traces;
  final List<MissingField> pendingFields;  // campos críticos faltantes
  final List<ConflictAlert> conflicts;     // R10
}

class SuggestedTime {
  final TimeOfDay time;
  final String ruleId;        // ej: "R01"
  final String explanation;   // texto legible para mostrar al usuario
}
```

### Ejemplo de ejecución trazada

**Entrada:**
```
frecuencia: cada_n_horas(12)
instruccion: "tomar con comida"
```

**Proceso:**
```
1. R01 se activa: cada_n_horas(12) → 24/12 = 2 tomas
2. R03 se activa: "con comida" → anclar a comidas principales
3. R01 y R03 coexisten: se toman 2 comidas del perfil → desayuno (07:00) y cena (19:00)
4. Resultado: [07:00, 19:00]
```

**Explicación generada (visible en UI):**
> *"Se sugirieron 07:00 y 19:00 porque la receta indica cada 12 horas (→ 2 tomas diarias) y debe tomarse con comida (→ anclado a desayuno y cena de tu perfil)."*

### Prioridad de reglas en conflicto

Si `R01`/`R02` y `R03`/`R04`/`R05` coexisten, las instrucciones especiales toman precedencia sobre la distribución matemática pura. Si el número de comidas no coincide con el número de tomas inferido por `R01`, el motor:
1. Aplica las comidas disponibles
2. Marca las tomas restantes como pendientes de confirmación manual
3. Notifica al usuario en la pantalla de revisión

---

## Explicabilidad — requisito no negociable

Toda conclusión del motor de inferencia debe poder mostrarse al usuario como texto en lenguaje natural. Esto es:
- Argumento académico: el sistema razona, no solo recupera
- Argumento de seguridad: el usuario confirma entendiendo por qué

La UI de revisión muestra para cada horario sugerido:
1. La hora propuesta
2. La explicación en lenguaje natural
3. La opción de ajustar manualmente

El motor nunca produce un horario sin traza. Si no puede explicar una conclusión, no la produce.

---

## Representación académica

Para la defensa del proyecto, la BC puede describirse como un **sistema de producción** (production system):
- **Base de hechos**: instancias del tratamiento confirmadas por el usuario
- **Base de reglas**: R01–R13, declaradas explícitamente
- **Motor de inferencia hacia adelante** (forward chaining): dado un conjunto de hechos, se evalúan todas las reglas y se producen conclusiones
- **Explicación**: cada conclusión lleva la cadena de reglas que la generó

Esta descripción es correcta técnicamente y suficiente para defender que el sistema usa razonamiento basado en conocimiento, no solo lógica de negocio implícita.

---

## Extensiones futuras (fuera de MVP)

- Interacciones medicamentosas: requiere base farmacológica externa (VADEMÉCUM, DrugBank)
- Reglas de contraindicación por condición del paciente (ej: insuficiencia renal → ajuste de dosis)
- Aprendizaje de preferencias horarias: si el usuario ajusta consistentemente los horarios sugeridos, el sistema puede proponer horarios personalizados
- Reglas para pautas de reducción (tapering): múltiples fases con lógica compleja
