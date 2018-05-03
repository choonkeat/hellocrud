{{- $tableNameSingular := .Table.Name | singular -}}
{{- $modelName := $tableNameSingular | titleCase -}}
{{- $modelNameCamel := $tableNameSingular | camelCase -}}
{{- $pkColNames := .Table.PKey.Columns -}}

var _ = `
# Search{{$modelName}}Input is a search input/arguments type for {{$modelName}} resources
input Search{{$modelName}}Input {
	{{range $column := .Table.Columns }}
	{{- if containsAny $pkColNames $column.Name }}
	{{- else if eq $column.Name "created_by" }}
	{{- else if eq $column.Name "created_at" }}
	{{- else if eq $column.Name "updated_by" }}
	{{- else if eq $column.Name "updated_at" }}
	{{- else if eq $column.Type "[]byte" }}
	  {{camelCase $column.Name}}: String
	{{- else if eq $column.Type "bool" }}
	  {{camelCase $column.Name}}: Boolean
	{{- else if eq $column.Type "float32" }}
	  {{camelCase $column.Name}}: Float
	{{- else if eq $column.Type "float64" }}
	  {{camelCase $column.Name}}: Float
	{{- else if eq $column.Type "int" }}
	  {{camelCase $column.Name}}: Int
	{{- else if eq $column.Type "int16" }}
	  {{camelCase $column.Name}}: Int
	{{- else if eq $column.Type "int64" }}
	  {{camelCase $column.Name}}: Int64
	{{- else if eq $column.Type "null.Bool" }}
	  {{camelCase $column.Name}}: Boolean
	{{- else if eq $column.Type "null.Byte" }}
	  {{camelCase $column.Name}}: string
	{{- else if eq $column.Type "null.Bytes" }}
	  {{camelCase $column.Name}}: string
	{{- else if eq $column.Type "null.Float64" }}
	  {{camelCase $column.Name}}: Float
	{{- else if eq $column.Type "null.Int" }}
	  {{camelCase $column.Name}}: Int
	{{- else if eq $column.Type "null.Int16" }}
	  {{camelCase $column.Name}}: Int
	{{- else if eq $column.Type "null.Int64" }}
	  {{camelCase $column.Name}}: Int64
	{{- else if eq $column.Type "null.JSON" }}
	  {{camelCase $column.Name}}: String
	{{- else if eq $column.Type "null.String" }}
	  {{camelCase $column.Name}}: String
	{{- else if eq $column.Type "null.Time" }}
	  {{camelCase $column.Name}}: Time
	{{- else if eq $column.Type "string" }}
	  {{camelCase $column.Name}}: String
	{{- else if eq $column.Type "time.Time" }}
	  {{camelCase $column.Name}}: Time
	{{- else if eq $column.Type "types.Byte" }}
	  {{camelCase $column.Name}}: String
	{{- else if eq $column.Type "types.JSON" }}
	  {{camelCase $column.Name}}: String
	{{- end -}}
	{{- end }}
}
`
