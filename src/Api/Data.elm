module Api.Data exposing
    ( Data(..)
    , expectJson
    , toMaybe
    )

import Html.Attributes exposing (value)
import Http
import Json.Decode as Json


type Data value
    = NotAsked
    | Loading
    | Failure (List String)
    | Success value


toMaybe : Data value -> Maybe value
toMaybe data =
    case data of
        Success value ->
            Just value

        _ ->
            Nothing


expectJson : (Data value -> msg) -> Json.Decoder value -> Http.Expect msg
expectJson toMsg decoder =
    Http.expectStringResponse (fromResult >> toMsg) <|
        \response ->
            case response of
                Http.BadUrl_ url ->
                    Err [ "Bad URL" ]

                Http.Timeout_ ->
                    Err [ "Request timeout" ]

                Http.NetworkError_ ->
                    Err [ "Connection issues" ]

                Http.BadStatus_ _ body ->
                    case Json.decodeString errorDecoder body of
                        Ok errors ->
                            Err errors

                        Err _ ->
                            Err [ "Bad status code" ]

                Http.GoodStatus_ _ body ->
                    case Json.decodeString decoder body of
                        Ok value ->
                            Ok value

                        Err err ->
                            Err [ Json.errorToString err ]


errorDecoder : Json.Decoder (List String)
errorDecoder =
    Json.keyValuePairs (Json.list Json.string)
        |> Json.field "errors"
        |> Json.map (List.concatMap (\( key, values ) -> values |> List.map (\value -> key ++ " " ++ value)))


fromResult : Result (List String) value -> Data value
fromResult result =
    case result of
        Ok value ->
            Success value

        Err reasons ->
            Failure reasons
