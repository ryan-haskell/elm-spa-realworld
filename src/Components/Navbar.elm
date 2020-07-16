module Components.Navbar exposing (view)

import Api.User exposing (User)
import Html exposing (..)
import Html.Attributes exposing (class, classList, href)
import Html.Events as Events
import Spa.Generated.Route as Route exposing (Route)


view :
    { user : Maybe User
    , currentRoute : Route
    , onSignOut : msg
    }
    -> Html msg
view options =
    nav [ class "navbar navbar-light" ]
        [ div [ class "container" ]
            [ a [ class "navbar-brand", href (Route.toString Route.Top) ] [ text "conduit" ]
            , ul [ class "nav navbar-nav pull-xs-right" ] <|
                case options.user of
                    Just user ->
                        List.concat
                            [ List.map (viewLink options.currentRoute) <|
                                [ ( "Home", Route.Top )
                                , ( "New Post", Route.Editor )
                                , ( "Settings", Route.Settings )
                                , ( user.username
                                  , Route.Profile__Username_String
                                        { username = user.username }
                                  )
                                ]
                            , [ li [ class "nav-item" ]
                                    [ a
                                        [ class "nav-link"
                                        , Events.onClick options.onSignOut
                                        ]
                                        [ text "Sign out" ]
                                    ]
                              ]
                            ]

                    Nothing ->
                        List.map (viewLink options.currentRoute) <|
                            [ ( "Home", Route.Top )
                            , ( "Sign in", Route.Login )
                            , ( "Sign up", Route.Register )
                            ]
            ]
        ]


viewLink : Route -> ( String, Route ) -> Html msg
viewLink currentRoute ( label, route ) =
    li [ class "nav-item" ]
        [ a
            [ class "nav-link"
            , classList [ ( "active", currentRoute == route ) ]
            , href (Route.toString route)
            ]
            [ text label ]
        ]
