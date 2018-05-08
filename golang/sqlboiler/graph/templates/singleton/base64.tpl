import (
	"encoding/base64"
	"errors"
)

// Base64 represents a custom GraphQL "Base64" scalar type
// Implements graphql.Unmarshaler
type Base64 string

// ImplementsGraphQLType returns the GraphQL type name
func (Base64) ImplementsGraphQLType(name string) bool {
	return name == "Base64"
}

// UnmarshalGraphQL unmarshals the GraphQL type
func (i *Base64) UnmarshalGraphQL(input interface{}) error {
	var err error
	switch input := input.(type) {
	case string:
		*i = Base64(input)
	default:
		err = errors.New("wrong type: expecting string format for Base64 types")
	}
	return err
}

// MarshalJSON implements JSON marshalling
func (i Base64) MarshalJSON() ([]byte, error) {
	return []byte(i), nil
}

// ToGo converts the custom scalar type to Go type
func (i *Base64) ToGo() ([]byte, error) {
	return base64.StdEncoding.DecodeString(string(*i))
}
