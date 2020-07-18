module Pages.Article.Slug_String exposing (Model, Msg, Params, page)

import Api.Article exposing (Article)
import Api.Article.Comment exposing (Comment)
import Api.Data exposing (Data)
import Api.Profile exposing (Profile)
import Api.User exposing (User)
import Html exposing (..)
import Html.Attributes exposing (attribute, class, href, id, placeholder, src, value)
import Html.Events as Events
import Markdown
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
    { slug : String
    }


type alias Model =
    { article : Data Article
    , comments : Data (List Comment)
    , user : Maybe User
    , commentText : String
    }


init : Shared.Model -> Url Params -> ( Model, Cmd Msg )
init shared { params } =
    ( { article = Api.Data.Loading
      , comments = Api.Data.Loading
      , user = shared.user
      , commentText = ""
      }
    , Cmd.batch
        [ Api.Article.get
            { slug = params.slug
            , token = shared.user |> Maybe.map .token
            , onResponse = GotArticle
            }
        , Api.Article.Comment.get
            { token = shared.user |> Maybe.map .token
            , articleSlug = params.slug
            , onResponse = GotComments
            }
        ]
    )



-- UPDATE


type Msg
    = GotArticle (Data Article)
    | ClickedFollow User Profile
    | ClickedUnfollow User Profile
    | GotAuthor (Data Profile)
    | ClickedFavorite User Article
    | ClickedUnfavorite User Article
    | GotComments (Data (List Comment))
    | ClickedDeleteComment User Article Comment
    | DeletedComment (Data Int)
    | SubmittedCommentForm User Article
    | CreatedComment (Data Comment)
    | UpdatedCommentText String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotArticle article ->
            ( { model | article = article }
            , Cmd.none
            )

        ClickedFavorite user article ->
            ( model
            , Api.Article.favorite
                { token = user.token
                , slug = article.slug
                , onResponse = GotArticle
                }
            )

        ClickedUnfavorite user article ->
            ( model
            , Api.Article.unfavorite
                { token = user.token
                , slug = article.slug
                , onResponse = GotArticle
                }
            )

        GotAuthor profile ->
            let
                updateAuthor : Article -> Article
                updateAuthor article =
                    case profile of
                        Api.Data.Success author ->
                            { article | author = author }

                        _ ->
                            article
            in
            ( { model | article = Api.Data.map updateAuthor model.article }
            , Cmd.none
            )

        ClickedFollow user profile ->
            ( model
            , Api.Profile.follow
                { token = user.token
                , username = profile.username
                , onResponse = GotAuthor
                }
            )

        ClickedUnfollow user profile ->
            ( model
            , Api.Profile.unfollow
                { token = user.token
                , username = profile.username
                , onResponse = GotAuthor
                }
            )

        GotComments comments ->
            ( { model | comments = comments }
            , Cmd.none
            )

        UpdatedCommentText text ->
            ( { model | commentText = text }
            , Cmd.none
            )

        SubmittedCommentForm user article ->
            if String.isEmpty model.commentText then
                ( model, Cmd.none )

            else
                ( { model | commentText = "" }
                , Api.Article.Comment.create
                    { token = user.token
                    , articleSlug = article.slug
                    , comment = { body = model.commentText }
                    , onResponse = CreatedComment
                    }
                )

        CreatedComment comment ->
            ( case comment of
                Api.Data.Success c ->
                    { model | comments = Api.Data.map (\comments -> c :: comments) model.comments }

                _ ->
                    model
            , Cmd.none
            )

        ClickedDeleteComment user article comment ->
            ( model
            , Api.Article.Comment.delete
                { token = user.token
                , articleSlug = article.slug
                , commentId = comment.id
                , onResponse = DeletedComment
                }
            )

        DeletedComment id ->
            let
                removeComment : List Comment -> List Comment
                removeComment =
                    List.filter (\comment -> Api.Data.Success comment.id /= id)
            in
            ( { model | comments = Api.Data.map removeComment model.comments }
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
    case model.article of
        Api.Data.Success article ->
            { title = article.title
            , body = [ viewArticle model article ]
            }

        _ ->
            { title = "Article"
            , body = []
            }


viewArticle : Model -> Article -> Html Msg
viewArticle model article =
    div [ class "article-page" ]
        [ div [ class "banner" ]
            [ div [ class "container" ]
                [ h1 [] [ text article.title ]
                , viewArticleMeta model article
                ]
            ]
        , div [ class "container page" ]
            [ div [ class "row article-content" ] [ Markdown.toHtml [ class "col-md-12" ] article.body ]
            , hr [] []
            , div [ class "article-actions" ] [ viewArticleMeta model article ]
            , viewCommentSection model article
            ]
        ]


viewArticleMeta : Model -> Article -> Html Msg
viewArticleMeta model article =
    div [ class "article-meta" ] <|
        List.concat
            [ [ a [ href ("/profile/" ++ article.author.username) ]
                    [ img [ src article.author.image ] []
                    ]
              , div [ class "info" ]
                    [ a [ class "author", href "" ] [ text article.author.username ]
                    , span [ class "date" ] [ text (Utils.Time.formatDate article.createdAt) ]
                    ]
              ]
            , case model.user of
                Just user ->
                    viewControls article user

                Nothing ->
                    []
            ]


viewControls : Article -> User -> List (Html Msg)
viewControls article user =
    [ if article.author.following then
        viewIconButton
            { color = FilledGray
            , icon = Plus
            , label = "Unfollow " ++ article.author.username
            , onClick = ClickedUnfollow user article.author
            }

      else
        viewIconButton
            { color = OutlinedGray
            , icon = Plus
            , label = "Follow " ++ article.author.username
            , onClick = ClickedFollow user article.author
            }
    , if article.favorited then
        viewIconButton
            { color = FilledGreen
            , icon = Heart
            , label = "Unfavorite Post (" ++ String.fromInt article.favoritesCount ++ ")"
            , onClick = ClickedUnfavorite user article
            }

      else
        viewIconButton
            { color = OutlinedGreen
            , icon = Heart
            , label = "Favorite Post (" ++ String.fromInt article.favoritesCount ++ ")"
            , onClick = ClickedFavorite user article
            }
    ]


viewCommentSection : Model -> Article -> Html Msg
viewCommentSection model article =
    div [ class "row" ]
        [ div [ class "col-xs-12 col-md-8 offset-md-2" ] <|
            List.concat
                [ case model.user of
                    Just user ->
                        [ viewCommentForm model user article ]

                    Nothing ->
                        []
                , case model.comments of
                    Api.Data.Success comments ->
                        List.map (viewComment model.user article) comments

                    _ ->
                        []
                ]
        ]


viewCommentForm : Model -> User -> Article -> Html Msg
viewCommentForm model user article =
    form [ class "card comment-form", Events.onSubmit (SubmittedCommentForm user article) ]
        [ div [ class "card-block" ]
            [ textarea
                [ class "form-control"
                , placeholder "Write a comment..."
                , attribute "rows" "3"
                , value model.commentText
                , Events.onInput UpdatedCommentText
                ]
                []
            ]
        , div [ class "card-footer" ]
            [ img [ class "comment-author-img", src user.image ] []
            , button [ class "btn btn-sm btn-primary" ] [ text "Post Comment" ]
            ]
        ]


viewComment : Maybe User -> Article -> Comment -> Html Msg
viewComment currentUser article comment =
    let
        viewCommentActions =
            case currentUser of
                Just user ->
                    if user.username == comment.author.username then
                        span
                            [ class "mod-options"
                            , Events.onClick (ClickedDeleteComment user article comment)
                            ]
                            [ i [ class "ion-trash-a" ] [] ]

                    else
                        text ""

                Nothing ->
                    text ""
    in
    div [ class "card" ]
        [ div [ class "card-block" ]
            [ p [ class "card-text" ] [ text comment.body ] ]
        , div [ class "card-footer" ]
            [ a
                [ class "comment-author"
                , href ("/profile/" ++ comment.author.username)
                ]
                [ img [ class "comment-author-img", src comment.author.image ] []
                , text comment.author.username
                ]
            , span [ class "date-posted" ] [ text (Utils.Time.formatDate comment.createdAt) ]
            , viewCommentActions
            ]
        ]



-- ICON BUTTONS


type Color
    = OutlinedGray
    | OutlinedGreen
    | FilledGray
    | FilledGreen


type Icon
    = Plus
    | Heart


viewIconButton :
    { color : Color
    , icon : Icon
    , label : String
    , onClick : msg
    }
    -> Html msg
viewIconButton options =
    let
        toIconClass : Icon -> String
        toIconClass icon =
            case icon of
                Plus ->
                    "ion-plus-round"

                Heart ->
                    "ion-heart"

        toButtonClass : Color -> String
        toButtonClass color =
            case color of
                OutlinedGreen ->
                    "btn-outline-primary"

                OutlinedGray ->
                    "btn-outline-secondary"

                FilledGreen ->
                    "btn-primary"

                FilledGray ->
                    "btn-secondary"
    in
    button
        [ Events.onClick options.onClick
        , class ("btn btn-sm " ++ toButtonClass options.color)
        ]
        [ i [ class (toIconClass options.icon) ] []
        , text options.label
        ]
