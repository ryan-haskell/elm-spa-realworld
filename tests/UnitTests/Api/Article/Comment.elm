module UnitTests.Api.Article.Comment exposing (suite)

import Api.Article.Comment
import Expect
import Json.Decode as Json
import Test exposing (..)


suite : Test
suite =
    describe "Api.Article.Comment"
        [ test "decodes example from spec" <|
            \_ ->
                """
                {
                    "id": 1,
                    "createdAt": "2016-02-18T03:22:56.637Z",
                    "updatedAt": "2016-02-18T03:22:56.637Z",
                    "body": "It takes a Jacobian",
                    "author": {
                        "username": "jake",
                        "bio": "I work at statefarm",
                        "image": "https://i.stack.imgur.com/xHWG8.jpg",
                        "following": false
                    }
                }
                """
                    |> Json.decodeString Api.Article.Comment.decoder
                    |> Expect.ok
        ]
