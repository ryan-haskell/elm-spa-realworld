module Api.Article exposing
    ( Article, decoder
    , Listing, updateArticle
    , list, feed
    , get, create, update, delete
    , favorite, unfavorite
    )

{-|

@docs Article, decoder
@docs Listing, updateArticle
@docs list, feed
@docs get, create, update, delete
@docs favorite, unfavorite

-}

import Api.Article.Filters as Filters exposing (Filters)
import Api.Data exposing (Data)
import Api.Profile exposing (Profile)
import Api.Token exposing (Token)
import Http
import Iso8601
import Json.Decode as Json
import Json.Encode as Encode
import Time
import Utils.Json exposing (withField)


type alias Article =
    { slug : String
    , title : String
    , description : String
    , body : String
    , tags : List String
    , createdAt : Time.Posix
    , updatedAt : Time.Posix
    , favorited : Bool
    , favoritesCount : Int
    , author : Profile
    }


decoder : Json.Decoder Article
decoder =
    Utils.Json.record Article
        |> withField "slug" Json.string
        |> withField "title" Json.string
        |> withField "description" Json.string
        |> withField "body" Json.string
        |> withField "tagList" (Json.list Json.string)
        |> withField "createdAt" Iso8601.decoder
        |> withField "updatedAt" Iso8601.decoder
        |> withField "favorited" Json.bool
        |> withField "favoritesCount" Json.int
        |> withField "author" Api.Profile.decoder


type alias Listing =
    { articles : List Article
    , page : Int
    , totalPages : Int
    }


updateArticle : Article -> Listing -> Listing
updateArticle article listing =
    let
        articles : List Article
        articles =
            List.map
                (\a ->
                    if a.slug == article.slug then
                        article

                    else
                        a
                )
                listing.articles
    in
    { listing | articles = articles }



-- ENDPOINTS


itemsPerPage : Int
itemsPerPage =
    25


list :
    { token : Maybe Token
    , filters : Filters
    , page : Int
    , onResponse : Data Listing -> msg
    }
    -> Cmd msg
list options =
    Api.Token.get options.token
        { url = "https://conduit.productionready.io/api/articles/" ++ Filters.toQueryString options.page options.filters
        , expect =
            Api.Data.expectJson options.onResponse
                (paginatedDecoder options.page)
        }


feed :
    { token : Token
    , page : Int
    , onResponse : Data Listing -> msg
    }
    -> Cmd msg
feed options =
    Api.Token.get (Just options.token)
        { url = "https://conduit.productionready.io/api/articles/feed" ++ Filters.pageQueryParameters options.page
        , expect =
            Api.Data.expectJson options.onResponse
                (paginatedDecoder options.page)
        }


get :
    { slug : String
    , token : Maybe Token
    , onResponse : Data Article -> msg
    }
    -> Cmd msg
get options =
    Api.Token.get options.token
        { url = "https://conduit.productionready.io/api/articles/" ++ options.slug
        , expect =
            Api.Data.expectJson options.onResponse
                (Json.field "article" decoder)
        }


create :
    { token : Token
    , article :
        { article
            | title : String
            , description : String
            , body : String
            , tags : List String
        }
    , onResponse : Data Article -> msg
    }
    -> Cmd msg
create options =
    let
        body : Json.Value
        body =
            Encode.object
                [ ( "article"
                  , Encode.object
                        [ ( "title", Encode.string options.article.title )
                        , ( "description", Encode.string options.article.description )
                        , ( "body", Encode.string options.article.body )
                        , ( "tagList", Encode.list Encode.string options.article.tags )
                        ]
                  )
                ]
    in
    Api.Token.post (Just options.token)
        { url = "https://conduit.productionready.io/api/articles"
        , body = Http.jsonBody body
        , expect =
            Api.Data.expectJson options.onResponse
                (Json.field "article" decoder)
        }


update :
    { token : Token
    , slug : String
    , article :
        { article
            | title : String
            , description : String
            , body : String
        }
    , onResponse : Data Article -> msg
    }
    -> Cmd msg
update options =
    let
        body : Json.Value
        body =
            Encode.object
                [ ( "article"
                  , Encode.object
                        [ ( "title", Encode.string options.article.title )
                        , ( "description", Encode.string options.article.description )
                        , ( "body", Encode.string options.article.body )
                        ]
                  )
                ]
    in
    Api.Token.put (Just options.token)
        { url = "https://conduit.productionready.io/api/articles/" ++ options.slug
        , body = Http.jsonBody body
        , expect =
            Api.Data.expectJson options.onResponse
                (Json.field "article" decoder)
        }


delete :
    { token : Token
    , slug : String
    , onResponse : Data Article -> msg
    }
    -> Cmd msg
delete options =
    Api.Token.delete (Just options.token)
        { url = "https://conduit.productionready.io/api/articles/" ++ options.slug
        , expect =
            Api.Data.expectJson options.onResponse
                (Json.field "article" decoder)
        }


favorite :
    { token : Token
    , slug : String
    , onResponse : Data Article -> msg
    }
    -> Cmd msg
favorite options =
    Api.Token.post (Just options.token)
        { url = "https://conduit.productionready.io/api/articles/" ++ options.slug ++ "/favorite"
        , body = Http.emptyBody
        , expect =
            Api.Data.expectJson options.onResponse
                (Json.field "article" decoder)
        }


unfavorite :
    { token : Token
    , slug : String
    , onResponse : Data Article -> msg
    }
    -> Cmd msg
unfavorite options =
    Api.Token.delete (Just options.token)
        { url = "https://conduit.productionready.io/api/articles/" ++ options.slug ++ "/favorite"
        , expect =
            Api.Data.expectJson options.onResponse
                (Json.field "article" decoder)
        }



-- INTERNALS


paginatedDecoder : Int -> Json.Decoder Listing
paginatedDecoder page =
    let
        multipleArticles : List Article -> Int -> Listing
        multipleArticles articles count =
            { articles = articles
            , page = page
            , totalPages = count // itemsPerPage
            }
    in
    Json.map2 multipleArticles
        (Json.field "articles" (Json.list decoder))
        (Json.field "articlesCount" Json.int)
