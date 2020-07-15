module Utils.Json exposing (record, withField)

import Json.Decode as Json


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



-- INTERNALS


apply : Json.Decoder field -> Json.Decoder (field -> value) -> Json.Decoder value
apply =
    Json.map2 (|>)
