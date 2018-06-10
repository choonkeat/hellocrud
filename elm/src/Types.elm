module Types exposing (..)

import RemoteData exposing (WebData)
import Json.Decode
import Json.Decode.Pipeline exposing (required)


---- MODEL ----


type Route
    = HomePage
    | NotFoundPage
    | CommentPage (CrudRoute Comment)


type alias ID =
    String


type alias Pagination =
    { page : Maybe Int
    , since : Maybe ID
    }


type CrudRoute thing
    = CrudNew
    | CrudEdit (WebData thing) ID
    | CrudShow (WebData thing) ID
    | CrudList (WebData (List thing)) Pagination


type alias Flags =
    {}


type alias Model =
    { route : Route
    , comment : CommentModel
    }


type alias CommentModel =
    { route : CrudRoute Comment
    , searchComments : WebData (List Comment)
    , commentByID : WebData Comment
    , formComment : Comment
    }


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
