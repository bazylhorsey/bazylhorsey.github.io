port module Main exposing (main)

{-| My portfolio.

Built on JORN, the Elm virtual DOM with a diff and a patch protocol
(github.com/bazylhorsey/jorn). Nothing on this page is hand-written markup:
every node is a value here, Jorn diffs the tree, and the browser applies only
what changed.

Two pieces of real state so the patch pipeline has something to do: the theme,
and the filter on the work list. Both are plain Elm values.

-}

import Json.Decode as Decode
import Json.Encode as Encode exposing (Value)

import CaseStudy
import Essay
import Jorn
import Jorn.Attribute as Attr
import Jorn.Effect as Effect exposing (Effect)
import Jorn.Element as Element exposing (Element)
import Jorn.Element.Html as Html
import Jorn.Event as Events



-- PORTS


port toJorn : Value -> Cmd msg


port fromJorn : (Value -> msg) -> Sub msg



-- MODEL


type Theme
    = Paper
    | Night


type Category
    = Framework
    | Tool
    | Upstream
    | Experiment


type Filter
    = Everything
    | Only Category


type Page
    = Home
    | EssayPage
    | StudyPage


type alias Model =
    { theme : Theme
    , filter : Filter
    , page : Page
    , study : CaseStudy.Model
    }


type Msg
    = ToggleTheme
    | PickFilter Filter
    | NudgeSaid Int
    | StudyMsg CaseStudy.Msg


{-| The shell passes `{ "dark": true }` when the visitor picked night last
time, or has never picked and their OS is in dark mode. Anything else, or no
flags at all (the headless check), starts on paper.
-}
init : Value -> Model
init flags =
    { theme =
        case Decode.decodeValue (Decode.field "dark" Decode.bool) flags of
            Ok True ->
                Night

            _ ->
                Paper
    , filter = Everything
    , page =
        case Decode.decodeValue (Decode.field "page" Decode.string) flags of
            Ok "essay" ->
                EssayPage

            Ok "study" ->
                StudyPage

            _ ->
                Home
    , study = CaseStudy.init
    }


{-| Two things on this page belong to the browser, not the tree: the theme
on `<html>` (body background, browser chrome, the stored choice) and
scrolling the testimonial strip. Both go out as client effects the shell
registers.
-}
update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        ToggleTheme ->
            let
                theme =
                    if model.theme == Paper then
                        Night

                    else
                        Paper
            in
            ( { model | theme = theme }
            , Effect.client "theme" (Encode.string (themeName theme))
            )

        PickFilter filter ->
            ( { model | filter = filter }, Effect.none )

        NudgeSaid direction ->
            ( model, Effect.client "nudgeSaid" (Encode.int direction) )

        StudyMsg studyMsg ->
            ( { model | study = CaseStudy.update studyMsg model.study }, Effect.none )



-- CONTENT
-- Kept as data so the view stays about layout and the diff stays small.


type alias Item =
    { name : String
    , tags : List String
    , blurb : String
    , href : Maybe String
    , category : Category
    , stages : List Stage
    }


type alias Stage =
    { number : String
    , description : String
    , status : Status
    }


type Status
    = Done
    | Next
    | Planned


type alias Metric =
    { figure : String
    , caption : String
    }


type alias Role =
    { span : String
    , place : String
    , org : String
    , title : String
    , body : List String
    , figures : List Metric
    }


type alias Post =
    { date : String
    , outlet : String
    , title : String
    , gist : String
    , href : String
    }


type alias Piece =
    { kind : String
    , heading : String
    , body : String
    , href : String
    , label : String
    }


jornStages : List Stage
jornStages =
    [ { number = "v0.0", description = "Pure Elm vdom, diff, wire protocol, browser patcher", status = Done }
    , { number = "v0.1", description = "Full HTML and SVG, keyed lists, effects, app runtime", status = Done }
    , { number = "v0.2", description = "Server components over a websocket, with reconnects", status = Done }
    , { number = "v0.2.1", description = "MathML, raw HTML, HTML strings, form submits", status = Done }
    , { number = "v0.3", description = "The rest of the view layer: memoized subtrees, per-event preventDefault", status = Next }
    , { number = "v0.4", description = "Server-side rendering, hydration, URL routing", status = Planned }
    , { number = "v0.5", description = "Components as custom elements: shadow DOM, slots, forms", status = Planned }
    , { number = "v0.6", description = "A dev server, a build command, and test utilities", status = Planned }
    , { number = "v1.0", description = "The full feature set, on the Elm package registry", status = Planned }
    ]


metrics : List Metric
metrics =
    [ { figure = "20", caption = "customer deployments, first commit to running on site" }
    , { figure = "9", caption = "engineers on the team, grown from solo" }
    , { figure = "131", caption = "versioned releases in a single quarter" }
    , { figure = "10.9→3", caption = "days, median time to close a bug" }
    , { figure = "90%+", caption = "of customer incidents traced to site power, network or hardware, not our code" }
    , { figure = "3 min", caption = "median first response to a customer" }
    , { figure = "400→26", caption = "ms per inference after a model swap" }
    , { figure = "6×", caption = "less GPT spend on one feature, same output" }
    ]


