module FreeCodeCamp exposing (suite)

import Expect
import Fuzz
import Html
import Html.Attributes
import Main
import Platform.Cmd
import Task
import Test
import Test.Html.Event as Event
import Test.Html.Query as Query
import Test.Html.Selector as Selector


suite : Test.Test
suite =
    Test.describe "Based on freeCodeCamp User Stories from Front End Libraries Projects - Build a Random Quote Machine"
        -- """**User Story #1:** I can see a wrapper element with a corresponding `id="quote-box"`""" 
        Test.test "" <|
            \_ ->
                Main.init ()
                    |> Tuple.first
                    |> Main.view
                    |> Query.fromHtml
                    |> Query.has [ Selector.id "quote-box" ]
        , Test.test """**User Story #2:** Within `#quote-box`, I can see an element with a corresponding `id="text"`.""" <|
            \_ ->
                Main.init ()
                    |> Tuple.first
                    |> Main.view
                    |> Query.fromHtml
                    |> Query.has
                        [ Selector.id "quote-box"
                        , Selector.containing [ Selector.id "text" ]
                        ]
        , Test.test """**User Story #3:** Within `#quote-box`, I can see an element with a corresponding `id="author"`.""" <|
            \_ ->
                Main.init ()
                    |> Tuple.first
                    |> Main.view
                    |> Query.fromHtml
                    |> Query.has
                        [ Selector.id "quote-box"
                        , Selector.containing [ Selector.id "author" ]
                        ]
        , Test.test """**User Story #4:** Within `#quote-box`, I can see a clickable element with a corresponding `id="new-quote"`.""" <|
            \_ ->
                Main.init ()
                    |> Tuple.first
                    |> Main.view
                    |> Query.fromHtml
                    |> Query.has
                        [ Selector.id "quote-box"
                        , Selector.containing
                            [ Selector.id "new-quote"
                            , Selector.tag "button"
                            ]
                        ]
        , Test.test """**User Story #5**: Within `#quote-box`, I can see a clickable `a` element with a corresponding `id="tweet-quote"`.""" <|
            \_ ->
                Main.init ()
                    |> Tuple.first
                    |> Main.view
                    |> Query.fromHtml
                    |> Query.has
                        [ Selector.id "quote-box"
                        , Selector.containing
                            [ Selector.id "tweet-quote"
                            , Selector.tag "a"
                            ]
                        ]
        , Test.test """**User Story #6**: On first load, my quote machine displays a random quote in the element with `id="text"`.""" <|
            \_ ->
                let
                    model =
                        Tuple.first (Main.init ())
                in
                Main.view model
                    |> Query.fromHtml
                    |> Query.find [ Selector.id "text" ]
                    |> Query.contains [ Html.text (Tuple.first model) ]
        , Test.test """**User Story #7:** On first load, my quote machine displays the random quote's author in the element with `id="author"`.""" <|
            \_ ->
                let
                    model =
                        Tuple.first (Main.init ())
                in
                Main.view model
                    |> Query.fromHtml
                    |> Query.find [ Selector.id "author" ]
                    |> Query.contains [ Html.text (Tuple.second model) ]
        , Test.fuzz Fuzz.unit """**User Story #8:** When the `#new-quote` button is clicked, my quote machine should fetch a new quote and display it in the `#text` element.""" <|
            \_ ->
                let
                    initModel =
                        Tuple.first (Main.init ())

                    result =
                        Main.view initModel
                            |> Query.fromHtml
                            |> Query.find [ Selector.id "new-quote" ]
                            |> Event.simulate Event.click
                            |> Event.toResult
                in
                case result of
                    Ok msg ->
                        let
                            ( updatedModel, cmd ) =
                                Main.update msg initModel
                        in
                        Main.view updatedModel
                            |> Query.fromHtml
                            |> Query.find [ Selector.id "text" ]
                            |> Query.find [ Selector.text (Tuple.first updatedModel) ]
                            |> Query.hasNot [ Selector.text (Tuple.first initModel) ]

                    Err err ->
                        Expect.fail err
        , Test.todo """**User Story #9:** My quote machine should fetch the new quote's author when the `#new-quote` button is clicked and display it in the `#author element.`"""
        , Test.todo """**User Story #10:** I can tweet the current quote by clicking on the `#tweet-quote a` element. This `a` element should include the `"twitter.com/intent/tweet"` path in its `href` attribute to tweet the current quote."""
        , Test.todo """**User Story #11:** The `#quote-box` wrapper element should be horizontally centered."""
        ]
