const (
  // defaultPageSize is used in AllXxx query methods `args.PageSize`
  defaultPageSize = 25
)


// queryModPageSize returns an SQLBoiler QueryMod limit based on the argument
func queryModPageSize(pageSize *int) qm.QueryMod {
  l := defaultPageSize // Default page size
	if pageSize != nil {
		l = *pageSize
	}
  return qm.Limit(l)
}
