module Api.Article.Tag exposing (Tag, list)

import Api.Data exposing (Data)
import Http
import Json.Decode as Json

type alias Tag =
    String


list : { onResponse : Data (List String) -> msg } -> Cmd msg
list options =
    Http.get
        { url = "/api/tags"
        , expect =
            Api.Data.expectJson options.onResponse
                (Json.field "tags" (Json.list Json.string))
        }
