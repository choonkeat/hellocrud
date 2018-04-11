// Resolver is the root GraphQL resolver
type Resolver struct {
	db boil.Executor
}

// NewResolver returns a new root GraphQL resolver
func NewResolver(databaseURL string) (*Resolver, error) {
	url, err := url.Parse(databaseURL)
	if err != nil {
		return nil, errors.Wrapf(err, "unable to parse DATABASE_URL")
	}
	db, err := sql.Open(url.Scheme, url.String())
	if err != nil {
		return nil, errors.Wrapf(err, "unable to connect to DATABASE_URL")
	}

	boil.DebugMode = (os.Getenv("DEBUG") != "")
	return &Resolver{db: db}, nil
}
