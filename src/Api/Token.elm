module Api.Token exposing
    ( Token
    , decoder
    , header
    )

import Http
import Json.Decode as Json


type Token
    = Token String


decoder : Json.Decoder Token
decoder =
    Json.map Token Json.string


header : Token -> Http.Header
header (Token token) =
    Http.header "Authorization" ("Token " ++ token)
