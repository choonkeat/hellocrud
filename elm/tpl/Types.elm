module Types exposing (..)

import RemoteData exposing (WebData)
import Json.Decode
import Json.Decode.Pipeline exposing (required)


---- MODEL ----


type Route
    = HomePage
    | NotFoundPage
    {{ range .Tables }}| {{ .TableName | .TitleCase }}Page CrudRoute
    {{ end }}


type CrudRoute
    = CrudNew
    | CrudEdit Int
    | CrudShow Int
    | CrudList


type alias Flags =
    {}


type alias Model =
    { route : Route
    {{ range .Tables }}, {{ .TableName | .CamelCase }} : {{ .TableName | .TitleCase }}Model
    {{ end }}
    }

{{ range .Tables }}
type alias {{ .TableName | .TitleCase }}Model =
    { search{{ .TableName | .TitleCase | .Plural }} : WebData (List {{ .TableName | .TitleCase }})
    , {{ .TableName | .CamelCase | .Singular }}ByID : WebData {{ .TableName | .TitleCase }}
    , form{{ .TableName | .TitleCase }} : {{ .TableName | .TitleCase }}
    }
{{ end }}

{{ range .Tables }}
type alias {{ .TableName | .TitleCase }} =
    { {{- range $index, $row := .DbCols -}}
    {{- if gt $index 0 }}, {{ end }}{{ .ColumnName | .CamelCase }} : {{ .ElmType }}
    {{ end -}}
    }

{{ .TableName | .CamelCase }}Decoder : Json.Decode.Decoder {{ .TableName | .TitleCase }}
{{ .TableName | .CamelCase }}Decoder =
  Json.Decode.Pipeline.decode {{ .TableName | .TitleCase }}
    {{- range .DbCols -}}
    |> required "{{ .ColumnName | .CamelCase }}" ({{ .ElmDecoder }})
    {{ end }}
{{ end }}

graphqlEndpoint : String
graphqlEndpoint =
    "http://localhost:5000/graphql"