work : List Item
work =
    [ { name = "Jorn"
      , tags = [ "elm", "v0.2.1" ]
      , blurb =
            "Write your UI once in Elm and decide at deploy time where each "
                ++ "piece runs: browser, server, or both. Pure Elm virtual DOM, a "
                ++ "diff that runs anywhere, a JSON wire protocol and a "
                ++ "dependency-free browser patcher. No kernel code, no fork. This "
                ++ "page runs on it."
      , href = Just "https://github.com/bazylhorsey/jorn"
      , category = Framework
      , stages = jornStages
      }
    , { name = "obsidian-mcp-server"
      , tags = [ "typescript", "22 stars" ]
      , blurb =
            "An MCP server that connects local and remote Obsidian vaults to "
                ++ "desktop AI tools: multi-vault switching, graph analysis, hybrid "
                ++ "search and backlinks."
      , href = Just "https://github.com/bazylhorsey/obsidian-mcp-server"
      , category = Tool
      , stages = []
      }
    , { name = "prompt-rust"
      , tags = [ "rust" ]
      , blurb =
            "A proposal to add typed stdin prompts to the Rust standard "
                ++ "library (rust-lang/rust#117852, RFC 3196). What upstream "
                ++ "actually feels like from the outside."
      , href = Just "https://github.com/bazylhorsey/prompt-rust"
      , category = Upstream
      , stages = []
      }
    , { name = "Aethos"
      , tags = [ "rust" ]
      , blurb =
            "A Rust take on Phoenix LiveView, built to learn the "
                ++ "browser-versus-server trade-off from the implementer's side. "
                ++ "The only way to have an opinion about it."
      , href = Nothing
      , category = Tool
      , stages = []
      }
    , { name = "Lustre"
      , tags = [ "gleam" ]
      , blurb =
            "Hayleigh Thompson's Gleam web framework. Four open PRs, including "
                ++ "a 337-line fix for server component context subscriptions and "
                ++ "a CI workflow for main. Upkeep is hard. Apparently I do it "
                ++ "anyway."
      , href = Just "https://github.com/lustre-labs/lustre/pulls?q=is%3Apr+author%3Abazylhorsey"
      , category = Upstream
      , stages = []
      }
    , { name = "Frigate"
      , tags = [ "python" ]
      , blurb =
            "The open-source NVR. A merged fix to its auth cookie pattern and "
                ++ "an open one for a shared-memory leak on skipped frames. Same "
                ++ "class of bug as the day job, in someone else's codebase."
      , href = Just "https://github.com/blakeblackshear/frigate/pulls?q=is%3Apr+author%3Abazylhorsey"
      , category = Upstream
      , stages = []
      }
    , { name = "astonish"
      , tags = [ "python" ]
      , blurb =
            "A ChatGPT 3.0-era Lovable, presented at the OpenAI Hackathon in "
                ++ "Chicago, 2022. Kept because it is funny and it was early."
      , href = Just "https://github.com/bazylhorsey/astonish"
      , category = Experiment
      , stages = []
      }
    ]


roles : List Role
roles =
    [ { span = "2023→now"
      , place = "Chicago, IL"
      , org = "Arvist"
      , title = "Co-founder & CTO, now Technical Advisor"
      , body =
            [ "Techstars '22, then a $4M seed led by Rackhouse. Took the "
                ++ "platform from first commit to about twenty customer "
                ++ "deployments across five product lines, then built the "
                ++ "plug-and-play inspection product behind the pivot: installs "
                ++ "in a day, works with the cameras and systems a site already "
                ++ "has."
            , "Grew engineering from solo to nine across time zones. As CISO, "
                ++ "built the ISMS from nothing to ISO 27001:2022 and SOC 2 Type I "
                ++ "readiness. Principal investigator on a $1M+ DoD-funded MxD "
                ++ "safety AI project."
            ]
      , figures = metrics
      }
    , { span = "2019→2022"
      , place = "Chicago, IL"
      , org = "Koloni"
      , title = "Software Manager → Application Manager → CTO"
      , body =
            [ "Smart-locker and mobility IoT, now Accessa, backed by Jason "
                ++ "Calacanis with a $1M pre-seed. Part-time through college, CTO "
                ++ "from 2021, leading a team of five. Built the BLE SDKs and mobile "
                ++ "integrations behind the 2020 Smart Locker launch, which became "
                ++ "the core business."
            , "Led the hardware too: our own System on Module with BLE and LTE "
                ++ "for the lockers, and the APIs that wrapped it. The software "
                ++ "was the easy half."
            ]
      , figures = []
      }
    , { span = "2020→2021"
      , place = "Storm Lake, IA"
      , org = "Levity"
      , title = "Co-founder & CEO"
      , body =
            [ "First startup out of Buena Vista's Foundry incubator. Wound it "
                ++ "down in 2021 and brought two of its engineers to Koloni, which "
                ++ "I count as the best outcome any of my companies had. Earlier: "
                ++ "the app for Match-Learn-Launch, a $175,000 Google.org Impact "
                ++ "Challenge winner."
            ]
      , figures = []
      }
    , { span = "2016→2020"
      , place = "Storm Lake, IA"
      , org = "Buena Vista University"
      , title = "BS Computer Science, minor in Communications"
      , body =
            [ "Dean's List. President of the Robotics Club. Collegiate wrestler, "
                ++ "which explains more about how I run engineering than any "
                ++ "conference talk does."
            ]
      , figures = []
      }
    ]


