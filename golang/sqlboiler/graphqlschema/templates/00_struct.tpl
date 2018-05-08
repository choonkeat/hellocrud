{{- $dot := . -}}
{{- $tableNameSingular := .Table.Name | singular -}}
{{- $modelName := $tableNameSingular | titleCase -}}
{{- $modelNamePlural := .Table.Name | plural | titleCase -}}
{{- $modelNameCamel := $tableNameSingular | camelCase -}}
{{- $pkColNames := .Table.PKey.Columns -}}
{{- $fkColDefs := .Table.FKeys -}}

/*sqlboiler2other
# {{$modelName}} is a resource type
type {{$modelName}} {
	{{range $column := .Table.Columns }}
	{{- if containsAny $pkColNames $column.Name }}
		# Convenient GUID for ReactJS component @key attribute
		rowId: String!
		{{camelCase $column.Name}}: ID!
	{{- else if eq $column.Type "[]byte" }}
		{{camelCase $column.Name}}: String!
	{{- else if eq $column.Type "bool" }}
		{{camelCase $column.Name}}: Boolean!
	{{- else if eq $column.Type "float32" }}
		{{camelCase $column.Name}}: Float!
	{{- else if eq $column.Type "float64" }}
		{{camelCase $column.Name}}: Float!
	{{- else if eq $column.Type "int" }}
		{{camelCase $column.Name}}: Int!
	{{- else if eq $column.Type "int16" }}
		{{camelCase $column.Name}}: Int!
	{{- else if eq $column.Type "int64" }}
		{{camelCase $column.Name}}: Int64!
	{{- else if eq $column.Type "null.Bool" }}
		{{camelCase $column.Name}}: Boolean
	{{- else if eq $column.Type "null.Byte" }}
		{{camelCase $column.Name}}: Base64
	{{- else if eq $column.Type "null.Bytes" }}
		{{camelCase $column.Name}}: Base64
	{{- else if eq $column.Type "null.Float64" }}
		{{camelCase $column.Name}}: Float
	{{- else if eq $column.Type "null.Int" }}
		{{camelCase $column.Name}}: Int
	{{- else if eq $column.Type "null.Int16" }}
		{{camelCase $column.Name}}: Int
	{{- else if eq $column.Type "null.Int64" }}
		{{camelCase $column.Name}}: Int64
	{{- else if eq $column.Type "null.JSON" }}
		{{camelCase $column.Name}}: Text
	{{- else if eq $column.Type "null.String" }}
		{{camelCase $column.Name}}: String
	{{- else if eq $column.Type "null.Time" }}
		{{camelCase $column.Name}}: Time
	{{- else if eq $column.Type "string" }}
		{{camelCase $column.Name}}: String!
	{{- else if eq $column.Type "time.Time" }}
		{{camelCase $column.Name}}: Time!
	{{- else if eq $column.Type "types.Byte" }}
		{{camelCase $column.Name}}: String!
	{{- else if eq $column.Type "types.JSON" }}
		{{camelCase $column.Name}}: String!
	{{- end -}}
	{{- end }}
	{{- /* Add to FK relationships */}}
	{{- range $r := $fkColDefs }}
		# {{ $r.ForeignTable | singular | camelCase }} has a foreign key pointing to {{$modelName}}
		{{ $r.ForeignTable | singular | camelCase }}: {{ $r.ForeignTable | singular | titleCase }}
	{{- end }}
	{{- /* Add to one relationships */}}
	{{- range $r := .Table.ToOneRelationships }}
		# {{ $r.ForeignTable | singular | camelCase }} has a one-to-one relationship with {{$modelName}}
		{{ $r.ForeignTable | singular | camelCase }}: {{ $r.ForeignTable | singular | titleCase }}
	{{- end }}
	{{- /* Add to many relationships */}}
	{{- range $r := .Table.ToManyRelationships }}
		# {{ $r.ForeignTable | plural | camelCase }} has a many-to-one relationship with {{$modelName}}
		{{$r.ForeignTable | plural | camelCase }}: {{ $r.ForeignTable | plural | titleCase }}Collection
	{{- end }}
}

type {{$modelNamePlural}}Collection {
	nodes: [{{$modelName}}!]!
}
sqlboiler2other*/
