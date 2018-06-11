module Style exposing (..)

import Html exposing (Html, a, button, div, input, label, small, text)
import Html.Attributes exposing (class, href, name, placeholder, type_, defaultValue)
import Html.Events exposing (onInput)


type alias InputField a =
    { label : String
    , name : String
    , value : String
    , placeholder : String
    , hint : String
    , msgTag : String -> a
    }


formField : InputField a -> Html a
formField inputField =
    div [ class "form-group row" ]
        [ label [ class "col-sm-2 col-form-label" ]
            [ text inputField.label ]
        , input
            [ class "form-control col-sm-10"
            , onInput inputField.msgTag
            , name inputField.name
            , defaultValue inputField.value
            , placeholder inputField.placeholder
            , type_ "text"
            ]
            []
        , small
            [ class "form-text text-muted offset-sm-2" ]
            [ text inputField.hint ]
        ]


formSubmitOrCancel : String -> Html msg
formSubmitOrCancel cancelPath =
    div [ class "form-group row" ]
        [ div [ class "offset-sm-2" ]
            [ button [ class "btn btn-primary", type_ "submit" ]
                [ text "Submit" ]
            , text " "
            , a
                [ href cancelPath ]
                [ text "Cancel" ]
            ]
        ]