podcasts : List Piece
podcasts =
    [ { kind = "software leaders uncensored / with steve taplin"
      , heading = "Doesn't sugarcoat it"
      , body =
            "Academic burnout through to running engineering at Arvist. Why "
                ++ "scrappy beats flashy when you are building a team, and what "
                ++ "most CTOs get wrong about leadership. The episode title is the "
                ++ "whole review."
      , href = "https://youtu.be/mk7CKtatU8U"
      , label = "youtu.be/mk7CKtatU8U"
      }
    , { kind = "deep learning leaders / with eric landau"
      , heading = "Building Arvist, and what AI actually needs in a warehouse"
      , body =
            "Encord's show, hosted by their co-founder. Going deep on AI in "
                ++ "logistics: what it takes to get a model out of a notebook and "
                ++ "onto a dock, why the old boring methods still win more often "
                ++ "than the shiny new thing, and where quality assurance in "
                ++ "warehousing is heading."
      , href = "https://encord.com/deep-learning-leaders/"
      , label = "deep learning leaders"
      }
    ]


{-| The deep pieces, newest first, split from the posts by depth rather than
by venue. Peer review shows in the outlet column instead of a group of its own.
-}
longForm : List Post
longForm =
    [ { date = Essay.dateLabel
      , outlet = "essay"
      , title = Essay.title
      , gist =
            "Distracted is what listening looks like when the person you're "
                ++ "listening to isn't in the room."
      , href = Essay.slug
      }
    , { date = CaseStudy.dateLabel
      , outlet = "case study"
      , title = CaseStudy.title
      , gist =
            "How to analyze the ROI of computer vision next to human inspectors. "
                ++ "Escapes multiply, people get worse as defects get rarer, and the "
                ++ "model is yours to push on."
      , href = CaseStudy.slug
      }
    , { date = "2024.07"
      , outlet = "peer reviewed"
      , title = "Implementing concepts from green logistics in the turkey production supply chain"
      , gist =
            "Frontiers in Sustainability, with Griffin Wilson and Richard Stone. "
                ++ "A mixed integer model routes birds from brooders to finishers "
                ++ "for roughly half the emissions."
      , href = "https://doi.org/10.3389/frsus.2024.1416964"
      }
    ]


{-| Shorter posts, mine and on company blogs, newest first. -}
posts : List Post
posts =
    [ { date = "2026.08"
      , outlet = "arvist blog"
      , title = "Why vertical monopoly doesn't work for warehouse software anymore"
      , gist =
            "Building software got cheap, so small niches pay now. The moat moves "
                ++ "from owning the platform to adapting fastest to each operation."
      , href = "https://arvist.ai/vertical-monopoly/"
      }
    , { date = "2026.08"
      , outlet = "arvist blog"
      , title = "Why your integration quote is wrong"
      , gist =
            "Quotes price the connection. The time and money go into mapping data "
                ++ "that doesn't line up and the scope nobody wrote down."
      , href = "https://arvist.ai/why-your-integration-quote-is-wrong/"
      }
    , { date = "2021.01"
      , outlet = "medium"
      , title = "Lessons learned in IoT product development"
      , gist =
            "Fresh out of school and building smart lockers at Koloni: hardware, "
                ++ "firmware and apps that all have to ship together."
      , href = "https://bazyl-25260.medium.com/lessons-learned-in-iot-product-development-405b569e5b4c"
      }
    , { date = "2020.11"
      , outlet = "medium"
      , title = "The future of sharing and micro-mobility"
      , gist = "Where shared lockers, scooters and bikes were headed, from inside the business."
      , href = "https://bazyl-25260.medium.com/the-future-of-sharing-and-micro-mobility-d63b26fa405"
      }
    ]


tracks : List String
tracks =
    [ "Pavement"
    , "916"
    , "Take the Wheel"
    , "360 No Scope"
    , "Statistically"
    , "Way You Aren't"
    ]



-- VIEW


