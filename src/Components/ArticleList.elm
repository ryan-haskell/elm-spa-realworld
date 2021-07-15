module Components.ArticleList exposing (view)

import Api.Article exposing (Article)
import Api.Data exposing (Data)
import Api.User exposing (User)
import Components.IconButton as IconButton
import Html exposing (..)
import Html.Attributes exposing (alt, class, classList, href, src)
import Html.Events as Events
import Utils.Maybe
import Utils.Time


view :
    { user : Maybe User
    , articleListing : Data Api.Article.Listing
    , onFavorite : User -> Article -> msg
    , onUnfavorite : User -> Article -> msg
    , onPageClick : Int -> msg
    }
    -> List (Html msg)
view options =
    case options.articleListing of
        Api.Data.Loading ->
            [ div [ class "article-preview" ] [ text "Loading..." ] ]

        Api.Data.Success listing ->
            let
                viewPage : Int -> Html msg
                viewPage page =
                    li
                        [ class "page-item"
                        , classList [ ( "active", listing.page == page ) ]
                        ]
                        [ button
                            [ class "page-link"
                            , Events.onClick (options.onPageClick page)
                            ]
                            [ text (String.fromInt page) ]
                        ]
            in
            List.concat
                [ List.map (viewArticlePreview options) listing.articles
                , [ List.range 1 listing.totalPages
                        |> List.map viewPage
                        |> ul [ class "pagination" ]
                  ]
                ]

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
        [ div [ class "article-meta" ][ text "ここに記事のメタ情報表示を実装してね★ミ"]
        , div [] [text "ここに記事情報の表示を実装してね★ミ"]
        ]
