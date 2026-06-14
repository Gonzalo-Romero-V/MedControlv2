---
status: draft
type: intent
layer: H1
created: 2026-06-14
---

# Visión — MedControlv2

## Visión

Aplicación móvil local-first que asiste a personas con dificultades para gestionar su medicación. Usa IA para interpretar recetas y una base de conocimiento explícita para inferir horarios y advertencias, garantizando que el usuario siempre confirme antes de crear recordatorios. El componente central no es la interfaz de recordatorios sino el razonamiento sobre la medicación.

## Propósito central

Reducir errores de medicación en personas con dificultades de gestión (edad, deterioro cognitivo, discapacidad visual) mediante un sistema que razona de forma explicable sobre recetas y genera recordatorios locales confirmados por el usuario o su cuidador.

## Contexto académico

Proyecto de la materia **Base de Conocimiento**. El criterio de evaluación es demostrar que el sistema resuelve un problema real en un dominio específico usando IA con razonamiento explicable. El formalismo de representación del conocimiento es libre; lo que se evalúa es que el sistema pueda justificar sus inferencias (ej: "Se sugirió 08:00 y 20:00 porque la receta indica cada 12 horas"). El dominio cubre: bases de conocimiento, NLP, visión por computador, ML supervisado/no supervisado/profundo — no todos deben usarse, se toma el subconjunto que resuelve el problema.

## Invariantes de negocio

1. **Confirmación humana obligatoria**: ningún recordatorio se crea sin que el usuario o cuidador revise y apruebe los datos interpretados por la IA. El riesgo médico de una interpretación incorrecta es inaceptable.
2. **Explicabilidad de inferencias**: toda sugerencia de horario debe poder mostrar la regla que la generó (ej: "cada 12h → 2 tomas diarias → 08:00 y 20:00").
3. **Recordatorios funcionan sin internet**: una vez confirmados los datos, los recordatorios locales deben dispararse independientemente de la conectividad.
4. **La IA es asistente, no autoridad**: la app nunca debe crear recordatorios en modo automático sin revisión. Si la IA no puede interpretar algo, pide confirmación manual.
5. **No diagnóstico ni consejo médico**: el sistema solo gestiona lo que el médico ya recetó. No sugiere tratamientos, no evalúa síntomas.

## Usuarios principales

### Paciente autónomo
Persona que gestiona su propia medicación. Puede tener dificultades visuales, auditivas o de memoria pero mantiene capacidad de interacción tecnológica. Configura sus propios medicamentos y confirma los datos. La GUI debe adaptarse a sus limitaciones: texto grande, alto contraste, targets táctiles generosos, flujos simples sin sobrecarga cognitiva.

### Paciente asistido
Persona que no puede interactuar con el sistema. El cuidador configura todo. El paciente puede ver pantallas simplificadas de "qué tomar ahora" sin necesidad de navegar.

### Cuidador / familiar
Configura medicamentos del paciente, revisa interpretaciones de IA, aprueba recordatorios, puede monitorear adherencia. Opera con mayor capacidad técnica que el paciente.

<!-- TODO: ¿El cuidador opera desde el mismo dispositivo o desde uno separado? -->
<!-- TODO: ¿Se contempla un panel web para cuidadores en fases futuras? (el bosquejo lo menciona como posibilidad) -->

## Fuera de alcance (MVP)

- Reconocimiento de recetas manuscritas (mencionable como experimental, no soportado)
- Asistente de voz completo
- Reconocimiento visual automático de pastillas desconocidas
- Diagnóstico o consejo médico
- Interacciones medicamentosas avanzadas
- Sincronización familiar / panel de cuidador remoto
- Backend obligatorio para funcionamiento core