view : Model -> Element Msg
view model =
    Html.div
        [ Attr.class ("page page--" ++ themeName model.theme) ]
        [ topbar model
        , Html.main_ []
            (case model.page of
                Home ->
                    [ hero
                    , claim
                    , said
                    , shipped model
                    , path
                    , writing
                    , band
                    , contact
                    ]

                EssayPage ->
                    [ Essay.view ]

                StudyPage ->
                    [ Element.map StudyMsg (CaseStudy.view model.study) ]
            )
        , foot
        ]


themeName : Theme -> String
themeName theme =
    case theme of
        Paper ->
            "paper"

        Night ->
            "night"


topbar : Model -> Element Msg
topbar model =
    Html.header [ Attr.class "topbar" ]
        [ Html.div [ Attr.class "wrap topbar-in" ]
            [ Html.a [ Attr.class "mark", Attr.href "/" ] [ Element.text "Bazyl Horsey" ]
            , Html.nav [ Attr.class "topnav" ]
                (List.map
                    (navLink
                        (if model.page == Home then
                            ""

                         else
                            "/"
                        )
                    )
                    [ ( "#claim", "claim" )
                    , ( "#work", "work" )
                    , ( "#path", "path" )
                    , ( "#writing", "writing" )
                    , ( "#band", "off hours" )
                    , ( "#contact", "contact" )
                    ]
                )
            , Html.button
                [ Attr.class "theme"
                , Attr.type_ "button"
                , Events.onClick ToggleTheme
                ]
                [ Element.text
                    (if model.theme == Paper then
                        "night"

                     else
                        "day"
                    )
                ]
            ]
        ]


navLink : String -> ( String, String ) -> Element msg
navLink base ( anchor, label ) =
    Html.a [ Attr.href (base ++ anchor) ] [ Element.text label ]


hero : Element msg
hero =
    Html.section [ Attr.class "hero wrap" ]
        [ Html.div [ Attr.class "hero-copy" ] heroCopy
        , diagram
        ]


heroCopy : List (Element msg)
heroCopy =
        [ Html.p [ Attr.class "status" ]
            [ Html.span [ Attr.class "dot" ] []
            , Element.text "Chicago, IL"
            , Element.text " / Open to work"
            ]
        , Html.h1 [ Attr.class "name" ]
            [ Element.text "Bazyl "
            , Html.br []
            , Element.text "Horsey"
            , Html.span [ Attr.class "caret" ] []
            ]
        , Html.p [ Attr.class "lede" ]
            [ Element.text
                ("Serial co-founder and two-time VC-backed startup CTO. Applied AI: agentic "
                    ++ "systems and edge inference."
                )
            ]
        , Html.p [ Attr.class "claim-line" ]
            [ Element.text
                "I build AI that has to work in production, not in a notebook."
            ]
        , Html.div [ Attr.class "hero-actions" ]
            [ Html.a [ Attr.class "btn btn-solid", Attr.href "#work" ]
                [ Element.text "What I've shipped" ]
            , Html.a
                [ Attr.class "btn"
                , Attr.href "mailto:bhorsey16@gmail.com"
                ]
                [ Element.text "bhorsey16@gmail.com" ]
            ]
        ]


{-| Fig. 1 in the hero: the general architecture playbook, the one that
usually starts on a napkin, drawn as SVG through Jorn's namespaced elements. Colors come from CSS classes, so it
follows the theme like everything else, and it is prerendered with the page.
-}
diagram : Element msg
diagram =
    svg "svg"
        [ Attr.class "diagram"
        , Attr.attribute "viewBox" "0 0 400 480"
        , Attr.attribute "role" "img"
        , Attr.attribute "aria-labelledby" "dg-title"
        ]
        ([ svg "title"
            [ Attr.id "dg-title" ]
            [ Element.text
                ("An example day-0 napkin: the customer's site feeds edge inference, "
                    ++ "which feeds the platform, which feeds agents and the people "
                    ++ "who approve their work. Misses loop back into retraining."
                )
            ]
         , svgText "dg-cap" 1 14 "FIG. 1 / A DAY-0 NAPKIN, WRAPPED IN CSS"
         ]
            ++ dgNode 40 "THEIR SITE" [ plain "their systems, data and IT" ]
            ++ dgEdge 112 "raw data"
            ++ dgNode 160 "EDGE INFERENCE" [ plain "x86 · ARM · TensorRT · ", hot "26 ms" ]
            ++ dgEdge 232 "events, results"
            ++ dgNode 280 "PLATFORM" [ plain "model registry, pinned per customer" ]
            ++ dgEdge 352 "tasks, alerts"
            ++ dgNode 400 "AGENTS + PEOPLE" [ plain "agents draft, a human approves" ]
            ++ dgLoop
        )


svgNs : String
svgNs =
    "http://www.w3.org/2000/svg"


svg : String -> List (Attr.Attribute msg) -> List (Element msg) -> Element msg
svg =
    Element.namespaced svgNs


num : Float -> String
num =
    String.fromFloat


