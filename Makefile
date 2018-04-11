DBTYPE=postgres
DEBUG=1
DATABASE_URL=postgres://postgres:postgres@127.0.0.1/hellocrud_development

run:
	make graphql web -j 2

graphql: generate
	env DEBUG=$(DEBUG) DATABASE_URL=$(DATABASE_URL)?sslmode=disable go run golang/example/main.go

web: js/node_modules
	cd js; yarn start

js/node_modules:
	cd js; yarn

setupdb:
	psql $(DATABASE_URL) < golang/example/schema.sql

generate:
	# for db
	sqlboiler --output golang/example/dbmodel --pkgname dbmodel --schema app $(DBTYPE)
	# for graphql
	sqlboiler --output golang/example/graph   --pkgname graph   --schema app --basedir golang/sqlboiler $(DBTYPE)
	goimports -w golang/example/*.go golang/example/graph/*.go golang/example/dbmodel/*.go
