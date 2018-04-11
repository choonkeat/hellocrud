{{- $tableNameSingular := .Table.Name | singular -}}
{{- $modelName := $tableNameSingular | titleCase -}}
{{- $modelNameCamel := $tableNameSingular | camelCase -}}

// update{{$modelName}}Input is an object to back {{$modelName}} mutation (update) input type
type update{{$modelName}}Input struct {
{{range $column := .Table.Columns }}
{{- if eq $column.Name "id" }}
{{- else if eq $column.Name "created_by" }}
{{- else if eq $column.Name "created_at" }}
{{- else if eq $column.Name "updated_by" }}
{{- else if eq $column.Name "updated_at" }}
{{- else if eq $column.Type "[]byte" }}
  {{titleCase $column.Name}} []byte
{{- else if eq $column.Type "bool" }}
  {{titleCase $column.Name}} bool
{{- else if eq $column.Type "float32" }}
  {{titleCase $column.Name}} float64
{{- else if eq $column.Type "float64" }}
  {{titleCase $column.Name}} float64
{{- else if eq $column.Type "int" }}
  {{titleCase $column.Name}} int32
{{- else if eq $column.Type "int16" }}
  {{titleCase $column.Name}} int32
{{- else if eq $column.Type "int64" }}
  {{titleCase $column.Name}} int32
{{- else if eq $column.Type "null.Bool" }}
  {{titleCase $column.Name}} *bool
{{- else if eq $column.Type "null.Byte" }}
  {{titleCase $column.Name}} *byte
{{- else if eq $column.Type "null.Bytes" }}
  {{titleCase $column.Name}} *[]byte
{{- else if eq $column.Type "null.Float64" }}
  {{titleCase $column.Name}} *float64
{{- else if eq $column.Type "null.Int" }}
  {{titleCase $column.Name}} *int32
{{- else if eq $column.Type "null.Int16" }}
  {{titleCase $column.Name}} *int32
{{- else if eq $column.Type "null.Int64" }}
  {{titleCase $column.Name}} *int64
{{- else if eq $column.Type "null.JSON" }}
  {{titleCase $column.Name}} *[]byte
{{- else if eq $column.Type "null.String" }}
  {{titleCase $column.Name}} *string
{{- else if eq $column.Type "null.Time" }}
  {{titleCase $column.Name}} *graphql.Time
{{- else if eq $column.Type "string" }}
  {{titleCase $column.Name}} string
{{- else if eq $column.Type "time.Time" }}
  {{titleCase $column.Name}} graphql.Time
{{- else if eq $column.Type "types.Byte" }}
  {{titleCase $column.Name}} string
{{- else if eq $column.Type "types.JSON" }}
  {{titleCase $column.Name}} string
{{- end -}}
{{- end }}

}
