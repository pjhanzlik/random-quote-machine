module Main exposing (..)

import Browser
import Dict
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Events
import Html.Lazy as Lazy
import Json.Decode as Decode
import Random
import Set
import Url
import Url.Parser as Parser


main : Program Decode.Value Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = \_ -> Sub.none
        , view = view
        }


type alias Quote =
    ( String, String )


type alias Sources =
    Dict.Dict Quote Url.Url


type alias Licenses =
    Dict.Dict Quote Url.Url


type alias Model =
    ( ( Quote, Set.Set Quote ), Random.Seed )


type Msg
    = NewQuote


quote : Decode.Decoder Quote
quote =
    Decode.map2 Tuple.pair (Decode.field "quotation" Decode.string) (Decode.field "citation" Decode.string)


link : Decode.Decoder (Maybe Url.Url)
link =
    Decode.map Url.fromString Decode.string


init : Decode.Value -> ( Model, Cmd Msg )
init json =
    case Decode.decodeValue (Decode.index 0 quote) json of
        Ok head ->
            case Decode.decodeValue (Decode.list quote) json of
                Ok quotes ->
                    ( Random.step (choose ( head, Set.fromList quotes )) (Random.initialSeed 42), Cmd.none )

                Err message ->
                    ( ( ( ( Decode.errorToString message, "Decode.list" ), Set.empty ), Random.initialSeed 404 ), Cmd.none )

        Err message ->
            ( ( ( ( Decode.errorToString message, "Decode.index 0" ), Set.empty ), Random.initialSeed 403 ), Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg ( quotes, seed ) =
    case msg of
        NewQuote ->
            ( Random.step (choose quotes) seed, Cmd.none )


choose : ( comparable, Set.Set comparable ) -> Random.Generator ( comparable, Set.Set comparable )
choose ( prevChoice, choices ) =
    case Set.toList choices of
        [] ->
            Random.constant ( prevChoice, choices )

        head :: tail ->
            let
                chosen choice =
                    Tuple.pair choice (Set.insert prevChoice (Set.remove choice choices))
            in
            Random.map chosen (Random.uniform head tail)



-- TODO: Add Lazy.lazy where appropriate


view : Model -> Html.Html Msg
view ( ( ( quotation, citation ), _ ), _ ) =
    Html.div [ Attr.id "quote-box" ]
        [ Html.blockquote []
            [ Html.p
                [ Attr.id "text" ]
                [ Html.text quotation ]
            , Html.cite
                [ Attr.id "author" ]
                [ Html.text citation ]
            ]
        , Html.div []
            [ Html.a [ Attr.id "tweet-quote" ] [ Html.text "Tweet" ]
            , Html.button
                [ Attr.id "new-quote"
                , Events.onClick NewQuote
                ]
                [ Html.text "New quote" ]
            ]
        ]
