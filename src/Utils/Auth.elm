module Utils.Auth exposing (protected)

import Api.User exposing (User)
import Html exposing (..)
import Html.Attributes exposing (class, href)
import View exposing (View)


protected :
    (User -> { model | user : Maybe User } -> View msg)
    -> { model | user : Maybe User }
    -> View msg
protected view model =
    case model.user of
        Just user ->
            view user model

        Nothing ->
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
