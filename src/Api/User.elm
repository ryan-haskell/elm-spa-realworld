module Api.User exposing
    ( User
    , decoder, encode
    , authentication, registration, update
    )

{-|

@docs User
@docs decoder, encode

@docs authentication, registration, current, update

-}

import Api.Data exposing (Data)
import Api.Token exposing (Token)
import Http
import Json.Decode as Json
import Json.Encode as Encode
import Utils.Json


type alias User =
    { email : String
    , token : Token
    , username : String
    , bio : Maybe String
    , image : String
    }


decoder : Json.Decoder User
decoder =
    Json.map5 User
        (Json.field "email" Json.string)
        (Json.field "token" Api.Token.decoder)
        (Json.field "username" Json.string)
        (Json.field "bio" (Json.maybe Json.string))
        (Json.field "image" (Json.string |> Utils.Json.withDefault "https://static.productionready.io/images/smiley-cyrus.jpg"))


encode : User -> Json.Value
encode user =
    Encode.object
        [ ( "username", Encode.string user.username )
        , ( "email", Encode.string user.email )
        , ( "token", Api.Token.encode user.token )
        , ( "image", Encode.string user.image )
        , ( "bio", Utils.Json.maybe Encode.string user.bio )
        ]


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
        { url = "https://conduit.productionready.io/api/users/login"
        , body = Http.jsonBody body
        , expect =
            Api.Data.expectJson options.onResponse
                (Json.field "user" decoder)
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
        { url = "https://conduit.productionready.io/api/users"
        , body = Http.jsonBody body
        , expect =
            Api.Data.expectJson options.onResponse
                (Json.field "user" decoder)
        }


update :
    { token : Token
    , user :
        { user
            | username : String
            , email : String
            , password : Maybe String
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
                        (List.concat
                            [ [ ( "username", Encode.string options.user.username )
                              , ( "email", Encode.string options.user.email )
                              , ( "image", Encode.string options.user.image )
                              , ( "bio", Encode.string options.user.bio )
                              ]
                            , case options.user.password of
                                Just password ->
                                    [ ( "password", Encode.string password ) ]

                                Nothing ->
                                    []
                            ]
                        )
                  )
                ]
    in
    Api.Token.put (Just options.token)
        { url = "https://conduit.productionready.io/api/user"
        , body = Http.jsonBody body
        , expect =
            Api.Data.expectJson options.onResponse
                (Json.field "user" decoder)
        }