svgText : String -> Float -> Float -> String -> Element msg
svgText cls x y label =
    svg "text"
        [ Attr.class cls, Attr.attribute "x" (num x), Attr.attribute "y" (num y) ]
        [ Element.text label ]


type Span
    = Plain String
    | Hot String


plain : String -> Span
plain =
    Plain


hot : String -> Span
hot =
    Hot


span : Span -> Element msg
span part =
    case part of
        Plain t ->
            svg "tspan" [] [ Element.text t ]

        Hot t ->
            svg "tspan" [ Attr.class "dg-hot" ] [ Element.text t ]


{-| A box with a hard offset shadow, the same move as the work cards. -}
dgNode : Float -> String -> List Span -> List (Element msg)
dgNode y title sub =
    [ svg "rect"
        [ Attr.class "dg-shadow"
        , Attr.attribute "x" "6"
        , Attr.attribute "y" (num (y + 5))
        , Attr.attribute "width" "318"
        , Attr.attribute "height" "72"
        ]
        []
    , svg "rect"
        [ Attr.class "dg-box"
        , Attr.attribute "x" "1.5"
        , Attr.attribute "y" (num y)
        , Attr.attribute "width" "318"
        , Attr.attribute "height" "72"
        ]
        []
    , svg "rect"
        [ Attr.class "dg-tick"
        , Attr.attribute "x" "18"
        , Attr.attribute "y" (num (y + 21))
        , Attr.attribute "width" "8"
        , Attr.attribute "height" "8"
        ]
        []
    , svgText "dg-title" 34 (y + 30) title
    , svg "text"
        [ Attr.class "dg-sub", Attr.attribute "x" "18", Attr.attribute "y" (num (y + 54)) ]
        (List.map span sub)
    ]


{-| A down arrow between two boxes, with what flows along it. -}
dgEdge : Float -> String -> List (Element msg)
dgEdge y label =
    [ svg "line"
        [ Attr.class "dg-edge"
        , Attr.attribute "x1" "160"
        , Attr.attribute "y1" (num y)
        , Attr.attribute "x2" "160"
        , Attr.attribute "y2" (num (y + 40))
        ]
        []
    , svg "path"
        [ Attr.class "dg-head"
        , Attr.attribute "d" ("M154 " ++ num (y + 38) ++ " L160 " ++ num (y + 47) ++ " L166 " ++ num (y + 38) ++ " Z")
        ]
        []
    , svgText "dg-label" 174 (y + 28) label
    ]


{-| Misses go back into training and come out as a new model, pinned per
customer. Dashed and orange: the part that keeps it working. -}
dgLoop : List (Element msg)
dgLoop =
    [ svg "path"
        [ Attr.class "dg-loop"
        , Attr.attribute "d" "M320 436 H366 V196 H331"
        ]
        []
    , svg "path"
        [ Attr.class "dg-loop-head"
        , Attr.attribute "d" "M333 190 L324 196 L333 202 Z"
        ]
        []
    , svg "text"
        [ Attr.class "dg-loop-label"
        , Attr.attribute "transform" "translate(386 316) rotate(-90)"
        , Attr.attribute "text-anchor" "middle"
        ]
        [ Element.text "misses → retrain → re-pin" ]
    ]


claim : Element msg
claim =
    Html.section [ Attr.class "section wrap split", Attr.id "claim" ]
        [ Html.div [ Attr.class "split-head" ]
            [ Html.p [ Attr.class "eyebrow" ] [ Element.text "01 / the claim" ]
            , Html.h2 [ Attr.class "h2" ]
                [ Element.text "Most AI dies in procurement and uptime, not in accuracy." ]
            ]
        , Html.ol [ Attr.class "claims split-body" ]
            (List.map claimItem
                [ ( "Ship the 0→1, then make it survive."
                  , "A platform is a demo on day one and an uptime problem "
                        ++ "on day ninety. I have taken one from the first commit "
                        ++ "to about twenty customer deployments, which is a "
                        ++ "different job than the one people pitch."
                  )
                , ( "Replace the API call when the API call is the bottleneck."
                  , "GPT-dependent detections moved to in-house models, and "
                        ++ "one feature's spend dropped 6×. A new segmentation model "
                        ++ "took inference from 400 ms to 26 ms and GPU load at five "
                        ++ "stations from 100% to about 30%. Same accuracy "
                        ++ "requirement, different bill."
                  )
                , ( "Own the boring parts."
                  , "ISO 27001:2022 from a standing start. SOC 2 Type I "
                        ++ "readiness. RLS multi-tenant Postgres. Hardened Linux on "
                        ++ "x86, micro-x86 and ARM. Three-minute median first "
                        ++ "response. Upkeep is hard, and it is also most of the "
                        ++ "job."
                  )
                , ( "Grow the people, then get out of the way."
                  , "As the team went from solo to nine across time zones, my "
                        ++ "week went from 80% code to 20%. The job became getting "
                        ++ "other people to their best work, and owning my mistakes "
                        ++ "out loud so they could own theirs."
                  )
                ]
            )
        ]


