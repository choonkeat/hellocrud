{{- $dot := . -}}
{{- $tableNameSingular := .Table.Name | singular -}}
{{- $modelName := $tableNameSingular | titleCase -}}
{{- $modelNamePlural := .Table.Name | plural | titleCase -}}
{{- $modelNameCamel := $tableNameSingular | camelCase}}
{{- $pkColDefs := sqlColDefinitions .Table.Columns .Table.PKey.Columns}}

// Search{{$modelNamePlural}} retrieves {{$modelNamePlural}} based on the provided search parameters
func (r *Resolver) Search{{$modelNamePlural}}(ctx context.Context, args struct {
	PageNumber *int32
	PageSize *int32
	Input *search{{$modelName}}Input
}) ({{$modelNamePlural}}Collection, error) {
	result := {{$modelNamePlural}}Collection{}

	mods := []qm.QueryMod{
		// TODO: Add eager loading based on requested fields
		{{/* Add eager loaders on FK relationships */}}
		{{- range .Table.FKeys -}}
		{{- $txt := txtsFromFKey $dot.Tables $dot.Table . -}}
		qm.Load("{{$txt.Function.Name}}"),
		{{- end -}}
		{{/* Add eager loaders on all to one relationships */}}
		{{- range .Table.ToOneRelationships -}}
		{{- $txt := txtsFromOneToOne $dot.Tables $dot.Table . -}}
		qm.Load("{{$txt.Function.Name}}"),
		{{- end -}}
		{{/* Add eager loaders on all to many relationships */}}
		{{- range .Table.ToManyRelationships -}}
		{{- $txt := txtsFromToMany $dot.Tables $dot.Table . -}}
		qm.Load("{{$txt.Function.Name}}"),
		{{- end }}
	}

	// Pagination
	mods = append(mods, QueryModPagination(args.PageNumber, args.PageSize)...)

	// Search input
	mods = append(mods, QueryModSearch(args.Input)...)
	
	// Retrieve model/s based on search criteria
	slice, err := dbmodel.{{$modelNamePlural}}(r.db, mods...).All()
	if err != nil {
		return result, errors.Wrapf(err, "search{{$modelNamePlural}}(%#v)", args)
	}

	// Convert to GraphQL type resolver
	result = New{{$modelNamePlural}}Collection(r.db, slice)

	return result, nil
}

// {{$modelName}}ByID retrieves {{$modelName}} by ID
func (r *Resolver) {{$modelName}}ByID(ctx context.Context, args struct {
	ID graphql.ID
}) ({{$modelName}}, error) {
	result := {{$modelName}}{}
	i, err := strconv.ParseInt(string(args.ID), 10, 64)
	if err != nil {
		return result, errors.Wrapf(err, "{{$modelName}}ByID(%#v)", args)
	}

	{{- range $column := $pkColDefs -}}
	{{- if eq $column.Type "int"}}
	id := int(i)
	{{- else if eq $column.Type "int16"}}
	id := int16(i)
	{{- else if eq $column.Type "int64"}}
	id := int64(i)
	{{- end -}}
	{{- end}}

	mods := []qm.QueryMod{
		qm.Where("id = ?", id),
		// TODO: Add eager loading based on requested fields
		{{/* Add eager loaders on FK relationships */}}
		{{- range .Table.FKeys -}}
		{{- $txt := txtsFromFKey $dot.Tables $dot.Table . -}}
		qm.Load("{{$txt.Function.Name}}"),
		{{- end -}}
		{{/* Add eager loaders on all to one relationships */}}
		{{- range .Table.ToOneRelationships -}}
		{{- $txt := txtsFromOneToOne $dot.Tables $dot.Table . -}}
		qm.Load("{{$txt.Function.Name}}"),
		{{- end -}}
		{{/* Add eager loaders on all to many relationships */}}
		{{- range .Table.ToManyRelationships -}}
		{{- $txt := txtsFromToMany $dot.Tables $dot.Table . -}}
		qm.Load("{{$txt.Function.Name}}"),
		{{- end -}}
	}

	m, err := dbmodel.{{$modelNamePlural}}(r.db, mods...).One()
	if err != nil {
		return result, errors.Wrapf(err, "{{$modelName}}ByID(%#v)", args)
	} else if m == nil {
		return result, errors.New("not found")
	}
	return {{$modelName}}{model: *m, db: r.db}, nil
}

