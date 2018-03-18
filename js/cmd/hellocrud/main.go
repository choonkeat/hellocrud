package main

import (
	"encoding/json"
	"flag"
	"io/ioutil"
	"log"
	"os"
	"strings"
	"text/template"
	"unicode"

	"github.com/jinzhu/inflection"
	"github.com/segmentio/go-camelcase"
)

func titleize(s string) string {
	if len(s) < 2 {
		return strings.ToUpper(s)
	}
	return strings.ToUpper(s[:1]) + s[1:]
}

func humanize(word string) string {
	var words []string
	var l int
	for s := titleize(camelcase.Camelcase(word)); s != ""; s = s[l:] {
		l = strings.IndexFunc(s[1:], unicode.IsUpper) + 1
		if l <= 0 {
			l = len(s)
		}
		words = append(words, s[:l])
	}
	return strings.Join(words, " ")
}

func main() {
	var (
		tableName       string
		columnNamesCSV  string
		railsTimestamps bool
	)
	flag.StringVar(&tableName, "table", "user", "postgresql table name")
	flag.StringVar(&columnNamesCSV, "columns", "id,rowId", "comma separated list of columns")
	flag.BoolVar(&railsTimestamps, "timestamps", false, "should we populate `created_at` and `updated_at` from reactjs")
	flag.Parse()

	columnNamesMap := map[string]string{
		"id":    "",
		"rowId": "",
	}
	for _, word := range strings.Split(columnNamesCSV, ",") {
		columnNamesMap[word] = humanize(word)
	}

	data, err := ioutil.ReadFile("templates/model.js")
	if err != nil {
		log.Fatalln(err)
	}

	funcMap := template.FuncMap{
		"ToTitle":    titleize,
		"ToHuman":    humanize,
		"ToCamel":    camelcase.Camelcase,
		"ToPlural":   inflection.Plural,
		"ToSingular": inflection.Singular,
	}

	t := template.Must(template.New("model.js").Funcs(funcMap).Parse(string(data)))
	templateData := struct {
		TableName, CamelCaseTableName, TitleCaseTableName, HumanizeWords string
		ColumnNames                                                      map[string]string
		RailsTimestamps                                                  bool
	}{
		TableName:       tableName,
		RailsTimestamps: railsTimestamps,
		ColumnNames:     columnNamesMap,
	}
	enc := json.NewEncoder(os.Stderr)
	enc.SetIndent("", "  ")
	enc.Encode(templateData)

	err = t.Execute(os.Stdout, templateData)
	if err != nil {
		log.Fatalln(err)
	}
}
