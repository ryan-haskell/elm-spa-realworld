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
import Url exposing (Url)
import Utils.Route
import View exposing (View)



-- INIT


type alias Flags =
    Json.Value


type alias Model =
    { user : Maybe User
    }


init : Request () -> Flags -> ( Model, Cmd Msg )
init _ json =
    let
        user =
            json
                |> Json.decodeValue (Json.field "user" Api.User.decoder)
                |> Result.toMaybe
    in
    ( Model user
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
    Request ()
    -> { page : View msg, toMsg : Msg -> msg }
    -> Model
    -> View msg
view req { page, toMsg } model =
    { title =
        if String.isEmpty page.title then
            "Conduit"

        else
            page.title ++ " | Conduit"
    , body =
        [ div [ class "layout" ]
            [ Components.Navbar.view
                { user = model.user
                , currentRoute = Utils.Route.fromUrl req.url
                , onSignOut = toMsg ClickedSignOut
                }
            , div [ class "page" ] page.body
            , Components.Footer.view
            ]
        ]
    }
