DBTYPE = postgres
DEBUG  = 1

run: dbmigrate
	env DEBUG=$(DEBUG) DATABASE_URL=$(DATABASE_URL) go run cmd/server/main.go

generate: dbmigrate generate-golang generate-graphql-schema generate-js

generate-golang: dbenv
	# 2. generate db orm
	sqlboiler --output dbmodel --pkgname dbmodel --schema app $(DBTYPE)
	# 3. generate graphql types and resolvers
	sqlboiler --output graph   --pkgname graph   --schema app --basedir sqlboiler/graph $(DBTYPE)
	# 4. clean up generated go code
	goimports -w graph/*.go dbmodel/*.go

generate-graphql-schema: dbenv
	sqlboiler --output graph/schema --pkgname schema --schema app --basedir sqlboiler/graphqlschema $(DBTYPE)
	go run cmd/sqlboiler2other/main.go -basedir graph/schema -ext graphql

generate-js: dbenv
	# 5. generate react+apollo crud
	sqlboiler --output ../js/src   --pkgname js   --schema app --basedir sqlboiler/js $(DBTYPE)
	# 5a. clean up generated js code; sqlboiler only generates `.go`
	# rm -f ../js/src/*js
	go run cmd/sqlboiler2other/main.go -basedir ../js/src -ext js

dbmigrate:
	# https://github.com/mattes/migrate/blob/master/cli/README.md
	[[ -n "$(DATABASE_URL)" ]] || (echo DATABASE_URL required; exit 1)
	migrate -path db/migrations -database $(DATABASE_URL) up

dbenv:
	# 1. setup toml to let `sqlboiler` retrieve schema from db
	go run cmd/url2toml/main.go -url "$(DATABASE_URL)" > sqlboiler.toml
