module Pages.Top exposing (Model, Msg, Params, page)

import Api.Article exposing (Article)
import Api.Article.Filters as Filters
import Api.Article.Tag exposing (Tag)
import Api.Data exposing (Data)
import Api.User exposing (User)
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (class, classList, href, src)
import Html.Events as Events
import Shared
import Spa.Document exposing (Document)
import Spa.Page as Page exposing (Page)
import Spa.Url exposing (Url)
import Url
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
    { user : Maybe User
    , articles : Data (List Article)
    , page : Int
    , tags : Data (List Tag)
    , activeTab : Tab
    }


type Tab
    = FeedFor User
    | Global
    | TagFilter Tag


init : Shared.Model -> Url Params -> ( Model, Cmd Msg )
init shared _ =
    ( { user = shared.user
      , page = 1
      , articles = Api.Data.Loading
      , tags = Api.Data.Loading
      , activeTab = Global
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
    | SelectedTab Tab


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

        SelectedTab tab ->
            ( { model
                | activeTab = tab
                , articles = Api.Data.Loading
                , page = 1
              }
            , Api.Article.list
                { filters =
                    case tab of
                        Global ->
                            Filters.create

                        FeedFor user ->
                            Filters.create
                                |> Filters.favoritedBy user.username

                        TagFilter tag ->
                            Filters.create
                                |> Filters.withTag tag
                , token = Maybe.map .token model.user
                , onResponse = GotArticles
                }
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
                        (viewTabs model :: viewArticles model.articles)
                    , div [ class "col-md-3" ] [ viewTags model.tags ]
                    ]
                ]
            ]
        ]
    }


viewTabs :
    { model
        | activeTab : Tab
        , user : Maybe User
    }
    -> Html Msg
viewTabs model =
    div [ class "feed-toggle" ]
        [ ul [ class "nav nav-pills outline-active" ]
            [ case model.user of
                Just user ->
                    li [ class "nav-item" ]
                        [ button
                            [ class "nav-link"
                            , classList [ ( "active", model.activeTab == FeedFor user ) ]
                            , Events.onClick (SelectedTab (FeedFor user))
                            ]
                            [ text "Your Feed" ]
                        ]

                Nothing ->
                    text ""
            , li [ class "nav-item" ]
                [ button
                    [ class "nav-link"
                    , classList [ ( "active", model.activeTab == Global ) ]
                    , Events.onClick (SelectedTab Global)
                    ]
                    [ text "Global Feed" ]
                ]
            , case model.activeTab of
                TagFilter tag ->
                    li [ class "nav-item" ] [ a [ class "nav-link active" ] [ text ("#" ++ tag) ] ]

                _ ->
                    text ""
            ]
        ]


viewArticles : Data (List Article) -> List (Html msg)
viewArticles data =
    case data of
        Api.Data.Loading ->
            [ div [ class "article-preview" ] [ text "Loading..." ] ]

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


viewTags : Data (List Tag) -> Html Msg
viewTags data =
    case data of
        Api.Data.Success tags ->
            div [ class "sidebar" ]
                [ p [] [ text "Popular Tags" ]
                , div [ class "tag-list" ] <|
                    List.map
                        (\tag ->
                            button
                                [ class "tag-pill tag-default"
                                , Events.onClick (SelectedTab (TagFilter tag))
                                ]
                                [ text tag ]
                        )
                        tags
                ]

        _ ->
            text ""
