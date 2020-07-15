module Api.Article exposing (Article, decoder)

import Api.Profile exposing (Profile)
import Iso8601
import Json.Decode as Json
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