type alias Testimonial =
    { quote : String
    , name : String
    , role : String
    , href : Maybe String
    }


testimonials : List Testimonial
testimonials =
    [ { quote =
            "He helped me design critical parts of Arvist\u{2019}s MLOps pipeline. "
                ++ "\u{2026} A single engineer can now keep the whole ML lifecycle "
                ++ "running across hundreds of clients and models with minimal "
                ++ "maintenance, where a less careful design would have needed a team."
      , name = "Lu\u{00ED}s Condados"
      , role = "ML Engineer"
      , href = Just "https://www.linkedin.com/in/luis-condados/"
      }
    , { quote =
            "Bazyl has a habit of making complicated things look suspiciously "
                ++ "easy. The kind of person you want around when things break, "
                ++ "ideas get weird, or someone says, \u{201C}That\u{2019}s probably "
                ++ "impossible.\u{201D} He\u{2019}ll either find a solution or make "
                ++ "the problem regret showing up."
      , name = "Sherif Okunade"
      , role = "Web Developer"
      , href = Just "https://www.linkedin.com/in/ACoAADlC9G4Bwlszm246aKubHcdIWI4ymrnp8Y4"
      }
    , { quote =
            "Passionate technology leader who is constantly geeking out over the "
                ++ "newest tech releases and figuring out how they can solve real "
                ++ "problems."
      , name = "Matthew Bronstein"
      , role = "Head of Engineering"
      , href = Just "https://www.linkedin.com/in/matthew-bronstein-a9230462/"
      }
    , { quote =
            "A natural mentor who empowers engineers. I started exploring "
                ++ "systems programming and Rust because of an impressive project "
                ++ "I saw on his GitHub."
      , name = "Jesse Onyekwelu"
      , role = "Web Developer"
      , href = Just "https://www.linkedin.com/in/ACoAAEM91EABQb_ji6dKGuFDCIYeRoTpS9Pbk_4"
      }
    , { quote =
            "His depth of knowledge, resourcefulness, and unwavering "
                ++ "commitment to excellence make him \u{2026} someone you can "
                ++ "always count on."
      , name = "Oshoke Oyati"
      , role = "Web Development Lead"
      , href = Just "https://www.linkedin.com/in/oshoke-oyati/"
      }
    ]


{-| What people who worked with me say. One card per person, in a strip that
scrolls sideways: swipe, trackpad, or the arrows. No autoplay: it sits still
until you move it.
-}
said : Element Msg
said =
    Html.div [ Attr.class "said wrap" ]
        [ Html.div [ Attr.class "said-head" ]
            [ Html.p [ Attr.class "eyebrow" ] [ Element.text "said about working with me" ]
            , Html.div [ Attr.class "said-nav" ]
                [ nudge -1 "Previous" "←"
                , nudge 1 "Next" "→"
                ]
            ]
        , Html.ul
            [ Attr.class "said-track"
            , Attr.tabindex 0
            , Attr.ariaLabel "Testimonials"
            ]
            (List.map testimonial testimonials)
        ]


nudge : Int -> String -> String -> Element Msg
nudge direction label glyph =
    Html.button
        [ Attr.class "said-arrow"
        , Attr.type_ "button"
        , Attr.ariaLabel label
        , Events.onClick (NudgeSaid direction)
        ]
        [ Element.text glyph ]


testimonial : Testimonial -> Element msg
testimonial t =
    Html.li [ Attr.class "said-card" ]
        [ Html.blockquote [] [ Html.p [] [ Element.text t.quote ] ]
        , Html.p [ Attr.class "said-who" ]
            [ case t.href of
                Just href ->
                    Html.a [ Attr.href href ] [ Element.text t.name ]

                Nothing ->
                    Html.b [] [ Element.text t.name ]
            , Html.span [] [ Element.text t.role ]
            ]
        ]


claimItem : ( String, String ) -> Element msg
claimItem ( heading, body ) =
    Html.li []
        [ Html.h3 [] [ Element.text heading ]
        , Html.p [] [ Element.text body ]
        ]


metric : Metric -> Element msg
metric item =
    Html.div [ Attr.class "num" ]
        [ Html.b [] [ Element.text item.figure ]
        , Html.span [] [ Element.text item.caption ]
        ]


shipped : Model -> Element Msg
shipped model =
    Html.section [ Attr.class "section wrap", Attr.id "work" ]
        [ Html.p [ Attr.class "eyebrow" ] [ Element.text "02 / work" ]
        , Html.h2 [ Attr.class "h2" ] [ Element.text "Things that exist and run." ]
        , Html.div [ Attr.class "filters" ]
            (List.map (filterButton model.filter) filters)
        , Html.ul [ Attr.class "work" ]
            (List.map (itemCard model.filter) (visibleWork model.filter))
        ]


