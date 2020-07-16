module Utils.Route exposing
    ( fromUrl
    , navigate
    )

import Browser.Navigation as Nav
import Spa.Generated.Route as Route exposing (Route)
import Url exposing (Url)


navigate : Nav.Key -> Route -> Cmd msg
navigate key route =
    Nav.pushUrl key (Route.toString route)


fromUrl : Url -> Route
fromUrl =
    Route.fromUrl >> Maybe.withDefault Route.NotFound
