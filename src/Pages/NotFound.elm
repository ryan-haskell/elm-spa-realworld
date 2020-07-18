module Pages.NotFound exposing (Model, Msg, Params, page)

import Html exposing (..)
import Html.Attributes exposing (class, href)
import Spa.Document exposing (Document)
import Spa.Page as Page exposing (Page)
import Spa.Url exposing (Url)


type alias Params =
    ()


type alias Model =
    Url Params


type alias Msg =
    Never


page : Page Params Model Msg
page =
    Page.static
        { view = view
        }



-- VIEW


view : Url Params -> Document Msg
view { params } =
    { title = "404"
    , body =
        [ div [ class "container page" ]
            [ h2 [] [ text "Page not found." ]
            , h5 []
                [ text "But here's the "
                , a [ href "/" ] [ text "homepage" ]
                , text "!"
                ]
            ]
        ]
    }
