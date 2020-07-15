module Pages.Article.Slug_String exposing (Model, Msg, Params, page)

import Html exposing (..)
import Html.Attributes exposing (attribute, class, href, id, placeholder, src)
import Shared
import Spa.Document exposing (Document)
import Spa.Page as Page exposing (Page)
import Spa.Url exposing (Url)


page : Page Params Model Msg
page =
    Page.application
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        , save = save
        , load = load
        }



-- INIT


type alias Params =
    { slug : String }


type alias Model =
    {}


init : Shared.Model -> Url Params -> ( Model, Cmd Msg )
init shared { params } =
    ( {}, Cmd.none )



-- UPDATE


type Msg
    = ReplaceMe


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ReplaceMe ->
            ( model, Cmd.none )


save : Model -> Shared.Model -> Shared.Model
save model shared =
    shared


load : Shared.Model -> Model -> ( Model, Cmd Msg )
load shared model =
    ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> Document Msg
view model =
    { title = "Article.Slug_String"
    , body =
        [ div [ class "article-page" ]
            [ div [ class "banner" ]
                [ div [ class "container" ]
                    [ h1 [] [ text "How to build webapps that scale" ]
                    , div [ class "article-meta" ]
                        [ a [ href "" ]
                            [ img [ src "http://i.imgur.com/Qr71crq.jpg" ] []
                            ]
                        , div [ class "info" ]
                            [ a [ class "author", href "" ] [ text "Eric Simons" ]
                            , span [ class "date" ] [ text "January 20th" ]
                            ]
                        , button [ class "btn btn-sm btn-outline-secondary" ]
                            [ i [ class "ion-plus-round" ] []
                            , text "Follow Eric Simons"
                            , span [ class "counter" ] [ text "(10)" ]
                            ]
                        , button [ class "btn btn-sm btn-outline-primary" ]
                            [ i [ class "ion-heart" ] []
                            , text "Favorite Post"
                            , span [ class "counter" ] [ text "(29)" ]
                            ]
                        ]
                    ]
                ]
            , div [ class "container page" ]
                [ div [ class "row article-content" ]
                    [ div [ class "col-md-12" ]
                        [ p [] [ text "Web development technologies have evolved at an incredible clip over the past few years.        " ]
                        , h2 [ id "introducing-ionic" ] [ text "Introducing RealWorld." ]
                        , p [] [ text "It's a great solution for learning how other frameworks work." ]
                        ]
                    ]
                , hr [] []
                , div [ class "article-actions" ]
                    [ div [ class "article-meta" ]
                        [ a [ href "profile.html" ]
                            [ img [ src "http://i.imgur.com/Qr71crq.jpg" ] []
                            ]
                        , div [ class "info" ]
                            [ a [ class "author", href "" ] [ text "Eric Simons" ]
                            , span [ class "date" ] [ text "January 20th" ]
                            ]
                        , button [ class "btn btn-sm btn-outline-secondary" ]
                            [ i [ class "ion-plus-round" ]
                                []
                            , text "Follow Eric Simons"
                            , span [ class "counter" ] [ text "(10)" ]
                            ]
                        , button [ class "btn btn-sm btn-outline-primary" ]
                            [ i [ class "ion-heart" ]
                                []
                            , text "Favorite Post "
                            , span [ class "counter" ] [ text "(29)" ]
                            ]
                        ]
                    ]
                , div [ class "row" ]
                    [ div [ class "col-xs-12 col-md-8 offset-md-2" ]
                        [ form [ class "card comment-form" ]
                            [ div [ class "card-block" ]
                                [ textarea [ class "form-control", placeholder "Write a comment...", attribute "rows" "3" ] []
                                ]
                            , div [ class "card-footer" ]
                                [ img [ class "comment-author-img", src "http://i.imgur.com/Qr71crq.jpg" ] []
                                , button [ class "btn btn-sm btn-primary" ] [ text "Post Comment" ]
                                ]
                            ]
                        , div [ class "card" ]
                            [ div [ class "card-block" ]
                                [ p [ class "card-text" ] [ text "With supporting text below as a natural lead-in to additional content." ]
                                ]
                            , div [ class "card-footer" ]
                                [ a [ class "comment-author", href "" ]
                                    [ img [ class "comment-author-img", src "http://i.imgur.com/Qr71crq.jpg" ] []
                                    ]
                                , a [ class "comment-author", href "" ] [ text "Jacob Schmidt" ]
                                , span [ class "date-posted" ] [ text "Dec 29th" ]
                                ]
                            ]
                        , div [ class "card" ]
                            [ div [ class "card-block" ]
                                [ p [ class "card-text" ]
                                    [ text "With supporting text below as a natural lead-in to additional content." ]
                                ]
                            , div [ class "card-footer" ]
                                [ a [ class "comment-author", href "" ]
                                    [ img [ class "comment-author-img", src "http://i.imgur.com/Qr71crq.jpg" ] []
                                    ]
                                , a [ class "comment-author", href "" ] [ text "Jacob Schmidt" ]
                                , span [ class "date-posted" ] [ text "Dec 29th" ]
                                , span [ class "mod-options" ]
                                    [ i [ class "ion-edit" ] []
                                    , i [ class "ion-trash-a" ] []
                                    ]
                                ]
                            ]
                        ]
                    ]
                ]
            ]
        ]
    }
