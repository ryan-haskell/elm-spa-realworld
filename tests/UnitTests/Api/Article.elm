module UnitTests.Api.Article exposing (suite)

import Api.Article exposing (Article)
import Expect
import Json.Decode as Json
import Test exposing (..)


suite : Test
suite =
    describe "Api.Article"
        [ test "decodes example from spec" <|
            \_ ->
                """
                {
                    "slug": "how-to-train-your-dragon",
                    "title": "How to train your dragon",
                    "description": "Ever wonder how?",
                    "body": "It takes a Jacobian",
                    "tagList": ["dragons", "training"],
                    "createdAt": "2016-02-18T03:22:56.637Z",
                    "updatedAt": "2016-02-18T03:48:35.824Z",
                    "favorited": false,
                    "favoritesCount": 0,
                    "author": {
                        "username": "jake",
                        "bio": "I work at statefarm",
                        "image": "https://i.stack.imgur.com/xHWG8.jpg",
                        "following": false
                    }
                }
                """
                    |> Json.decodeString Api.Article.decoder
                    |> Expect.ok
        , test "works with multiple articles example from spec" <|
            \_ ->
                """
                {
                    "articles": [
                        {
                            "slug": "how-to-train-your-dragon",
                            "title": "How to train your dragon",
                            "description": "Ever wonder how?",
                            "body": "It takes a Jacobian",
                            "tagList": ["dragons", "training"],
                            "createdAt": "2016-02-18T03:22:56.637Z",
                            "updatedAt": "2016-02-18T03:48:35.824Z",
                            "favorited": false,
                            "favoritesCount": 0,
                            "author": {
                                "username": "jake",
                                "bio": "I work at statefarm",
                                "image": "https://i.stack.imgur.com/xHWG8.jpg",
                                "following": false
                            }
                        },
                        {
                            "slug": "how-to-train-your-dragon-2",
                            "title": "How to train your dragon 2",
                            "description": "So toothless",
                            "body": "It a dragon",
                            "tagList": ["dragons", "training"],
                            "createdAt": "2016-02-18T03:22:56.637Z",
                            "updatedAt": "2016-02-18T03:48:35.824Z",
                            "favorited": false,
                            "favoritesCount": 0,
                            "author": {
                                "username": "jake",
                                "bio": "I work at statefarm",
                                "image": "https://i.stack.imgur.com/xHWG8.jpg",
                                "following": false
                            }
                        }
                    ],
                    "articlesCount": 2
                }
                """
                    |> Json.decodeString
                        (Json.field "articles" (Json.list Api.Article.decoder))
                    |> Expect.ok
        ]
