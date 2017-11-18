module Internal.Line exposing (Look, Style, style, look, view, viewSample)

{-| -}

import Svg
import Svg.Attributes
import Lines.Color as Color
import Lines.Coordinate as Coordinate exposing (..)
import Internal.Interpolation as Interpolation
import Internal.Path as Path



{-| -}
type Look data =
  Look
    { normal : Style
    , emphasized : Style
    , isEmphasized : List data -> Bool
    }


{-| -}
type Style =
  Style
    { width : Int -- TODO Float
    , color : Color.Color -> Color.Color
    }


{-| -}
style : Int -> (Color.Color -> Color.Color) -> Style
style width color =
  Style { width = width, color = color }


{-| -}
look :
  { normal : Style
  , emphasized : Style
  , isEmphasized : List data -> Bool
  } -> Look data
look config =
  Look config


{-| -}
view : Look data -> Interpolation.Interpolation -> Coordinate.System -> Color.Color -> List Float -> List data -> List Point -> Svg.Svg msg
view look interpolation system mainColor dashing data points =
  let
    interpolationCommands =
      Interpolation.toCommands interpolation points

    commands =
      case points of
        first :: rest ->
          Path.Move first :: interpolationCommands

        [] ->
          []

    attributes =
      toAttributes look mainColor dashing data
  in
  Path.view system attributes commands


toAttributes : Look data -> Color.Color -> List Float -> List data -> List (Svg.Attribute msg)
toAttributes (Look look) mainColor dashing data =
  let
    isEmphasized =
      look.isEmphasized data

    (Style style) =
      if isEmphasized then
        look.emphasized
      else
        look.normal

    width =
      toFloat style.width / 2
  in
      [ Svg.Attributes.style "pointer-events: none;"
      , Svg.Attributes.class "interpolation"
      , Svg.Attributes.stroke (style.color mainColor)
      , Svg.Attributes.strokeWidth (toString width)
      , Svg.Attributes.strokeDasharray <| String.join " " (List.map toString dashing)
      , Svg.Attributes.fill "transparent"
      ]


{-| -}
viewSample : Look data -> Color.Color -> List Float -> Float -> Svg.Svg msg
viewSample look mainColor dashing sampleWidth =
  let
    lookAttributes =
      toAttributes look mainColor dashing []

    sizeAttributes =
      [ Svg.Attributes.x1 "0"
      , Svg.Attributes.y1 "0"
      , Svg.Attributes.x2 <| toString sampleWidth
      , Svg.Attributes.y2 "0"
      ]
  in
  Svg.line (lookAttributes ++ sizeAttributes) []