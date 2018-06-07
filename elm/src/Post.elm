module Post exposing (..)

import Html exposing (Html, a, button, code, div, form, h1, hr, img, input, label, small, table, tbody, td, text, th, thead, tr)
import Html.Attributes exposing (attribute, class, href, method, name, placeholder, style, type_, value)
import Html.Events exposing (onInput, onSubmit, onWithOptions)
import Http
import Json.Decode
import Json.Encode
import Json.Encode.Extra
import RemoteData exposing (WebData)
import Style exposing (InputField, formField, formSubmitOrCancel)
import Types exposing (CrudRoute, CrudRoute(..), PostModel, Route, graphqlEndpoint)
import UrlParser exposing ((</>), s, string)
import Navigation
import Convert


-- Post and its APIs


querySearchPosts : String -> PostModel -> Cmd Msg
querySearchPosts graphqlEndpoint model =
    let
        body =
            Json.Encode.object
                [ ( "query", Json.Encode.string """
                  query {
                    searchPosts {
                      nodes {
                        id
                        title
                        author
                        body
                        notes
                        createdAt
                        updatedAt

                      }
                    }
                  }
                  """ )
                ]
    in
        Http.post graphqlEndpoint (Http.jsonBody body) (Json.Decode.at [ "data", "searchPosts", "nodes" ] decodeSearchPosts)
            |> RemoteData.sendRequest
            |> Cmd.map OnSearchPosts


decodeSearchPosts : Json.Decode.Decoder (List Types.Post)
decodeSearchPosts =
    Json.Decode.list Types.postDecoder


queryPostByID : String -> String -> Cmd Msg
queryPostByID graphqlEndpoint idInt =
    let
        body =
            Json.Encode.object
                [ ( "query", Json.Encode.string """
                  query postByID($id: ID!) {
                    postByID(id: $id) {
                      id
                      title
                      author
                      body
                      notes
                      createdAt
                      updatedAt

                    }
                  }
                  """ )
                , ( "variables"
                  , Json.Encode.object
                        [ ( "id", Json.Encode.string idInt ) ]
                  )
                ]
    in
        Http.post graphqlEndpoint (Http.jsonBody body) (Json.Decode.at [ "data", "postByID" ] decodePostByID)
            |> RemoteData.sendRequest
            |> Cmd.map OnPostByID


decodePostByID : Json.Decode.Decoder Types.Post
decodePostByID =
    Types.postDecoder


mutationCreatePost : String -> Types.Post -> Cmd Msg
mutationCreatePost graphqlEndpoint post =
    let
        body =
            Json.Encode.object
                [ ( "query", Json.Encode.string """
                  mutation mutation($input: CreatePostInput!){
                    createPost(input:$input) {
                      id
                      title
                      author
                      body
                      notes
                      createdAt
                      updatedAt

                    }
                  }
                  """ )
                , ( "variables"
                  , Json.Encode.object
                        [ ( "input"
                          , Json.Encode.object
                                [ ( "_deleteme", Json.Encode.Extra.maybe Json.Encode.string Nothing )
                                , ( "title", Json.Encode.string post.title )
                                , ( "author", Json.Encode.string post.author )
                                , ( "body", Json.Encode.string post.body )
                                , ( "notes", Json.Encode.Extra.maybe Json.Encode.string post.notes )
                                ]
                          )
                        ]
                  )
                ]
    in
        Http.post graphqlEndpoint (Http.jsonBody body) (Json.Decode.at [ "data", "createPost" ] decodeCreatePost)
            |> RemoteData.sendRequest
            |> Cmd.map OnCrudNewResult


decodeCreatePost : Json.Decode.Decoder Types.Post
decodeCreatePost =
    Types.postDecoder


