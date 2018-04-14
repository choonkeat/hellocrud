package main

import (
	"io/ioutil"
	"log"
	"os"
	"path/filepath"
	"strings"
)

func main() {
	pattern := filepath.Join(os.Args[1], "*.go")
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
		parts := strings.Split(string(data), "// import ")
		if len(parts) >= 2 {
			parts = parts[1:]
			s := "import " + strings.Join(parts, "// import ")
			s = strings.Replace(s, "\n// ", "\n", -1)
			s = strings.Replace(s, "\n//\n", "\n\n", -1)
			if err := ioutil.WriteFile(strings.Replace(p, ".go", ".js", 1), []byte(s), 0660); err != nil {
				log.Fatal(err, p)
			}
		}
		os.Remove(p)
	}
}
