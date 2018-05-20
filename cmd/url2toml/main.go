package main

import (
	"flag"
	"fmt"
	"log"
	"net/url"
	"os"
	"strings"
	"text/template"
)

var toml = `
[{{ .Section }}]
{{- if .Url.User }}
  user={{ .Url.User.Username | printf "%q"}}
  pass={{ .Url.Password | printf "%q"}}
{{- end }}
  host={{ .Url.Hostname | printf "%q"}}
{{- if .Url.Port }}
  port={{ .Url.Port }}
{{- end }}
  dbname={{ .Url.RelativePath | printf "%q"}}
  {{- range $key, $values := .Url.Query }}
  {{- range $values }}
  {{ $key }}={{ . | printf "%q" }}
  {{- end }}
  {{- end }}
`

type customUrl struct {
	*url.URL
}

func (u customUrl) Password() string {
	if u.URL.User != nil {
		if s, ok := u.URL.User.Password(); ok {
			return s
		}
	}
	return ""
}

func (u customUrl) RelativePath() string {
	return strings.TrimPrefix(u.Path, "/")
}

func main() {
	var section string
	var rawurl string
	flag.StringVar(&section, "section", "", "name of toml section, e.g. [postgres]")
	flag.StringVar(&rawurl, "url", os.Getenv("DATABASE_URL"), "url to parse")
	flag.Parse()
	if rawurl == "" {
		flag.Usage()
		os.Exit(1)
	}

	uri, err := url.Parse(rawurl)
	if err != nil {
		log.Fatalln(err)
	}
	if section == "" {
		section = uri.Scheme
	}

	t := template.Must(template.New("toml").Parse(toml))
	err = t.Execute(os.Stdout, struct {
		Section string
		Url     customUrl
	}{
		Section: section,
		Url:     customUrl{URL: uri},
	})
	if err != nil {
		log.Fatal(err)
	}
	fmt.Println("")
}
