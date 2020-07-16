port module Ports exposing (clearUser, saveUser)

import Api.User exposing (User)
import Json.Decode as Json
import Json.Encode as Encode


port outgoing :
    { tag : String
    , data : Json.Value
    }
    -> Cmd msg


saveUser : User -> Cmd msg
saveUser user =
    outgoing
        { tag = "saveUser"
        , data = Api.User.encode user
        }


clearUser : Cmd msg
clearUser =
    outgoing
        { tag = "clearUser"
        , data = Encode.null
        }
