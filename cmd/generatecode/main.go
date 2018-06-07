package main

import (
	"flag"
	"log"
	"net/url"
	"os"
	"path/filepath"
	"strconv"
	"strings"
	"text/template"

	_ "github.com/lib/pq"
	"github.com/pkg/errors"
	"github.com/volatiletech/sqlboiler/bdb"
	"github.com/volatiletech/sqlboiler/bdb/drivers"
	"github.com/volatiletech/sqlboiler/strmangle"
)

var (
	dbschema             string
	dbport               int64
	whitelist, blacklist string
	tpl, src             string
	tableGlobPrefix      = "Table"
)

type arrayFlags []string

func main() {
	flag.StringVar(&dbschema, "schema", "public", "db schema to inspect")
	flag.Int64Var(&dbport, "port", 5432, "db port")
	flag.StringVar(&whitelist, "whitelist", "", "whitelist tables")
	flag.StringVar(&blacklist, "blacklist", "", "blacklist tables")
	flag.StringVar(&tpl, "tpl", "tpl", "template directory")
	flag.StringVar(&src, "src", "src", "generated source code directory")
	flag.Parse()

	url, err := url.Parse(os.Getenv("DATABASE_URL"))
	if err != nil {
		log.Fatalln(errors.Wrapf(err, "unable to parse DATABASE_URL"))
	}

	var username, password string
	if url.User != nil {
		username = url.User.Username()
		password, _ = url.User.Password()
	}
	if i, _ := strconv.ParseInt(url.Port(), 10, 64); i != 0 {
		dbport = i
	}

	db := drivers.NewPostgresDriver(username, password, strings.TrimPrefix(url.Path, "/"), url.Hostname(), int(dbport), url.Query().Get("sslmode"))
	if err = db.Open(); err != nil {
		log.Println(errors.Wrapf(err, "db open"))
		return
	}
	defer db.Close()

	tableNames, err := db.TableNames(dbschema, nil, nil)
	if err != nil {
		log.Println(errors.Wrapf(err, "table names"))
		return
	}

	pattern := filepath.Join(tpl, "*.*")
	tableTemplates, err := template.ParseGlob(pattern)
	if err != nil {
		log.Println(errors.Wrapf(err, "template.ParseGlob %q", pattern))
		return
	}

	schema := struct {
		strmanip
		Tables []dbtable
	}{
		Tables: []dbtable{},
	}
	for _, tableName := range tableNames {
		cols, err := db.Columns(dbschema, tableName)
		if err != nil {
			log.Println(errors.Wrapf(err, "columns of %q", tableName))
			return
		}
		pk, err := db.PrimaryKeyInfo(dbschema, tableName)
		if err != nil {
			log.Println(errors.Wrapf(err, "pk of %q", tableName))
			return
		}

		fk, err := db.ForeignKeyInfo(dbschema, tableName)
		if err != nil {
			log.Println(errors.Wrapf(err, "fk of %q", tableName))
			return
		}

		tbl := dbtable{
			TableName:   tableName,
			PrimaryKeys: pk.Columns,
			ForeignKeys: fk,
		}

		for _, col := range cols {
			tbl.DbCols = append(tbl.DbCols, dbcol{
				IsPrimaryKey: tbl.ContainsAny(tbl.PrimaryKeys, col.Name),
				TableName:    tableName,
				ColumnName:   col.Name,
				ColumnType:   db.TranslateColumnType(col).Type,
			})
		}

		for _, t := range tableTemplates.Templates() {
			if !strings.HasPrefix(t.Name(), tableGlobPrefix) {
				continue
			}

			fbasename := tbl.TableName
			if t.Name() == strmangle.TitleCase(t.Name()) {
				fbasename = strmangle.TitleCase(fbasename)
			} else if t.Name() == strmangle.CamelCase(t.Name()) {
				fbasename = strmangle.CamelCase(fbasename)
			}

			fname := filepath.Join(src, fbasename+filepath.Ext(t.Name()))
			f, err := os.OpenFile(fname, os.O_WRONLY|os.O_CREATE, 0600)
			if err != nil {
				log.Println(errors.Wrapf(err, "write %q", fname))
				return
			}
			defer f.Close()
			t.Execute(f, tbl)
		}

		schema.Tables = append(schema.Tables, tbl)
	}

	for _, t := range tableTemplates.Templates() {
		if strings.HasPrefix(t.Name(), tableGlobPrefix) {
			continue
		}

		fname := filepath.Join(src, t.Name())
		f, err := os.OpenFile(fname, os.O_WRONLY|os.O_CREATE|os.O_TRUNC, 0600)
		if err != nil {
			log.Println(errors.Wrapf(err, "write %q", fname))
			return
		}
		defer f.Close()
		if err := t.Execute(f, schema); err != nil {
			log.Println(errors.Wrapf(err, "execute template %q", fname))
			return
		}
	}
}

type dbtable struct {
	strmanip
	TableName   string
	PrimaryKeys []string
	ForeignKeys []bdb.ForeignKey
	DbCols      []dbcol
}

type dbcol struct {
	strmanip
	IsPrimaryKey bool
	ColumnName   string
	ColumnType   string
	TableName    string
}

