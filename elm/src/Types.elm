module Types exposing (..)

import RemoteData exposing (WebData)
import Json.Decode
import Json.Decode.Pipeline exposing (required)


---- MODEL ----


type Route
    = HomePage
    | NotFoundPage
    | PostPage CrudRoute
    | CommentPage CrudRoute


type CrudRoute
    = CrudNew
    | CrudEdit Int
    | CrudShow Int
    | CrudList


type alias Flags =
    {}


type alias Model =
    { route : Route
    , post : PostModel
    , comment : CommentModel
    }


type alias PostModel =
    { searchPosts : WebData (List Post)
    , postByID : WebData Post
    , formPost : Post
    }


type alias CommentModel =
    { searchComments : WebData (List Comment)
    , commentByID : WebData Comment
    , formComment : Comment
    }


type alias Post =
    { id : String
    , title : String
    , author : String
    , body : String
    , notes : Maybe String
    , createdAt : Maybe String
    , updatedAt : Maybe String
    }


postDecoder : Json.Decode.Decoder Post
postDecoder =
    Json.Decode.Pipeline.decode Post
        |> required "id" (Json.Decode.string)
        |> required "title" (Json.Decode.string)
        |> required "author" (Json.Decode.string)
        |> required "body" (Json.Decode.string)
        |> required "notes" (Json.Decode.maybe Json.Decode.string)
        |> required "createdAt" (Json.Decode.maybe Json.Decode.string)
        |> required "updatedAt" (Json.Decode.maybe Json.Decode.string)


type alias Comment =
    { id : String
    , postID : Int
    , author : String
    , body : String
    , notes : Maybe String
    , createdAt : Maybe String
    , updatedAt : Maybe String
    }


commentDecoder : Json.Decode.Decoder Comment
commentDecoder =
    Json.Decode.Pipeline.decode Comment
        |> required "id" (Json.Decode.string)
        |> required "postID" (Json.Decode.int)
        |> required "author" (Json.Decode.string)
        |> required "body" (Json.Decode.string)
        |> required "notes" (Json.Decode.maybe Json.Decode.string)
        |> required "createdAt" (Json.Decode.maybe Json.Decode.string)
        |> required "updatedAt" (Json.Decode.maybe Json.Decode.string)


graphqlEndpoint : String
graphqlEndpoint =
    "http://localhost:5000/graphql"
