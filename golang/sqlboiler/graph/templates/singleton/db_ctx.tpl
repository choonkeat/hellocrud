func (r *Resolver) db(ctx context.Context) boil.Executor {
	return r.sqldb
}
