{{- $tableNameSingular := .Table.Name | singular -}}
{{- $modelName := $tableNameSingular | titleCase -}}
{{- $modelNameCamel := $tableNameSingular | camelCase}}
{{- $pkColDefs := sqlColDefinitions .Table.Columns .Table.PKey.Columns}}

// {{$modelName}}sCollection is the struct representing a collection of GraphQL types
type {{$modelName}}sCollection struct {
	nodes []{{$modelName}}
	// future meta data goes here, e.g. count
}

// Nodes returns the list of GraphQL types
func (c {{$modelName}}sCollection) Nodes(ctx context.Context) []{{$modelName}} {
	return c.nodes
}

// All{{$modelName}}s retrieves all {{$modelName}}
func (r *Resolver) All{{$modelName}}s(ctx context.Context, args struct {
	Since    *graphql.ID
	PageSize int32
}) ({{$modelName}}sCollection, error) {
	result := {{$modelName}}sCollection{}
	mods := []qm.QueryMod{qm.Limit(int(args.PageSize))}
	if args.Since != nil {
		s := string(*args.Since)
		i, err := strconv.ParseInt(s, 10, 64)
		if err != nil {
			return result, err
		}
		mods = append(mods, qm.Offset(int(i)))
	}
	slice, err := dbmodel.{{$modelName}}s(r.db, mods...).All()
	if err != nil {
		return result, errors.Wrapf(err, "all{{$modelName}}s(%#v)", args)
	}
	for _, m := range slice {
		result.nodes = append(result.nodes, {{$modelName}}{model: *m, db: r.db})
	}

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

	m, err := dbmodel.Find{{$modelName}}(r.db, id)
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