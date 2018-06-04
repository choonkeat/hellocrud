func strptr(s string) *string {
	return &s
}

func bool2ptr(b bool) *bool {
	return &b
}

func base64ptr(b Base64) *Base64 {
	return &b
}

func floatptr(f float64) *float64 {
	return &f
}

func intptr(i int32) *int32 {
	return &i
}

func int64ptr(i Int64) *Int64 {
	return &i
}

func textptr(t Text) *Text {
	return &t
}

func timeptr(t graphql.Time) *graphql.Time {
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
		{{- $pkColNames := .PKey.Columns -}}
		{
			givenInput:          (*search{{$modelName}}Input)(nil),
			expectResultsLength: 0,
		},
		{
			givenInput:          &search{{$modelName}}Input{
			{{range $column := .Columns }}
			{{- if containsAny $pkColNames $column.Name }}
			{{- else if eq $column.Name "created_by" }}
			{{- else if eq $column.Name "created_at" }}
			{{- else if eq $column.Name "updated_by" }}
			{{- else if eq $column.Name "updated_at" }}
			{{- else if eq $column.Type "[]byte" }}
				{{titleCase $column.Name}}: strptr("lorem ipsum"), // {{ $column.Type }}
			{{- else if eq $column.Type "bool" }}
				{{titleCase $column.Name}}: bool2ptr(true),
			{{- else if eq $column.Type "float32" }}
				{{titleCase $column.Name}}: float2ptr(3.14),
			{{- else if eq $column.Type "float64" }}
				{{titleCase $column.Name}}: float2ptr(3.14),
			{{- else if eq $column.Type "int" }}
				{{titleCase $column.Name}}: int2ptr(42),
			{{- else if eq $column.Type "int16" }}
				{{titleCase $column.Name}}: int2ptr(42),
			{{- else if eq $column.Type "int64" }}
				{{titleCase $column.Name}}: int64ptr(Int64("42")),
			{{- else if eq $column.Type "null.Bool" }}
				{{titleCase $column.Name}}: bool2ptr(true),
			{{- else if eq $column.Type "null.Byte" }}
				{{titleCase $column.Name}}: base64ptr("Base64"),
			{{- else if eq $column.Type "null.Bytes" }}
				{{titleCase $column.Name}}: base64ptr("Base64"),
			{{- else if eq $column.Type "null.Float64" }}
				{{titleCase $column.Name}}: floatptr(3.14),
			{{- else if eq $column.Type "null.Int" }}
				{{titleCase $column.Name}}: intptr(42),
			{{- else if eq $column.Type "null.Int16" }}
				{{titleCase $column.Name}}: intptr(42),
			{{- else if eq $column.Type "null.Int64" }}
				{{titleCase $column.Name}}: int64ptr(Int64("42")),
			{{- else if eq $column.Type "null.JSON" }}
				{{titleCase $column.Name}}: textptr("text"),
			{{- else if eq $column.Type "null.String" }}
				{{titleCase $column.Name}}: strptr("lorem ipsum"), // {{ $column.Type }}
			{{- else if eq $column.Type "null.Time" }}
				{{titleCase $column.Name}}: timeptr(graphql.Time{}),
			{{- else if eq $column.Type "string" }}
				{{titleCase $column.Name}}: strptr("lorem ipsum"), // {{ $column.Type }}
			{{- else if eq $column.Type "time.Time" }}
				{{titleCase $column.Name}}: timeptr(graphql.Time{}),
			{{- else if eq $column.Type "types.Byte" }}
				{{titleCase $column.Name}}: strptr("lorem ipsum"), // {{ $column.Type }}
			{{- else if eq $column.Type "types.JSON" }}
				{{titleCase $column.Name}}: strptr("lorem ipsum"), // {{ $column.Type }}
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
