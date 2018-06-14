module {{ .TableName | .TitleCase }} exposing (..)

import Html exposing (Html, a, button, code, div, form, h1, hr, img, input, label, small, table, tbody, td, text, th, thead, tr)
import Html.Attributes exposing (attribute, class, href, method, name, placeholder, style, type_, value)
import Html.Events exposing (onInput, onSubmit, onWithOptions)
import Http
import Json.Decode
import Json.Encode
import Json.Encode.Extra
import RemoteData exposing (WebData)
import Style exposing (InputField, formField, formSubmitOrCancel)
import Types exposing (CrudRoute, CrudRoute(..), {{ .TableName | .TitleCase }}Model, Route, graphqlEndpoint)
import UrlParser exposing ((</>), s, string)
import Navigation
import Convert


-- {{ .TableName | .TitleCase }} and its APIs


querySearch{{ .TableName | .TitleCase | .Plural }} : String -> {{ .TableName | .TitleCase }}Model -> Cmd Msg
querySearch{{ .TableName | .TitleCase | .Plural }} graphqlEndpoint model =
    let
        body =
            Json.Encode.object
                [ ( "query", Json.Encode.string """
                  query {
                    search{{ .TableName | .TitleCase | .Plural }} {
                      nodes {
                        {{ range .DbCols -}}
                        {{ .ColumnName | .CamelCase }}
                        {{ end }}
                      }
                    }
                  }
                  """ )
                ]
    in
        Http.post graphqlEndpoint (Http.jsonBody body) (Json.Decode.at [ "data", "search{{ .TableName | .TitleCase | .Plural }}", "nodes" ] decodeSearch{{ .TableName | .TitleCase | .Plural }})
            |> RemoteData.sendRequest
            |> Cmd.map OnSearch{{ .TableName | .TitleCase | .Plural }}


decodeSearch{{ .TableName | .TitleCase | .Plural }} : Json.Decode.Decoder (List Types.{{ .TableName | .TitleCase }})
decodeSearch{{ .TableName | .TitleCase | .Plural }} =
    Json.Decode.list Types.{{ .TableName | .CamelCase }}Decoder


query{{ .TableName | .TitleCase | .Singular }}ByID : String -> String -> Cmd Msg
query{{ .TableName | .TitleCase | .Singular }}ByID graphqlEndpoint idInt =
    let
        body =
            Json.Encode.object
                [ ( "query", Json.Encode.string """
                  query {{ .TableName | .CamelCase | .Singular }}ByID($id: ID!) {
                    {{ .TableName | .CamelCase | .Singular }}ByID(id: $id) {
                      {{ range .DbCols -}}
                      {{ .ColumnName | .CamelCase }}
                      {{ end }}
                    }
                  }
                  """ )
                , ( "variables"
                  , Json.Encode.object
                    [ ( "id", Json.Encode.string idInt ) ]
                  )
                ]
    in
        Http.post graphqlEndpoint (Http.jsonBody body) (Json.Decode.at [ "data", "{{ .TableName | .CamelCase | .Singular }}ByID" ] decode{{ .TableName | .TitleCase | .Singular }}ByID)
            |> RemoteData.sendRequest
            |> Cmd.map On{{ .TableName | .TitleCase | .Singular }}ByID


decode{{ .TableName | .TitleCase | .Singular }}ByID : Json.Decode.Decoder Types.{{ .TableName | .TitleCase }}
decode{{ .TableName | .TitleCase | .Singular }}ByID =
    Types.{{ .TableName | .CamelCase }}Decoder


