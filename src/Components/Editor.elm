module Components.Editor exposing
    ( Field
    , Form
    , updateField
    , view
    )

import Api.Article exposing (Article)
import Api.Data exposing (Data)
import Html exposing (..)
import Html.Attributes exposing (attribute, class, placeholder, type_, value)
import Html.Events as Events


type Field
    = Title
    | Description
    | Body
    | Tags


type alias Form =
    { title : String
    , description : String
    , body : String
    , tags : String
    }


updateField : Field -> String -> Form -> Form
updateField field value form =
    case field of
        Title ->
            { form | title = value }

        Description ->
            { form | description = value }

        Body ->
            { form | body = value }

        Tags ->
            { form | tags = value }


view :
    { onFormSubmit : msg
    , title : String
    , form :
        { title : String
        , description : String
        , body : String
        , tags : String
        }
    , buttonLabel : String
    , onUpdate : Field -> String -> msg
    , article : Data Article
    }
    -> Html msg
view options =
    div [ class "editor-page" ]
        [ div [ class "container page" ]
            [ div [ class "row" ]
                [ div [ class "col-md-6 offset-md-3 col-xs-12" ]
                    [ h1 [ class "text-xs-center" ] [ text options.title ]
                    , br [] []
                    , form [ Events.onSubmit options.onFormSubmit ]
                        [ fieldset []
                            [ fieldset [ class "form-group" ]
                                [ input
                                    [ class "form-control form-control-lg"
                                    , placeholder "Article Title"
                                    , type_ "text"
                                    , value options.form.title
                                    , Events.onInput (options.onUpdate Title)
                                    ]
                                    []
                                ]
                            , fieldset [ class "form-group" ]
                                [ input
                                    [ class "form-control"
                                    , placeholder "What's this article about?"
                                    , type_ "text"
                                    , value options.form.description
                                    , Events.onInput (options.onUpdate Description)
                                    ]
                                    []
                                ]
                            , fieldset [ class "form-group" ]
                                [ textarea
                                    [ class "form-control"
                                    , placeholder "Write your article (in markdown)"
                                    , attribute "rows" "8"
                                    , value options.form.body
                                    , Events.onInput (options.onUpdate Body)
                                    ]
                                    []
                                ]
                            , fieldset [ class "form-group" ]
                                [ input
                                    [ class "form-control"
                                    , placeholder "Enter tags (separated by commas)"
                                    , type_ "text"
                                    , value options.form.tags
                                    , Events.onInput (options.onUpdate Tags)
                                    ]
                                    []
                                , div [ class "tag-list" ] []
                                ]
                            , button
                                [ class "btn btn-lg pull-xs-right btn-primary"
                                ]
                                [ text options.buttonLabel ]
                            ]
                        , case options.article of
                            Api.Data.Failure reasons ->
                                ul [ class "error-messages" ]
                                    (List.map (\message -> li [] [ text message ]) reasons)

                            _ ->
                                text ""
                        ]
                    ]
                ]
            ]
        ]
