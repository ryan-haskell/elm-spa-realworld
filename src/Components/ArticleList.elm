module Components.ArticleList exposing (view)

import Api.Article exposing (Article)
import Api.Data exposing (Data)
import Api.User exposing (User)
import Components.IconButton as IconButton
import Html exposing (..)
import Html.Attributes exposing (alt, class, href, src)
import Utils.Maybe
import Utils.Time


view :
    { user : Maybe User
    , articles : Data (List Article)
    , onFavorite : User -> Article -> msg
    , onUnfavorite : User -> Article -> msg
    }
    -> List (Html msg)
view data =
    case data.articles of
        Api.Data.Loading ->
            [ div [ class "article-preview" ] [ text "Loading..." ] ]

        Api.Data.Success articles ->
            List.map (viewArticlePreview data) articles

        _ ->
            []


viewArticlePreview :
    { options
        | user : Maybe User
        , onFavorite : User -> Article -> msg
        , onUnfavorite : User -> Article -> msg
    }
    -> Article
    -> Html msg
viewArticlePreview options article =
    div [ class "article-preview" ]
        [ div [ class "article-meta" ]
            [ a [ href ("/profile/" ++ article.author.username) ]
                [ img [ src article.author.image, alt article.author.username ] []
                ]
            , div [ class "info" ]
                [ a [ class "author", href ("/profile/" ++ article.author.username) ] [ text article.author.username ]
                , span [ class "date" ] [ text (Utils.Time.formatDate article.createdAt) ]
                ]
            , div [ class "pull-xs-right" ]
                [ Utils.Maybe.view options.user <|
                    \user ->
                        if user.username == article.author.username then
                            text ""

                        else if article.favorited then
                            IconButton.view
                                { color = IconButton.FilledGreen
                                , icon = IconButton.Heart
                                , label = " " ++ String.fromInt article.favoritesCount
                                , onClick = options.onUnfavorite user article
                                }

                        else
                            IconButton.view
                                { color = IconButton.OutlinedGreen
                                , icon = IconButton.Heart
                                , label = " " ++ String.fromInt article.favoritesCount
                                , onClick = options.onFavorite user article
                                }
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
                    (List.map
                        (\tag -> li [ class "tag-default tag-pill tag-outline" ] [ text tag ])
                        article.tags
                    )
            ]
        ]