filters : List ( Filter, String )
filters =
    [ ( Everything, "everything" )
    , ( Only Framework, "frameworks" )
    , ( Only Tool, "tools" )
    , ( Only Upstream, "upstream" )
    , ( Only Experiment, "experiments" )
    ]


filterButton : Filter -> ( Filter, String ) -> Element Msg
filterButton current ( filter, label ) =
    Html.button
        [ Attr.class
            (if filter == current then
                "filter is-on"

             else
                "filter"
            )
        , Attr.type_ "button"
        , Events.onClick (PickFilter filter)
        ]
        [ Element.text label ]


visibleWork : Filter -> List Item
visibleWork filter =
    List.filter (\item -> kept filter item.category) work


kept : Filter -> Category -> Bool
kept filter category =
    case filter of
        Everything ->
            True

        Only wanted ->
            wanted == category


itemCard : Filter -> Item -> Element Msg
itemCard filter item =
    Html.li
        [ Attr.classes
            [ ( "card", True )
            , ( "card-feature", item.category == Framework && filter == Everything )
            ]
        ]
        [ Html.div [ Attr.class "card-head" ]
            (Html.h3 [] [ Element.text item.name ]
                :: List.map tag (item.tags ++ statusTag item.category)
            )
        , if item.category == Framework then
            Html.p [ Attr.class "card-quote" ] [ Element.text item.blurb ]

          else
            Html.p [] [ Element.text item.blurb ]
        , if List.isEmpty item.stages then
            Html.span [] []

          else
            stageTable item.stages
        , case item.href of
            Just href ->
                Html.a [ Attr.class "link", Attr.href href ]
                    [ Element.text href ]

            Nothing ->
                Html.span [] []
        ]


statusTag : Category -> List String
statusTag category =
    case category of
        Framework ->
            [ "current" ]

        Upstream ->
            [ "upstream" ]

        _ ->
            []


tag : String -> Element msg
tag label =
    Html.span [ Attr.class "tag" ] [ Element.text label ]


stageTable : List Stage -> Element msg
stageTable stages =
    Html.table [ Attr.class "roadmap" ]
        [ Html.tbody [] (List.map stageRow stages) ]


stageRow : Stage -> Element msg
stageRow stage =
    Html.tr []
        [ Html.td [] [ Element.text stage.number ]
        , Html.td [] [ Element.text stage.description ]
        , Html.td []
            [ Html.span
                [ Attr.class ("chip chip-" ++ statusName stage.status) ]
                [ Element.text (statusLabel stage.status) ]
            ]
        ]


statusName : Status -> String
statusName status =
    case status of
        Done ->
            "done"

        Next ->
            "next"

        Planned ->
            "plan"


statusLabel : Status -> String
statusLabel status =
    case status of
        Done ->
            "done"

        Next ->
            "next"

        Planned ->
            "planned"


path : Element msg
path =
    section "path"
        "03 / path"
        "Where the scar tissue came from."
        [ Html.ol [ Attr.class "path" ] (List.map roleItem roles) ]


roleItem : Role -> Element msg
roleItem role =
    Html.li []
        [ Html.div [ Attr.class "path-when" ]
            [ Html.b [] [ Element.text role.span ]
            , Html.span [] [ Element.text role.place ]
            ]
        , Html.div [ Attr.class "path-what" ]
            (Html.h3 []
                [ Element.text role.org
                , Html.span [ Attr.class "path-role" ] [ Element.text role.title ]
                ]
                :: List.map (\line -> Html.p [] [ Element.text line ]) role.body
                ++ figures role.figures
            )
        ]


{-| The numbers belong to the role that earned them, not to a section of
their own. Arvist carried the receipts; Koloni gets an empty list and no
heading.
-}
figures : List Metric -> List (Element msg)
figures items =
    if List.isEmpty items then
        []

    else
        [ Html.div [ Attr.class "nums nums--inline" ]
            (List.map metric items)
        ]


writing : Element msg
writing =
    section "writing"
        "04 / writing & talking"
        "Said out loud, on the record."
        [ groupLabel "Long form"
        , Html.ul [ Attr.class "posts" ] (List.map postRow longForm)
        , groupLabel "Podcasts"
        , Html.div [ Attr.class "writes" ] (List.map piece podcasts)
        , groupLabel "Posts"
        , Html.ul [ Attr.class "posts" ] (List.map postRow posts)
        ]


groupLabel : String -> Element msg
groupLabel label =
    Html.p [ Attr.class "group-label" ] [ Element.text label ]


postRow : Post -> Element msg
postRow post =
    Html.li []
        [ Html.a [ Attr.class "post", Attr.href post.href ]
            [ Html.span [ Attr.class "post-meta" ]
                [ Html.b [] [ Element.text post.date ]
                , Html.span [] [ Element.text post.outlet ]
                ]
            , Html.span [ Attr.class "post-body" ]
                [ Html.b [ Attr.class "post-title" ] [ Element.text post.title ]
                , Html.span [ Attr.class "post-gist" ] [ Element.text post.gist ]
                ]
            , Html.span [ Attr.class "post-go" ] [ Element.text "→" ]
            ]
        ]


