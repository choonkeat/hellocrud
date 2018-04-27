const (
  // defaultPageSize is used in SearchXxx query methods `args.PageSize`
  defaultPageSize = 25
)

// QueryModPagination returns SQLBoiler QueryMods for pagination 
func QueryModPagination(pageNum, pageSize *int32) []qm.QueryMod { 
  // Page size
  limit := defaultPageSize // Default page size
	if pageSize != nil {
		limit = int(*pageSize)
	}

  // Page number
  if pageNum == nil || pageSize == nil {
    return []qm.QueryMod{qm.Limit(limit)}
  }

  offset := (int(*pageNum) * int(*pageSize))
  return []qm.QueryMod{qm.Limit(limit), qm.Offset(offset)}
}

// QueryModSearch returns a list of search QueryMod based on the struct values
func QueryModSearch(input interface{}) []qm.QueryMod {
  mods := []qm.QueryMod{}
  // Get reflect value
  v := reflect.ValueOf(input).Elem()
  // Iterate struct fields
  for i := 0; i < v.NumField(); i++ {
    field := v.Type().Field(i) // StructField
    value := v.Field(i) // Value
    if value.IsNil() || !value.IsValid() {
      // Skip if field is nil
      continue
    }

    // Get column name from tags
    column, hasColumnName := field.Tag.Lookup("json")
    // Skip if no DB definition
    if !hasColumnName {
      continue
    }

    operator := "="
    val := value.Elem().Interface()
    if dataType := field.Type.String(); (dataType == "string" || dataType == "*string") &&
      val.(string) != "" {
      operator = "LIKE"
      val = fmt.Sprintf("%%%s%%", val)
    }
    mods = append(mods, qm.And(fmt.Sprintf("%s %s ?", column, operator), val))
  }
  return mods
}
