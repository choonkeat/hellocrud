// Schema is the GraphQL schema
var Schema string

func init() {
	var query strings.Builder
	var mutation strings.Builder
	var subscription strings.Builder
	var schema strings.Builder

	matches, err := filepath.Glob("graph/schema/*.graphql")
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
			subscription.Write(data)
		} else {
			schema.Write(data)
		}
	}

	operationFields := []string{}
	operationTypes := []string{}
	// Query
	if strings.TrimSpace(query.String()) != "" {
		operationFields = append(operationFields, "query: Query")
		operationTypes = append(operationTypes, `type Query {`+query.String()+`}`)
	}
	// Mutation
	if strings.TrimSpace(mutation.String()) != "" {
		operationFields = append(operationFields, "mutation: Mutation")
		operationTypes = append(operationTypes, `type Mutation {`+mutation.String()+`}`)
	}
	// Subscription
	if strings.TrimSpace(subscription.String()) != "" {
		operationFields = append(operationFields, "subscription: Subscription")
		operationTypes = append(operationTypes, `type Subscription {`+subscription.String()+`}`)
	}

	Schema = `
		schema {` +
		strings.Join(operationFields, "\n") + // Operation fields associated to the types (i.e. query: Query, mutation: Mutation)
		`}` +
		strings.Join(operationTypes, "\n") + "\n" + // Operation types (i.e. type Query {}, type Mutation {})
		schema.String() // Other schema types

	ioutil.WriteFile("graph/schema.graphql", []byte(Schema), 0660)
	graphql.MustParseSchema(Schema, &Resolver{})
}
