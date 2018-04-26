{{- $dot := . -}}
{{- $tableNameSingular := .Table.Name | singular -}}
{{- $modelName := $tableNameSingular | titleCase -}}
{{- $modelNamePlural := .Table.Name | plural | titleCase -}}
{{- $modelNameCamel := $tableNameSingular | camelCase -}}
{{- $pkColNames := .Table.PKey.Columns -}}
{{- $fkColDefs := .Table.FKeys -}}

// SchemaType{{$modelName}} is the GraphQL schema type for {{$modelName}}
var SchemaType{{$modelName}} = `
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
`

// New{{$modelName}} returns a new {{$modelName}} instance
func New{{$modelName}}(db boil.Executor, model dbmodel.{{$modelName}}) {{$modelName}} {
	return {{$modelName}}{
		model: model, 
		db: db,
	}
}

// New{{$modelNamePlural}}Collection returns a new {{$modelNamePlural}}Collection instance
func New{{$modelNamePlural}}Collection(nodes []{{$modelName}}) {{$modelNamePlural}}Collection {
	return {{$modelNamePlural}}Collection{
		nodes: nodes,
	}
}

// {{$modelName}} is an object to back GraphQL type
type {{$modelName}} struct {
  model dbmodel.{{$modelName}}
  db    boil.Executor
}

// GraphQL friendly getters
{{range $column := .Table.Columns }}
{{- if containsAny $pkColNames $column.Name }}
// RowID is the {{$modelName}} GUID
func (o {{$modelName}}) RowID() string {
  return fmt.Sprintf("{{$modelName}}%d", o.model.{{titleCase $column.Name}}) // {{$column.Type}}
}

