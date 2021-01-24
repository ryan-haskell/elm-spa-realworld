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
import Page exposing (Page)
import Request exposing (Request)
import Shared
import Spa.Document exposing (Document)
import Spa.Url exposing (Url)
import Utils.Maybe


page : Shared.Model -> Request Params -> Page Model Msg
page shared _ =
    Page.element
        { init = init shared
        , update = update
        , subscriptions = subscriptions
        , view = view
        }



-- INIT


type alias Params =
    ()


type alias Model =
    { user : Maybe User
    , listing : Data Api.Article.Listing
    , page : Int
    , tags : Data (List Tag)
    , activeTab : Tab
    }


type Tab
    = FeedFor User
    | Global
    | TagFilter Tag


init : Shared.Model -> ( Model, Cmd Msg )
init shared =
    let
        activeTab : Tab
        activeTab =
            shared.user
                |> Maybe.map FeedFor
                |> Maybe.withDefault Global

        model : Model
        model =
            { user = shared.user
            , listing = Api.Data.Loading
            , page = 1
            , tags = Api.Data.Loading
            , activeTab = activeTab
            }
    in
    ( model
    , Cmd.batch
        [ fetchArticlesForTab model
        , Api.Article.Tag.list { onResponse = GotTags }
        ]
    )


fetchArticlesForTab :
    { model
        | user : Maybe User
        , page : Int
        , activeTab : Tab
    }
    -> Cmd Msg
fetchArticlesForTab model =
    case model.activeTab of
        Global ->
            Api.Article.list
                { filters = Filters.create
                , page = model.page
                , token = Maybe.map .token model.user
                , onResponse = GotArticles
                }

        FeedFor user ->
            Api.Article.feed
                { token = user.token
                , page = model.page
                , onResponse = GotArticles
                }

        TagFilter tag ->
            Api.Article.list
                { filters =
                    Filters.create
                        |> Filters.withTag tag
                , page = model.page
                , token = Maybe.map .token model.user
                , onResponse = GotArticles
                }



-- UPDATE


type Msg
    = GotArticles (Data Api.Article.Listing)
    | GotTags (Data (List Tag))
    | SelectedTab Tab
    | ClickedFavorite User Article
    | ClickedUnfavorite User Article
    | ClickedPage Int
    | UpdatedArticle (Data Article)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotArticles listing ->
            ( { model | listing = listing }
            , Cmd.none
            )

        GotTags tags ->
            ( { model | tags = tags }
            , Cmd.none
            )

        SelectedTab tab ->
            let
                newModel : Model
                newModel =
                    { model
                        | activeTab = tab
                        , listing = Api.Data.Loading
                        , page = 1
                    }
            in
            ( newModel
            , fetchArticlesForTab newModel
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

        ClickedPage page_ ->
            let
                newModel : Model
                newModel =
                    { model
                        | listing = Api.Data.Loading
                        , page = page_
                    }
            in
            ( newModel
            , fetchArticlesForTab newModel
            )

        UpdatedArticle (Api.Data.Success article) ->
            ( { model
                | listing =
                    Api.Data.map (Api.Article.updateArticle article)
                        model.listing
              }
            , Cmd.none
            )

        UpdatedArticle _ ->
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
                                , articleListing = model.listing
                                , onFavorite = ClickedFavorite
                                , onUnfavorite = ClickedUnfavorite
                                , onPageClick = ClickedPage
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
