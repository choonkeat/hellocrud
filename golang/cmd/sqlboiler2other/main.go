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
	basedir          string
	ext              string
	startPlaceholder = "/*sqlboiler2other\n"
	endPlaceholder   = "sqlboiler2other*/"
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
		// Find index of start of actual content
		start := strings.Index(s, startPlaceholder)
		if start == -1 {
			continue
		}

		// Slice content from start index
		s = s[start+len(startPlaceholder) : len(s)]
		// Remove all /* */
		s = strings.Replace(s, startPlaceholder, "", -1)
		s = strings.Replace(s, endPlaceholder, "", -1)
		s = strings.TrimSpace(s) + "\n"

		if err := ioutil.WriteFile(strings.Replace(p, ".go", "."+ext, 1), []byte(s), 0660); err != nil {
			log.Fatal(err, p)
		}
	}
}
