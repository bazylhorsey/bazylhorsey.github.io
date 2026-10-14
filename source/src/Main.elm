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

import Jorn.Attribute as Attr
import Jorn.Element as Element exposing (Element)
import Jorn.Element.Html as Html
import Jorn.Event as Events
import Jorn.Internal.Event as Routing
import Jorn.Patch



-- PORTS


port toClient : Value -> Cmd msg


port fromClient : (Value -> msg) -> Sub msg



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


type alias Model =
    { theme : Theme
    , filter : Filter
    }


type Msg
    = ToggleTheme
    | PickFilter Filter


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
    }


update : Msg -> Model -> Model
update msg model =
    case msg of
        ToggleTheme ->
            { model | theme = if model.theme == Paper then Night else Paper }

        PickFilter filter ->
            { model | filter = filter }



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
    [ { number = "1", description = "Pure Elm vdom, diff, wire protocol, event routing", status = Done }
    , { number = "2", description = "Browser patcher, applies patches to the real DOM", status = Done }
    , { number = "3", description = "Full HTML/SVG/MathML, keyed lists, effects, runtime", status = Next }
    , { number = "4", description = "Server runtime over a websocket", status = Planned }
    , { number = "5", description = "Generated, compiler-checked encoders for shared types", status = Planned }
    , { number = "6", description = "Session snapshots and typed migrations across deploys", status = Planned }
    ]


metrics : List Metric
metrics =
    [ { figure = "90%+", caption = "of customer incidents traced to site power, network or hardware, not our code" }
    , { figure = "10.9→3", caption = "days, median time to close a bug" }
    , { figure = "400→26", caption = "ms per segmentation inference, new model" }
    , { figure = "100→30%", caption = "GPU load across five edge stations" }
    , { figure = "6×", caption = "less GPT spend on one feature, same output" }
    , { figure = "131", caption = "versioned releases in a single quarter" }
    , { figure = "3 min", caption = "median first response to a customer" }
    , { figure = "9", caption = "engineers on a global team, from solo" }
    ]