// Create{{$modelName}} creates a {{$modelName}} based on the provided input
func (r *Resolver) Create{{$modelName}}(ctx context.Context, args struct {
	Input create{{$modelName}}Input
}) ({{$modelName}}, error) {
	result := {{$modelName}}{}
	m := dbmodel.{{$modelName}}{

	}
	data, err := json.Marshal(args.Input)
	if err != nil {
		return result, errors.Wrapf(err, "json.Marshal(%#v)", args.Input)
	}
	if err = json.Unmarshal(data, &m); err != nil {
		return result, errors.Wrapf(err, "json.Unmarshal(%s)", data)
	}

	if err := m.Insert(r.db); err != nil {
		return result, errors.Wrapf(err, "create{{$modelName}}(%#v)", m)
	}
	return {{$modelName}}{model: m, db: r.db}, nil
}

// Update{{$modelName}}ByID updates a {{$modelName}} based on the provided ID and input
func (r *Resolver) Update{{$modelName}}ByID(ctx context.Context, args struct {
	ID    graphql.ID
	Input update{{$modelName}}Input
}) ({{$modelName}}, error) {
	result := {{$modelName}}{}
	i, err := strconv.ParseInt(string(args.ID), 10, 64)
	if err != nil {
		return result, errors.Wrapf(err, "{{$modelName}}ByID(%#v)", args)
	}

	{{- range $column := $pkColDefs -}}
	{{- if eq $column.Type "int"}}
	id := int(i)
	{{- else if eq $column.Type "int16"}}
	id := int16(i)
	{{- else if eq $column.Type "int64"}}
	id := int64(i)
	{{- end -}}
	{{- end}}

	m, err := dbmodel.Find{{$modelName}}(r.db, id)
	if err != nil {
		return result, errors.Wrapf(err, "update{{$modelName}}ByID(%#v)", args)
	} else if m == nil {
		return result, errors.New("not found")
	}
	data, err := json.Marshal(args.Input)
	if err != nil {
		return result, errors.Wrapf(err, "json.Marshal(%#v)", args.Input)
	}
	if err = json.Unmarshal(data, &m); err != nil {
		return result, errors.Wrapf(err, "json.Unmarshal(%s)", data)
	}

	if err := m.Update(r.db); err != nil {
		return result, errors.Wrapf(err, "update{{$modelName}}(%#v)", m)
	}
	return {{$modelName}}{model: *m, db: r.db}, nil
}

// Delete{{$modelName}}ByID deletes a {{$modelName}} based on the provided ID
func (r *Resolver) Delete{{$modelName}}ByID(ctx context.Context, args struct {
	ID graphql.ID
}) ({{$modelName}}, error) {
	result := {{$modelName}}{}
	i, err := strconv.ParseInt(string(args.ID), 10, 64)
	if err != nil {
		return result, errors.Wrapf(err, "{{$modelName}}ByID(%#v)", args)
	}

	{{- range $column := $pkColDefs -}}
	{{- if eq $column.Type "int"}}
	id := int(i)
	{{- else if eq $column.Type "int16"}}
	id := int16(i)
	{{- else if eq $column.Type "int64"}}
	id := int64(i)
	{{- end -}}
	{{- end}}

	m, err := dbmodel.Find{{$modelName}}(r.db, id)
	if err != nil {
		return result, errors.Wrapf(err, "update{{$modelName}}ByID(%#v)", args)
	} else if m == nil {
		return result, errors.New("not found")
	}
	if err := m.Delete(r.db); err != nil {
		return result, errors.Wrapf(err, "delete{{$modelName}}ByID(%#v)", m)
	}
	return {{$modelName}}{model: *m, db: r.db}, nil
}
