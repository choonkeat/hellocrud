func strptr(s string) *string {
	return &s
}

func bool2ptr(b bool) *bool {
	return &b
}

func base64ptr(b Base64) *Base64 {
	return &b
}

func floatptr(f float) *float {
	return &f
}

func intptr(i int) *int {
	return &i
}

func int64ptr(i int64) *int64 {
	return &i
}

func textptr(t Text) *Text {
	return &t
}

func timeptr(t time.Time) *time.Time {
	return &t
}

func TestQueryModSearch(t *testing.T) {
	testCases := []struct {
		givenInput          interface{}
		expectResultsLength int
	}{
		{{range $table := .Tables}}
		{{- $tableNameSingular := .Name | singular -}}
		{{- $modelName := $tableNameSingular | titleCase -}}
		{{- $modelNamePlural := $table.Name | plural | titleCase -}}
		{{- $modelNameCamel := $tableNameSingular | camelCase}}
		{
			givenInput:          (*search{{$modelName}}Input)(nil),
			expectResultsLength: 0,
		},
		{
			givenInput:          &search{{$modelName}}Input{
			{{range $column := .Columns }}
			{{- if eq $column.Name "created_by" }}
			{{- else if eq $column.Name "created_at" }}
			{{- else if eq $column.Name "updated_by" }}
			{{- else if eq $column.Name "updated_at" }}
			{{- else if eq $column.Type "[]byte" }}
				{{camelCase $column.Name}}: "lorem ipsum",
			{{- else if eq $column.Type "bool" }}
				{{camelCase $column.Name}}: true,
			{{- else if eq $column.Type "float32" }}
				{{camelCase $column.Name}}: 3.14,
			{{- else if eq $column.Type "float64" }}
				{{camelCase $column.Name}}: 3.14,
			{{- else if eq $column.Type "int" }}
				{{camelCase $column.Name}}: 42,
			{{- else if eq $column.Type "int16" }}
				{{camelCase $column.Name}}: 42,
			{{- else if eq $column.Type "int64" }}
				{{camelCase $column.Name}}: int64(42),
			{{- else if eq $column.Type "null.Bool" }}
				{{camelCase $column.Name}}: bool2ptr(true),
			{{- else if eq $column.Type "null.Byte" }}
				{{camelCase $column.Name}}: base64ptr("Base64"),
			{{- else if eq $column.Type "null.Bytes" }}
				{{camelCase $column.Name}}: base64ptr("Base64"),
			{{- else if eq $column.Type "null.Float64" }}
				{{camelCase $column.Name}}: floatptr(3.14),
			{{- else if eq $column.Type "null.Int" }}
				{{camelCase $column.Name}}: intptr(42),
			{{- else if eq $column.Type "null.Int16" }}
				{{camelCase $column.Name}}: intptr(42),
			{{- else if eq $column.Type "null.Int64" }}
				{{camelCase $column.Name}}: int64ptr(int64(42)),
			{{- else if eq $column.Type "null.JSON" }}
				{{camelCase $column.Name}}: textptr("text"),
			{{- else if eq $column.Type "null.String" }}
				{{camelCase $column.Name}}: strptr("lorem ipsum"),
			{{- else if eq $column.Type "null.Time" }}
				{{camelCase $column.Name}}: timeptr(time.Now()),
			{{- else if eq $column.Type "string" }}
				{{camelCase $column.Name}}: "lorem ipsum",
			{{- else if eq $column.Type "time.Time" }}
				{{camelCase $column.Name}}: time.Now(),
			{{- else if eq $column.Type "types.Byte" }}
				{{camelCase $column.Name}}: "lorem ipsum",
			{{- else if eq $column.Type "types.JSON" }}
				{{camelCase $column.Name}}: "lorem ipsum",
			{{- end -}}
			{{- end }}
      },
			expectResultsLength: 0,
		},
		{{end}}
	}

	for i, tc := range testCases {
		t.Run(strconv.Itoa(i), func(t *testing.T) {
			result := QueryModSearch(tc.givenInput)
			assert.Len(t, result, tc.expectResultsLength)
		})
	}
}