piece : Piece -> Element msg
piece item =
    Html.article [ Attr.class "write" ]
        [ Html.p [ Attr.class "write-meta" ] [ Element.text item.kind ]
        , Html.h3 [] [ Element.text item.heading ]
        , Html.p [] [ Element.text item.body ]
        , Html.a [ Attr.class "link", Attr.href item.href ] [ Element.text item.label ]
        ]


band : Element msg
band =
    Html.section [ Attr.class "band", Attr.id "band" ]
        [ Html.div [ Attr.class "wrap band-in" ]
            [ Html.p [ Attr.class "eyebrow" ] [ Element.text "05 / off the clock" ]
            , Html.h2 [ Attr.class "band-name" ] [ Element.text "The Comedowns" ]
            , Html.p [ Attr.class "band-sub" ]
                [ Element.text
                    "Chicago punk / midwest emo. Somewhere between loud and sincere."
                ]
            , Html.ol
                [ Attr.class "tracks"

                -- Rows for the two-column layout, so the list fills down
                -- the first column before the second, like a record sleeve.
                , Attr.attribute "style"
                    ("--track-rows: " ++ String.fromInt trackRows)
                ]
                (List.indexedMap track tracks)
            , Html.p [ Attr.class "band-note" ]
                [ Element.text
                    ("The rest of this site is the day job. This is the night one. "
                        ++ "The other off-hours constant: four years as a Big with "
                        ++ "Big Brothers Big Sisters."
                    )
                ]
            ]
        ]


trackRows : Int
trackRows =
    (List.length tracks + 1) // 2


{-| The first track in each column gets the top rule, so in the two-column
layout the line breaks at the gap instead of running across it.
-}
track : Int -> String -> Element msg
track index title =
    Html.li
        [ Attr.classes [ ( "col-top", index == 0 || index == trackRows ) ] ]
        [ Html.b [] [ Element.text title ] ]


contact : Element msg
contact =
    Html.section [ Attr.class "section wrap", Attr.id "contact" ]
        [ Html.p [ Attr.class "eyebrow" ] [ Element.text "06 / contact" ]
        , Html.h2 [ Attr.class "h2" ] [ Element.text "Got something worth breaking?" ]
        , Html.p [ Attr.class "contact-lede" ]
            [ Element.text
                ("Forward deployed and applied AI roles, technical leadership, or a "
                    ++ "deployment that will not stay up. Chicago-based, happy to be on "
                    ++ "site with customers. I read all of it and I answer."
                )
            ]
        , Html.ul [ Attr.class "links" ]
            [ contactLine "email" "bhorsey16@gmail.com" "mailto:bhorsey16@gmail.com"
            , contactLine "github" "github.com/bazylhorsey" "https://github.com/bazylhorsey"
            , contactLine "linkedin" "in/bazyl-horsey" "https://www.linkedin.com/in/bazyl-horsey-075506139"
            , contactLine "orcid" "0009-0000-4566-0406" "https://orcid.org/0009-0000-4566-0406"
            ]
        ]


contactLine : String -> String -> String -> Element msg
contactLine key label href =
    Html.li []
        [ Html.span [ Attr.class "links-k" ] [ Element.text key ]
        , Html.a [ Attr.href href ] [ Element.text label ]
        ]


foot : Element msg
foot =
    Html.footer [ Attr.class "foot" ]
        [ Html.div [ Attr.class "wrap foot-in" ]
            [ Html.p [ Attr.class "foot-line" ]
                [ Element.text "Upkeep is hard. I do it anyway." ]
            , Html.p [ Attr.class "foot-sub" ]
                [ Element.text
                    ("Every element on this page is a value in an Elm program. "
                        ++ "Jorn diffs the view and ships only what changed, so "
                        ++ "there is no hand-written markup and no framework."
                    )
                ]
            , Html.p [ Attr.class "foot-sub foot-fine" ]
                [ Element.text
                    ("Written in Elm against github.com/bazylhorsey/jorn. "
                        ++ "One stylesheet, one compiled script, zero "
                        ++ "dependencies."
                    )
                ]
            ]
        ]


section : String -> String -> String -> List (Element msg) -> Element msg
section anchor eyebrow heading children =
    Html.section [ Attr.class "section wrap", Attr.id anchor ]
        [ Html.p [ Attr.class "eyebrow" ] [ Element.text eyebrow ]
        , Html.h2 [ Attr.class "h2" ] [ Element.text heading ]
        , Html.div [] children
        ]



-- MAIN


main : Jorn.Program Value Model Msg
main =
    Jorn.application
        { init = \flags -> ( init flags, Effect.none )
        , update = update
        , view = view
        , subscriptions = \_ -> Sub.none
        , ports = { toJorn = toJorn, fromJorn = fromJorn }
        }
