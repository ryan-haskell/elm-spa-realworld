port module Ports exposing (saveUser)

import Api.User exposing (User)
import Json.Decode as Json


port outgoing : { tag : String, data : Json.Value } -> Cmd msg


saveUser : User -> Cmd msg
saveUser user =
    outgoing
        { tag = "saveUser"
        , data = Api.User.encode user
        }
