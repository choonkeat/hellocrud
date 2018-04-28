const (
  // defaultPageSize is used in SearchXxx query methods `args.PageSize`
  defaultPageSize = 25
)

// QueryModPagination returns SQLBoiler QueryMods for pagination
// Supports limit-offset and keyset pagination techniques based on the arguments provided
//
// Limit-offset is used to paginate arbitrary queries.
// Please note that there are performance and inconsistency implications when using this technique.
// Sample:
// `QueryModPagination(nil, 5, 25)`
// Retrieves page 5 (from 125 - 150), using default order
//
// Keyset pagination is used to paginate ordered queries (by indexed column - ID)
// Typically used if performance and page result consistency is important.
// Sample:
// `QueryModPagination("123", nil, 25)`
// Retrieves all next 25 records *after* ID 123, ordered by ID
//
// Note: If both sinceID and pageNum is provided, sinceID (keyset pagination) will be used.
// Reference: https://www.citusdata.com/blog/2016/03/30/five-ways-to-paginate/
func QueryModPagination(sinceID *graphql.ID, pageNum, pageSize *int32) []qm.QueryMod {
  mods := []qm.QueryMod{}

  // Page size
  limit := defaultPageSize // Default page size
	if pageSize != nil {
		limit = int(*pageSize)
	}
  mods = append(mods, qm.Limit(limit))

  // Keyset pagination
  if sinceID != nil {
    // Parse ID
    s := string(*sinceID)
    id, err := strconv.ParseInt(s, 10, 64)
    if err != nil {
      return mods
    }

    // Add ID condition
    mods = append(mods,
      qm.And("id > ?", id),
      qm.OrderBy("id"),
    )
  } else if pageNum != nil {
    // Get offset based on page number and page size
    offset := int(*pageNum) * limit
    mods = append(mods, qm.Offset(offset))
  }

  return mods
}

// QueryModSearch returns a list of search QueryMod based on the struct values
func QueryModSearch(input interface{}) []qm.QueryMod {
  mods := []qm.QueryMod{}
  if reflect.ValueOf(input).IsNil() {
    return mods
  }
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
