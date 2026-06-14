---
status: draft
type: domain
layer: H2
created: 2026-06-14
related: [[medicamento]], [[recordatorio]], [[base-de-conocimiento]]
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
