package main

import (
	"io"
	"log"
	"net/http"
	"os"
	"path/filepath"
	"strings"

	"github.com/choonkeat/hellocrud/graph"
	graphql "github.com/graph-gophers/graphql-go"
	"github.com/graph-gophers/graphql-go/relay"

	_ "github.com/lib/pq"
)

func main() {
	r, err := graph.NewResolver(os.Getenv("DATABASE_URL"))
	if err != nil {
		log.Fatalln(err.Error())
	}
	graphqlHandler := &relay.Handler{
		Schema: graphql.MustParseSchema(graph.Schema, r),
	}
	graphqlHandler.Schema.ToJSON() // force panic if schema is barfed

	if os.Getenv("DEBUG") != "" {
		http.HandleFunc("/graphiql", func(w http.ResponseWriter, r *http.Request) {
			w.Write(graphiqlHTML)
		})
		http.HandleFunc("/graphql", allowCors(graphqlHandler))
	} else {
		http.Handle("/graphql", graphqlHandler)
	}

	http.HandleFunc("/", serveFilesWithDefault("js/build", "js/build/index.html"))

	addr := ":" + os.Getenv("PORT")
	if addr == ":" {
		addr = ":5000"
	}
	log.Println("Listening at", addr, "...")
	if err := http.ListenAndServe(addr, nil); err != nil {
		log.Fatal(err)
	}
}

var graphiqlHTML = []byte(`
<!DOCTYPE html>
<html>
	<head>
		<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/graphiql/0.10.2/graphiql.css" />
		<script src="https://cdnjs.cloudflare.com/ajax/libs/fetch/1.1.0/fetch.min.js"></script>
		<script src="https://cdnjs.cloudflare.com/ajax/libs/react/15.5.4/react.min.js"></script>
		<script src="https://cdnjs.cloudflare.com/ajax/libs/react/15.5.4/react-dom.min.js"></script>
		<script src="https://cdnjs.cloudflare.com/ajax/libs/graphiql/0.10.2/graphiql.js"></script>
	</head>
	<body style="width: 100%; height: 100%; margin: 0; overflow: hidden;">
		<div id="graphiql" style="height: 100vh;">Loading...</div>
		<script>
			function graphQLFetcher(graphQLParams) {
				return fetch("/graphql", {
					method: "post",
					body: JSON.stringify(graphQLParams),
					credentials: "include",
				}).then(function (response) {
					return response.text();
				}).then(function (responseBody) {
					try {
						return JSON.parse(responseBody);
					} catch (error) {
						return responseBody;
					}
				});
			}
			ReactDOM.render(
				React.createElement(GraphiQL, {fetcher: graphQLFetcher}),
				document.getElementById("graphiql")
			);
		</script>
	</body>
</html>
`)

func allowCors(handler http.Handler) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Access-Control-Allow-Origin", "*")
		w.Header().Set("Access-Control-Allow-Methods", "POST, GET, OPTIONS, PUT, DELETE")
		w.Header().Set("Access-Control-Allow-Headers", "Accept, Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization")
		if r.Method == "OPTIONS" {
			return
		}
		handler.ServeHTTP(w, r)
	}
}

func serveFilesWithDefault(staticDir, notfound string) http.HandlerFunc {
	uriPathMap := map[string]string{}
	filepath.Walk("js/build", func(path string, info os.FileInfo, err error) error {
		if info.IsDir() || path == notfound {
			return nil
		}
		uriPathMap[strings.TrimPrefix(path, staticDir)] = path
		return nil
	})
	return func(w http.ResponseWriter, r *http.Request) {
		path, ok := uriPathMap[r.RequestURI]
		if !ok {
			path = notfound
		}

		f, _ := os.Open(path)
		defer f.Close()
		io.Copy(w, f)
	}
}
