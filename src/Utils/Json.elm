module Utils.Json exposing (maybe, record, withField)

import Json.Decode as Json
import Json.Encode as Encode



-- DECODING RECORDS


record : fn -> Json.Decoder fn
record =
    Json.succeed


withField :
    String
    -> Json.Decoder field
    -> Json.Decoder (field -> value)
    -> Json.Decoder value
withField str decoder =
    apply (Json.field str decoder)



-- ENCODING


maybe : (value -> Json.Value) -> Maybe value -> Json.Value
maybe encode value =
    value |> Maybe.map encode |> Maybe.withDefault Encode.null



-- INTERNALS


apply : Json.Decoder field -> Json.Decoder (field -> value) -> Json.Decoder value
apply =
    Json.map2 (|>)
