DBTYPE=postgres
DEBUG=1
DATABASE_URL=postgres://postgres:postgres@127.0.0.1/hellocrud_development

all:
	make graphql web -j 2

graphql: generate
	env DEBUG=$(DEBUG) DATABASE_URL=$(DATABASE_URL)?sslmode=disable go run golang/cmd/server/main.go

web:
	cd js; yarn start

generate:
	sqlboiler --output golang/dbmodel --pkgname dbmodel --schema app $(DBTYPE)
	sqlboiler --basedir golang/sqlboiler --output golang/graph --pkgname graph --schema app $(DBTYPE)
	goimports -w golang/graph/*.go golang/dbmodel/*.go
