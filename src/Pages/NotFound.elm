module Pages.NotFound exposing (page)

import Components.NotFound
import Html exposing (..)


page : { title : String, body : List (Html msg) }
page =
    { title = "404"
    , body =
        [ Components.NotFound.view
        ]
    }
