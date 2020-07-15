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
    , bio : String
    , image : Maybe String
    , following : Bool
    }


decoder : Json.Decoder Profile
decoder =
    Json.map4 Profile
        (Json.field "username" Json.string)
        (Json.field "bio" Json.string)
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
    Http.request
        { method = "GET"
        , headers =
            case options.token of
                Just token ->
                    [ Api.Token.header token ]

                Nothing ->
                    []
        , url = "/api/profiles/" ++ options.username
        , body = Http.emptyBody
        , expect =
            Api.Data.expectJson options.onResponse
                (Json.field "profile" decoder)
        , timeout = Just (1000 * 60) -- 60 second timeout
        , tracker = Nothing
        }


follow :
    { token : Token
    , username : String
    , onResponse : Data Profile -> msg
    }
    -> Cmd msg
follow options =
    Http.request
        { method = "POST"
        , headers = [ Api.Token.header options.token ]
        , url = "/api/profiles/" ++ options.username ++ "/follow"
        , body = Http.emptyBody
        , expect =
            Api.Data.expectJson options.onResponse
                (Json.field "profile" decoder)
        , timeout = Just (1000 * 60) -- 60 second timeout
        , tracker = Nothing
        }


unfollow :
    { token : Token
    , username : String
    , onResponse : Data Profile -> msg
    }
    -> Cmd msg
unfollow options =
    Http.request
        { method = "DELETE"
        , headers = [ Api.Token.header options.token ]
        , url = "/api/profiles/" ++ options.username ++ "/follow"
        , body = Http.emptyBody
        , expect =
            Api.Data.expectJson options.onResponse
                (Json.field "profile" decoder)
        , timeout = Just (1000 * 60) -- 60 second timeout
        , tracker = Nothing
        }
