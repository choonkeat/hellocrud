module Convert exposing (..)


convertWithDefault : (a -> Result err b) -> a -> b -> b
convertWithDefault convertToB a b =
    let
        result =
            convertToB a
    in
        case result of
            Result.Ok bb ->
                bb

            Result.Err err ->
                b
