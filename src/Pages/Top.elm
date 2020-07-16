module Pages.Top exposing (Model, Msg, Params, page)

import Api.Article exposing (Article)
import Api.Article.Filters as Filters
import Api.Article.Tag exposing (Tag)
import Api.Data exposing (Data)
import Html exposing (..)
import Html.Attributes exposing (class, href, src)
import Shared
import Spa.Document exposing (Document)
import Spa.Page as Page exposing (Page)
import Spa.Url exposing (Url)
import Utils.Time


page : Page Params Model Msg
page =
    Page.application
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        , save = save
        , load = load
        }



-- INIT


type alias Params =
    ()


type alias Model =
    { articles : Data (List Article)
    , page : Int
    , tags : Data (List Tag)
    }


init : Shared.Model -> Url Params -> ( Model, Cmd Msg )
init shared { params } =
    ( { page = 1
      , articles = Api.Data.Loading
      , tags = Api.Data.Loading
      }
    , Cmd.batch
        [ Api.Article.list
            { filters = Filters.create
            , token = Maybe.map .token shared.user
            , onResponse = GotArticles
            }
        , Api.Article.Tag.list { onResponse = GotTags }
        ]
    )



-- UPDATE


type Msg
    = GotArticles (Data { articles : List Article, count : Int })
    | GotTags (Data (List Tag))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotArticles data ->
            ( { model | articles = Api.Data.map .articles data }
            , Cmd.none
            )

        GotTags tags ->
            ( { model | tags = tags }
            , Cmd.none
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


view : Model -> Document Msg
view model =
    { title = ""
    , body =
        [ div [ class "home-page" ]
            [ div [ class "banner" ]
                [ div [ class "container" ]
                    [ h1 [ class "logo-font" ] [ text "conduit" ]
                    , p [] [ text "A place to share your knowledge." ]
                    ]
                ]
            , div [ class "container page" ]
                [ div [ class "row" ]
                    [ div [ class "col-md-9" ] <|
                        (viewTabs :: viewArticles model.articles)
                    , div [ class "col-md-3" ] [ viewTags model.tags ]
                    ]
                ]
            ]
        ]
    }


viewTabs : Html msg
viewTabs =
    div [ class "feed-toggle" ]
        [ ul [ class "nav nav-pills outline-active" ]
            [ -- li [ class "nav-item" ]
              -- [ a [ class "nav-link disabled", href "" ] [ text "Your Feed" ]
              -- ]
              -- ,
              li [ class "nav-item" ]
                [ a [ class "nav-link active", href "" ] [ text "Global Feed" ]
                ]
            ]
        ]


viewArticles : Data (List Article) -> List (Html msg)
viewArticles data =
    case data of
        Api.Data.Success articles ->
            List.map viewArticlePreview articles

        _ ->
            []


viewArticlePreview : Article -> Html msg
viewArticlePreview article =
    div [ class "article-preview" ]
        [ div [ class "article-meta" ]
            [ a [ href ("/profile/" ++ article.author.username) ]
                [ img
                    [ src
                        (article.author.image
                            |> Maybe.withDefault "https://static.productionready.io/images/smiley-cyrus.jpg"
                        )
                    ]
                    []
                ]
            , div [ class "info" ]
                [ a [ class "author", href ("/profile/" ++ article.author.username) ] [ text article.author.username ]
                , span [ class "date" ] [ text (Utils.Time.formatDate article.createdAt) ]
                ]
            , button [ class "btn btn-outline-primary btn-sm pull-xs-right" ]
                [ i [ class "ion-heart" ] []
                , text " "
                , text (String.fromInt article.favoritesCount)
                ]
            ]
        , a [ class "preview-link", href ("/article/" ++ article.slug) ]
            [ h1 [] [ text article.title ]
            , p [] [ text article.description ]
            , span [] [ text "Read more..." ]
            , if List.isEmpty article.tags then
                text ""

              else
                ul [ class "tag-list" ]
                    (List.map (\tag -> li [ class "tag-default tag-pill tag-outline" ] [ text tag ]) article.tags)
            ]
        ]


viewTags : Data (List Tag) -> Html msg
viewTags data =
    case data of
        Api.Data.Success tags ->
            div [ class "sidebar" ]
                [ p [] [ text "Popular Tags" ]
                , div [ class "tag-list" ] <|
                    List.map (\tag -> a [ class "tag-pill tag-default", href ("#" ++ tag) ] [ text tag ])
                        tags
                ]

        _ ->
            text ""
