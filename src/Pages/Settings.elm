module Pages.Settings exposing (Model, Msg, page)

import Api.Data exposing (Data)
import Api.User exposing (User)
import Components.ErrorList
import Effect exposing (Effect)
import Html exposing (..)
import Html.Attributes exposing (attribute, class, placeholder, type_, value)
import Html.Events as Events
import Page exposing (Page)
import Ports
import Request exposing (Request)
import Shared
import Utils.Maybe
import View exposing (View)


page : Shared.Model -> Request -> Page.With Model Msg
page shared _ =
    Page.protected.advanced
        (\user ->
            { init = init shared
            , update = update
            , subscriptions = subscriptions
            , view = view user
            }
        )



-- INIT


type alias Model =
    { image : String
    , username : String
    , bio : String
    , email : String
    , password : Maybe String
    , message : Maybe String
    , errors : List String
    }


init : Shared.Model -> ( Model, Effect Msg )
init shared =
    ( case shared.user of
        Just user ->
            { image = user.image
            , username = user.username
            , bio = user.bio |> Maybe.withDefault ""
            , email = user.email
            , password = Nothing
            , message = Nothing
            , errors = []
            }

        Nothing ->
            { image = ""
            , username = ""
            , bio = ""
            , email = ""
            , password = Nothing
            , message = Nothing
            , errors = []
            }
    , Effect.none
    )



-- UPDATE


type Msg
    = Updated Field String
    | SubmittedForm User
    | GotUser (Data User)


type Field
    = Image
    | Username
    | Bio
    | Email
    | Password


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        Updated Image value ->
            ( { model | image = value }, Effect.none )

        Updated Username value ->
            ( { model | username = value }, Effect.none )

        Updated Bio value ->
            ( { model | bio = value }, Effect.none )

        Updated Email value ->
            ( { model | email = value }, Effect.none )

        Updated Password value ->
            ( { model | password = Just value }, Effect.none )

        SubmittedForm user ->
            ( { model | message = Nothing, errors = [] }
            , Effect.fromCmd <|
                Api.User.update
                    { token = user.token
                    , user = model
                    , onResponse = GotUser
                    }
            )

        GotUser (Api.Data.Success user) ->
            ( { model | message = Just "User updated!" }
            , Effect.batch
                [ Effect.fromCmd (Ports.saveUser user)
                , Effect.fromShared (Shared.SignedInUser user)
                ]
            )

        GotUser (Api.Data.Failure reasons) ->
            ( { model | errors = reasons }
            , Effect.none
            )

        GotUser _ ->
            ( model, Effect.none )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : User -> Model -> View Msg
view user model =
    { title = "Settings"
    , body =
        [ div [ class "settings-page" ]
            [ div [ class "container page" ]
                [ div [ class "row" ]
                    [ div [ class "col-md-6 offset-md-3 col-xs-12" ]
                        [ h1 [ class "text-xs-center" ] [ text "Your Settings" ]
                        , br [] []
                        , Components.ErrorList.view model.errors
                        , Utils.Maybe.view model.message <|
                            \message ->
                                p [ class "text-success" ] [ text message ]
                        , form [ Events.onSubmit (SubmittedForm user) ]
                            [ fieldset []
                                [ fieldset [ class "form-group" ]
                                    [ input
                                        [ class "form-control"
                                        , placeholder "URL of profile picture"
                                        , type_ "text"
                                        , value model.image
                                        , Events.onInput (Updated Image)
                                        ]
                                        []
                                    ]
                                , fieldset [ class "form-group" ]
                                    [ input
                                        [ class "form-control form-control-lg"
                                        , placeholder "Your Username"
                                        , type_ "text"
                                        , value model.username
                                        , Events.onInput (Updated Username)
                                        ]
                                        []
                                    ]
                                , fieldset [ class "form-group" ]
                                    [ textarea
                                        [ class "form-control form-control-lg"
                                        , placeholder "Short bio about you"
                                        , attribute "rows" "8"
                                        , value model.bio
                                        , Events.onInput (Updated Bio)
                                        ]
                                        []
                                    ]
                                , fieldset [ class "form-group" ]
                                    [ input
                                        [ class "form-control form-control-lg"
                                        , placeholder "Email"
                                        , type_ "text"
                                        , value model.email
                                        , Events.onInput (Updated Email)
                                        ]
                                        []
                                    ]
                                , fieldset [ class "form-group" ]
                                    [ input
                                        [ class "form-control form-control-lg"
                                        , placeholder "Password"
                                        , type_ "password"
                                        , value (Maybe.withDefault "" model.password)
                                        , Events.onInput (Updated Password)
                                        ]
                                        []
                                    ]
                                , button [ class "btn btn-lg btn-primary pull-xs-right" ] [ text "Update Settings" ]
                                ]
                            ]
                        ]
                    ]
                ]
            ]
        ]
    }
