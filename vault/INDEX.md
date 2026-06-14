---
type: index
status: locked
---

# INDEX — MedControlv2

**Vault**: `C:/Users/Gonzalo/Dev/MATERIAS/02_BC/MedControlv2/vault`

---

## Sistema

- [[SYSTEM]] — cómo funciona el vault y la sincronización (leer antes de modificar)

---

## Intent — H1 El Porqué

> Visión, invariantes de negocio, reglas que no negocian con la implementación.

- [[vision]] — qué es, para quién, problema que resuelve _(empezar aquí — obligatorio antes del primer feature)_

---

## Domain — H2 El Qué

> Entidades de dominio, sus estados, sus reglas, sus relaciones.

- [[medicamento]] — entidad principal: nombre, dosis, frecuencia, vía, instrucciones, duración _(pendiente de crear)_
- [[base-de-conocimiento]] — hechos, reglas de inferencia, motor de razonamiento explícito _(pendiente de crear)_
- [[paciente]] — perfil de usuario, accesibilidad, relación con cuidador _(pendiente de crear)_
- [[recordatorio]] — horario confirmado, historial de tomas, estados _(pendiente de crear)_

---

## Decisions — H3 El Cómo

> Decisiones arquitectónicas que propagan hacia H4–H5.

- [[stack]] — tecnologías elegidas por capa _(obligatoria antes del primer feature técnico)_
- [[architecture]] — patrón arquitectónico, convenciones, manejo de errores

_(agregar más al tomar decisiones — auth, design-system, rbac, deploy, etc.)_

---

## Raw — Fuentes

_(documentos crudos en `raw/` — PDFs, transcripts, imágenes — ingeridos con `/ingest`)_

---

## Tarea → notas obligatorias

> **Completar esta tabla al instanciar el proyecto.** Es la mitad del valor
> del sistema. Sin ella, los agentes no saben qué leer antes de tocar código
> en cada área del repo.

| Tarea | Notas obligatorias |
|-------|---------------------|
| Agregar o modificar un medicamento | `domain/medicamento.md` + `decisions/architecture.md` |
| Cambiar reglas de inferencia | `domain/base-de-conocimiento.md` + `decisions/architecture.md` |
| Modificar flujo de registro de receta (OCR/IA) | `domain/medicamento.md` + `decisions/stack.md` |
| Agregar/modificar recordatorios | `domain/recordatorio.md` + `decisions/architecture.md` |
| Cambiar modelo de datos / schema SQLite | `domain/medicamento.md` + `domain/paciente.md` + `domain/recordatorio.md` |
| Feature de accesibilidad / GUI | `domain/paciente.md` + `intent/vision.md` |
| Cambio de proveedor IA u OCR | `decisions/stack.md` + `domain/base-de-conocimiento.md` |
| Feature de cuidador / multi-paciente | `domain/paciente.md` + `decisions/architecture.md` |

---

## Protocolo para agentes

1. Leer este índice antes de cualquier tarea no-trivial.
2. Leer las notas relevantes al área de trabajo (no leer todo el vault).
3. Tras implementar: actualizar `code_path` en la nota correspondiente vía `/sync`.
4. **Nunca modificar** notas con `status: locked`.
5. Si una implementación contradice una nota de dominio → reportar, no resolver.
6. Los snapshots y READMEs son fuentes secundarias — la fuente de verdad
   semántica es este vault.

**Sistema de sincronización**: ver [[SYSTEM]].
