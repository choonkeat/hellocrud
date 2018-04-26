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

// queryModOffset returns an SQLBoiler QueryMod offset based on the argument
func queryModOffset(offset *graphql.ID) (qm.QueryMod, error) { 
  if offset == nil {
    return qm.Offset(0), nil
  }

  s := string(*offset)
  i, err := strconv.ParseInt(s, 10, 64)
  if err != nil {
    return nil, err
  }
  return qm.Offset(int(i)), nil
}
