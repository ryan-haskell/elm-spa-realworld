module Utils.Maybe exposing (view)

import Html exposing (Html)


view : Maybe value -> (value -> Html msg) -> Html msg
view maybe toView =
    case maybe of
        Just value ->
            toView value

        Nothing ->
            Html.text ""