type strmanip struct{}

func (_ strmanip) TitleCase(s string) string {
	return strmangle.TitleCase(s)
}

func (_ strmanip) CamelCase(s string) string {
	return strmangle.CamelCase(s)
}

func (_ strmanip) Plural(s string) string {
	return strmangle.Plural(s)
}

func (_ strmanip) Singular(s string) string {
	return strmangle.Singular(s)
}

func (_ strmanip) ToLower(s string) string {
	return strings.ToLower(s)
}

func (_ strmanip) ContainsAny(haystack []string, needle string) bool {
	for _, s := range haystack {
		if needle == s {
			return true
		}
	}
	return false
}

func (d *dbcol) ElmEncoder() string {
	if strings.HasPrefix(d.ElmType(), "Maybe ") {
		return strings.Replace(strings.ToLower(d.ElmType()), "maybe ", "Json.Encode.Extra.maybe Json.Encode.", -1)
	} else {
		return "Json.Encode." + strings.ToLower(d.ElmType())
	}
}

func (d *dbcol) ElmDecoder() string {
	return "Json.Decode." + strings.Join(strings.Split(strings.ToLower(d.ElmType()), " "), " Json.Decode.")
}

func (d *dbcol) ElmTypeNoMaybe() string {
	return strings.Replace(d.ElmType(), "Maybe ", "", -1)
}

func (d *dbcol) Just() string {
	if strings.HasPrefix(d.ElmType(), "Maybe ") {
		return "Just "
	}
	return ""
}

func (d *dbcol) Optional() bool {
	return strings.HasPrefix(d.ElmType(), "Maybe ")
}

func (d *dbcol) ElmType() string {
	if d.IsPrimaryKey {
		return "String"
	} else if d.ColumnType == "[]byte" {
		return "String"
	} else if d.ColumnType == "bool" {
		return "Bool"
	} else if d.ColumnType == "float32" {
		return "Float"
	} else if d.ColumnType == "float64" {
		return "Float"
	} else if d.ColumnType == "int" {
		return "Int"
	} else if d.ColumnType == "int16" {
		return "Int"
	} else if d.ColumnType == "int64" {
		return "Int"
	} else if d.ColumnType == "string" {
		return "String"
	} else if d.ColumnType == "time.Time" {
		return "String"
	} else if d.ColumnType == "types.Byte" {
		return "String"
	} else if d.ColumnType == "types.JSON" {
		return "String"
	} else if d.ColumnType == "null.Bool" {
		return "Maybe Bool"
	} else if d.ColumnType == "null.Byte" {
		return "Maybe String"
	} else if d.ColumnType == "null.Bytes" {
		return "Maybe String"
	} else if d.ColumnType == "null.Float64" {
		return "Maybe Float"
	} else if d.ColumnType == "null.Int" {
		return "Maybe Int"
	} else if d.ColumnType == "null.Int16" {
		return "Maybe Int"
	} else if d.ColumnType == "null.Int64" {
		return "Maybe Int"
	} else if d.ColumnType == "null.JSON" {
		return "Maybe String"
	} else if d.ColumnType == "null.String" {
		return "Maybe String"
	} else if d.ColumnType == "null.Time" {
		return "Maybe String"
	}

	log.Fatalf("unknown type: %q", d.ColumnType)
	return ""
}

func (d *dbcol) EmptyElmValue() string {
	if d.IsPrimaryKey {
		return `""`
	} else if d.ColumnType == "[]byte" {
		return `""`
	} else if d.ColumnType == "bool" {
		return "False"
	} else if d.ColumnType == "float32" {
		return "0.0"
	} else if d.ColumnType == "float64" {
		return "0.0"
	} else if d.ColumnType == "int" {
		return "0"
	} else if d.ColumnType == "int16" {
		return "0"
	} else if d.ColumnType == "int64" {
		return "0"
	} else if d.ColumnType == "string" {
		return `""`
	} else if d.ColumnType == "time.Time" {
		return `""`
	} else if d.ColumnType == "types.Byte" {
		return `""`
	} else if d.ColumnType == "types.JSON" {
		return `""`
	} else if d.ColumnType == "null.Bool" {
		return "Maybe.Nothing"
	} else if d.ColumnType == "null.Byte" {
		return "Maybe.Nothing"
	} else if d.ColumnType == "null.Bytes" {
		return "Maybe.Nothing"
	} else if d.ColumnType == "null.Float64" {
		return "Maybe.Nothing"
	} else if d.ColumnType == "null.Int" {
		return "Maybe.Nothing"
	} else if d.ColumnType == "null.Int16" {
		return "Maybe.Nothing"
	} else if d.ColumnType == "null.Int64" {
		return "Maybe.Nothing"
	} else if d.ColumnType == "null.JSON" {
		return "Maybe.Nothing"
	} else if d.ColumnType == "null.String" {
		return "Maybe.Nothing"
	} else if d.ColumnType == "null.Time" {
		return "Maybe.Nothing"
	}

	log.Fatalf("unknown type: %q", d.ColumnType)
	return `""`
}
