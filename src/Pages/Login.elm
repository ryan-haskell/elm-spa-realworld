module Pages.Login exposing (Model, Msg, Params, page)

import Api.Data exposing (Data)
import Api.User exposing (User)
import Browser.Navigation exposing (Key)
import Components.UserForm
import Gen.Route as Route
import Html exposing (..)
import Page exposing (Page)
import Ports
import Request exposing (Request)
import Shared
import Spa.Document exposing (Document)
import Spa.Url exposing (Url)
import Utils.Route


page : Shared.Model -> Request Params -> Page Model Msg
page shared req =
    Page.element
        { init = init shared req
        , update = update
        , subscriptions = subscriptions
        , view = view
        }



-- INIT


type alias Params =
    ()


type alias Model =
    { user : Data User
    , key : Key
    , email : String
    , password : String
    }


init : Shared.Model -> Request Params -> ( Model, Cmd Msg )
init shared { key } =
    ( Model
        (case shared.user of
            Just user ->
                Api.Data.Success user

            Nothing ->
                Api.Data.NotAsked
        )
        key
        ""
        ""
    , Cmd.none
    )



-- UPDATE


type Msg
    = Updated Field String
    | AttemptedSignIn
    | GotUser (Data User)


type Field
    = Email
    | Password


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Updated Email email ->
            ( { model | email = email }
            , Cmd.none
            )

        Updated Password password ->
            ( { model | password = password }
            , Cmd.none
            )

        AttemptedSignIn ->
            ( model
            , Api.User.authentication
                { user =
                    { email = model.email
                    , password = model.password
                    }
                , onResponse = GotUser
                }
            )

        GotUser user ->
            ( { model | user = user }
            , case Api.Data.toMaybe user of
                Just user_ ->
                    Cmd.batch
                        [ Ports.saveUser user_
                        , Utils.Route.navigate model.key Route.Top
                        ]

                Nothing ->
                    Cmd.none
            )


save : Model -> Shared.Model -> Shared.Model
save model shared =
    { shared
        | user =
            case Api.Data.toMaybe model.user of
                Just user ->
                    Just user

                Nothing ->
                    shared.user
    }


load : Shared.Model -> Model -> ( Model, Cmd Msg )
load _ model =
    ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : Model -> Document Msg
view model =
    { title = "Sign in"
    , body =
        [ Components.UserForm.view
            { user = model.user
            , label = "Sign in"
            , onFormSubmit = AttemptedSignIn
            , alternateLink = { label = "Need an account?", route = Route.Register }
            , fields =
                [ { label = "Email"
                  , type_ = "email"
                  , value = model.email
                  , onInput = Updated Email
                  }
                , { label = "Password"
                  , type_ = "password"
                  , value = model.password
                  , onInput = Updated Password
                  }
                ]
            }
        ]
    }
