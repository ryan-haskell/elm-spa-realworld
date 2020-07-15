module Api.User exposing
    ( User
    , decoder
    , authentication, registration, current, update
    )

{-|

@docs User
@docs decoder

@docs authentication, registration, current, update

-}

import Api.Data exposing (Data)
import Api.Token exposing (Token)
import Http
import Json.Decode as Json
import Json.Encode as Encode


type alias User =
    { email : String
    , token : Token
    , username : String
    , bio : String
    , image : Maybe String
    }


decoder : Json.Decoder User
decoder =
    Json.field "user"
        (Json.map5 User
            (Json.field "email" Json.string)
            (Json.field "token" Api.Token.decoder)
            (Json.field "username" Json.string)
            (Json.field "bio" Json.string)
            (Json.field "image" (Json.maybe Json.string))
        )


authentication :
    { user : { user | email : String, password : String }
    , onResponse : Data User -> msg
    }
    -> Cmd msg
authentication options =
    let
        body : Json.Value
        body =
            Encode.object
                [ ( "user"
                  , Encode.object
                        [ ( "email", Encode.string options.user.email )
                        , ( "password", Encode.string options.user.password )
                        ]
                  )
                ]
    in
    Http.post
        { url = "/api/users/login"
        , body = Http.jsonBody body
        , expect =
            Api.Data.expectJson options.onResponse decoder
        }


registration :
    { user :
        { user
            | username : String
            , email : String
            , password : String
        }
    , onResponse : Data User -> msg
    }
    -> Cmd msg
registration options =
    let
        body : Json.Value
        body =
            Encode.object
                [ ( "user"
                  , Encode.object
                        [ ( "username", Encode.string options.user.username )
                        , ( "email", Encode.string options.user.email )
                        , ( "password", Encode.string options.user.password )
                        ]
                  )
                ]
    in
    Http.post
        { url = "/api/users"
        , body = Http.jsonBody body
        , expect =
            Api.Data.expectJson options.onResponse decoder
        }


current : { token : Token, onResponse : Data User -> msg } -> Cmd msg
current options =
    Http.request
        { method = "GET"
        , headers = [ Api.Token.header options.token ]
        , url = "/api/user"
        , body = Http.emptyBody
        , expect = Api.Data.expectJson options.onResponse decoder
        , timeout = Just (1000 * 60) -- 60 second timeout
        , tracker = Nothing
        }


update :
    { token : Token
    , user :
        { user
            | username : String
            , email : String
            , password : String
            , image : String
            , bio : String
        }
    , onResponse : Data User -> msg
    }
    -> Cmd msg
update options =
    let
        body : Json.Value
        body =
            Encode.object
                [ ( "user"
                  , Encode.object
                        [ ( "username", Encode.string options.user.username )
                        , ( "email", Encode.string options.user.email )
                        , ( "password", Encode.string options.user.password )
                        , ( "image", Encode.string options.user.image )
                        , ( "bio", Encode.string options.user.bio )
                        ]
                  )
                ]
    in
    Http.request
        { method = "PUT"
        , headers = [ Api.Token.header options.token ]
        , url = "/api/user"
        , body = Http.jsonBody body
        , expect = Api.Data.expectJson options.onResponse decoder
        , timeout = Just (1000 * 60) -- 60 second timeout
        , tracker = Nothing
        }
