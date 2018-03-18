{{- $tableNameSingular := .Table.Name | singular -}}
{{- $modelName := $tableNameSingular | titleCase -}}
{{- $modelNameCamel := $tableNameSingular | camelCase}}

type {{$modelName}}sCollection struct {
	nodes []{{$modelName}}
	// future meta data goes here, e.g. count
}

func (c {{$modelName}}sCollection) Nodes(ctx context.Context) []{{$modelName}} {
	return c.nodes
}

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

func (r *Resolver) {{$modelName}}ByID(ctx context.Context, args struct {
	ID graphql.ID
}) ({{$modelName}}, error) {
	result := {{$modelName}}{}
	i, err := strconv.ParseInt(string(args.ID), 10, 64)
	if err != nil {
		return result, errors.Wrapf(err, "{{$modelName}}ByID(%#v)", args)
	}

	m, err := dbmodel.Find{{$modelName}}(r.db, int(i))
	if err != nil {
		return result, errors.Wrapf(err, "{{$modelName}}ByID(%#v)", args)
	} else if m == nil {
		return result, errors.New("not found")
	}
	return {{$modelName}}{model: *m, db: r.db}, nil
}

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

func (r *Resolver) Update{{$modelName}}ByID(ctx context.Context, args struct {
	ID    graphql.ID
	Input update{{$modelName}}Input
}) ({{$modelName}}, error) {
	result := {{$modelName}}{}
	i, err := strconv.ParseInt(string(args.ID), 10, 64)
	if err != nil {
		return result, errors.Wrapf(err, "{{$modelName}}ByID(%#v)", args)
	}

	m, err := dbmodel.Find{{$modelName}}(r.db, int(i))
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

func (r *Resolver) Delete{{$modelName}}ByID(ctx context.Context, args struct {
	ID graphql.ID
}) ({{$modelName}}, error) {
	result := {{$modelName}}{}
	i, err := strconv.ParseInt(string(args.ID), 10, 64)
	if err != nil {
		return result, errors.Wrapf(err, "{{$modelName}}ByID(%#v)", args)
	}

	m, err := dbmodel.Find{{$modelName}}(r.db, int(i))
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
