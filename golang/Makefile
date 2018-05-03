DBTYPE = postgres
DEBUG  = 1

generate-and-run: generate run

run: dbmigrate
	env DEBUG=$(DEBUG) DATABASE_URL=$(DATABASE_URL) go run example/main.go

generate: dbmigrate generate-golang generate-graphql-schema generate-js

generate-golang: dbenv
	# 2. generate db orm
	sqlboiler --output example/dbmodel --pkgname dbmodel --schema app $(DBTYPE)
	# 3. generate graphql types and resolvers
	sqlboiler --output example/graph   --pkgname graph   --schema app --basedir sqlboiler/graph $(DBTYPE)
	# 4. clean up generated go code
	goimports -w example/*.go example/graph/*.go example/dbmodel/*.go

generate-graphql-schema: dbenv
	sqlboiler --output example/graph/schema --pkgname schema --schema app --basedir sqlboiler/graphqlschema $(DBTYPE)
	go run cmd/sqlboiler2other/main.go -basedir example/graph/schema -ext graphql

generate-js: dbenv
	# 5. generate react+apollo crud
	sqlboiler --output ../js/src   --pkgname js   --schema app --basedir sqlboiler/js $(DBTYPE)
	# 5a. clean up generated js code; sqlboiler only generates `.go`
	# rm -f ../js/src/*js
	go run cmd/sqlboiler2js/main.go ../js/src

dbmigrate:
	# https://github.com/mattes/migrate/blob/master/cli/README.md
	[[ -n "$(DATABASE_URL)" ]] || (echo DATABASE_URL required; exit 1)
	migrate -path example/db/migrations -database $(DATABASE_URL) up

dbenv:
	# 1. setup toml to let `sqlboiler` retrieve schema from db
	go run cmd/url2toml/main.go -url "$(DATABASE_URL)" > sqlboiler.toml
