module Api.Profile exposing
    ( Profile
    , decoder
    , get, follow, unfollow
    )

{-|

@docs Profile
@docs decoder
@docs get, follow, unfollow

-}

import Api.Data exposing (Data)
import Api.Token exposing (Token)
import Http
import Json.Decode as Json


type alias Profile =
    { username : String
    , bio : Maybe String
    , image : Maybe String
    , following : Bool
    }


decoder : Json.Decoder Profile
decoder =
    Json.map4 Profile
        (Json.field "username" Json.string)
        (Json.field "bio" (Json.maybe Json.string))
        (Json.field "image" (Json.maybe Json.string))
        (Json.field "following" Json.bool)



-- ENDPOINTS


get :
    { token : Maybe Token
    , username : String
    , onResponse : Data Profile -> msg
    }
    -> Cmd msg
get options =
    Api.Token.get options.token
        { url = "/api/profiles/" ++ options.username
        , expect =
            Api.Data.expectJson options.onResponse
                (Json.field "profile" decoder)
        }


follow :
    { token : Token
    , username : String
    , onResponse : Data Profile -> msg
    }
    -> Cmd msg
follow options =
    Api.Token.post (Just options.token)
        { url = "/api/profiles/" ++ options.username ++ "/follow"
        , body = Http.emptyBody
        , expect =
            Api.Data.expectJson options.onResponse
                (Json.field "profile" decoder)
        }


unfollow :
    { token : Token
    , username : String
    , onResponse : Data Profile -> msg
    }
    -> Cmd msg
unfollow options =
    Api.Token.delete (Just options.token)
        { url = "/api/profiles/" ++ options.username ++ "/follow"
        , expect =
            Api.Data.expectJson options.onResponse
                (Json.field "profile" decoder)
        }
