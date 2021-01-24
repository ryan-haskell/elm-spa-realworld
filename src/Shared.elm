module Shared exposing
    ( Flags
    , Model
    , Msg
    , init
    , subscriptions
    , update
    , view
    )

import Api.User exposing (User)
import Browser.Navigation exposing (Key)
import Components.Footer
import Components.Navbar
import Html exposing (..)
import Html.Attributes exposing (class)
import Json.Decode as Json
import Ports
import Request exposing (Request)
import Spa.Document exposing (Document)
import Url exposing (Url)
import Utils.Route



-- INIT


type alias Flags =
    Json.Value


type alias Model =
    { url : Url
    , key : Key
    , user : Maybe User
    }


init : Request () -> Flags -> ( Model, Cmd Msg )
init { url, key } json =
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
    = ClickedSignOut


update : Request () -> Msg -> Model -> ( Model, Cmd Msg )
update _ msg model =
    case msg of
        ClickedSignOut ->
            ( { model | user = Nothing }
            , Ports.clearUser
            )


subscriptions : Request () -> Model -> Sub Msg
subscriptions _ _ =
    Sub.none



-- VIEW


view :
    { page : Document msg, toMsg : Msg -> msg }
    -> Model
    -> Document msg
view { page, toMsg } model =
    { title =
        if String.isEmpty page.title then
            "Conduit"

        else
            page.title ++ " | Conduit"
    , body =
        [ div [ class "layout" ]
            [ Components.Navbar.view
                { user = model.user
                , currentRoute = Utils.Route.fromUrl model.url
                , onSignOut = toMsg ClickedSignOut
                }
            , div [ class "page" ] page.body
            , Components.Footer.view
            ]
        ]
    }