mutationCreate{{ .TableName | .TitleCase }} : String -> Types.{{ .TableName | .TitleCase }} -> Cmd Msg
mutationCreate{{ .TableName | .TitleCase }} graphqlEndpoint {{ .TableName | .CamelCase }} =
    let
        body =
            Json.Encode.object
                [ ( "query", Json.Encode.string """
                  mutation mutation($input: Create{{ .TableName | .TitleCase | .Singular }}Input!){
                    create{{ .TableName | .TitleCase | .Singular }}(input:$input) {
                      {{ range .DbCols -}}
                      {{ .ColumnName | .CamelCase }}
                      {{ end }}
                    }
                  }
                  """ )
                , ( "variables"
                  , Json.Encode.object
                        [ ( "input"
                          , Json.Encode.object
                                [ {{- range $index, $row := .NonPkColsWithout "created_at" "updated_at" -}}
                                {{- if gt $index 0 }}, {{ end }}( "{{ .ColumnName | .CamelCase }}", {{ .ElmEncoder }} {{ .TableName | .CamelCase }}.{{ .ColumnName | .CamelCase }} )
                                {{ end -}}
                                ]
                          )
                        ]
                  )
                ]
    in
        Http.post graphqlEndpoint (Http.jsonBody body) (Json.Decode.at [ "data", "create{{ .TableName | .TitleCase }}" ] decodeCreate{{ .TableName | .TitleCase }})
            |> RemoteData.sendRequest
            |> Cmd.map OnCrudNewResult


decodeCreate{{ .TableName | .TitleCase }} : Json.Decode.Decoder Types.{{ .TableName | .TitleCase }}
decodeCreate{{ .TableName | .TitleCase }} =
    Types.{{ .TableName | .CamelCase }}Decoder


mutationUpdate{{ .TableName | .TitleCase }} : String -> Types.{{ .TableName | .TitleCase }} -> Cmd Msg
mutationUpdate{{ .TableName | .TitleCase }} graphqlEndpoint {{ .TableName | .CamelCase }} =
    let
        body =
            Json.Encode.object
                [ ( "query", Json.Encode.string """
                  mutation mutation($id: ID!, $input: Update{{ .TableName | .TitleCase | .Singular }}Input!){
                    update{{ .TableName | .TitleCase | .Singular }}ByID(id:$id,input:$input) {
                      {{ range .DbCols -}}
                      {{ .ColumnName | .CamelCase }}
                      {{ end }}
                    }
                  }
                  """ )
                , ( "variables"
                  , Json.Encode.object
                        [ ( "id"
                          , Json.Encode.string {{ .TableName | .CamelCase }}.id)
                        , ( "input"
                          , Json.Encode.object
                                [ {{- range $index, $row := .NonPkColsWithout "created_at" "updated_at" -}}
                                {{- if gt $index 0 }}, {{ end }}( "{{ .ColumnName | .CamelCase }}", {{ .ElmEncoder }} {{ .TableName | .CamelCase }}.{{ .ColumnName | .CamelCase }} )
                                {{ end -}}
                                ]
                          )
                        ]
                  )
                ]
    in
        Http.post graphqlEndpoint (Http.jsonBody body) (Json.Decode.at [ "data", "update{{ .TableName | .TitleCase }}ByID" ] decodeUpdate{{ .TableName | .TitleCase }})
            |> RemoteData.sendRequest
            |> Cmd.map OnCrudEditResult


decodeUpdate{{ .TableName | .TitleCase }} : Json.Decode.Decoder Types.{{ .TableName | .TitleCase }}
decodeUpdate{{ .TableName | .TitleCase }} =
    Types.{{ .TableName | .CamelCase }}Decoder


---- MODEL ----


init : ( {{ .TableName | .TitleCase }}Model, Cmd Msg )
init =
    let
        model =
            {{ .TableName | .TitleCase }}Model
                RemoteData.NotAsked
                RemoteData.NotAsked
                (Types.{{ .TableName | .TitleCase }} {{ range .DbCols }}{{ .EmptyElmValue }} {{ end }})
    in
        updateModelByLocation model CrudList



---- UPDATE ----