// {{titleCase $column.Name}} is the {{$modelName}} {{$column.Name}}
func (o {{$modelName}}) {{titleCase $column.Name}}() graphql.ID {
  return graphql.ID(fmt.Sprintf("%d", o.model.{{titleCase $column.Name}})) // {{$column.Type}}
}
{{- else if eq $column.Type "[]byte" }}
// {{titleCase $column.Name}} is the {{$modelName}} {{$column.Name}}
func (o {{$modelName}}) {{titleCase $column.Name}}() []byte {
  return o.model.{{titleCase $column.Name}} // {{$column.Type}}
}
{{- else if eq $column.Type "bool" }}
// {{titleCase $column.Name}} is the {{$modelName}} {{$column.Name}}
func (o {{$modelName}}) {{titleCase $column.Name}}() bool {
  return o.model.{{titleCase $column.Name}} // {{$column.Type}}
}
{{- else if eq $column.Type "float32" }}
// {{titleCase $column.Name}} is the {{$modelName}} {{$column.Name}}
func (o {{$modelName}}) {{titleCase $column.Name}}() float64 {
  return float64(o.model.{{titleCase $column.Name}}) // {{$column.Type}}
}
{{- else if eq $column.Type "float64" }}
// {{titleCase $column.Name}} is the {{$modelName}} {{$column.Name}}
func (o {{$modelName}}) {{titleCase $column.Name}}() float64 {
  return o.model.{{titleCase $column.Name}} // {{$column.Type}}
}
{{- else if eq $column.Type "int" }}
// {{titleCase $column.Name}} is the {{$modelName}} {{$column.Name}}
func (o {{$modelName}}) {{titleCase $column.Name}}() int32 {
  return int32(o.model.{{titleCase $column.Name}}) // {{$column.Type}}
}
{{- else if eq $column.Type "int16" }}
// {{titleCase $column.Name}} is the {{$modelName}} {{$column.Name}}
func (o {{$modelName}}) {{titleCase $column.Name}}() int32 {
  return int32(o.model.{{titleCase $column.Name}}) // {{$column.Type}}
}
{{- else if eq $column.Type "int64" }}
// {{titleCase $column.Name}} is the {{$modelName}} {{$column.Name}}
func (o {{$modelName}}) {{titleCase $column.Name}}() Int64 {
  return Int64(fmt.Sprintf("%d", o.model.{{titleCase $column.Name}})) // {{$column.Type}}
}
{{- else if eq $column.Type "null.Bool" }}Int64(fmt.Sprintf("%d", o.model.{{titleCase $column.Name}})) // {{$column.Type}}
// {{titleCase $column.Name}} is the {{$modelName}} {{$column.Name}}
func (o {{$modelName}}) {{titleCase $column.Name}}() *bool {
  return o.model.{{titleCase $column.Name}}.Ptr() // {{$column.Type}}
}
{{- else if eq $column.Type "null.Byte" }}
// {{titleCase $column.Name}} is the {{$modelName}} {{$column.Name}}
func (o {{$modelName}}) {{titleCase $column.Name}}() *byte {
  return o.model.{{titleCase $column.Name}}.Ptr() // {{$column.Type}}
}
{{- else if eq $column.Type "null.Bytes" }}
// {{titleCase $column.Name}} is the {{$modelName}} {{$column.Name}}
func (o {{$modelName}}) {{titleCase $column.Name}}() *[]byte {
  return o.model.{{titleCase $column.Name}}.Ptr() // {{$column.Type}}
}
{{- else if eq $column.Type "null.Float64" }}
// {{titleCase $column.Name}} is the {{$modelName}} {{$column.Name}}
func (o {{$modelName}}) {{titleCase $column.Name}}() *float64 {
  return o.model.{{titleCase $column.Name}}.Ptr() // {{$column.Type}}
}
{{- else if eq $column.Type "null.Int" }}
// {{titleCase $column.Name}} is the {{$modelName}} {{$column.Name}}
func (o {{$modelName}}) {{titleCase $column.Name}}() *int32 {
  if !o.model.{{titleCase $column.Name}}.Valid {
    return nil
  }
  x := int32(o.model.{{titleCase $column.Name}}.Int) // {{$column.Type}}
  return &x
}
{{- else if eq $column.Type "null.Int16" }}
// {{titleCase $column.Name}} is the {{$modelName}} {{$column.Name}}
func (o {{$modelName}}) {{titleCase $column.Name}}() *int32 {
  if !o.model.{{titleCase $column.Name}}.Valid {
    return nil
  }
  x := int32(o.model.{{titleCase $column.Name}}.Int16) // {{$column.Type}}
  return &x
}
{{- else if eq $column.Type "null.Int64" }}
// {{titleCase $column.Name}} is the {{$modelName}} {{$column.Name}}
func (o {{$modelName}}) {{titleCase $column.Name}}() *Int64 {
  if !o.model.{{titleCase $column.Name}}.Valid {
    return nil
  }
  x := Int64(fmt.Sprintf("%d", o.model.{{titleCase $column.Name}}.Int64)) // {{$column.Type}}
  return &x
}
{{- else if eq $column.Type "null.JSON" }}
// {{titleCase $column.Name}} is the {{$modelName}} {{$column.Name}}
func (o {{$modelName}}) {{titleCase $column.Name}}() *[]byte {
  return o.model.{{titleCase $column.Name}}.Ptr() // {{$column.Type}}
}
{{- else if eq $column.Type "null.String" }}
// {{titleCase $column.Name}} is the {{$modelName}} {{$column.Name}}
func (o {{$modelName}}) {{titleCase $column.Name}}() *string {
  return o.model.{{titleCase $column.Name}}.Ptr() // {{$column.Type}}
}
{{- else if eq $column.Type "null.Time" }}
// {{titleCase $column.Name}} is the {{$modelName}} {{$column.Name}}
func (o {{$modelName}}) {{titleCase $column.Name}}() *graphql.Time {
  if o.model.{{titleCase $column.Name}}.Valid {
		return &graphql.Time{Time: o.model.{{titleCase $column.Name}}.Time}
	}
	return nil // {{$column.Type}}
}
{{- else if eq $column.Type "string" }}
// {{titleCase $column.Name}} is the {{$modelName}} {{$column.Name}}
func (o {{$modelName}}) {{titleCase $column.Name}}() string {
  return o.model.{{titleCase $column.Name}} // {{$column.Type}}
}
{{- else if eq $column.Type "time.Time" }}
// {{titleCase $column.Name}} is the {{$modelName}} {{$column.Name}}
func (o {{$modelName}}) {{titleCase $column.Name}}() graphql.Time {
  return graphql.Time{Time: o.model.{{titleCase $column.Name}}} // {{$column.Type}}
}
{{- else if eq $column.Type "types.Byte" }}
// {{titleCase $column.Name}} is the {{$modelName}} {{$column.Name}}
func (o {{$modelName}}) {{titleCase $column.Name}}() string {
  return o.model.{{titleCase $column.Name}}.String() // {{$column.Type}}
}
{{- else if eq $column.Type "types.JSON" }}
// {{titleCase $column.Name}} is the {{$modelName}} {{$column.Name}}
func (o {{$modelName}}) {{titleCase $column.Name}}() string {
  return o.model.{{titleCase $column.Name}}.String() // {{$column.Type}}
}
{{- end -}}
{{- end }}

