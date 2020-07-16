module Shared exposing
    ( Flags
    , Model
    , Msg
    , init
    , subscriptions
    , update
    , view
    )

import Browser.Navigation exposing (Key)
import Components.Footer
import Components.Navbar
import Html exposing (..)
import Html.Attributes exposing (class)
import Spa.Document exposing (Document)
import Url exposing (Url)
import Json.Decode as Json
import Api.User exposing (User)


-- INIT


type alias Flags =
    Json.Value


type alias Model =
    { url : Url
    , key : Key
    , user : Maybe User
    }


init : Flags -> Url -> Key -> ( Model, Cmd Msg )
init json url key =
    let
        user =
            json
                |> Json.decodeValue (Json.field "user" Api.User.decoder)
                |> Result.toMaybe
                
    in
    ( Model url key user
    , Cmd.none
    )



-- UPDATE


type Msg
    = ReplaceMe


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ReplaceMe ->
            ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view :
    { page : Document msg, toMsg : Msg -> msg }
    -> Model
    -> Document msg
view { page, toMsg } model =
    { title = page.title
    , body =
        [ div [ class "layout" ]
            [ Components.Navbar.view
            , div [ class "page" ] page.body
            , Components.Footer.view
            ]
        ]
    }
