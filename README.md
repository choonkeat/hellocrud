# Summary

Uses [sqlboiler](https://github.com/volatiletech/sqlboiler) to generate [ORM](https://github.com/choonkeat/hellocrud/tree/master/dbmodel), [GraphQL backend](https://github.com/choonkeat/hellocrud/tree/master/graph), [React JS frontend](https://github.com/choonkeat/hellocrud/tree/master/js/src), and [Elm app](https://github.com/choonkeat/hellocrud/tree/master/elm/src) to CRUD against your [database schema](https://github.com/choonkeat/hellocrud/tree/master/db/migrations)

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

- Generated React app http://localhost:3000/
- Generated Elm app http://localhost:4000/
- Generated GraphQL endpoint http://localhost:5000/graphql
- GraphiQL interface http://localhost:5000/graphiql

### Omakase

- GraphQL https://graphql.org/
- Go GraphQL https://github.com/graph-gophers/graphql-go
- Go ORM builder https://github.com/volatiletech/sqlboiler
- Go DB migration https://github.com/mattes/migrate/blob/master/cli/README.md
- Javascript form https://github.com/final-form/final-form
- Javascript GraphQL https://www.apollographql.com/docs/react/
- React https://reactjs.org/
- Elm http://elm-lang.org/
  - [krisajenkins/remotedata](http://package.elm-lang.org/packages/krisajenkins/remotedata/4.5.0/RemoteData)
  - [NoRedInk/elm-decode-pipeline](http://package.elm-lang.org/packages/NoRedInk/elm-decode-pipeline/3.0.0/Json-Decode-Pipeline)