type Msg
    = OnSearch{{ .TableName | .TitleCase | .Plural }} (WebData (List Types.{{ .TableName | .TitleCase }}))
    | On{{ .TableName | .TitleCase | .Singular }}ByID (WebData Types.{{ .TableName | .TitleCase }})
    {{ range .NonPkColsWithout "created_at" "updated_at" -}}
    | OnFormFieldSet{{ .ColumnName | .TitleCase }} String
    {{ end -}}
    | OnCrudNewSubmit
    | OnCrudNewResult (WebData Types.{{ .TableName | .TitleCase }})
    | OnCrudEditSubmit
    | OnCrudEditResult (WebData Types.{{ .TableName | .TitleCase }})


update : Msg -> {{ .TableName | .TitleCase }}Model -> ( {{ .TableName | .TitleCase }}Model, Cmd Msg )
update msg model =
    case msg of
        OnSearch{{ .TableName | .TitleCase | .Plural }} resp ->
            ( { model | search{{ .TableName | .TitleCase | .Plural }} = resp }, Cmd.none )

        On{{ .TableName | .TitleCase | .Singular }}ByID resp ->
            let
                form{{ .TableName | .TitleCase }} =
                    case resp of
                        RemoteData.NotAsked ->
                            model.form{{ .TableName | .TitleCase }}

                        RemoteData.Loading ->
                            model.form{{ .TableName | .TitleCase }}

                        RemoteData.Failure err ->
                            model.form{{ .TableName | .TitleCase }}

                        RemoteData.Success a ->
                            a

            in
              ( { model | {{ .TableName | .CamelCase | .Singular }}ByID = resp, form{{ .TableName | .TitleCase }} = form{{ .TableName | .TitleCase }} }, Cmd.none )

        {{ range .NonPkColsWithout "created_at" "updated_at" -}}
        OnFormFieldSet{{ .ColumnName | .TitleCase }} str ->
            {{ if eq .ElmTypeNoMaybe "String" -}}
            let
                old{{ .TableName | .TitleCase }} =
                    model.form{{ .TableName | .TitleCase }}
            in
                ( { model | form{{ .TableName | .TitleCase }} = { old{{ .TableName | .TitleCase }} | {{ .ColumnName | .CamelCase }} = {{ .Just }}str } }, Cmd.none )
            {{ else -}}
            let
                old{{ .TableName | .TitleCase }} =
                    model.form{{ .TableName | .TitleCase }}
                newValue =
                    Convert.convertWithDefault String.to{{.ElmTypeNoMaybe}} str 0
            in
                ( { model | form{{ .TableName | .TitleCase }} = { old{{ .TableName | .TitleCase }} | {{ .ColumnName | .CamelCase }} = {{ .Just }}newValue } }, Cmd.none )
            {{ end }}
        {{ end -}}

        OnCrudNewSubmit ->
            ( model, mutationCreate{{ .TableName | .TitleCase }} graphqlEndpoint model.form{{ .TableName | .TitleCase }} )

        OnCrudNewResult result ->
            case result of
                RemoteData.NotAsked ->
                    ( model, Cmd.none )

                RemoteData.Loading ->
                    ( model, Cmd.none )

                RemoteData.Failure err ->
                    ( model, Cmd.none )

                RemoteData.Success form{{ .TableName | .TitleCase }} ->
                    ( { model | form{{ .TableName | .TitleCase }} = form{{ .TableName | .TitleCase }} }, Navigation.newUrl ("/{{ .TableName }}/" ++ form{{ .TableName | .TitleCase }}.id) )

        OnCrudEditSubmit ->
          ( model, mutationUpdate{{ .TableName | .TitleCase }} graphqlEndpoint model.form{{ .TableName | .TitleCase }} )

        OnCrudEditResult result ->
            case result of
                RemoteData.NotAsked ->
                    ( model, Cmd.none )

                RemoteData.Loading ->
                    ( model, Cmd.none )

                RemoteData.Failure err ->
                    ( model, Cmd.none )

                RemoteData.Success form{{ .TableName | .TitleCase }} ->
                    ( { model | form{{ .TableName | .TitleCase }} = form{{ .TableName | .TitleCase }} }, Navigation.newUrl ("/{{ .TableName }}/" ++ form{{ .TableName | .TitleCase }}.id) )


