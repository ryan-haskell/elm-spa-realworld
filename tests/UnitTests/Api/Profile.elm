module UnitTests.Api.Profile exposing (suite)

import Api.Profile exposing (Profile)
import Expect
import Json.Decode as Json
import Test exposing (..)


suite : Test
suite =
    describe "Api.Profile"
        [ test "decodes example from spec" <|
            \_ ->
                """
                {
                    "username": "jake",
                    "bio": "I work at statefarm",
                    "image": "https://static.productionready.io/images/smiley-cyrus.jpg",
                    "following": false
                }
                """
                    |> Json.decodeString Api.Profile.decoder
                    |> Expect.ok
        ]
