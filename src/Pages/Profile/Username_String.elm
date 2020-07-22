module Pages.Profile.Username_String exposing (Model, Msg, Params, page)

import Api.Article exposing (Article)
import Api.Article.Filters as Filters exposing (Filters)
import Api.Data exposing (Data)
import Api.Profile exposing (Profile)
import Api.Token exposing (Token)
import Api.User exposing (User)
import Components.ArticleList
import Components.IconButton as IconButton
import Components.NotFound
import Html exposing (..)
import Html.Attributes exposing (class, classList, href, src)
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
    { username : String }


type alias Model =
    { username : String
    , user : Maybe User
    , profile : Data Profile
    , articles : Data (List Article)
    , selectedTab : Tab
    }


type Tab
    = MyArticles
    | FavoritedArticles


init : Shared.Model -> Url Params -> ( Model, Cmd Msg )
init shared { params } =
    let
        token : Maybe Token
        token =
            Maybe.map .token shared.user
    in
    ( { username = params.username
      , user = shared.user
      , profile = Api.Data.Loading
      , articles = Api.Data.Loading
      , selectedTab = MyArticles
      }
    , Cmd.batch
        [ Api.Profile.get
            { token = token
            , username = params.username
            , onResponse = GotProfile
            }
        , fetchArticlesBy token params.username
        ]
    )


fetchArticlesBy : Maybe Token -> String -> Cmd Msg
fetchArticlesBy token username =
    Api.Article.list
        { token = token
        , filters =
            Filters.create
                |> Filters.byAuthor username
        , onResponse = GotArticles
        }


fetchArticlesFavoritedBy : Maybe Token -> String -> Cmd Msg
fetchArticlesFavoritedBy token username =
    Api.Article.list
        { token = token
        , filters =
            Filters.create |> Filters.favoritedBy username
        , onResponse = GotArticles
        }



-- UPDATE


type Msg
    = GotProfile (Data Profile)
    | GotArticles (Data { articles : List Article, count : Int })
    | Clicked Tab
    | ClickedFavorite User Article
    | ClickedUnfavorite User Article
    | UpdatedArticle (Data Article)
    | ClickedFollow User Profile
    | ClickedUnfollow User Profile


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotProfile profile ->
            ( { model | profile = profile }
            , Cmd.none
            )

        ClickedFollow user profile ->
            ( model
            , Api.Profile.follow
                { token = user.token
                , username = profile.username
                , onResponse = GotProfile
                }
            )

        ClickedUnfollow user profile ->
            ( model
            , Api.Profile.unfollow
                { token = user.token
                , username = profile.username
                , onResponse = GotProfile
                }
            )

        GotArticles articles ->
            ( { model | articles = Api.Data.map .articles articles }
            , Cmd.none
            )

        Clicked MyArticles ->
            ( { model
                | selectedTab = MyArticles
                , articles = Api.Data.Loading
              }
            , fetchArticlesBy (Maybe.map .token model.user) model.username
            )

        Clicked FavoritedArticles ->
            ( { model
                | selectedTab = FavoritedArticles
                , articles = Api.Data.Loading
              }
            , fetchArticlesFavoritedBy (Maybe.map .token model.user) model.username
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
    { title = "Profile"
    , body =
        case model.profile of
            Api.Data.Success profile ->
                [ viewProfile profile model ]

            Api.Data.Failure _ ->
                [ Components.NotFound.view ]

            _ ->
                []
    }


viewProfile : Profile -> Model -> Html Msg
viewProfile profile model =
    let
        isViewingOwnProfile : Bool
        isViewingOwnProfile =
            Maybe.map .username model.user == Just profile.username

        viewUserInfo : Html Msg
        viewUserInfo =
            div [ class "user-info" ]
                [ div [ class "container" ]
                    [ div [ class "row" ]
                        [ div [ class "col-xs-12 col-md-10 offset-md-1" ]
                            [ img [ class "user-img", src profile.image ] []
                            , h4 [] [ text profile.username ]
                            , Utils.Maybe.view profile.bio
                                (\bio -> p [] [ text bio ])
                            , if isViewingOwnProfile then
                                text ""

                              else
                                Utils.Maybe.view model.user <|
                                    \user ->
                                        if profile.following then
                                            IconButton.view
                                                { color = IconButton.FilledGray
                                                , icon = IconButton.Plus
                                                , label = "Unfollow " ++ profile.username
                                                , onClick = ClickedUnfollow user profile
                                                }

                                        else
                                            IconButton.view
                                                { color = IconButton.OutlinedGray
                                                , icon = IconButton.Plus
                                                , label = "Follow " ++ profile.username
                                                , onClick = ClickedFollow user profile
                                                }
                            ]
                        ]
                    ]
                ]

        viewTabRow : Html Msg
        viewTabRow =
            div [ class "articles-toggle" ]
                [ ul [ class "nav nav-pills outline-active" ]
                    (List.map viewTab [ MyArticles, FavoritedArticles ])
                ]

        viewTab : Tab -> Html Msg
        viewTab tab =
            li [ class "nav-item" ]
                [ button
                    [ class "nav-link"
                    , Events.onClick (Clicked tab)
                    , classList [ ( "active", tab == model.selectedTab ) ]
                    ]
                    [ text
                        (case tab of
                            MyArticles ->
                                "My Articles"

                            FavoritedArticles ->
                                "Favorited Articles"
                        )
                    ]
                ]
    in
    div [ class "profile-page" ]
        [ viewUserInfo
        , div [ class "container" ]
            [ div [ class "row" ]
                [ div [ class "col-xs-12 col-md-10 offset-md-1" ]
                    (viewTabRow
                        :: Components.ArticleList.view
                            { user = model.user
                            , articles = model.articles
                            , onFavorite = ClickedFavorite
                            , onUnfavorite = ClickedUnfavorite
                            }
                    )
                ]
            ]
        ]
