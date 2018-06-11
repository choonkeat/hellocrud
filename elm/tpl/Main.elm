module Main exposing (..)

import Html exposing (Html, a, br, button, code, div, h1, hr, img, li, nav, span, table, tbody, td, text, th, thead, tr, ul)
import Html.Attributes exposing (attribute, class, href, id, style, type_)
import Navigation exposing (Location)
import Platform.Cmd as Cmd exposing (map)
import Types exposing (CrudRoute, Flags, Model, {{ range .Tables }}{{ .TableName | .TitleCase }}Model, {{ end }}Route(..))
import UrlParser exposing ((</>), map, s)
{{ range .Tables -}}
import {{ .TableName | .TitleCase }}
{{ end -}}


---- INIT ----


init : Flags -> Location -> ( Model, Cmd Msg )
init flags location =
    let {{ range .Tables }}
        ( {{ .TableName | .CamelCase }}Model, _ ) =
            {{ .TableName | .TitleCase }}.init
        {{ end }}
        currentRoute =
            routeFromLocation location

        model =
            Model currentRoute
                {{ range .Tables -}}
                {{ .TableName | .CamelCase }}Model
                {{ end }}
    in
        updateModelByLocation model currentRoute



---- UPDATE ----


type Msg
    = OnLocationChange Location
    {{ range .Tables -}}
    | {{ .TableName | .TitleCase }}Message {{ .TableName | .TitleCase }}.Msg
    {{ end }}

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        OnLocationChange location ->
            let
                newroute =
                    routeFromLocation location
            in
                updateModelByLocation { model | route = newroute } newroute

        -- Otherwise, we'll delegate to {X} module to handle {X}Message updates

        {{ range .Tables }}
        {{ .TableName | .TitleCase }}Message m ->
            let
                ( {{ .TableName | .CamelCase }}, cmd ) =
                    {{ .TableName | .TitleCase }}.update m model.{{ .TableName | .CamelCase }}
            in
                ( { model | {{ .TableName | .CamelCase }} = {{ .TableName | .CamelCase }} }, Cmd.map {{ .TableName | .TitleCase }}Message cmd )
        {{ end }}



---- VIEW ----


view : Model -> Html Msg
view model =
    let
        innerContent =
            case model.route of
                NotFoundPage ->
                    text "Not found"

                HomePage ->
                    div [] []

                -- Otherwise, we'll delegate to {X} module to handle {X}Page views

                {{ range .Tables }}
                {{ .TableName | .TitleCase }}Page crudroute ->
                    div []
                        [ Html.map {{ .TableName | .TitleCase }}Message ({{ .TableName | .TitleCase }}.view crudroute model.{{ .TableName | .CamelCase }})
                        ]
                {{ end }}


    in
        -- Render a common navbar + route specific `innerContent`
        div []
            [ nav [ class "navbar navbar-expand-md navbar-dark bg-dark fixed-top" ]
                [ a [ class "navbar-brand", href "/" ]
                    [ text "Home" ]
                , button [ class "navbar-toggler", attribute "data-target" "#navbarSupportedContent", attribute "data-toggle" "collapse", type_ "button" ]
                    [ span [ class "navbar-toggler-icon" ]
                        []
                    , text "  "
                    ]
                , div [ class "collapse navbar-collapse", id "navbarSupportedContent" ]
                    [ ul [ class "navbar-nav mr-auto" ]
                        [ text ""
                        {{ range .Tables }}
                        , li [ class "nav-item" ]
                            [ a [ class "nav-link", href "/{{ .TableName }}" ]
                                [ text "{{ .TableName | .TitleCase | .Plural }}" ]
                            ]
                        {{ end }}
                        ]
                    ]
                ]
            , innerContent
            ]



---- PROGRAM ----


main : Program Flags Model Msg
main =
    Navigation.programWithFlags OnLocationChange
        { view = view
        , init = init
        , update = update
        , subscriptions = always Sub.none
        }



---- ROUTING ----


routes : UrlParser.Parser (Route -> a) a
routes =
    UrlParser.oneOf
        [ UrlParser.map HomePage UrlParser.top
        {{ range .Tables -}}
        , UrlParser.map {{ .TableName | .TitleCase }}Page (s "{{ .TableName }}" </> {{ .TableName | .TitleCase }}.routes)
        {{ end -}}
        ]

-- Given the browser URL, what Route are we?
routeFromLocation : Navigation.Location -> Route
routeFromLocation location =
    case UrlParser.parsePath routes location of
        Just route ->
            route

        Nothing ->
            NotFoundPage


-- Given the browser URL, what is our updated Model? what is our next Cmd Msg?
-- e.g. after authentication, model is `{ model | loggedIn = True }` and Cmd is `Http.get "/newsfeed.json"`
updateModelByLocation : Model -> Route -> ( Model, Cmd Msg )
updateModelByLocation model route =
    case route of
        NotFoundPage ->
            ( model, Cmd.none )

        HomePage ->
            ( model, Cmd.none )
        {{ range .Tables }}
        {{ .TableName | .TitleCase }}Page crudroute ->
            let
                ( {{ .TableName | .CamelCase }}, cmd ) =
                    {{ .TableName | .TitleCase }}.updateModelByLocation model.{{ .TableName | .CamelCase }} crudroute
            in
                ( { model | {{ .TableName | .CamelCase }} = {{ .TableName | .CamelCase }} }, Cmd.map {{ .TableName | .TitleCase }}Message cmd )
        {{ end }}
