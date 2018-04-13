# Summary

This repo is a big code generator

- Sample GraphQL backend (generated code) https://github.com/choonkeat/hellocrud/tree/master/golang/example/graph ([using custom sqlboiler templates](https://github.com/choonkeat/hellocrud/tree/master/golang/sqlboiler))
- Sample React CRUD (generated code) https://github.com/choonkeat/hellocrud/blob/master/js/src/thing.js (using the web app at http://localhost:3000 and copy-paste)

# Getting started (Docker)

```
docker-compose up
```

once you see

```
graphql_1   | 2018/04/13 05:16:44 Listening at :5000 ...
web_1       | You can now view hellocrud-js in the browser.
web_1       |
web_1       |   Local:            http://localhost:3000/
web_1       |   On Your Network:  http://172.19.0.2:3000/
web_1       |
web_1       | Note that the development build is not optimized.
web_1       | To create a production build, use yarn build.
```


- React CRUD generating app http://localhost:3000/
- GraphiQL interface http://localhost:5000/graphiql
- GraphQL endpoint http://localhost:5000/graphql

# Getting started (Development)

Setup the db (see `example.sql`) and generate the graphql server code

```
make setupdb generate
```

Start the graphql server and reactjs app

```
make run
```

# Combining

### Back-end
- GraphQL https://graphql.org/
- Go GraphQL https://github.com/graph-gophers/graphql-go
- Go ORM https://github.com/volatiletech/sqlboiler
- Go DB migration https://github.com/mattes/migrate/blob/master/cli/README.md

### Front-end
- Javascript form https://github.com/final-form/final-form
- Javascript GraphQL https://www.apollographql.com/docs/react/
- React https://reactjs.org/
