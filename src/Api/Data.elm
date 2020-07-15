module Api.Data exposing
    ( Data(..)
    , expectJson
    )

import Http
import Json.Decode as Json


type Data value
    = NotAsked
    | Loading
    | Failure Http.Error
    | Success value


expectJson : (Data value -> msg) -> Json.Decoder value -> Http.Expect msg
expectJson toMsg decoder =
    Http.expectJson (fromResult >> toMsg) decoder


fromResult : Result Http.Error value -> Data value
fromResult result =
    case result of
        Ok value ->
            Success value

        Err reason ->
            Failure reason
