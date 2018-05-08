{{- $tableNameSingular := .Table.Name | singular -}}
{{- $modelName := $tableNameSingular | titleCase -}}
{{- $modelNameCamel := $tableNameSingular | camelCase -}}
{{- $pkColNames := .Table.PKey.Columns -}}

// create{{$modelName}}Input is an object to back {{$modelName}} mutation (create) input type
type create{{$modelName}}Input struct {
{{range $column := .Table.Columns }}
{{- if containsAny $pkColNames $column.Name }}
{{- else if eq $column.Name "created_by" }}
{{- else if eq $column.Name "created_at" }}
{{- else if eq $column.Name "updated_by" }}
{{- else if eq $column.Name "updated_at" }}
{{- else if eq $column.Type "[]byte" }}
  {{titleCase $column.Name}} Base64 `json:"{{$column.Name }}"`
{{- else if eq $column.Type "bool" }}
  {{titleCase $column.Name}} bool `json:"{{$column.Name }}"`
{{- else if eq $column.Type "float32" }}
  {{titleCase $column.Name}} float64 `json:"{{$column.Name }}"`
{{- else if eq $column.Type "float64" }}
  {{titleCase $column.Name}} float64 `json:"{{$column.Name }}"`
{{- else if eq $column.Type "int" }}
  {{titleCase $column.Name}} int32 `json:"{{$column.Name }}"`
{{- else if eq $column.Type "int16" }}
  {{titleCase $column.Name}} int32 `json:"{{$column.Name }}"`
{{- else if eq $column.Type "int64" }}
  {{titleCase $column.Name}} Int64 `json:"{{$column.Name }}"`
{{- else if eq $column.Type "null.Bool" }}
  {{titleCase $column.Name}} *bool `json:"{{$column.Name }}"`
{{- else if eq $column.Type "null.Byte" }}
  {{titleCase $column.Name}} *byte `json:"{{$column.Name }}"`
{{- else if eq $column.Type "null.Bytes" }}
  {{titleCase $column.Name}} *Base64 `json:"{{$column.Name }}"`
{{- else if eq $column.Type "null.Float64" }}
  {{titleCase $column.Name}} *float64 `json:"{{$column.Name }}"`
{{- else if eq $column.Type "null.Int" }}
  {{titleCase $column.Name}} *int32 `json:"{{$column.Name }}"`
{{- else if eq $column.Type "null.Int16" }}
  {{titleCase $column.Name}} *int32 `json:"{{$column.Name }}"`
{{- else if eq $column.Type "null.Int64" }}
  {{titleCase $column.Name}} *Int64 `json:"{{$column.Name }}"`
{{- else if eq $column.Type "null.JSON" }}
  {{titleCase $column.Name}} *Text `json:"{{$column.Name }}"`
{{- else if eq $column.Type "null.String" }}
  {{titleCase $column.Name}} *string `json:"{{$column.Name }}"`
{{- else if eq $column.Type "null.Time" }}
  {{titleCase $column.Name}} *graphql.Time `json:"{{$column.Name }}"`
{{- else if eq $column.Type "string" }}
  {{titleCase $column.Name}} string `json:"{{$column.Name }}"`
{{- else if eq $column.Type "time.Time" }}
  {{titleCase $column.Name}} graphql.Time `json:"{{$column.Name }}"`
{{- else if eq $column.Type "types.Byte" }}
  {{titleCase $column.Name}} string `json:"{{$column.Name }}"`
{{- else if eq $column.Type "types.JSON" }}
  {{titleCase $column.Name}} string `json:"{{$column.Name }}"`
{{- end -}}
{{- end }}
}