work : List Item
work =
    [ { name = "Jorn"
      , tags = [ "elm", "v0.0" ]
      , blurb =
            "Write your UI once in Elm. Run each piece in the browser, on the "
                ++ "server, or both, and decide at deploy time. An attempt at the "
                ++ "web framework that does not make you choose where your UI "
                ++ "runs: pure Elm virtual DOM, a diff that runs anywhere, a JSON "
                ++ "wire protocol, event routing, and a dependency-free browser "
                ++ "patcher. No kernel code, no fork. This page is one of its "
                ++ "consumers."
      , href = Just "https://github.com/bazylhorsey/jorn"
      , category = Framework
      , stages = jornStages
      }
    , { name = "obsidian-mcp-server"
      , tags = [ "typescript", "22 stars" ]
      , blurb =
            "An MCP server that connects local and remote Obsidian vaults to "
                ++ "desktop AI tools. Multi-vault switching, knowledge graph "
                ++ "analysis with hubs and orphans, hybrid full-text search, "
                ++ "backlink analysis, and vault analytics."
      , href = Just "https://github.com/bazylhorsey/obsidian-mcp-server"
      , category = Tool
      , stages = []
      }
    , { name = "prompt-rust"
      , tags = [ "rust" ]
      , blurb =
            "A proposal to add user auto-stdin decoding to the Rust standard "
                ++ "library, filed as rust-lang/rust#117852 and prototyped in "
                ++ "RFC 3196. The most direct answer I have for what upstream "
                ++ "actually feels like from the outside."
      , href = Just "https://github.com/bazylhorsey/prompt-rust"
      , category = Upstream
      , stages = []
      }
    , { name = "Aethos"
      , tags = [ "rust" ]
      , blurb =
            "A Rust take on Phoenix LiveView. Mostly valuable for what it taught "
                ++ "me: I know the browser-versus-server component trade-off from "
                ++ "the implementer side, which is the only way to have an "
                ++ "opinion about it."
      , href = Nothing
      , category = Tool
      , stages = []
      }
    , { name = "Lustre"
      , tags = [ "gleam" ]
      , blurb =
            "Not my project: Hayleigh Thompson's Gleam web framework. Four open "
                ++ "PRs against it, including a 337-line fix for server component "
                ++ "context subscriptions, a replaced list.range in the diff "
                ++ "benchmark, a re-measured effects example, and a CI workflow "
                ++ "that runs the test suite on pushes to main. My bio says "
                ++ "upkeep is hard. Apparently I do it anyway."
      , href = Just "https://github.com/lustre-labs/lustre/pulls?q=is%3Apr+author%3Abazylhorsey"
      , category = Upstream
      , stages = []
      }
    , { name = "Frigate"
      , tags = [ "python" ]
      , blurb =
            "Not mine either: the open-source NVR that runs object detection "
                ++ "on camera feeds at the edge. A merged fix to its auth cookie "
                ++ "name pattern, and an open one for a shared-memory handle that "
                ++ "leaked whenever a captured frame was skipped. Same class of "
                ++ "bug as the day job, in someone else's codebase."
      , href = Just "https://github.com/blakeblackshear/frigate/pulls?q=is%3Apr+author%3Abazylhorsey"
      , category = Upstream
      , stages = []
      }
    , { name = "astonish"
      , tags = [ "python" ]
      , blurb =
            "A ChatGPT 3.0-era Lovable. Presented at the OpenAI Hackathon in "
                ++ "Chicago, 2022. Kept because it is funny and because it was "
                ++ "early."
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
            [ "Techstars '22. Vision AI for warehouse quality control, joined at "
                ++ "pre-seed. $4M seed led by Rackhouse. Built the platform from "
                ++ "first commit to about twenty customer deployments, shipping "
                ++ "Quality, Safety, Yard Management, Productivity and Claims plus "
                ++ "a mobile operator app and an admin console. Then built Arvist "
                ++ "QC, the plug-and-play inspection system behind the pivot to "
                ++ "quality: installs in a day, camera-agnostic, WMS optional. It "
                ++ "halved a shipper's error rate at roughly 96% detection and "
                ++ "about a second per item."
            , "Grew engineering from solo to nine people across time zones, "
                ++ "around 300 PRs and 131 releases in a quarter. As CISO, built "
                ++ "the ISMS from nothing and got the company to ISO 27001:2022 "
                ++ "and SOC 2 Type I readiness. Principal investigator on a $1M+ "
                ++ "DoD-funded MxD ergonomic-safety AI project, deployed at PPC "
                ++ "Flex."
            ]
      , figures = metrics
      }
    , { span = "2019→2022"
      , place = "Chicago, IL"
      , org = "Koloni"
      , title = "Software Manager → Application Manager → CTO"
      , body =
            [ "Smart-locker and mobility IoT, now Accessa, backed by Jason "
                ++ "Calacanis with a $1M pre-seed. Part-time in college and at "
                ++ "Levity, full-time CTO from 2021. Led a team of five and "
                ++ "rebuilt the legacy PHP application as FastAPI and React "
                ++ "microservices on AWS. Built the BLE SDKs and the iOS and "
                ++ "Android integrations behind the 2020 Smart Locker launch, "
                ++ "which became the core business."
            , "Led development of the hardware as well: a System on Module with "
                ++ "BLE and LTE for the lockers, and the APIs that wrapped it. The "
                ++ "software was the easy half."
            ]
      , figures = []
      }
    , { span = "2020→2021"
      , place = "Storm Lake, IA"
      , org = "Levity"
      , title = "Co-founder & CEO"
      , body =
            [ "First startup out of Buena Vista's Foundry incubator. In 2021 I "
                ++ "brought two of its engineers to Koloni and wound it down, "
                ++ "which I count as the best outcome any of my companies had. "
                ++ "Earlier: built the app for Match-Learn-Launch, a $175,000 "
                ++ "Google.org Impact Challenge winner in 2019."
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


paper : Piece
paper =
    { kind = "peer reviewed / 2024 / second author"
    , heading = "Implementing concepts from green logistics in the turkey production supply chain"
    , body =
        "Frontiers in Sustainability 5:1416964. Modeled roughly 50% lower "
            ++ "emissions by rerouting livestock between brooders and "
            ++ "finishers with a Gurobi optimization over distance, "
            ++ "exclusivity, and capacity. The notebook is public, which is "
            ++ "the point of publishing."
    , href = "https://doi.org/10.3389/frsus.2024.1416964"
    , label = "doi:10.3389/frsus.2024.1416964"
    }


podcasts : List Piece
podcasts =
    [ { kind = "software leaders uncensored / with steve taplin"
      , heading = "Doesn't sugarcoat it"
      , body =
            "Academic burnout through to running engineering at Arvist. Why "
                ++ "scrappy beats flashy when you are building a team, why "
                ++ "bootstrapped pragmatism beats bloated VC hype, and what most "
                ++ "CTOs get wrong about leadership. The episode title is the "
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


{-| Blog posts under my own byline, newest first. -}
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
    Element.element "div"
        [ Attr.class ("page page--" ++ themeName model.theme) ]
        [ topbar model
        , Html.main_ []
            [ hero
            , claim
            , shipped model
            , path
            , writing
            , band
            , contact
            ]
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
            [ Html.span [ Attr.class "mark" ] [ Element.text "Bazyl Horsey" ]
            , Html.nav [ Attr.class "topnav" ]
                (List.map navLink
                    [ ( "#claim", "claim" )
                    , ( "#work", "work" )
                    , ( "#path", "path" )
                    , ( "#writing", "writing" )
                    , ( "#band", "band" )
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


navLink : ( String, String ) -> Element msg
navLink ( anchor, label ) =
    Html.a [ Attr.href anchor ] [ Element.text label ]


hero : Element msg
hero =
    Html.section [ Attr.class "hero wrap" ]
        [ Html.p [ Attr.class "status" ]
            [ Html.span [ Attr.class "dot" ] []
            , Element.text "Chicago, IL"
            , Element.text " / Open to work"
            ]
        , Html.h1 [ Attr.class "name" ]
            [ Element.text "Bazyl "
            , Element.element "br" [] []
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


claim : Element msg
claim =
    section "claim"
        "01 / the claim"
        "Most AI dies in procurement and uptime, not in accuracy."
        [ Html.ol [ Attr.class "claims" ]
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
                ]
            )
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
        [ Element.element "b" [] [ Element.text item.figure ]
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
            Element.element "span" [] []

          else
            stageTable item.stages
        , case item.href of
            Just href ->
                Html.a [ Attr.class "link", Attr.href href ]
                    [ Element.text href ]

            Nothing ->
                Element.element "span" [] []
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
    Element.element "table" [ Attr.class "roadmap" ]
        [ Element.element "tbody" [] (List.map stageRow stages) ]


stageRow : Stage -> Element msg
stageRow stage =
    Element.element "tr" []
        [ Element.element "td" [] [ Element.text stage.number ]
        , Element.element "td" [] [ Element.text stage.description ]
        , Element.element "td" []
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
            [ Element.element "b" [] [ Element.text role.span ]
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
        [ groupLabel "Research"
        , paperCard
        , groupLabel "Podcasts"
        , Html.div [ Attr.class "writes" ] (List.map piece podcasts)
        , groupLabel "Posts"
        , Html.ul [ Attr.class "posts" ] (List.map postRow posts)
        ]


groupLabel : String -> Element msg
groupLabel label =
    Html.p [ Attr.class "group-label" ] [ Element.text label ]


{-| The paper gets the full width and two links: the article, and the notebook
that produced it, because the notebook being public is the point.
-}
paperCard : Element msg
paperCard =
    Element.element "article" [ Attr.class "write write--paper" ]
        [ Html.p [ Attr.class "write-meta" ] [ Element.text paper.kind ]
        , Html.h3 [] [ Element.text paper.heading ]
        , Html.p [] [ Element.text paper.body ]
        , Html.div [ Attr.class "write-links" ]
            [ Html.a [ Attr.class "link", Attr.href paper.href ] [ Element.text paper.label ]
            , Html.a
                [ Attr.class "link"
                , Attr.href "https://github.com/bazylhorsey/livestock-logistic-optimizer"
                ]
                [ Element.text "the notebook, gurobi MIP" ]
            ]
        ]


postRow : Post -> Element msg
postRow post =
    Html.li []
        [ Html.a [ Attr.class "post", Attr.href post.href ]
            [ Html.span [ Attr.class "post-meta" ]
                [ Element.element "b" [] [ Element.text post.date ]
                , Html.span [] [ Element.text post.outlet ]
                ]
            , Html.span [ Attr.class "post-body" ]
                [ Element.element "b" [ Attr.class "post-title" ] [ Element.text post.title ]
                , Html.span [ Attr.class "post-gist" ] [ Element.text post.gist ]
                ]
            , Html.span [ Attr.class "post-go" ] [ Element.text "→" ]
            ]
        ]


piece : Piece -> Element msg
piece item =
    Element.element "article" [ Attr.class "write" ]
        [ Html.p [ Attr.class "write-meta" ] [ Element.text item.kind ]
        , Html.h3 [] [ Element.text item.heading ]
        , Html.p [] [ Element.text item.body ]
        , Html.a [ Attr.class "link", Attr.href item.href ] [ Element.text item.label ]
        ]


band : Element msg
band =
    Html.section [ Attr.class "band", Attr.id "band" ]
        [ Html.div [ Attr.class "wrap band-in" ]
            [ Html.p [ Attr.class "eyebrow" ] [ Element.text "05 / other thing" ]
            , Html.h2 [ Attr.class "band-name" ] [ Element.text "The Comedowns" ]
            , Html.p [ Attr.class "band-sub" ]
                [ Element.text
                    "Chicago punk / midwest emo. Somewhere between loud and sincere."
                ]
            , Html.ol [ Attr.class "tracks" ] (List.map track tracks)
            , Html.p [ Attr.class "band-note" ]
                [ Element.text
                    "The rest of this site is the day job. This is the night one."
                ]
            ]
        ]


track : String -> Element msg
track title =
    Html.li [] [ Element.element "b" [] [ Element.text title ] ]


contact : Element msg
contact =
    Html.section [ Attr.class "section wrap", Attr.id "contact" ]
        [ Html.p [ Attr.class "eyebrow" ] [ Element.text "06 / contact" ]
        , Html.h2 [ Attr.class "h2" ] [ Element.text "Got something worth breaking?" ]
        , Html.p [ Attr.class "contact-lede" ]
            [ Element.text
                ("Roles, technical leadership, or a hard edge-inference problem. "
                    ++ "I read all of it and I answer."
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
        , Element.element "div" [] children
        ]



-- GLUE
-- What a Jorn runtime does for you.


main : Program Value Model Value
main =
    Platform.worker
        { init =
            \flags ->
                let
                    model =
                        init flags
                in
                ( model, send "mount" (Jorn.Patch.encodeHtml (view model)) )
        , update = receive
        , subscriptions = \_ -> fromClient identity
        }


receive : Value -> Model -> ( Model, Cmd msg )
receive raw model =
    let
        routed =
            Decode.decodeValue Routing.decoder raw
                |> Result.mapError Decode.errorToString
                |> Result.andThen
                    (\incoming ->
                        Routing.route incoming (view model)
                            |> Result.mapError Routing.errorToString
                    )
    in
    case routed of
        Ok msg ->
            let
                next =
                    update msg model
            in
            ( next
            , send "patches" (Jorn.Patch.encode (Jorn.Patch.diff (view model) (view next)))
            )

        Err problem ->
            ( model, send "error" (Encode.string problem) )


send : String -> Value -> Cmd msg
send kind payload =
    toClient (Encode.object [ ( kind, payload ) ])