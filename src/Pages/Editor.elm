module Pages.Editor exposing (Model, Msg, Params, page)

import Api.Article exposing (Article)
import Api.Data exposing (Data)
import Api.User exposing (User)
import Browser.Navigation exposing (Key)
import Components.Editor exposing (Field, Form)
import Html exposing (..)
import Html.Attributes exposing (attribute, class, placeholder, type_, value)
import Html.Events as Events
import Shared
import Spa.Document exposing (Document)
import Spa.Generated.Route as Route
import Spa.Page as Page exposing (Page)
import Spa.Url exposing (Url)
import Utils.Auth
import Utils.Route


page : Page Params Model Msg
page =
    Page.application
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = Utils.Auth.protected view
        , save = save
        , load = load
        }



-- INIT


type alias Params =
    ()


type alias Model =
    { key : Key
    , user : Maybe User
    , form : Form
    , article : Data Article
    }


init : Shared.Model -> Url Params -> ( Model, Cmd Msg )
init shared { params } =
    ( { key = shared.key
      , user = shared.user
      , form =
            { title = ""
            , description = ""
            , body = ""
            , tags = ""
            }
      , article = Api.Data.NotAsked
      }
    , Cmd.none
    )



-- UPDATE


type Msg
    = SubmittedForm User
    | Updated Field String
    | GotArticle (Data Article)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Updated field value ->
            ( { model
                | form =
                    Components.Editor.updateField
                        field
                        value
                        model.form
              }
            , Cmd.none
            )

        SubmittedForm user ->
            ( model
            , Api.Article.create
                { token = user.token
                , article =
                    { title = model.form.title
                    , description = model.form.description
                    , body = model.form.body
                    , tags =
                        model.form.tags
                            |> String.split ","
                            |> List.map String.trim
                    }
                , onResponse = GotArticle
                }
            )

        GotArticle article ->
            ( { model | article = article }
            , case article of
                Api.Data.Success newArticle ->
                    Utils.Route.navigate model.key
                        (Route.Article__Slug_String { slug = newArticle.slug })

                _ ->
                    Cmd.none
            )


save : Model -> Shared.Model -> Shared.Model
save model shared =
    shared


load : Shared.Model -> Model -> ( Model, Cmd Msg )
load shared model =
    ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : User -> Model -> Document Msg
view user model =
    { title = "New Article"
    , body =
        [ Components.Editor.view
            { onFormSubmit = SubmittedForm user
            , form = model.form
            , onUpdate = Updated
            , label = "Publish Article"
            , article = model.article
            }
        ]
    }
