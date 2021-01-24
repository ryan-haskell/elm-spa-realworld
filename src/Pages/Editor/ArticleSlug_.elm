module Pages.Editor.ArticleSlug_ exposing (Model, Msg, Params, page)

import Api.Article exposing (Article)
import Api.Data exposing (Data)
import Api.User exposing (User)
import Browser.Navigation exposing (Key)
import Components.Editor exposing (Field, Form)
import Gen.Route as Route
import Html exposing (..)
import Page exposing (Page)
import Request exposing (Request)
import Shared
import Utils.Auth
import Utils.Route
import View exposing (View)


page : Shared.Model -> Request Params -> Page Model Msg
page shared req =
    Page.element
        { init = init shared req
        , update = update req
        , subscriptions = subscriptions
        , view = Utils.Auth.protected view
        }



-- INIT


type alias Params =
    { articleSlug : String }


type alias Model =
    { user : Maybe User
    , slug : String
    , form : Maybe Form
    , article : Data Article
    }


init : Shared.Model -> Request Params -> ( Model, Cmd Msg )
init shared { params } =
    ( { user = shared.user
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


update : Request Params -> Msg -> Model -> ( Model, Cmd Msg )
update req msg model =
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
                    Utils.Route.navigate req.key
                        (Route.Article__Slug_ { slug = newArticle.slug })

                _ ->
                    Cmd.none
            )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : User -> Model -> View Msg
view user model =
    { title = "Editing Article"
    , body =
        case model.form of
            Just form ->
                [ Components.Editor.view
                    { onFormSubmit = SubmittedForm user form
                    , title = "Edit Article"
                    , form = form
                    , onUpdate = Updated
                    , buttonLabel = "Save"
                    , article = model.article
                    }
                ]

            Nothing ->
                []
    }
