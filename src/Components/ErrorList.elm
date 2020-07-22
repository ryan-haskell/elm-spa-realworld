module Components.ErrorList exposing (view)

import Html exposing (..)
import Html.Attributes exposing (class)


view : List String -> Html msg
view reasons =
    if List.isEmpty reasons then
        text ""

    else
        ul [ class "error-messages" ]
            (List.map (\message -> li [] [ text message ]) reasons)
