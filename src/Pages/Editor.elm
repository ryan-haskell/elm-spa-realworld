module Pages.Editor exposing (Model, Msg, page)

import Api.Article exposing (Article)
import Api.Data exposing (Data)
import Api.User exposing (User)
import Components.Editor exposing (Field, Form)
import Gen.Route as Route
import Html exposing (..)
import Page exposing (Page)
import Request exposing (Request)
import Shared
import Utils.Route
import View exposing (View)


page : Shared.Model -> Request -> Page.With Model Msg
page shared req =
    Page.protected.element <|
        \user ->
            { init = init shared
            , update = update req
            , subscriptions = subscriptions
            , view = view user
            }



-- INIT


type alias Model =
    { form : Form
    , article : Data Article
    }


init : Shared.Model -> ( Model, Cmd Msg )
init shared =
    ( { form =
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


update : Request -> Msg -> Model -> ( Model, Cmd Msg )
update req msg model =
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
    { title = "New Article"
    , body =
        [ Components.Editor.view
            { onFormSubmit = SubmittedForm user
            , title = "New Article"
            , form = model.form
            , onUpdate = Updated
            , buttonLabel = "Publish"
            , article = model.article
            }
        ]
    }
