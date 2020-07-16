module Pages.Profile.Username_String exposing (Model, Msg, Params, page)

import Html exposing (..)
import Html.Attributes exposing (class, href, src)
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
    { username : String }


type alias Model =
    { username : String
    }


init : Shared.Model -> Url Params -> ( Model, Cmd Msg )
init shared { params } =
    ( { username = params.username }
    , Cmd.none
    )



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
    { title = model.username
    , body =
        [ div [ class "profile-page" ]
            [ div [ class "user-info" ]
                [ div [ class "container" ]
                    [ div [ class "row" ]
                        [ div [ class "col-xs-12 col-md-10 offset-md-1" ]
                            [ img [ class "user-img", src "http://i.imgur.com/Qr71crq.jpg" ]
                                []
                            , h4 [] [ text model.username ]
                            , p []
                                [ text "Cofounder @GoThinkster, lived in Aol's HQ for a few months, kinda looks like Peeta from the Hunger Games          " ]
                            , button [ class "btn btn-sm btn-outline-secondary action-btn" ]
                                [ i [ class "ion-plus-round" ] []
                                , text "Follow Eric Simons"
                                ]
                            ]
                        ]
                    ]
                ]
            , div [ class "container" ]
                [ div [ class "row" ]
                    [ div [ class "col-xs-12 col-md-10 offset-md-1" ]
                        [ div [ class "articles-toggle" ]
                            [ ul [ class "nav nav-pills outline-active" ]
                                [ li [ class "nav-item" ]
                                    [ a [ class "nav-link active", href "" ] [ text "My Articles" ]
                                    ]
                                , li [ class "nav-item" ]
                                    [ a [ class "nav-link", href "" ] [ text "Favorited Articles" ]
                                    ]
                                ]
                            ]
                        , div [ class "article-preview" ]
                            [ div [ class "article-meta" ]
                                [ a [ href "" ]
                                    [ img [ src "http://i.imgur.com/Qr71crq.jpg" ] []
                                    ]
                                , div [ class "info" ]
                                    [ a [ class "author", href "" ] [ text "Eric Simons" ]
                                    , span [ class "date" ] [ text "January 20th" ]
                                    ]
                                , button [ class "btn btn-outline-primary btn-sm pull-xs-right" ]
                                    [ i [ class "ion-heart" ] []
                                    , text "29"
                                    ]
                                ]
                            , a [ class "preview-link", href "" ]
                                [ h1 [] [ text "How to build webapps that scale" ]
                                , p [] [ text "This is the description for the post." ]
                                , span [] [ text "Read more..." ]
                                ]
                            ]
                        , div [ class "article-preview" ]
                            [ div [ class "article-meta" ]
                                [ a [ href "" ]
                                    [ img [ src "http://i.imgur.com/N4VcUeJ.jpg" ] []
                                    ]
                                , div [ class "info" ]
                                    [ a [ class "author", href "" ] [ text "Albert Pai" ]
                                    , span [ class "date" ] [ text "January 20th" ]
                                    ]
                                , button [ class "btn btn-outline-primary btn-sm pull-xs-right" ]
                                    [ i [ class "ion-heart" ] []
                                    , text "32"
                                    ]
                                ]
                            , a [ class "preview-link", href "" ]
                                [ h1 [] [ text "The song you won't ever stop singing. No matter how hard you try." ]
                                , p [] [ text "This is the description for the post." ]
                                , span [] [ text "Read more..." ]
                                , ul [ class "tag-list" ]
                                    [ li [ class "tag-default tag-pill tag-outline" ] [ text "Music" ]
                                    , li [ class "tag-default tag-pill tag-outline" ] [ text "Song" ]
                                    ]
                                ]
                            ]
                        ]
                    ]
                ]
            ]
        ]
    }
