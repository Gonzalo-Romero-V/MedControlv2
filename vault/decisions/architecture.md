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

## Decisiones pendientes

- [ ] State management: Riverpod vs BLoC vs Provider
- [ ] TalkBack / VoiceOver: ¿MVP o fase 2?
- [ ] Estrategia de backup local: export a archivo vs sync cloud futuro
- [ ] UI multi-paciente: ¿selector de perfil activo o tabs simultáneos?
