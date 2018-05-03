package main

import (
	"flag"
	"io/ioutil"
	"log"
	"os"
	"path/filepath"
	"strings"
)

var (
	basedir string
	ext     string
)

func main() {
	flag.StringVar(&basedir, "basedir", "", "directory of `.go` files")
	flag.StringVar(&ext, "ext", "", "rename files to this extension")
	flag.Parse()

	pattern := filepath.Join(basedir, "*.go")
	log.Println("globbing", pattern)
	paths, err := filepath.Glob(pattern)
	if err != nil {
		log.Fatal(err)
	}
	for _, p := range paths {
		log.Println("processing", p)
		data, err := ioutil.ReadFile(p)
		if err != nil {
			log.Fatal(err, p)
		}
		os.Remove(p)

		s := string(data)
		parts := strings.SplitN(s, "var _ = `", 2)
		if len(parts) == 1 {
			continue
		}
		s = parts[1]
		s = strings.TrimSpace(s)
		s = strings.TrimSuffix(s, "`")
		s = strings.Replace(s, "\n\n\n", "\n\n", -1)
		parts = strings.Split(s, "`\nvar _ = `")

		if err := ioutil.WriteFile(strings.Replace(p, ".go", "."+ext, 1), []byte(strings.Join(parts, "")), 0660); err != nil {
			log.Fatal(err, p)
		}
	}
}