mutationUpdatePost : String -> Types.Post -> Cmd Msg
mutationUpdatePost graphqlEndpoint post =
    let
        body =
            Json.Encode.object
                [ ( "query", Json.Encode.string """
                  mutation mutation($id: ID!, $input: UpdatePostInput!){
                    updatePostByID(id:$id,input:$input) {
                      id
                      title
                      author
                      body
                      notes
                      createdAt
                      updatedAt

                    }
                  }
                  """ )
                , ( "variables"
                  , Json.Encode.object
                        [ ( "id"
                          , Json.Encode.string post.id
                          )
                        , ( "input"
                          , Json.Encode.object
                                [ ( "_deleteme", Json.Encode.Extra.maybe Json.Encode.string Nothing )
                                , ( "title", Json.Encode.string post.title )
                                , ( "author", Json.Encode.string post.author )
                                , ( "body", Json.Encode.string post.body )
                                , ( "notes", Json.Encode.Extra.maybe Json.Encode.string post.notes )
                                ]
                          )
                        ]
                  )
                ]
    in
        Http.post graphqlEndpoint (Http.jsonBody body) (Json.Decode.at [ "data", "updatePostByID" ] decodeUpdatePost)
            |> RemoteData.sendRequest
            |> Cmd.map OnCrudEditResult


decodeUpdatePost : Json.Decode.Decoder Types.Post
decodeUpdatePost =
    Types.postDecoder



---- MODEL ----


init : ( PostModel, Cmd Msg )
init =
    let
        model =
            PostModel
                RemoteData.NotAsked
                RemoteData.NotAsked
                (Types.Post "" "" "" "" Maybe.Nothing Maybe.Nothing Maybe.Nothing)
    in
        updateModelByLocation model CrudList



---- UPDATE ----


type Msg
    = OnSearchPosts (WebData (List Types.Post))
    | OnPostByID (WebData Types.Post)
    | OnFormFieldSetTitle String
    | OnFormFieldSetAuthor String
    | OnFormFieldSetBody String
    | OnFormFieldSetNotes String
    | OnCrudNewSubmit
    | OnCrudNewResult (WebData Types.Post)
    | OnCrudEditSubmit
    | OnCrudEditResult (WebData Types.Post)


update : Msg -> PostModel -> ( PostModel, Cmd Msg )
update msg model =
    case msg of
        OnSearchPosts resp ->
            ( { model | searchPosts = resp }, Cmd.none )

        OnPostByID resp ->
            let
                formPost =
                    case resp of
                        RemoteData.NotAsked ->
                            model.formPost

                        RemoteData.Loading ->
                            model.formPost

                        RemoteData.Failure err ->
                            model.formPost

                        RemoteData.Success a ->
                            a
            in
                ( { model | postByID = resp, formPost = formPost }, Cmd.none )

        OnFormFieldSetTitle str ->
            let
                oldPost =
                    model.formPost
            in
                ( { model | formPost = { oldPost | title = str } }, Cmd.none )

        OnFormFieldSetAuthor str ->
            let
                oldPost =
                    model.formPost
            in
                ( { model | formPost = { oldPost | author = str } }, Cmd.none )

        OnFormFieldSetBody str ->
            let
                oldPost =
                    model.formPost
            in
                ( { model | formPost = { oldPost | body = str } }, Cmd.none )

        OnFormFieldSetNotes str ->
            let
                oldPost =
                    model.formPost
            in
                ( { model | formPost = { oldPost | notes = Just str } }, Cmd.none )

        OnCrudNewSubmit ->
            ( model, mutationCreatePost graphqlEndpoint model.formPost )

        OnCrudNewResult result ->
            case result of
                RemoteData.NotAsked ->
                    ( model, Cmd.none )

                RemoteData.Loading ->
                    ( model, Cmd.none )

                RemoteData.Failure err ->
                    ( model, Cmd.none )

                RemoteData.Success formPost ->
                    ( { model | formPost = formPost }, Navigation.newUrl ("/post/" ++ formPost.id) )

        OnCrudEditSubmit ->
            ( model, mutationUpdatePost graphqlEndpoint model.formPost )

        OnCrudEditResult result ->
            case result of
                RemoteData.NotAsked ->
                    ( model, Cmd.none )

                RemoteData.Loading ->
                    ( model, Cmd.none )

                RemoteData.Failure err ->
                    ( model, Cmd.none )

                RemoteData.Success formPost ->
                    ( { model | formPost = formPost }, Navigation.newUrl ("/post/" ++ formPost.id) )



