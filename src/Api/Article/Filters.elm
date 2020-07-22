module Api.Article.Filters exposing
    ( Filters, create
    , withTag, byAuthor, favoritedBy
    , toQueryString
    , pageQueryParameters
    )

{-|

@docs Filters, create
@docs withTag, byAuthor, onPage, favoritedBy

@docs toQueryString
@docs pageQueryParameters

-}


type Filters
    = Filters
        { tag : Maybe String
        , author : Maybe String
        , favorited : Maybe String
        }


create : Filters
create =
    Filters
        { tag = Nothing
        , author = Nothing
        , favorited = Nothing
        }


withTag : String -> Filters -> Filters
withTag tag (Filters filters) =
    Filters { filters | tag = Just tag }


byAuthor : String -> Filters -> Filters
byAuthor username (Filters filters) =
    Filters { filters | author = Just username }


favoritedBy : String -> Filters -> Filters
favoritedBy username (Filters filters) =
    Filters { filters | favorited = Just username }



-- To a query string


toQueryString : Int -> Filters -> String
toQueryString page (Filters filters) =
    let
        optionalFilters : List String
        optionalFilters =
            List.filterMap identity
                [ filters.tag |> Maybe.map (String.append "tag=")
                , filters.author |> Maybe.map (String.append "author=")
                , filters.favorited |> Maybe.map (String.append "favorited=")
                ]
    in
    pageQueryParameters page
        ++ String.concat (List.map (String.append "&") optionalFilters)


pageQueryParameters : Int -> String
pageQueryParameters page_ =
    let
        limit : Int
        limit =
            25
    in
    String.join "&"
        [ "?limit=" ++ String.fromInt limit
        , "offset=" ++ String.fromInt ((page_ - 1) * limit)
        ]
