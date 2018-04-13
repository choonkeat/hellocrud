# Docker

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

# Development

Setup the db (see `example.sql`) and generate the graphql server code

```
make setupdb generate
```

Start the graphql server and reactjs app

```
make run
```
