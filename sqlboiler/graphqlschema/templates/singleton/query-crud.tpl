/*sqlboiler2other
{{range $table := .Tables}}
{{- $tableNameSingular := .Name | singular -}}
{{- $modelName := $tableNameSingular | titleCase -}}
{{- $modelNamePlural := $table.Name | plural | titleCase -}}
{{- $modelNameCamel := $tableNameSingular | camelCase}}
search{{$modelNamePlural}}(
  sinceID: ID
  pageNumber: Int
  pageSize: Int
  input: Search{{$modelName}}Input
): {{$modelNamePlural}}Collection!

{{$modelNameCamel}}ByID(
  id: ID!
): {{$modelName}}!
{{end}}
sqlboiler2other*/
