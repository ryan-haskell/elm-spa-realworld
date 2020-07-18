module Pages.Editor.ArticleSlug_String exposing (Model, Msg, Params, page)

import Api.Article exposing (Article)
import Api.Data exposing (Data)
import Api.User exposing (User)
import Browser.Navigation exposing (Key)
import Components.Editor exposing (Field, Form)
import Html exposing (..)
import Html.Attributes exposing (class)
import Shared
import Spa.Document exposing (Document)
import Spa.Generated.Route as Route
import Spa.Page as Page exposing (Page)
import Spa.Url as Url exposing (Url)
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
    { articleSlug : String }


type alias Model =
    { key : Key
    , user : Maybe User
    , slug : String
    , form : Maybe Form
    , article : Data Article
    }


init : Shared.Model -> Url Params -> ( Model, Cmd Msg )
init shared { params } =
    ( { key = shared.key
      , user = shared.user
      , slug = params.articleSlug
      , form = Nothing
      , article = Api.Data.Loading
      }
    , Api.Article.get
        { token = shared.user |> Maybe.map .token
        , slug = params.articleSlug
        , onResponse = LoadedInitialArticle
        }
    )



-- UPDATE


type Msg
    = SubmittedForm User Form
    | Updated Field String
    | UpdatedArticle (Data Article)
    | LoadedInitialArticle (Data Article)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LoadedInitialArticle article ->
            case article of
                Api.Data.Success a ->
                    ( { model
                        | form =
                            Just <|
                                { title = a.title
                                , description = a.description
                                , body = a.body
                                , tags = String.join ", " a.tags
                                }
                      }
                    , Cmd.none
                    )

                _ ->
                    ( model, Cmd.none )

        Updated field value ->
            ( { model
                | form =
                    Maybe.map
                        (Components.Editor.updateField field value)
                        model.form
              }
            , Cmd.none
            )

        SubmittedForm user form ->
            ( model
            , Api.Article.update
                { token = user.token
                , slug = model.slug
                , article =
                    { title = form.title
                    , description = form.description
                    , body = form.body
                    , tags =
                        form.tags
                            |> String.split ","
                            |> List.map String.trim
                    }
                , onResponse = UpdatedArticle
                }
            )

        UpdatedArticle article ->
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
    { title = "Editing Article"
    , body =
        case model.form of
            Just form ->
                [ Components.Editor.view
                    { onFormSubmit = SubmittedForm user form
                    , form = form
                    , onUpdate = Updated
                    , label = "Edit Article"
                    , article = model.article
                    }
                ]

            Nothing ->
                []
    }
