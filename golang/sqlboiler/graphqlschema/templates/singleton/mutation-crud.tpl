var _ = `
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
`
