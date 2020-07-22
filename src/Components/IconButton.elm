module Components.IconButton exposing (Color(..), Icon(..), view)

import Html exposing (..)
import Html.Attributes exposing (class)
import Html.Events as Events


type Color
    = OutlinedGray
    | OutlinedGreen
    | OutlinedRed
    | FilledGray
    | FilledGreen


type Icon
    = Plus
    | Heart
    | Trash


view :
    { color : Color
    , icon : Icon
    , label : String
    , onClick : msg
    }
    -> Html msg
view options =
    let
        toIconClass : Icon -> String
        toIconClass icon =
            case icon of
                Plus ->
                    "ion-plus-round"

                Heart ->
                    "ion-heart"

                Trash ->
                    "ion-trash-a"

        toButtonClass : Color -> String
        toButtonClass color =
            case color of
                OutlinedGreen ->
                    "btn-outline-primary"

                OutlinedGray ->
                    "btn-outline-secondary"

                OutlinedRed ->
                    "btn-outline-danger"

                FilledGreen ->
                    "btn-primary"

                FilledGray ->
                    "btn-secondary"
    in
    button
        [ Events.onClick options.onClick
        , class ("btn btn-sm " ++ toButtonClass options.color)
        ]
        [ i [ class (toIconClass options.icon) ] []
        , text options.label
        ]
