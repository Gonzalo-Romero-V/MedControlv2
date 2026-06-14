@AGENTS.md

## Protocolo de sincronización (obligatorio)

Después de **cualquier commit no-trivial**, incluir visiblemente en la respuesta:

> "Hook generó `change_report.json`. ¿Corremos `/sync` para sincronizar el vault?"

No omitir aunque el commit sea solo documentación. El output del post-commit hook
confirma si el reporte se generó — si dice "change_report.json actualizado", la
pregunta es obligatoria.

## Fase de requisitos vs fase de código

- **Fase requisitos/arquitectura** (sin código): escritura directa al vault. `/sync`
  es opcional pero la pregunta sigue siendo necesaria para que el humano decida.
- **Fase de código**: `/sync` después de cada commit es parte del ciclo, no opcional.
  El vault debe reflejar el código; si no se corre, el grafo drifta.
