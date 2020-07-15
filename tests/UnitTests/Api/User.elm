module UnitTests.Api.User exposing (suite)

import Api.User exposing (User)
import Expect
import Json.Decode as Json
import Test exposing (..)


suite : Test
suite =
    describe "Api.User"
        [ test "decodes example from spec" <|
            \_ ->
                """
                {
                    "user": {
                        "email": "jake@jake.jake",
                        "token": "jwt.token.here",
                        "username": "jake",
                        "bio": "I work at statefarm",
                        "image": null
                    }
                }
                """
                    |> Json.decodeString Api.User.decoder
                    |> Expect.ok
        ]
