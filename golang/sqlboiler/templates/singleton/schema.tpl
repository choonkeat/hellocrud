// Schema is the GraphQL schema
var Schema = `
scalar Time
scalar Int64

schema {
  query: Query
  mutation: Mutation
}

type Query {
{{range $table := .Tables}}
{{- $tableNameSingular := .Name | singular -}}
{{- $modelName := $tableNameSingular | titleCase -}}
{{- $modelNameCamel := $tableNameSingular | camelCase}}

  all{{$modelName}}s(
    since: ID
    pageSize: Int!
    search: Search{{$modelName}}Args
  ): {{$modelName}}sCollection!

  {{$modelNameCamel}}ByID(
    id: ID!
  ): {{$modelName}}!
{{end}}
}

type Mutation {
{{range $table := .Tables}}
{{- $tableNameSingular := .Name | singular -}}
{{- $modelName := $tableNameSingular | titleCase -}}
{{- $modelNameCamel := $tableNameSingular | camelCase}}

  create{{$modelName}}(
    input: Create{{$modelName}}Input!
  ): {{$modelName}}!

  update{{$modelName}}ByID(
    id: ID!
    input: Update{{$modelName}}Input!
  ): {{$modelName}}!

  delete{{$modelName}}ByID(
    id: ID!
  ): {{$modelName}}!
{{end}}
}

{{range $table := .Tables}}
{{- $tableNameSingular := .Name | singular -}}
{{- $modelName := $tableNameSingular | titleCase -}}
{{- $modelNameCamel := $tableNameSingular | camelCase -}}
{{- $pkColNames := $table.PKey.Columns -}}

type {{$modelName}} {
	{{range $column := $table.Columns }}
	{{- if containsAny $pkColNames $column.Name }}
		# Convenient GUID for react component @key attribute
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
		{{camelCase $column.Name}}: String!
	{{- else if eq $column.Type "time.Time" }}
		{{camelCase $column.Name}}: Time!
	{{- else if eq $column.Type "types.Byte" }}
		{{camelCase $column.Name}}: String!
	{{- else if eq $column.Type "types.JSON" }}
		{{camelCase $column.Name}}: String!
	{{- end -}}
	{{- end }}
}

type {{$modelName}}sCollection {
	nodes: [{{$modelName}}!]!
}

input Create{{$modelName}}Input {
	{{range $column := $table.Columns }}
	{{- if containsAny $pkColNames $column.Name }}
	{{- else if eq $column.Name "created_by" }}
	{{- else if eq $column.Name "created_at" }}
	{{- else if eq $column.Name "updated_by" }}
	{{- else if eq $column.Name "updated_at" }}
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
	  {{camelCase $column.Name}}: String!
	{{- else if eq $column.Type "time.Time" }}
	  {{camelCase $column.Name}}: Time!
	{{- else if eq $column.Type "types.Byte" }}
	  {{camelCase $column.Name}}: String!
	{{- else if eq $column.Type "types.JSON" }}
	  {{camelCase $column.Name}}: String!
	{{- end -}}
	{{- end }}
}

input Update{{$modelName}}Input {
	{{range $column := $table.Columns }}
	{{- if containsAny $pkColNames $column.Name }}
	{{- else if eq $column.Name "created_by" }}
	{{- else if eq $column.Name "created_at" }}
	{{- else if eq $column.Name "updated_by" }}
	{{- else if eq $column.Name "updated_at" }}
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
	  {{camelCase $column.Name}}: String!
	{{- else if eq $column.Type "time.Time" }}
	  {{camelCase $column.Name}}: Time!
	{{- else if eq $column.Type "types.Byte" }}
	  {{camelCase $column.Name}}: String!
	{{- else if eq $column.Type "types.JSON" }}
	  {{camelCase $column.Name}}: String!
	{{- end -}}
	{{- end }}
}

input Search{{$modelName}}Args {
	{{range $column := $table.Columns }}
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

{{end}}
`

var _ = graphql.MustParseSchema(Schema, &Resolver{})
