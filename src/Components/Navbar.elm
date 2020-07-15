module Components.Navbar exposing (view)

import Html exposing (..)
import Html.Attributes exposing (class, href)


view : Html msg
view =
    nav [ class "navbar navbar-light" ]
        [ div [ class "container" ]
            [ a [ class "navbar-brand", href "/" ] [ text "conduit" ]
            , ul [ class "nav navbar-nav pull-xs-right" ]
                [ li [ class "nav-item" ]
                    [ a [ class "nav-link active", href "/" ] [ text "Home" ]
                    ]
                , li [ class "nav-item" ]
                    [ a [ class "nav-link", href "/editor" ]
                        [ i [ class "ion-compose" ] []
                        , text "New Post"
                        ]
                    ]
                , li [ class "nav-item" ]
                    [ a [ class "nav-link", href "/settings" ]
                        [ i [ class "ion-gear-a" ] []
                        , text "Settings"
                        ]
                    ]
                , li [ class "nav-item" ]
                    [ a [ class "nav-link", href "/register" ]
                        [ text "Sign up" ]
                    ]
                ]
            ]
        ]
