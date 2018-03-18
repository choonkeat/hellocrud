{{- $tableNameSingular := .Table.Name | singular -}}
{{- $modelName := $tableNameSingular | titleCase -}}
{{- $modelNameCamel := $tableNameSingular | camelCase -}}

// {{$modelName}} is an object to back GraphQL type
type {{$modelName}} struct {
  model dbmodel.{{$modelName}}
  db    boil.Executor
}

// GraphQL friendly getters
{{range $column := .Table.Columns }}
{{- if eq $column.Name "id" }}
func (o {{$modelName}}) Row{{titleCase $column.Name}}() string {
  return fmt.Sprintf("{{$modelName}}%d", o.model.{{titleCase $column.Name}}) // {{$column.Type}}
}
func (o {{$modelName}}) {{titleCase $column.Name}}() graphql.ID {
  return graphql.ID(fmt.Sprintf("%d", o.model.{{titleCase $column.Name}})) // {{$column.Type}}
}
{{- else if eq $column.Type "[]byte" }}
func (o {{$modelName}}) {{titleCase $column.Name}}() []byte {
  return o.model.{{titleCase $column.Name}} // {{$column.Type}}
}
{{- else if eq $column.Type "bool" }}
func (o {{$modelName}}) {{titleCase $column.Name}}() bool {
  return o.model.{{titleCase $column.Name}} // {{$column.Type}}
}
{{- else if eq $column.Type "float32" }}
func (o {{$modelName}}) {{titleCase $column.Name}}() float64 {
  return float64(o.model.{{titleCase $column.Name}}) // {{$column.Type}}
}
{{- else if eq $column.Type "float64" }}
func (o {{$modelName}}) {{titleCase $column.Name}}() float64 {
  return o.model.{{titleCase $column.Name}} // {{$column.Type}}
}
{{- else if eq $column.Type "int" }}
func (o {{$modelName}}) {{titleCase $column.Name}}() int32 {
  return int32(o.model.{{titleCase $column.Name}}) // {{$column.Type}}
}
{{- else if eq $column.Type "int16" }}
func (o {{$modelName}}) {{titleCase $column.Name}}() int32 {
  return int32(o.model.{{titleCase $column.Name}}) // {{$column.Type}}
}
{{- else if eq $column.Type "int64" }}
func (o {{$modelName}}) {{titleCase $column.Name}}() int32 {
  return int32(o.model.{{titleCase $column.Name}}) // {{$column.Type}}
}
{{- else if eq $column.Type "null.Bool" }}
func (o {{$modelName}}) {{titleCase $column.Name}}() *bool {
  return o.model.{{titleCase $column.Name}}.Ptr() // {{$column.Type}}
}
{{- else if eq $column.Type "null.Byte" }}
func (o {{$modelName}}) {{titleCase $column.Name}}() *byte {
  return o.model.{{titleCase $column.Name}}.Ptr() // {{$column.Type}}
}
{{- else if eq $column.Type "null.Bytes" }}
func (o {{$modelName}}) {{titleCase $column.Name}}() *[]byte {
  return o.model.{{titleCase $column.Name}}.Ptr() // {{$column.Type}}
}
{{- else if eq $column.Type "null.Float64" }}
func (o {{$modelName}}) {{titleCase $column.Name}}() *float64 {
  return o.model.{{titleCase $column.Name}}.Ptr() // {{$column.Type}}
}
{{- else if eq $column.Type "null.Int" }}
func (o {{$modelName}}) {{titleCase $column.Name}}() *int32 {
  if !o.model.{{titleCase $column.Name}}.Valid {
    return nil
  }
  x := int32(o.model.{{titleCase $column.Name}}) // {{$column.Type}}
  return &x
}
{{- else if eq $column.Type "null.Int16" }}
func (o {{$modelName}}) {{titleCase $column.Name}}() *int32 {
  if !o.model.{{titleCase $column.Name}}.Valid {
    return nil
  }
  x := int32(o.model.{{titleCase $column.Name}}) // {{$column.Type}}
  return &x
}
{{- else if eq $column.Type "null.Int64" }}
func (o {{$modelName}}) {{titleCase $column.Name}}() *int64 {
  return o.model.{{titleCase $column.Name}}.Ptr() // {{$column.Type}}
}
{{- else if eq $column.Type "null.JSON" }}
func (o {{$modelName}}) {{titleCase $column.Name}}() *[]byte {
  return o.model.{{titleCase $column.Name}}.Ptr() // {{$column.Type}}
}
{{- else if eq $column.Type "null.String" }}
func (o {{$modelName}}) {{titleCase $column.Name}}() *string {
  return o.model.{{titleCase $column.Name}}.Ptr() // {{$column.Type}}
}
{{- else if eq $column.Type "null.Time" }}
func (o {{$modelName}}) {{titleCase $column.Name}}() *graphql.Time {
  if o.model.{{titleCase $column.Name}}.Valid {
		return &graphql.Time{Time: o.model.{{titleCase $column.Name}}.Time}
	}
	return nil // {{$column.Type}}
}
{{- else if eq $column.Type "string" }}
func (o {{$modelName}}) {{titleCase $column.Name}}() string {
  return o.model.{{titleCase $column.Name}} // {{$column.Type}}
}
{{- else if eq $column.Type "time.Time" }}
func (o {{$modelName}}) {{titleCase $column.Name}}() graphql.Time {
  return graphql.Time{Time: o.model.{{titleCase $column.Name}}.Time} // {{$column.Type}}
}
{{- else if eq $column.Type "types.Byte" }}
func (o {{$modelName}}) {{titleCase $column.Name}}() string {
  return o.model.{{titleCase $column.Name}}.String() // {{$column.Type}}
}
{{- else if eq $column.Type "types.JSON" }}
func (o {{$modelName}}) {{titleCase $column.Name}}() string {
  return o.model.{{titleCase $column.Name}}.String() // {{$column.Type}}
}
{{- end -}}
{{- end }}