---- VIEW ----


view : CrudRoute -> {{ .TableName | .TitleCase }}Model -> Html Msg
view crudroute model =
    case crudroute of
        CrudNew ->
            div [ class "card-body" ]
                [ a [ href "/{{ .TableName }}" ] [ text "< {{ .TableName | .TitleCase }}" ]
                , h1 [ class "card-title" ] [ text "New {{ .TableName | .TitleCase }}" ]
                , form [ onSubmit OnCrudNewSubmit ]
                  [ {{- range $index, $row := .NonPkColsWithout "created_at" "updated_at" -}}
                  {{- if gt $index 0 }}, {{ end }}formField <|
                      { label = "{{ .ColumnName | .TitleCase }}"
                      , name = "{{ .ColumnName | .CamelCase }}"
                      , placeholder = ""
                      , value = ""
                      , hint = ""
                      , msgTag = OnFormFieldSet{{ .ColumnName | .TitleCase }}
                      }
                  {{ end -}}
                  , formSubmitOrCancel "/{{ .TableName }}"
                  ]
                ]

        CrudEdit {{ .TableName | .CamelCase }}ID ->
            case model.{{ .TableName | .CamelCase | .Singular }}ByID of
                RemoteData.NotAsked ->
                    div [] [ text "Not asked" ]

                RemoteData.Loading ->
                    div [] [ text "Loading" ]

                RemoteData.Failure err ->
                    div [] [ text (toString err) ]

                RemoteData.Success {{ .TableName | .CamelCase }} ->
                    div [ class "card-body" ]
                        [ a [ href "/{{ .TableName }}" ] [ text "< {{ .TableName | .TitleCase }}" ]
                        , h1 [ class "card-title" ] [ text ("Edit " ++ toString {{ .TableName | .CamelCase }}ID) ]
                        , form [ onSubmit OnCrudEditSubmit ]
                          [ {{- range $index, $row := .NonPkColsWithout "created_at" "updated_at" -}}
                          {{- if gt $index 0 }}, {{ end }}formField <|
                              { label = "{{ .ColumnName | .TitleCase }}"
                              , name = "{{ .ColumnName | .CamelCase }}"
                              , placeholder = ""
                              , value = {{ if ne .ElmType "String" }}(toString {{ end }}{{ .TableName | .CamelCase }}.{{ .ColumnName | .CamelCase }}{{ if ne .ElmType "String" }}){{ end }}
                              , hint = ""
                              , msgTag = OnFormFieldSet{{ .ColumnName | .TitleCase }}
                              }
                          {{ end -}}
                          , formSubmitOrCancel "/{{ .TableName }}"
                          ]
                        ]

        CrudShow {{ .TableName | .CamelCase }}ID ->
            case model.{{ .TableName | .CamelCase | .Singular }}ByID of
                RemoteData.NotAsked ->
                    div [] [ text "Not asked" ]

                RemoteData.Loading ->
                    div [] [ text "Loading" ]

                RemoteData.Failure err ->
                    div [] [ text (toString err) ]

                RemoteData.Success {{ .TableName | .CamelCase }} ->
                    div [ class "card-body" ]
                        [ a [ href "/{{ .TableName }}" ]
                            [ text "← {{ .TableName | .TitleCase | .Plural }}" ]
                        , h1 [ class "card-title" ] [ text ("Show {{ .TableName | .TitleCase | .Singular }} #" ++ toString {{ .TableName | .CamelCase }}ID) ]
                        , table []
                            [ tbody []
                                [ {{- range $index, $row := .NonPkColsWithout "created_at" "updated_at" -}}
                                {{- if gt $index 0 }}, {{ end }}tr []
                                  [ th []
                                      [ text "{{ .ColumnName | .TitleCase }}" ]
                                  , td []
                                      [ text {{ if ne .ElmType "String" }}(toString {{ end }}{{ .TableName | .CamelCase }}.{{ .ColumnName | .CamelCase }}{{ if ne .ElmType "String" }}){{ end }} ]
                                  ]
                                {{ end -}}
                                ]
                            ]
                        , a [ href ("/{{ .TableName }}/" ++ {{ .TableName | .CamelCase }}.id ++ "/edit") ]
                            [ button [ class "btn btn-secondary" ]
                                [ text "Edit" ]
                            ]
                        ]



        CrudList ->
            case model.search{{ .TableName | .TitleCase | .Plural }} of
                RemoteData.NotAsked ->
                    div [] [ text "Not asked" ]

                RemoteData.Loading ->
                    div [] [ text "Loading" ]

                RemoteData.Failure err ->
                    div [] [ text (toString err) ]

                RemoteData.Success {{ .TableName | .CamelCase }}s ->
                    div [ class "card-body" ]
                        [ a [ href "/" ] [text "< Home"]
                        , h1 [ class "card-title" ] [ text "{{ .TableName | .TitleCase | .Plural }}" ]
                        , div [ class "float-right" ]
                          [ a [ href "/{{ .TableName }}/new" ]
                            [ button [class "btn btn-primary"] [text "New {{ .TableName | .TitleCase | .Singular }} ..."]]
                          ]
                        , table [ class "table table-hover" ]
                            [ thead []
                                [ tr []
                                    [ text ""
                                    {{ range .DbCols -}}
                                    , th []
                                        [ text "{{ .ColumnName | .TitleCase }}" ]
                                    {{ end -}}
                                    , th []
                                        []
                                    , text ""
                                    , th []
                                        []
                                    , text ""
                                    ]
                                ]
                            , tbody []
                                (List.map
                                    (\{{ .TableName | .CamelCase }} ->
                                        tr []
                                            [ text ""
                                            {{ range .DbCols -}}
                                            , td []
                                              [ a [ href ("/{{ .TableName }}/" ++ {{ .TableName | .CamelCase }}.id) ]
                                                [ text {{ if ne .ElmType "String" }}(toString {{ end }}{{ .TableName | .CamelCase }}.{{ .ColumnName | .CamelCase }}{{ if ne .ElmType "String" }}){{ end }} ]
                                              ]
                                            {{ end -}}
                                            ]
                                    )
                                    {{ .TableName | .CamelCase }}s
                                )
                            ]
                        ]



