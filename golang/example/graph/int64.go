// Code generated by SQLBoiler (https://github.com/volatiletech/sqlboiler). DO NOT EDIT.
// This file is meant to be re-generated in place and/or deleted at any time.

package graph

import (
	"errors"
	"strconv"
)

// Int64 represents a custom GraphQL "Int64" scalar type
// Implements graphql.Unmarshaler
type Int64 string

// ImplementsGraphQLType returns the GraphQL type name
func (Int64) ImplementsGraphQLType(name string) bool {
	return name == "Int64"
}

// UnmarshalGraphQL unmarshals the GraphQL type
func (i *Int64) UnmarshalGraphQL(input interface{}) error {
	var err error
	switch input := input.(type) {
	case string:
		*i = Int64(input)
	case int64:
		*i = Int64(strconv.FormatInt(int64(input), 10))
	default:
		err = errors.New("wrong type: expecting string format for Int64 types")
	}
	return err
}

// MarshalJSON implements JSON marshalling
func (i Int64) MarshalJSON() ([]byte, error) {
	return []byte(i), nil
}
