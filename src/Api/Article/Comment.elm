module Api.Article.Comment exposing
    ( Comment
    , decoder
    , get, create, delete
    )

{-|

@docs Comment
@docs decoder
@docs get, create, delete

-}

import Api.Data exposing (Data)
import Api.Profile exposing (Profile)
import Api.Token exposing (Token)
import Http
import Iso8601
import Json.Decode as Json
import Json.Encode as Encode
import Time


type alias Comment =
    { id : Int
    , createdAt : Time.Posix
    , updatedAt : Time.Posix
    , body : String
    , author : Profile
    }


decoder : Json.Decoder Comment
decoder =
    Json.map5 Comment
        (Json.field "id" Json.int)
        (Json.field "createdAt" Iso8601.decoder)
        (Json.field "updatedAt" Iso8601.decoder)
        (Json.field "body" Json.string)
        (Json.field "author" Api.Profile.decoder)



-- ENDPOINTS


get :
    { token : Maybe Token
    , articleSlug : String
    , onResponse : Data (List Comment) -> msg
    }
    -> Cmd msg
get options =
    Api.Token.get options.token
        { url = "https://conduit.productionready.io/api/articles/" ++ options.articleSlug ++ "/comments"
        , expect =
            Api.Data.expectJson options.onResponse
                (Json.field "comments" (Json.list decoder))
        }


create :
    { token : Token
    , articleSlug : String
    , comment : { comment | body : String }
    , onResponse : Data Comment -> msg
    }
    -> Cmd msg
create options =
    let
        body : Json.Value
        body =
            Encode.object
                [ ( "comment"
                  , Encode.object
                        [ ( "body", Encode.string options.comment.body )
                        ]
                  )
                ]
    in
    Api.Token.post (Just options.token)
        { url = "https://conduit.productionready.io/api/articles/" ++ options.articleSlug ++ "/comments"
        , body = Http.jsonBody body
        , expect =
            Api.Data.expectJson options.onResponse
                (Json.field "comment" decoder)
        }


delete :
    { token : Token
    , articleSlug : String
    , commentId : Int
    , onResponse : Data Int -> msg
    }
    -> Cmd msg
delete options =
    Api.Token.delete (Just options.token)
        { url =
            "https://conduit.productionready.io/api/articles/"
                ++ options.articleSlug
                ++ "/comments/"
                ++ String.fromInt options.commentId
        , expect =
            Api.Data.expectJson options.onResponse (Json.succeed options.commentId)
        }