---- ROUTING ----


routes : UrlParser.Parser (CrudRoute -> a) a
routes =
    UrlParser.oneOf
        [ UrlParser.map CrudList UrlParser.top
        , UrlParser.map CrudNew (s "new")
        , UrlParser.map CrudShow UrlParser.int
        , UrlParser.map CrudEdit (UrlParser.int </> s "edit")
        ]


updateModelByLocation : {{ .TableName | .TitleCase }}Model -> CrudRoute -> ( {{ .TableName | .TitleCase }}Model, Cmd Msg )
updateModelByLocation model route =
    case route of
        CrudList ->
            ( { model | search{{ .TableName | .TitleCase | .Plural }} = RemoteData.Loading }, querySearch{{ .TableName | .TitleCase | .Plural }} graphqlEndpoint model )

        CrudNew ->
            ( model, Cmd.none )

        CrudShow idInt ->
            ( { model | {{ .TableName | .CamelCase | .Singular }}ByID = RemoteData.Loading }, query{{ .TableName | .TitleCase | .Singular }}ByID graphqlEndpoint (toString idInt) )

        CrudEdit idInt ->
            ( { model | {{ .TableName | .CamelCase | .Singular }}ByID = RemoteData.Loading }, query{{ .TableName | .TitleCase | .Singular }}ByID graphqlEndpoint (toString idInt) )