---- VIEW ----


view : CrudRoute -> PostModel -> Html Msg
view crudroute model =
    case crudroute of
        CrudNew ->
            div [ class "card-body" ]
                [ a [ href "/post" ] [ text "< Post" ]
                , h1 [ class "card-title" ] [ text "New Post" ]
                , form [ onSubmit OnCrudNewSubmit ]
                    [ text ""
                    , formField <|
                        { label = "Title"
                        , name = "title"
                        , placeholder = ""
                        , value = ""
                        , hint = ""
                        , msgTag = OnFormFieldSetTitle
                        }
                    , formField <|
                        { label = "Author"
                        , name = "author"
                        , placeholder = ""
                        , value = ""
                        , hint = ""
                        , msgTag = OnFormFieldSetAuthor
                        }
                    , formField <|
                        { label = "Body"
                        , name = "body"
                        , placeholder = ""
                        , value = ""
                        , hint = ""
                        , msgTag = OnFormFieldSetBody
                        }
                    , formField <|
                        { label = "Notes"
                        , name = "notes"
                        , placeholder = ""
                        , value = ""
                        , hint = ""
                        , msgTag = OnFormFieldSetNotes
                        }
                    , formSubmitOrCancel "/post"
                    ]
                ]

        CrudEdit postID ->
            case model.postByID of
                RemoteData.NotAsked ->
                    div [] [ text "Not asked" ]

                RemoteData.Loading ->
                    div [] [ text "Loading" ]

                RemoteData.Failure err ->
                    div [] [ text (toString err) ]

                RemoteData.Success post ->
                    div [ class "card-body" ]
                        [ a [ href "/post" ] [ text "< Post" ]
                        , h1 [ class "card-title" ] [ text ("Edit " ++ toString postID) ]
                        , form [ onSubmit OnCrudEditSubmit ]
                            [ text ""
                            , formField <|
                                { label = "Title"
                                , name = "title"
                                , placeholder = ""
                                , value = post.title
                                , hint = ""
                                , msgTag = OnFormFieldSetTitle
                                }
                            , formField <|
                                { label = "Author"
                                , name = "author"
                                , placeholder = ""
                                , value = post.author
                                , hint = ""
                                , msgTag = OnFormFieldSetAuthor
                                }
                            , formField <|
                                { label = "Body"
                                , name = "body"
                                , placeholder = ""
                                , value = post.body
                                , hint = ""
                                , msgTag = OnFormFieldSetBody
                                }
                            , formField <|
                                { label = "Notes"
                                , name = "notes"
                                , placeholder = ""
                                , value = (toString post.notes)
                                , hint = ""
                                , msgTag = OnFormFieldSetNotes
                                }
                            , formSubmitOrCancel "/post"
                            ]
                        ]

        CrudShow postID ->
            case model.postByID of
                RemoteData.NotAsked ->
                    div [] [ text "Not asked" ]

                RemoteData.Loading ->
                    div [] [ text "Loading" ]

                RemoteData.Failure err ->
                    div [] [ text (toString err) ]

                RemoteData.Success post ->
                    div [ class "card-body" ]
                        [ a [ href "/post" ]
                            [ text "← Posts" ]
                        , h1 [ class "card-title" ] [ text ("Show Post #" ++ toString postID) ]
                        , table []
                            [ tbody []
                                [ tr []
                                    [ tr []
                                        [ th []
                                            [ text "ID" ]
                                        , td []
                                            [ text post.id ]
                                        ]
                                    , tr []
                                        [ th []
                                            [ text "Title" ]
                                        , td []
                                            [ text post.title ]
                                        ]
                                    , tr []
                                        [ th []
                                            [ text "Author" ]
                                        , td []
                                            [ text post.author ]
                                        ]
                                    , tr []
                                        [ th []
                                            [ text "Body" ]
                                        , td []
                                            [ text post.body ]
                                        ]
                                    , tr []
                                        [ th []
                                            [ text "Notes" ]
                                        , td []
                                            [ text (toString post.notes) ]
                                        ]
                                    , tr []
                                        [ th []
                                            [ text "CreatedAt" ]
                                        , td []
                                            [ text (toString post.createdAt) ]
                                        ]
                                    , tr []
                                        [ th []
                                            [ text "UpdatedAt" ]
                                        , td []
                                            [ text (toString post.updatedAt) ]
                                        ]
                                    ]
                                ]
                            ]
                        , a [ href ("/post/" ++ post.id ++ "/edit") ]
                            [ button [ class "btn btn-secondary" ]
                                [ text "Edit" ]
                            ]
                        ]

        CrudList ->
            case model.searchPosts of
                RemoteData.NotAsked ->
                    div [] [ text "Not asked" ]

                RemoteData.Loading ->
                    div [] [ text "Loading" ]

                RemoteData.Failure err ->
                    div [] [ text (toString err) ]

                RemoteData.Success posts ->
                    div [ class "card-body" ]
                        [ a [ href "/" ] [ text "< Home" ]
                        , h1 [ class "card-title" ] [ text "Posts" ]
                        , div [ class "float-right" ]
                            [ a [ href "/post/new" ]
                                [ button [ class "btn btn-primary" ] [ text "New Post ..." ] ]
                            ]
                        , table [ class "table table-hover" ]
                            [ thead []
                                [ tr []
                                    [ text ""
                                    , th []
                                        [ text "ID" ]
                                    , th []
                                        [ text "Title" ]
                                    , th []
                                        [ text "Author" ]
                                    , th []
                                        [ text "Body" ]
                                    , th []
                                        [ text "Notes" ]
                                    , th []
                                        [ text "CreatedAt" ]
                                    , th []
                                        [ text "UpdatedAt" ]
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
                                    (\post ->
                                        tr []
                                            [ text ""
                                            , td []
                                                [ a [ href ("/post/" ++ post.id) ]
                                                    [ text post.id ]
                                                ]
                                            , td []
                                                [ a [ href ("/post/" ++ post.id) ]
                                                    [ text post.title ]
                                                ]
                                            , td []
                                                [ a [ href ("/post/" ++ post.id) ]
                                                    [ text post.author ]
                                                ]
                                            , td []
                                                [ a [ href ("/post/" ++ post.id) ]
                                                    [ text post.body ]
                                                ]
                                            , td []
                                                [ a [ href ("/post/" ++ post.id) ]
                                                    [ text (toString post.notes) ]
                                                ]
                                            , td []
                                                [ a [ href ("/post/" ++ post.id) ]
                                                    [ text (toString post.createdAt) ]
                                                ]
                                            , td []
                                                [ a [ href ("/post/" ++ post.id) ]
                                                    [ text (toString post.updatedAt) ]
                                                ]
                                            ]
                                    )
                                    posts
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


updateModelByLocation : PostModel -> CrudRoute -> ( PostModel, Cmd Msg )
updateModelByLocation model route =
    case route of
        CrudList ->
            ( model, querySearchPosts graphqlEndpoint model )

        CrudNew ->
            ( model, Cmd.none )

        CrudShow idInt ->
            ( model, queryPostByID graphqlEndpoint (toString idInt) )

        CrudEdit idInt ->
            ( model, queryPostByID graphqlEndpoint (toString idInt) )
