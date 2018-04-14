{{- $tableNameSingular := .Table.Name | singular -}}
{{- $modelName := $tableNameSingular | titleCase -}}
{{- $modelNameCamel := $tableNameSingular | camelCase -}}
{{- $pkColNames := .Table.PKey.Columns -}}

// search{{$modelName}}Args is an object to back {{$modelName}} search arguments type
type search{{$modelName}}Args struct {
{{range $column := .Table.Columns }}
{{- if containsAny $pkColNames $column.Name }}
{{- else if eq $column.Type "[]byte" }}
  {{titleCase $column.Name}} *[]byte `json:"{{$column.Name }}"` 
{{- else if eq $column.Type "bool" }}
  {{titleCase $column.Name}} *bool `json:"{{$column.Name }}"` 
{{- else if eq $column.Type "float32" }}
  {{titleCase $column.Name}} *float64 `json:"{{$column.Name }}"` 
{{- else if eq $column.Type "float64" }}
  {{titleCase $column.Name}} *float64 `json:"{{$column.Name }}"` 
{{- else if eq $column.Type "int" }}
  {{titleCase $column.Name}} *int32 `json:"{{$column.Name }}"` 
{{- else if eq $column.Type "int16" }}
  {{titleCase $column.Name}} *int32 `json:"{{$column.Name }}"` 
{{- else if eq $column.Type "int64" }}
  {{titleCase $column.Name}} *Int64 `json:"{{$column.Name }}"` 
{{- else if eq $column.Type "null.Bool" }}
  {{titleCase $column.Name}} *bool `json:"{{$column.Name }}"` 
{{- else if eq $column.Type "null.Byte" }}
  {{titleCase $column.Name}} *byte `json:"{{$column.Name }}"` 
{{- else if eq $column.Type "null.Bytes" }}
  {{titleCase $column.Name}} *[]byte `json:"{{$column.Name }}"` 
{{- else if eq $column.Type "null.Float64" }}
  {{titleCase $column.Name}} *float64 `json:"{{$column.Name }}"` 
{{- else if eq $column.Type "null.Int" }}
  {{titleCase $column.Name}} *int32 `json:"{{$column.Name }}"` 
{{- else if eq $column.Type "null.Int16" }}
  {{titleCase $column.Name}} *int32 `json:"{{$column.Name }}"` 
{{- else if eq $column.Type "null.Int64" }}
  {{titleCase $column.Name}} *Int64 `json:"{{$column.Name }}"` 
{{- else if eq $column.Type "null.JSON" }}
  {{titleCase $column.Name}} *[]byte `json:"{{$column.Name }}"` 
{{- else if eq $column.Type "null.String" }}
  {{titleCase $column.Name}} *string `json:"{{$column.Name }}"` 
{{- else if eq $column.Type "null.Time" }}
  {{titleCase $column.Name}} *graphql.Time `json:"{{$column.Name }}"`
{{- else if eq $column.Type "string" }}
  {{titleCase $column.Name}} *string `json:"{{$column.Name }}"` 
{{- else if eq $column.Type "time.Time" }}
  {{titleCase $column.Name}} *graphql.Time `json:"{{$column.Name }}"`
{{- else if eq $column.Type "types.Byte" }}
  {{titleCase $column.Name}} *string `json:"{{$column.Name }}"` 
{{- else if eq $column.Type "types.JSON" }}
  {{titleCase $column.Name}} *string `json:"{{$column.Name }}"` 
{{- end -}}
{{- end }}
}

// QueryMods returns a list of QueryMod based on the struct values
func (s *search{{$modelName}}Args) QueryMods() []qm.QueryMod {
  mods := []qm.QueryMod{}
  // Get reflect value
  v := reflect.ValueOf(s).Elem()
  // Iterate struct fields
  for i := 0; i < v.NumField(); i++ {
    field := v.Type().Field(i) // StructField
    value := v.Field(i) // Value
    if value.IsNil() || !value.IsValid() {
      // Skip if field is nil
      continue
    }

    // Get column name from tags
    column, hasColumnName := field.Tag.Lookup("json")
    // Skip if no DB definition
    if !hasColumnName {
      continue
    }

    operator := "="
    val := value.Elem().Interface()
    if dataType := field.Type.String(); (dataType == "string" || dataType == "*string") &&
      val.(string) != "" {
      operator = "LIKE"
      val = fmt.Sprintf("%%%s%%", val)
    }
    mods = append(mods, qm.And(fmt.Sprintf("%s %s ?", column, operator), val))
  }
  return mods
}
