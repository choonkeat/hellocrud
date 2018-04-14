DBTYPE = postgres
DEBUG  = 1

run: generate
	env DEBUG=$(DEBUG) DATABASE_URL=$(DATABASE_URL) go run example/main.go

generate: dbmigrate
	# 1. setup toml to let `sqlboiler` retrieve schema from db
	go run cmd/url2toml/main.go -url "$(DATABASE_URL)" > sqlboiler.toml
	# 2. generate db orm
	sqlboiler --output example/dbmodel --pkgname dbmodel --schema app $(DBTYPE)
	# 2. generate graphql types and resolvers
	sqlboiler --output example/graph   --pkgname graph   --schema app --basedir sqlboiler/graph $(DBTYPE)
	# 3. clean up generated go code
	goimports -w example/*.go example/graph/*.go example/dbmodel/*.go

dbmigrate:
	# https://github.com/mattes/migrate/blob/master/cli/README.md
	[[ -n "$(DATABASE_URL)" ]] || (echo DATABASE_URL required; exit 1)
	migrate -path example/db/migrations -database $(DATABASE_URL) up