{{/* Add resolvers to FK relationships */}}
{{range .Table.FKeys -}}
{{- $txt := txtsFromFKey $dot.Tables $dot.Table . -}}
// {{$txt.ForeignTable.NameGo}} pointed to by the foreign key
func (o {{$modelName}}) {{$txt.ForeignTable.NameGo}}() *{{$txt.ForeignTable.NameGo}} {
  if o.model.R == nil || o.model.R.{{$txt.Function.Name}} == nil {
    return nil
  }
  return &{{$txt.ForeignTable.NameGo}}{
		model: *o.model.R.{{$txt.Function.Name}},
		db:    o.db,
	}
}
{{end -}}

{{/* Add resolvers to one relationships */}}
{{range .Table.ToOneRelationships -}}
{{- $txt := txtsFromOneToOne $dot.Tables $dot.Table . -}}
// {{$txt.ForeignTable.NameGo}} pointed to by the foreign key
func (o {{$modelName}}) {{$txt.ForeignTable.NameGo}}() *{{$txt.ForeignTable.NameGo}} {
  if o.model.R == nil || o.model.R.{{$txt.Function.Name}} == nil {
    return nil
  }
  return &{{$txt.ForeignTable.NameGo}}{
		model: *o.model.R.{{$txt.Function.Name}},
		db:    o.db,
	}
}
{{end -}}

{{/* Add resolvers to many relationships */}}
{{range .Table.ToManyRelationships -}}
{{- $txt := txtsFromToMany $dot.Tables $dot.Table . -}}
{{- $toManyModelNamePlural := .ForeignTable | plural | titleCase -}}
// {{$toManyModelNamePlural}} returns the list of {{$toManyModelNamePlural}} that has a foreign key pointing to {{$modelName}}
func (o {{$modelName}}) {{$toManyModelNamePlural}}() *{{$toManyModelNamePlural}}Collection {
  if o.model.R == nil || o.model.R.{{$txt.Function.Name}} == nil {
    return nil
  }
  
  result := &{{$toManyModelNamePlural}}Collection{}
  for _, it := range o.model.R.{{$txt.Function.Name}} {
		result.nodes = append(result.nodes, {{$txt.ForeignTable.NameGo}}{model: *it, db: o.db})
	}
  return result
}
{{end -}}

// {{$modelNamePlural}}Collection is the struct representing a collection of GraphQL types
type {{$modelNamePlural}}Collection struct {
	nodes []{{$modelName}}
	// future meta data goes here, e.g. count
}

// Nodes returns the list of GraphQL types
func (c {{$modelNamePlural}}Collection) Nodes(ctx context.Context) []{{$modelName}} {
	return c.nodes
}
