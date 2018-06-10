module Comment exposing (..)

import Convert
import Html exposing (Html, a, button, code, div, form, h1, hr, img, input, label, small, table, tbody, td, text, th, thead, tr)
import Html.Attributes exposing (attribute, class, href, method, name, placeholder, style, type_, value)
import Html.Events exposing (onInput, onSubmit, onWithOptions)
import Http
import Json.Decode
import Json.Encode
import Json.Encode.Extra
import Navigation
import RemoteData exposing (WebData)
import Style exposing (InputField, formField, formSubmitOrCancel)
import Types exposing (CommentModel, CrudRoute, CrudRoute(..), Pagination, Route, graphqlEndpoint)
import UrlParser exposing ((</>), s, string)


-- Comment and its APIs


querySearchComments : String -> CommentModel -> Cmd Msg
querySearchComments graphqlEndpoint model =
    let
        body =
            Json.Encode.object
                [ ( "query", Json.Encode.string """
                  query {
                    searchComments {
                      nodes {
                        id
                        postID
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
        Http.post graphqlEndpoint (Http.jsonBody body) (Json.Decode.at [ "data", "searchComments", "nodes" ] decodeSearchComments)
            |> RemoteData.sendRequest
            |> Cmd.map OnSearchComments


decodeSearchComments : Json.Decode.Decoder (List Types.Comment)
decodeSearchComments =
    Json.Decode.list Types.commentDecoder


queryCommentByID : String -> Types.ID -> Cmd Msg
queryCommentByID graphqlEndpoint idInt =
    let
        body =
            Json.Encode.object
                [ ( "query", Json.Encode.string """
                  query commentByID($id: ID!) {
                    commentByID(id: $id) {
                      id
                      postID
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
        Http.post graphqlEndpoint (Http.jsonBody body) (Json.Decode.at [ "data", "commentByID" ] decodeCommentByID)
            |> RemoteData.sendRequest
            |> Cmd.map OnCommentByID


decodeCommentByID : Json.Decode.Decoder Types.Comment
decodeCommentByID =
    Types.commentDecoder


mutationCreateComment : String -> Types.Comment -> Cmd Msg
mutationCreateComment graphqlEndpoint comment =
    let
        body =
            Json.Encode.object
                [ ( "query", Json.Encode.string """
                  mutation mutation($input: CreateCommentInput!){
                    createComment(input:$input) {
                      id
                      postID
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
                                , ( "postID", Json.Encode.int comment.postID )
                                , ( "author", Json.Encode.string comment.author )
                                , ( "body", Json.Encode.string comment.body )
                                , ( "notes", Json.Encode.Extra.maybe Json.Encode.string comment.notes )
                                ]
                          )
                        ]
                  )
                ]
    in
        Http.post graphqlEndpoint (Http.jsonBody body) (Json.Decode.at [ "data", "createComment" ] decodeCreateComment)
            |> RemoteData.sendRequest
            |> Cmd.map OnCrudNewResult


decodeCreateComment : Json.Decode.Decoder Types.Comment
decodeCreateComment =
    Types.commentDecoder


mutationUpdateComment : String -> Types.Comment -> Cmd Msg
mutationUpdateComment graphqlEndpoint comment =
    let
        body =
            Json.Encode.object
                [ ( "query", Json.Encode.string """
                  mutation mutation($id: ID!, $input: UpdateCommentInput!){
                    updateCommentByID(id:$id,input:$input) {
                      id
                      postID
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
                          , Json.Encode.string comment.id
                          )
                        , ( "input"
                          , Json.Encode.object
                                [ ( "_deleteme", Json.Encode.Extra.maybe Json.Encode.string Nothing )
                                , ( "postID", Json.Encode.int comment.postID )
                                , ( "author", Json.Encode.string comment.author )
                                , ( "body", Json.Encode.string comment.body )
                                , ( "notes", Json.Encode.Extra.maybe Json.Encode.string comment.notes )
                                ]
                          )
                        ]
                  )
                ]
    in
        Http.post graphqlEndpoint (Http.jsonBody body) (Json.Decode.at [ "data", "updateCommentByID" ] decodeUpdateComment)
            |> RemoteData.sendRequest
            |> Cmd.map OnCrudEditResult


decodeUpdateComment : Json.Decode.Decoder Types.Comment
decodeUpdateComment =
    Types.commentDecoder



---- MODEL ----


nopagination : Types.Pagination
nopagination =
    Types.Pagination Maybe.Nothing Maybe.Nothing


init : ( CommentModel, Cmd Msg )
init =
    let
        model =
            CommentModel
                (CrudList RemoteData.NotAsked nopagination)
                RemoteData.NotAsked
                RemoteData.NotAsked
                (Types.Comment "" 0 "" "" Maybe.Nothing Maybe.Nothing Maybe.Nothing)
    in
        updateModelByLocation model model.route



---- UPDATE ----


type Msg
    = OnSearchComments (WebData (List Types.Comment))
    | OnCommentByID (WebData Types.Comment)
    | OnFormFieldSetPostID String
    | OnFormFieldSetAuthor String
    | OnFormFieldSetBody String
    | OnFormFieldSetNotes String
    | OnCrudNewSubmit
    | OnCrudNewResult (WebData Types.Comment)
    | OnCrudEditSubmit
    | OnCrudEditResult (WebData Types.Comment)


update : Msg -> CommentModel -> ( CommentModel, Cmd Msg )
update msg model =
    case msg of
        OnSearchComments resp ->
            ( { model | searchComments = resp, route = CrudList resp nopagination }, Cmd.none )

        OnCommentByID resp ->
            let
                formComment =
                    case resp of
                        RemoteData.NotAsked ->
                            model.formComment

                        RemoteData.Loading ->
                            model.formComment

                        RemoteData.Failure err ->
                            model.formComment

                        RemoteData.Success a ->
                            a
            in
                ( { model | commentByID = resp, formComment = formComment }, Cmd.none )

        OnFormFieldSetPostID str ->
            let
                oldComment =
                    model.formComment

                newValue =
                    Convert.convertWithDefault String.toInt str 0
            in
                ( { model | formComment = { oldComment | postID = newValue } }, Cmd.none )

        OnFormFieldSetAuthor str ->
            let
                oldComment =
                    model.formComment
            in
                ( { model | formComment = { oldComment | author = str } }, Cmd.none )

        OnFormFieldSetBody str ->
            let
                oldComment =
                    model.formComment
            in
                ( { model | formComment = { oldComment | body = str } }, Cmd.none )

        OnFormFieldSetNotes str ->
            let
                oldComment =
                    model.formComment
            in
                ( { model | formComment = { oldComment | notes = Just str } }, Cmd.none )

        OnCrudNewSubmit ->
            ( model, mutationCreateComment graphqlEndpoint model.formComment )

        OnCrudNewResult result ->
            case result of
                RemoteData.NotAsked ->
                    ( model, Cmd.none )

                RemoteData.Loading ->
                    ( model, Cmd.none )

                RemoteData.Failure err ->
                    ( model, Cmd.none )

                RemoteData.Success formComment ->
                    ( { model | formComment = formComment }, Navigation.newUrl ("/comment/" ++ formComment.id) )

        OnCrudEditSubmit ->
            ( model, mutationUpdateComment graphqlEndpoint model.formComment )

        OnCrudEditResult result ->
            case result of
                RemoteData.NotAsked ->
                    ( model, Cmd.none )

                RemoteData.Loading ->
                    ( model, Cmd.none )

                RemoteData.Failure err ->
                    ( model, Cmd.none )

                RemoteData.Success formComment ->
                    ( { model | formComment = formComment }, Navigation.newUrl ("/comment/" ++ formComment.id) )



---- VIEW ----


view : CrudRoute Types.Comment -> CommentModel -> Html Msg
view crudroute model =
    case crudroute of
        CrudNew ->
            div [ class "card-body" ]
                [ a [ href "/comment" ] [ text "< Comment" ]
                , h1 [ class "card-title" ] [ text "New Comment" ]
                , form [ onSubmit OnCrudNewSubmit ]
                    [ text ""
                    , formField <|
                        { label = "PostID"
                        , name = "postID"
                        , placeholder = ""
                        , value = ""
                        , hint = ""
                        , msgTag = OnFormFieldSetPostID
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
                    , formSubmitOrCancel "/comment"
                    ]
                ]

        CrudEdit thing id ->
            case thing of
                RemoteData.NotAsked ->
                    div [] [ text "Not asked" ]

                RemoteData.Loading ->
                    div [] [ text "Loading" ]

                RemoteData.Failure err ->
                    div [] [ text (toString err) ]

                RemoteData.Success comment ->
                    div [ class "card-body" ]
                        [ a [ href "/comment" ] [ text "< Comment" ]
                        , h1 [ class "card-title" ] [ text ("Edit " ++ id) ]
                        , form [ onSubmit OnCrudEditSubmit ]
                            [ text ""
                            , formField <|
                                { label = "PostID"
                                , name = "postID"
                                , placeholder = ""
                                , value = (toString comment.postID)
                                , hint = ""
                                , msgTag = OnFormFieldSetPostID
                                }
                            , formField <|
                                { label = "Author"
                                , name = "author"
                                , placeholder = ""
                                , value = comment.author
                                , hint = ""
                                , msgTag = OnFormFieldSetAuthor
                                }
                            , formField <|
                                { label = "Body"
                                , name = "body"
                                , placeholder = ""
                                , value = comment.body
                                , hint = ""
                                , msgTag = OnFormFieldSetBody
                                }
                            , formField <|
                                { label = "Notes"
                                , name = "notes"
                                , placeholder = ""
                                , value = (toString comment.notes)
                                , hint = ""
                                , msgTag = OnFormFieldSetNotes
                                }
                            , formSubmitOrCancel "/comment"
                            ]
                        ]

        CrudShow thing id ->
            case thing of
                RemoteData.NotAsked ->
                    div [] [ text "Not asked" ]

                RemoteData.Loading ->
                    div [] [ text "Loading" ]

                RemoteData.Failure err ->
                    div [] [ text (toString err) ]

                RemoteData.Success comment ->
                    div [ class "card-body" ]
                        [ a [ href "/comment" ]
                            [ text "← Comments" ]
                        , h1 [ class "card-title" ] [ text ("Show Comment #" ++ id) ]
                        , table []
                            [ tbody []
                                [ tr []
                                    [ tr []
                                        [ th []
                                            [ text "ID" ]
                                        , td []
                                            [ text comment.id ]
                                        ]
                                    , tr []
                                        [ th []
                                            [ text "PostID" ]
                                        , td []
                                            [ text (toString comment.postID) ]
                                        ]
                                    , tr []
                                        [ th []
                                            [ text "Author" ]
                                        , td []
                                            [ text comment.author ]
                                        ]
                                    , tr []
                                        [ th []
                                            [ text "Body" ]
                                        , td []
                                            [ text comment.body ]
                                        ]
                                    , tr []
                                        [ th []
                                            [ text "Notes" ]
                                        , td []
                                            [ text (toString comment.notes) ]
                                        ]
                                    , tr []
                                        [ th []
                                            [ text "CreatedAt" ]
                                        , td []
                                            [ text (toString comment.createdAt) ]
                                        ]
                                    , tr []
                                        [ th []
                                            [ text "UpdatedAt" ]
                                        , td []
                                            [ text (toString comment.updatedAt) ]
                                        ]
                                    ]
                                ]
                            ]
                        , a [ href ("/comment/" ++ comment.id ++ "/edit") ]
                            [ button [ class "btn btn-secondary" ]
                                [ text "Edit" ]
                            ]
                        ]

        CrudList things pagination ->
            case things of
                RemoteData.NotAsked ->
                    div [] [ text "Not asked" ]

                RemoteData.Loading ->
                    div [] [ text "Loading" ]

                RemoteData.Failure err ->
                    div [] [ text (toString err) ]

                RemoteData.Success comments ->
                    div [ class "card-body" ]
                        [ a [ href "/" ] [ text "< Home" ]
                        , h1 [ class "card-title" ] [ text "Comments" ]
                        , div [ class "float-right" ]
                            [ a [ href "/comment/new" ]
                                [ button [ class "btn btn-primary" ] [ text "New Comment ..." ] ]
                            ]
                        , table [ class "table table-hover" ]
                            [ thead []
                                [ tr []
                                    [ text ""
                                    , th []
                                        [ text "ID" ]
                                    , th []
                                        [ text "PostID" ]
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
                                    (\comment ->
                                        tr []
                                            [ text ""
                                            , td []
                                                [ a [ href ("/comment/" ++ comment.id) ]
                                                    [ text comment.id ]
                                                ]
                                            , td []
                                                [ a [ href ("/comment/" ++ comment.id) ]
                                                    [ text (toString comment.postID) ]
                                                ]
                                            , td []
                                                [ a [ href ("/comment/" ++ comment.id) ]
                                                    [ text comment.author ]
                                                ]
                                            , td []
                                                [ a [ href ("/comment/" ++ comment.id) ]
                                                    [ text comment.body ]
                                                ]
                                            , td []
                                                [ a [ href ("/comment/" ++ comment.id) ]
                                                    [ text (toString comment.notes) ]
                                                ]
                                            , td []
                                                [ a [ href ("/comment/" ++ comment.id) ]
                                                    [ text (toString comment.createdAt) ]
                                                ]
                                            , td []
                                                [ a [ href ("/comment/" ++ comment.id) ]
                                                    [ text (toString comment.updatedAt) ]
                                                ]
                                            ]
                                    )
                                    comments
                                )
                            ]
                        ]



---- ROUTING ----


routes : UrlParser.Parser (CrudRoute a -> c) c
routes =
    UrlParser.oneOf
        [ UrlParser.map (CrudList RemoteData.NotAsked (Types.Pagination Nothing Nothing)) UrlParser.top
        , UrlParser.map CrudNew (s "new")
        , UrlParser.map (CrudShow RemoteData.NotAsked) UrlParser.string
        , UrlParser.map (CrudEdit RemoteData.NotAsked) (UrlParser.string </> s "edit")
        ]


updateModelByLocation : CommentModel -> CrudRoute thing -> ( CommentModel, Cmd Msg )
updateModelByLocation model route =
    case route of
        CrudList things pagination ->
            case things of
                RemoteData.NotAsked ->
                    ( model, querySearchComments graphqlEndpoint model )

                RemoteData.Loading ->
                    ( model, Cmd.none )

                RemoteData.Failure err ->
                    ( model, Cmd.none )

                RemoteData.Success comments ->
                    ( model, Cmd.none )

        CrudNew ->
            ( model, Cmd.none )

        CrudShow thing id ->
            case thing of
                RemoteData.NotAsked ->
                    ( model, Cmd.none )

                RemoteData.Loading ->
                    ( model, Cmd.none )

                RemoteData.Failure err ->
                    ( model, Cmd.none )

                RemoteData.Success comments ->
                    ( model, queryCommentByID graphqlEndpoint id )

        CrudEdit thing id ->
            case thing of
                RemoteData.NotAsked ->
                    ( model, Cmd.none )

                RemoteData.Loading ->
                    ( model, Cmd.none )

                RemoteData.Failure err ->
                    ( model, Cmd.none )

                RemoteData.Success comments ->
                    ( model, queryCommentByID graphqlEndpoint id )
