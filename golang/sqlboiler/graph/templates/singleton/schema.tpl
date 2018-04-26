// Schema is the GraphQL schema
var Schema string

// schemaRoot is the GraphQL root schema containing query and mutation resolvers
var schemaRoot = `
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
{{- $modelNamePlural := $table.Name | plural | titleCase -}}
{{- $modelNameCamel := $tableNameSingular | camelCase}}

  all{{$modelNamePlural}}(
    pageNumber: Int
    pageSize: Int
    search: Search{{$modelName}}Input
  ): {{$modelNamePlural}}Collection!

  {{$modelNameCamel}}ByID(
    id: ID!
  ): {{$modelName}}!
{{end}}
}

type Mutation {
{{range $table := .Tables}}
{{- $tableNameSingular := .Name | singular -}}
{{- $modelName := $tableNameSingular | titleCase -}}
{{- $modelNamePlural := $table.Name | plural | titleCase -}}
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
`

func init() {
	strs := []string{
		schemaRoot,
		{{range $table := .Tables}}
		{{- $tableNameSingular := .Name | singular -}}
		{{- $modelName := $tableNameSingular | titleCase -}}
		SchemaType{{$modelName}},
		SchemaCreate{{$modelName}}Input,
		SchemaUpdate{{$modelName}}Input,
		SchemaSearch{{$modelName}}Input,
		{{end}}
	}
	Schema = strings.Join(strs, "\n")
	
	// Sanity check generated schema
	graphql.MustParseSchema(Schema, &Resolver{})
}
