module Components.Navbar exposing (view)

import Api.User exposing (User)
import Gen.Route as Route exposing (Route)
import Html exposing (..)
import Html.Attributes exposing (class, classList, href)
import Html.Events as Events


view :
    { user : Maybe User
    , currentRoute : Route
    , onSignOut : msg
    }
    -> Html msg
view options =
    nav [ class "navbar navbar-light" ]
        [ text "ここにヘッダーを実装してね★ミ"]


viewLink : Route -> ( String, Route ) -> Html msg
viewLink currentRoute ( label, route ) =
    li [ class "nav-item" ]
        [ a
            [ class "nav-link"
            , classList [ ( "active", currentRoute == route ) ]
            , href (Route.toHref route)
            ]
            [ text label ]
        ]
