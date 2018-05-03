// Schema is the GraphQL schema
var Schema string

func init() {
	var query strings.Builder
	var mutation strings.Builder
	var subscriptions strings.Builder
	var schema strings.Builder

	matches, err := filepath.Glob("example/graph/schema/*.graphql")
	if err != nil {
		log.Fatalln(err)
	}

	for _, m := range matches {
		data, err := ioutil.ReadFile(m)
		if err != nil {
			log.Fatalln(err)
		}
		basename := filepath.Base(m)

		if strings.HasPrefix(basename, "query-") { // add your own `query-*.graphql` files
			query.Write(data)
		} else if strings.HasPrefix(basename, "mutation-") { // add your own `mutation-*.graphql` files
			mutation.Write(data)
		} else if strings.HasPrefix(basename, "subscription-") { // add your own `subscription-*.graphql` files
			subscriptions.Write(data)
		} else {
			schema.Write(data)
		}
	}

	Schema = `
    schema {
      query: Query
      mutation: Mutation
      subscription: Subscription
    }
    type Query {` + query.String() + `}
    type Mutation {` + mutation.String() + `}
    type Subscription {` + subscriptions.String() + `}
  ` + schema.String()

	graphql.MustParseSchema(Schema, &Resolver{})
}
