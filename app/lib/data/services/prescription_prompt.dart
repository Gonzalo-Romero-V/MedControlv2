/// Prompt compartido entre todos los proveedores de AI para parseo de recetas.
/// Centralizado aquí para mantener coherencia cuando se ajuste el prompt.
abstract final class PrescriptionPrompt {
  static String build(String ocrText) => '''
Sos un asistente médico especializado en interpretar recetas.
Extraé la información del siguiente texto y devolvé SOLO un objeto JSON válido con este esquema exacto:

{
  "nombre_medicamento": "string o null",
  "principio_activo": "string o null",
  "dosis_cantidad": numero_decimal_o_null,
  "dosis_unidad": "tabletas|ml|mg|gotas|puff|aplicacion|null",
  "frecuencia_tipo": "cada_n_horas|n_veces_dia|a_demanda|pauta_reduccion|null",
  "frecuencia_valor": entero_o_null,
  "via_administracion": "oral|topica|inhalatoria|sublingual|rectal|otro|null",
  "instrucciones_especiales": "string o null",
  "criterio_fin_tipo": "por_duracion|por_cantidad|indefinido|a_demanda|null",
  "duracion_dias": entero_o_null,
  "cantidad_total_dosis": entero_o_null,
  "es_critico": true_o_false
}

Reglas estrictas:
- Si un campo no aparece claramente en el texto, usá null (no inventes valores)
- es_critico = true SOLO si el medicamento es anticonvulsivo, anticoagulante, insulina, inmunosupresor u otro con ventana terapéutica estrecha conocida
- "cada 8 horas" → frecuencia_tipo=cada_n_horas, frecuencia_valor=8
- "3 veces al día" → frecuencia_tipo=n_veces_dia, frecuencia_valor=3
- "según necesidad" o "PRN" → frecuencia_tipo=a_demanda, frecuencia_valor=null
- Devolvé SOLO el JSON, sin markdown, sin explicaciones, sin texto adicional

Texto de la receta:
$ocrText
''';
}
