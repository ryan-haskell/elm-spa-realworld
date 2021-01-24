module Utils.Auth exposing (protected)

import Api.User exposing (User)
import Html exposing (..)
import Html.Attributes exposing (class, href)
import Shared
import View exposing (View)


protected :
    Shared.Model
    -> (User -> model -> View msg)
    -> model
    -> View msg
protected shared view =
    case shared.user of
        Just user ->
            view user

        Nothing ->
            \_ ->
                { title = "401"
                , body =
                    [ div [ class "container page" ]
                        [ h2 [] [ text "Not signed in." ]
                        , h5 []
                            [ text "Please "
                            , a [ href "/login" ] [ text "sign in" ]
                            , text " to view this page."
                            ]
                        ]
                    ]
                }
