DBTYPE = postgres
DEBUG  = 1

run: generate
	env DEBUG=$(DEBUG) DATABASE_URL=$(DATABASE_URL) go run example/main.go

generate: dbmigrate
	# setup toml
	go run cmd/url2toml/main.go -url "$(DATABASE_URL)" > sqlboiler.toml
	# for db
	sqlboiler --output example/dbmodel --pkgname dbmodel --schema app $(DBTYPE)
	# for graphql
	sqlboiler --output example/graph   --pkgname graph   --schema app --basedir sqlboiler $(DBTYPE)
	goimports -w example/*.go example/graph/*.go example/dbmodel/*.go

dbmigrate:
	# https://github.com/mattes/migrate/blob/master/cli/README.md
	[[ -n "$(DATABASE_URL)" ]] || (echo DATABASE_URL required; exit 1)
	migrate -path example/db/migrations -database $(DATABASE_URL) up
