module Pages.Top exposing (Model, Msg, Params, page)

import Api.Article exposing (Article)
import Api.Article.Filters as Filters
import Api.Article.Tag exposing (Tag)
import Api.Data exposing (Data)
import Api.User exposing (User)
import Components.ArticleList
import Html exposing (..)
import Html.Attributes exposing (class, classList)
import Html.Events as Events
import Shared
import Spa.Document exposing (Document)
import Spa.Page as Page exposing (Page)
import Spa.Url exposing (Url)
import Utils.Maybe


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
    let
        activeTab : Tab
        activeTab =
            shared.user
                |> Maybe.map FeedFor
                |> Maybe.withDefault Global
    in
    ( { user = shared.user
      , page = 1
      , articles = Api.Data.Loading
      , tags = Api.Data.Loading
      , activeTab = activeTab
      }
    , Cmd.batch
        [ fetchArticlesForTab shared activeTab
        , Api.Article.Tag.list { onResponse = GotTags }
        ]
    )


fetchArticlesForTab : { model | user : Maybe User } -> Tab -> Cmd Msg
fetchArticlesForTab model tab =
    case tab of
        Global ->
            Api.Article.list
                { filters = Filters.create
                , token = Maybe.map .token model.user
                , onResponse = GotArticles
                }

        FeedFor user ->
            Api.Article.feed
                { token = user.token
                , page = 1
                , onResponse = GotArticles
                }

        TagFilter tag ->
            Api.Article.list
                { filters =
                    Filters.create
                        |> Filters.withTag tag
                , token = Maybe.map .token model.user
                , onResponse = GotArticles
                }



-- UPDATE


type Msg
    = GotArticles (Data { articles : List Article, count : Int })
    | GotTags (Data (List Tag))
    | SelectedTab Tab
    | ClickedFavorite User Article
    | ClickedUnfavorite User Article
    | UpdatedArticle (Data Article)


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
            , fetchArticlesForTab model tab
            )

        ClickedFavorite user article ->
            ( model
            , Api.Article.favorite
                { token = user.token
                , slug = article.slug
                , onResponse = UpdatedArticle
                }
            )

        ClickedUnfavorite user article ->
            ( model
            , Api.Article.unfavorite
                { token = user.token
                , slug = article.slug
                , onResponse = UpdatedArticle
                }
            )

        UpdatedArticle (Api.Data.Success article) ->
            let
                updateArticle : List Article -> List Article
                updateArticle =
                    List.map
                        (\a ->
                            if a.slug == article.slug then
                                article

                            else
                                a
                        )
            in
            ( { model | articles = Api.Data.map updateArticle model.articles }
            , Cmd.none
            )

        UpdatedArticle _ ->
            ( model, Cmd.none )


save : Model -> Shared.Model -> Shared.Model
save _ shared =
    shared


load : Shared.Model -> Model -> ( Model, Cmd Msg )
load _ model =
    ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions _ =
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
                        (viewTabs model
                            :: Components.ArticleList.view
                                { user = model.user
                                , articles = model.articles
                                , onFavorite = ClickedFavorite
                                , onUnfavorite = ClickedUnfavorite
                                }
                        )
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
            [ Utils.Maybe.view model.user <|
                \user ->
                    li [ class "nav-item" ]
                        [ button
                            [ class "nav-link"
                            , classList [ ( "active", model.activeTab == FeedFor user ) ]
                            , Events.onClick (SelectedTab (FeedFor user))
                            ]
                            [ text "Your Feed" ]
                        ]
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
