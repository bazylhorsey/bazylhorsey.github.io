module CaseStudy exposing (Model, Msg, date, dateLabel, init, slug, title, update, view)

{-| "Escapes Multiply", a case study on pricing a vision layer next to the
people who already inspect a dock.

The math is the cumulative quality model I built in a spreadsheet in July
2026, rebuilt here so every number on the page moves when you drag an input.
Outside numbers are published benchmarks, cited at the bottom. Inside numbers
are illustrative defaults, not anyone's customer data.

Equations are plain text for now. Each one has a MATHML comment above it with
the markup it should become once Jorn ships MathML (v0.3).

-}

import Jorn.Attribute as Attr
import Jorn.Element as Element exposing (Element)
import Jorn.Element.Html as Html
import Jorn.Event as Events


title : String
title =
    "Escapes Multiply"


slug : String
slug =
    "/writing/escapes-multiply/"


date : String
date =
    "2026-08-01"


dateLabel : String
dateLabel =
    "2026.08"



-- MODEL


type alias Model =
    { d0 : Float
    , coverage : Float
    , recall : Float
    , rho : Float
    , audit : Float
    , useMeasured : Bool
    , measured : Float
    , cost : Float
    , volume : Float
    , fpr : Float
    , minutes : Float
    , wage : Float
    , hover : Maybe Int
    }


{-| The spreadsheet's base case. -}
init : Model
init =
    { d0 = 0.2
    , coverage = 1
    , recall = 0.91
    , rho = 0.15
    , audit = 0.8
    , useMeasured = False
    , measured = 0.95
    , cost = 150
    , volume = 250000
    , fpr = 0.03
    , minutes = 2.5
    , wage = 28
    , hover = Nothing
    }


type Field
    = D0
    | Coverage
    | Recall
    | Rho
    | Audit
    | Measured
    | Cost
    | Volume
    | Fpr
    | Minutes
    | Wage


type Msg
    = Set Field String
    | UseMeasured Bool
    | Hover Int
    | Unhover
    | Reset


update : Msg -> Model -> Model
update msg model =
    case msg of
        Set field raw ->
            case String.toFloat raw of
                Just v ->
                    put field v model

                Nothing ->
                    model

        UseMeasured on ->
            { model | useMeasured = on }

        Hover i ->
            { model | hover = Just i }

        Unhover ->
            { model | hover = Nothing }

        Reset ->
            init


get : Field -> Model -> Float
get field m =
    case field of
        D0 ->
            m.d0

        Coverage ->
            m.coverage

        Recall ->
            m.recall

        Rho ->
            m.rho

        Audit ->
            m.audit

        Measured ->
            m.measured

        Cost ->
            m.cost

        Volume ->
            m.volume

        Fpr ->
            m.fpr

        Minutes ->
            m.minutes

        Wage ->
            m.wage


put : Field -> Float -> Model -> Model
put field v m =
    case field of
        D0 ->
            { m | d0 = v }

        Coverage ->
            { m | coverage = v }

        Recall ->
            { m | recall = v }

        Rho ->
            { m | rho = v }

        Audit ->
            { m | audit = v }

        Measured ->
            { m | measured = v }

        Cost ->
            { m | cost = v }

        Volume ->
            { m | volume = v }

        Fpr ->
            { m | fpr = v }

        Minutes ->
            { m | minutes = v }

        Wage ->
            { m | wage = v }



-- THE MATH
-- Same formulas as the spreadsheet, cell for cell.


{-| Human recall at prevalence d, fitted to the Wolfe anchor points:
7% missed at 50%, 25% at 10%, 52% at 1%. Valid roughly 0.5% to 50%.
-}
humanRecall : Float -> Float
humanRecall d =
    clamp 0 1 (1.01 + 0.112 * logBase e d)


{-| Escape rate with people only, at prevalence d. -}
humanEscape : Float -> Float
humanEscape d =
    d * (1 - humanRecall d)


{-| Share of human misses the vision layer catches: c R (1 - rho). -}
catch : Model -> Float
catch m =
    m.coverage * m.recall * (1 - m.rho)


type alias Result =
    { e0 : Float
    , e1 : Float
    , e2 : Float
    , reduction : Float
    , prevented : Float
    , avoided : Float
    , avoidedWithAudit : Float
    , tp : Float
    , fp : Float
    , precision : Float
    , hours : Float
    , reviewCost : Float
    , net : Float
    , ratio : Float
    }


results : Model -> Result
results m =
    let
        e0 =
            if m.useMeasured then
                1 - m.measured

            else
                humanEscape m.d0

        k =
            catch m

        e1 =
            e0 * (1 - k)

        e2 =
            e1 * (1 - m.audit)

        avoided =
            (e0 - e1) * m.volume * m.cost

        tp =
            e0 * m.volume * k

        fp =
            (1 - m.d0) * m.volume * m.coverage * m.fpr

        hours =
            (tp + fp) * m.minutes / 60

        reviewCost =
            hours * m.wage
    in
    { e0 = e0
    , e1 = e1
    , e2 = e2
    , reduction = safeDiv (e0 - e1) e0
    , prevented = (e0 - e1) * 10000
    , avoided = avoided
    , avoidedWithAudit = (e0 - e2) * m.volume * m.cost
    , tp = tp
    , fp = fp
    , precision = safeDiv tp (tp + fp)
    , hours = hours
    , reviewCost = reviewCost
    , net = avoided - reviewCost
    , ratio = safeDiv avoided reviewCost
    }


safeDiv : Float -> Float -> Float
safeDiv a b =
    if b == 0 then
        0

    else
        a / b



-- CONTENT


type Block
    = P String
    | Eq String
    | Defs (List ( String, String ))
    | Note String
    | Steps (List ( String, String ))
    | Figure Fig


type Fig
    = Funnel
    | Ceiling
    | Overlap
    | Burden
    | Dollars


sections : List ( String, List Block )
sections =
    [ ( "The question every ops lead asks"
      , [ P "Every operations lead I've sat across from asks some version of the same thing. My people already check every shipment. What does a camera add?"
        , P "The honest answer isn't a percentage. It's a model. This page is that model. I built it in July 2026 during my time at Arvist, and what I'm sharing here is the method, not anyone's customer data. Every outside number is a published benchmark with its source at the bottom. Every inside number is an assumption, and you can drag it."
        , P "The short version: people and machines fail in different ways, and on a dock that difference is where the money is."
        ]
      )
    , ( "Escapes multiply"
      , [ P "A defect only reaches the customer if every inspection layer misses it. That one sentence does most of the work. Escapes multiply. They don't average."

        -- MATHML (Jorn v0.3): render as one display equation, e.g.
        --   <math display="block">
        --     <mi>e</mi><mo>=</mo><msub><mi>d</mi><mn>0</mn></msub>
        --     <mo>[</mo><mn>1</mn><mo>-</mo><msub><mi>E</mi><mi>h</mi></msub>
        --       <mo>(</mo><msub><mi>d</mi><mn>0</mn></msub><mo>)</mo><mo>]</mo>
        --     <mo>[</mo><mn>1</mn><mo>-</mo><mi>c</mi><mi>R</mi>
        --       <mo>(</mo><mn>1</mn><mo>-</mo><mi>ρ</mi><mo>)</mo><mo>]</mo>
        --     <mo>(</mo><mn>1</mn><mo>-</mo><mi>a</mi><mo>)</mo>
        --   </math>
        -- followed by a second <math> for Q = 1 - e.
        , Eq "e = d₀ · [1 − Eₕ(d₀)] · [1 − c·R·(1 − ρ)] · (1 − a)        Q = 1 − e"
        , Defs
            [ ( "d₀", "upstream defect rate: the share of shipments with any defect before anyone looks." )
            , ( "Eₕ(d₀)", "human recall at that prevalence. Not a constant, more on that below." )
            , ( "c", "coverage: the share of shipments the cameras actually see." )
            , ( "R", "model recall: the share of present defects the model catches." )
            , ( "ρ", "miss overlap. 0 means people and the model fail on different things. 1 means the model only misses what people already miss." )
            , ( "a", "audit recovery: the share of what's left that gets caught on review, before it ships or when a claim comes in." )
            , ( "Q", "outbound accuracy, the number that ends up on a slide." )
            ]
        , P "If you averaged, a 91% model and a team that catches 83% would land somewhere in the high eighties. Multiply instead and the picture changes. People let some defects through, the model catches most of those, and what's left is small. Push the inputs around and watch where the defects go."
        , Figure Funnel
        ]
      )
    , ( "People get worse as the floor gets cleaner"
      , [ P "The big assumption in the model is that human recall isn't a constant. It falls as defects get rarer. Researchers call it the low prevalence effect, and it's one of the most replicated results in visual search."
        , P "In Jeremy Wolfe's lab, observers missed about 7% of targets when half the displays had one. In a mixed-prevalence study the miss rate climbed to 25% for targets that showed up 10% of the time, and 52% for targets that showed up 1% of the time. It isn't laziness. The cause is a shift in criterion, not a loss of sensitivity: when something is rare, people want more evidence before they call it. Trained airport screeners show it too."

        -- MATHML (Jorn v0.3):
        --   <math display="block">
        --     <msub><mi>E</mi><mi>h</mi></msub><mo>(</mo><mi>d</mi><mo>)</mo>
        --     <mo>=</mo><mn>1.01</mn><mo>+</mo><mn>0.112</mn>
        --     <mo>&#x2062;</mo><mi>ln</mi><mo>&#x2061;</mo><mi>d</mi>
        --   </math>
        -- with the validity range (0.5% to 50%) as a caption, not inside the math.
        , Eq "Eₕ(d) = 1.01 + 0.112 · ln d        fitted for 0.5% ≤ d ≤ 50%"
        , P "Machine recall has no prevalence term. A model looks at the ten thousandth clean pallet with the same attention it gave the first one. That asymmetry is the whole argument for putting the two together."
        , Figure Ceiling
        , P "Here's the result that surprised me. Across a 5x swing in upstream defect rate, from 10% to 50%, human-only outbound accuracy barely moves. It stays between about 96.2% and 97.5%. As an operation gets cleaner, people get proportionally worse at catching what's left. The layer limits itself."
        , P "That's a candidate explanation, not a proof, for why perfect order rate medians sit around 93 to 96% no matter who you benchmark. Perfect order counts more kinds of failure than damage and mispicks, so the two numbers aren't the same thing. But a ceiling that holds across very different operations deserves a hard look."
        , Note "Below 10% the curve looks better for a boring reason: there are almost no defects to escape in the first place. The ceiling claim is about the realistic operating range. One more caveat: Wolfe's 2005 single-prevalence study put misses near 30% at 1% prevalence. The fit uses the mixed-prevalence numbers, which is the harsher read on people."
        ]
      )
    , ( "The number nobody has measured"
      , [ P "ρ is the most important input in the model and the one with the least evidence behind it. It asks a simple question. When the model misses something, is it the same thing a person would have missed?"
        , P "If the model and your people fail on different things, the model's recall counts in full. If the model mostly misses the same hard cases your people miss, it adds a lot less. At ρ = 0.5 the model adds half of what it looks like it adds."
        , Figure Overlap
        , P "The good news is you can measure it with data most sites already have. Take the shipments where a person flagged nothing and the model flagged something, and the reverse. The overlap between those two sets is ρ. It's one query. The 15% default here is a placeholder until somebody runs it."
        ]
      )
    , ( "Coverage beats recall"
      , [ P "Coverage and recall trade almost one for one, because they multiply. A model that sees every shipment at 88% recall catches more than a model that sees 80% of shipments at 99%: 0.88 against 0.79."
        , P "For an ROI case that changes where the effort goes. Getting every dock door covered, with camera angles that actually see the freight, is usually worth more than the last few points of model accuracy. It's also the less glamorous work, which is why it gets skipped."
        ]
      )
    , ( "Good operations get the same relative gain"
      , [ P "If you plug in a site's measured accuracy instead of the curve, something useful falls out. The escape reduction doesn't depend on the baseline at all."

        -- MATHML (Jorn v0.3):
        --   <math display="block">
        --     <mn>1</mn><mo>-</mo>
        --     <mfrac><msub><mi>e</mi><mn>1</mn></msub><msub><mi>e</mi><mn>0</mn></msub></mfrac>
        --     <mo>=</mo><mi>c</mi><mi>R</mi><mo>(</mo><mn>1</mn><mo>-</mo><mi>ρ</mi><mo>)</mo>
        --   </math>
        , Eq "1 − e₁ / e₀ = c · R · (1 − ρ)"
        , P "A site at 90% and a site at 99% cut escapes by the same share. The absolute gain shrinks as the baseline improves, but the relative gain doesn't. So an operation that's already good isn't a bad fit for this kind of system. Turn on the measured baseline switch in the first figure and try a few."
        ]
      )
    , ( "False positives move labor, not quality"
      , [ P "This is the objection an ops lead raises the second you show them 99.2%. What does it cost my people to clear the flags?"
        , P "False positives don't change what ships. They change how many minutes somebody spends looking at a clean pallet. So I track them on their own line."

        -- MATHML (Jorn v0.3): three rows, best as one <math display="block">
        -- holding an <mtable> so the equals signs line up:
        --   FP = (1 - d0) N c FPR
        --   TP = e0 N c R (1 - rho)
        --   precision = TP / (TP + FP), with <mfrac>
        , Eq "FP = (1 − d₀) · N · c · FPR        TP = e₀ · N · c·R·(1 − ρ)        precision = TP / (TP + FP)"
        , Figure Burden
        , P "At the defaults, about half the flags are real. That sounds bad until you price it. Clearing every flag costs a small fraction of what the prevented escapes are worth. Having that number ready is stronger than having the story ready."
        , Note "People raise false alarms too: about 2% in classic visual inspection studies, and 15 to 25% in some manufacturing settings. The fair comparison is against that, not against zero."
        ]
      )
    , ( "Putting a dollar on an escape"
      , [ P "An escaped defect costs labor, return freight and goodwill. Published estimates put one shipping error somewhere between $50 and $250. The default here is $150. Use the site's own number when they have one. They usually do."
        , P "The audit loop is the last layer, and it's easy to oversell. It resolves things that were flagged. It doesn't go back and find escapes nobody saw. What it does is turn an escape into a claim you can defend with timestamped footage, and that matters, because concealed damage claims get denied far more often and the burden of proof shifts to the receiver. So I count the audit loop as financial exposure, not dock accuracy, and I report the two separately."
        , Figure Dollars
        ]
      )
    , ( "How I'd run this at a new site"
      , [ Steps
            [ ( "Pick one denominator.", "Pick-line, order and retail-compliance accuracy are three different numbers. Agree on one before you measure anything." )
            , ( "Measure the baseline at two prevalences.", "The human curve comes from lab studies. Check it against one site at two different defect rates before it goes in a deck." )
            , ( "Measure ρ.", "One query over shipments flagged by one layer and not the other." )
            , ( "Count coverage honestly.", "The shipments the cameras actually see, not the doors that have cameras." )
            , ( "Count false positives and the minutes to clear one.", "That's the labor line, and it's the first thing an ops lead will ask about." )
            , ( "Price an escape with the site's numbers.", "Then report quality and financial exposure as two lines, not one." )
            ]
        ]
      )
    , ( "What this doesn't claim"
      , [ P "It doesn't say any particular model hits 91%. That's a conservative starting figure for the math, not a measured result. Published vision benchmarks run from 97 to 99.5%, and I'd still assume less until a site proves otherwise."
        , P "It doesn't say the human curve is a measurement of your floor. It's lab data, extrapolated to dock work. Directionally sound, worth validating."
        , P "And it doesn't say AI replaces inspectors. The whole point of the math is that two different kinds of failure, stacked, beat either one alone. The best number on this page needs both."
        ]
      )
    ]


sources : List ( String, String )
sources =
    [ ( "Wolfe, Horowitz and Kenner, \"Rare items often missed in visual searches,\" Nature 2005, supplement", "https://search.bwh.harvard.edu/new/pubs/Nature_suppl.pdf" )
    , ( "Wolfe et al. 2005, low prevalence miss rates, Journal of Vision", "https://jov.arvojournals.org/article.aspx?articleid=2193138" )
    , ( "Criterion shift as the cause of the prevalence effect", "https://pmc.ncbi.nlm.nih.gov/articles/PMC2662480/" )
    , ( "Wolfe, Brunelli, Rubinstein and Horowitz, prevalence effects in airport screeners", "https://pubmed.ncbi.nlm.nih.gov/24297778/" )
    , ( "Fleck and Mitroff 2007, correcting the last response", "https://link.springer.com/article/10.3758/APP.71.3.541" )
    , ( "Perfect order rate medians and top quartile, Modern Materials Handling", "https://www.modernmaterialshandling.com/warehouse-mgmt/warehouse-kpis/" )
    , ( "Pick-line, order and compliance accuracy as different denominators", "https://openskygroup.com/warehouse-kpis/" )
    , ( "Cost of one shipping mistake, $50 to $250", "https://wisys.com/blog/warehouse-scanner-roi-what-the-data-actually-shows" )
    , ( "Human false positive rates in visual inspection", "https://en.wikipedia.org/wiki/Visual_inspection" )
    , ( "Computer vision detection accuracy and false positive rates", "https://oxmaint.com/industries/steel-plant/computer-vision-vs-manual-inspection-in-manufacturing" )
    , ( "US warehouse wages, 2023", "https://gitnux.org/warehouse-statistics/" )
    , ( "Concealed damage claims and burden of proof", "https://armstrongtransport.com/blog/what-is-a-concealed-damage-claim-and-how-can-it-be-resolved" )
    ]



-- VIEW


view : Model -> Element Msg
view model =
    Html.article
        [ Attr.class "essay study wrap" ]
        [ Html.header [ Attr.class "essay-head" ]
            [ Html.p [ Attr.class "eyebrow" ]
                [ Element.text ("case study / " ++ dateLabel) ]
            , Html.h1 [ Attr.class "essay-title" ] [ Element.text title ]
            , Html.p [ Attr.class "study-dek" ]
                [ Element.text "How to analyze the ROI of computer vision working next to the people who already inspect a warehouse dock. With a model you can push on." ]
            , Html.p [ Attr.class "essay-byline" ]
                [ Html.b [] [ Element.text "Bazyl Horsey" ]
                , Html.span [] [ Element.text "Chicago, IL" ]
                ]
            ]
        , Html.div [ Attr.class "essay-body" ]
            (List.concatMap (viewSection model) sections
                ++ [ Html.h2 [] [ Element.text "Sources" ]
                   , Html.ol [ Attr.class "study-sources" ] (List.map source sources)
                   ]
            )
        , Html.footer [ Attr.class "essay-end" ]
            [ Html.a [ Attr.class "btn", Attr.href "/" ] [ Element.text "Back to the portfolio" ]
            , Html.a [ Attr.class "btn", Attr.href "mailto:bhorsey16@gmail.com" ]
                [ Element.text "bhorsey16@gmail.com" ]
            ]
        ]


viewSection : Model -> ( String, List Block ) -> List (Element Msg)
viewSection model ( heading, blocks ) =
    Html.h2 [] [ Element.text heading ] :: List.map (viewBlock model) blocks


viewBlock : Model -> Block -> Element Msg
viewBlock model block =
    case block of
        P text ->
            Html.p [] [ Element.text text ]

        Eq text ->
            Html.p [ Attr.class "study-eq", Attr.attribute "role" "math", Attr.attribute "aria-label" text ]
                [ Element.text text ]

        Defs items ->
            Html.dl [ Attr.class "study-defs" ]
                (List.concatMap
                    (\( k, v ) -> [ Html.dt [] [ Element.text k ], Html.dd [] [ Element.text v ] ])
                    items
                )

        Note text ->
            Html.p [ Attr.class "study-note" ] [ Element.text text ]

        Steps items ->
            Html.ol [ Attr.class "essay-steps" ] (List.map leadItem items)

        Figure fig ->
            viewFigure model fig


leadItem : ( String, String ) -> Element msg
leadItem ( lead, rest ) =
    Html.li []
        [ Html.span []
            [ Html.strong [] [ Element.text lead ]
            , Element.text (" " ++ rest)
            ]
        ]


source : ( String, String ) -> Element msg
source ( label, href ) =
    Html.li [] [ Html.a [ Attr.href href ] [ Element.text label ] ]



-- FIGURES


viewFigure : Model -> Fig -> Element Msg
viewFigure model fig =
    let
        r =
            results model
    in
    case fig of
        Funnel ->
            figure "fig 01 / where the defects go, per 10,000 shipments"
                [ controls model [ D0, Coverage, Recall, Rho, Audit ]
                , measuredSwitch model
                , funnel model r
                , tiles
                    [ ( pct 1 (1 - r.e0), "outbound accuracy, people only" )
                    , ( pct 2 (1 - r.e1), "with the vision layer" )
                    , ( pct 1 r.reduction, "fewer escapes" )
                    , ( fixed 0 r.prevented, "defects stopped per 10,000 shipments" )
                    ]
                , Html.button [ Attr.class "btn study-reset", Attr.type_ "button", Events.onClick Reset ]
                    [ Element.text "reset to the base case" ]
                ]

        Ceiling ->
            figure "fig 02 / outbound accuracy across upstream defect rates"
                [ ceiling model ]

        Overlap ->
            figure "fig 03 / combined accuracy by model recall and miss overlap"
                [ controls model [ Recall, Rho ]
                , overlapTable model r
                , Html.p [ Attr.class "study-caption" ]
                    [ Element.text "Columns are model recall R, rows are miss overlap ρ. The row and column closest to your current inputs are highlighted. Coverage and baseline come from the first figure." ]
                ]

        Burden ->
            figure "fig 04 / review burden per year"
                [ controls model [ Fpr, Minutes, Wage ]
                , tiles
                    [ ( fixed 0 (r.tp + r.fp), "flags to review" )
                    , ( pct 0 r.precision, "of flags are real" )
                    , ( fixed 0 r.hours, "review hours" )
                    , ( money r.reviewCost, "review labor" )
                    ]
                ]

        Dollars ->
            figure "fig 05 / what it's worth per year"
                [ controls model [ Cost, Volume ]
                , tiles
                    [ ( money r.avoided, "escapes avoided, dock only" )
                    , ( money r.avoidedWithAudit, "including the audit loop" )
                    , ( money r.net, "net of review labor" )
                    , ( fixed 0 r.ratio ++ "x", "benefit to review cost" )
                    ]
                , Html.p [ Attr.class "study-caption" ]
                    [ Element.text "The first and third figures leave the audit loop out on purpose. Read the middle one as financial exposure, not dock accuracy." ]
                ]


figure : String -> List (Element msg) -> Element msg
figure caption children =
    Html.figure [ Attr.class "study-fig" ]
        (Html.figcaption [ Attr.class "study-fig-cap" ] [ Element.text caption ] :: children)


tiles : List ( String, String ) -> Element msg
tiles items =
    Html.div [ Attr.class "nums nums--inline study-tiles" ]
        (List.map
            (\( big, small ) ->
                Html.div [ Attr.class "num" ]
                    [ Html.b [] [ Element.text big ], Html.span [] [ Element.text small ] ]
            )
            items
        )



-- CONTROLS


type alias Spec =
    { label : String
    , symbol : String
    , min : Float
    , max : Float
    , step : Float
    , show : Float -> String
    }


spec : Field -> Spec
spec field =
    case field of
        D0 ->
            Spec "upstream defect rate" "d₀" 0.005 0.5 0.005 (pct 1)

        Coverage ->
            Spec "coverage" "c" 0.3 1 0.01 (pct 0)

        Recall ->
            Spec "model recall" "R" 0.5 0.99 0.01 (pct 0)

        Rho ->
            Spec "miss overlap" "ρ" 0 0.9 0.01 (fixed 2)

        Audit ->
            Spec "audit recovery" "a" 0 0.95 0.05 (pct 0)

        Measured ->
            Spec "measured baseline accuracy" "Q₀" 0.85 0.995 0.005 (pct 1)

        Cost ->
            Spec "cost per escape" "$" 25 400 5 money

        Volume ->
            Spec "shipments per year" "N" 10000 2000000 10000 (fixed 0)

        Fpr ->
            Spec "model false positive rate" "FPR" 0 0.15 0.005 (pct 1)

        Minutes ->
            Spec "minutes to clear a flag" "min" 0.5 10 0.5 (fixed 1)

        Wage ->
            Spec "loaded labor cost per hour" "$/h" 15 60 1 money


controls : Model -> List Field -> Element Msg
controls model fields =
    Html.div [ Attr.class "study-controls" ] (List.map (slider model) fields)


slider : Model -> Field -> Element Msg
slider model field =
    let
        s =
            spec field

        v =
            get field model
    in
    Html.label [ Attr.class "study-slider" ]
        [ Html.span [ Attr.class "study-slider-k" ]
            [ Element.text s.label
            , Html.i [] [ Element.text s.symbol ]
            ]
        , Html.output [ Attr.class "study-slider-v" ] [ Element.text (s.show v) ]
        , Html.input
            [ Attr.type_ "range"
            , Attr.attribute "min" (String.fromFloat s.min)
            , Attr.attribute "max" (String.fromFloat s.max)
            , Attr.attribute "step" (String.fromFloat s.step)
            , Attr.value (String.fromFloat v)
            , Events.onInput (Set field)
            ]
        ]


measuredSwitch : Model -> Element Msg
measuredSwitch model =
    Html.div [ Attr.class "study-measured" ]
        [ Html.label [ Attr.class "study-check" ]
            [ Html.input
                [ Attr.type_ "checkbox"
                , Attr.checked model.useMeasured
                , Events.onCheck UseMeasured
                ]
            , Element.text "use a measured baseline instead of the human curve"
            ]
        , if model.useMeasured then
            controls model [ Measured ]

          else
            Element.none
        ]



-- FIG 01: the funnel


funnel : Model -> Result -> Element msg
funnel model r =
    let
        rows =
            (if model.useMeasured then
                []

             else
                [ ( "arrive with a defect", model.d0 ) ]
            )
                ++ [ ( "missed by people", r.e0 )
                   , ( "also missed by the vision layer", r.e1 )
                   , ( "left after review", r.e2 )
                   ]

        top =
            List.head rows |> Maybe.map Tuple.second |> Maybe.withDefault 1
    in
    Html.ol [ Attr.class "study-funnel" ]
        (List.indexedMap
            (\i ( label, share ) ->
                Html.li [ Attr.classes [ ( "is-last", i == List.length rows - 1 ) ] ]
                    [ Html.span [ Attr.class "study-funnel-k" ] [ Element.text label ]
                    , Html.span [ Attr.class "study-funnel-bar" ]
                        [ Html.span
                            [ Attr.style "width" (String.fromFloat (100 * safeDiv share top) ++ "%") ]
                            []
                        ]
                    , Html.b [ Attr.class "study-funnel-v" ] [ Element.text (fixed 0 (share * 10000)) ]
                    ]
            )
            rows
        )



-- FIG 02: the ceiling chart


chartW : Float
chartW =
    640


chartH : Float
chartH =
    320


left : Float
left =
    52


right : Float
right =
    16


top_ : Float
top_ =
    16


bottom : Float
bottom =
    40


dMin : Float
dMin =
    0.005


dMax : Float
dMax =
    0.5


qMin : Float
qMin =
    0.95


samples : List Float
samples =
    List.map
        (\i -> dMin * ((dMax / dMin) ^ (toFloat i / 40)))
        (List.range 0 40)


xOf : Float -> Float
xOf d =
    left + (logBase e d - logBase e dMin) / (logBase e dMax - logBase e dMin) * (chartW - left - right)


yOf : Float -> Float
yOf q =
    top_ + (1 - (clamp qMin 1 q - qMin) / (1 - qMin)) * (chartH - top_ - bottom)


ceiling : Model -> Element Msg
ceiling model =
    let
        k =
            catch model

        human d =
            1 - humanEscape d

        combined d =
            1 - humanEscape d * (1 - k)

        line cls f =
            svg "path"
                [ Attr.class cls
                , Attr.attribute "d"
                    (samples
                        |> List.indexedMap
                            (\i d ->
                                (if i == 0 then
                                    "M"

                                 else
                                    "L"
                                )
                                    ++ n (xOf d)
                                    ++ " "
                                    ++ n (yOf (f d))
                            )
                        |> String.join " "
                    )
                ]
                []

        focus =
            case model.hover |> Maybe.andThen (\i -> List.head (List.drop i samples)) of
                Just d ->
                    d

                Nothing ->
                    clamp dMin dMax model.d0

        dot cls q =
            svg "circle"
                [ Attr.class cls
                , Attr.attribute "cx" (n (xOf focus))
                , Attr.attribute "cy" (n (yOf q))
                , Attr.attribute "r" "5"
                ]
                []

        band =
            svg "rect"
                [ Attr.class "ch-band"
                , Attr.attribute "x" (n (xOf 0.1))
                , Attr.attribute "y" (n top_)
                , Attr.attribute "width" (n (xOf 0.5 - xOf 0.1))
                , Attr.attribute "height" (n (chartH - top_ - bottom))
                ]
                []

        yTicks =
            List.concatMap
                (\q ->
                    [ svg "line"
                        [ Attr.class "ch-grid"
                        , Attr.attribute "x1" (n left)
                        , Attr.attribute "x2" (n (chartW - right))
                        , Attr.attribute "y1" (n (yOf q))
                        , Attr.attribute "y2" (n (yOf q))
                        ]
                        []
                    , svgText "ch-tick" (left - 8) (yOf q + 4) "end" (pct 0 q)
                    ]
                )
                [ 0.95, 0.96, 0.97, 0.98, 0.99, 1 ]

        xTicks =
            List.map
                (\d -> svgText "ch-tick" (xOf d) (chartH - bottom + 18) "middle" (pctTrim d))
                [ 0.005, 0.01, 0.02, 0.05, 0.1, 0.2, 0.5 ]

        hits =
            let
                w =
                    (chartW - left - right) / 40
            in
            List.indexedMap
                (\i d ->
                    svg "rect"
                        [ Attr.class "ch-hit"
                        , Attr.attribute "x" (n (xOf d - w / 2))
                        , Attr.attribute "y" (n top_)
                        , Attr.attribute "width" (n w)
                        , Attr.attribute "height" (n (chartH - top_ - bottom))
                        , Events.onMouseEnter (Hover i)
                        ]
                        []
                )
                samples
    in
    Html.div [ Attr.class "study-chart" ]
        [ Html.ul [ Attr.class "study-legend" ]
            [ Html.li [] [ Html.span [ Attr.class "sw sw-human" ] [], Element.text "people only" ]
            , Html.li [] [ Html.span [ Attr.class "sw sw-both" ] [], Element.text "people plus the vision layer" ]
            , Html.li [] [ Html.span [ Attr.class "sw sw-band" ] [], Element.text "the 10 to 50% ceiling band" ]
            ]
        , svg "svg"
            [ Attr.attribute "viewBox" ("0 0 " ++ n chartW ++ " " ++ n chartH)
            , Attr.attribute "role" "img"
            , Attr.attribute "aria-label" "Outbound accuracy against upstream defect rate, people only and with the vision layer"
            , Events.onMouseLeave Unhover
            ]
            ([ band ]
                ++ yTicks
                ++ xTicks
                ++ [ svgText "ch-axis" ((left + chartW - right) / 2) (chartH - 4) "middle" "upstream defect rate d₀ (log scale)"
                   , svg "line"
                        [ Attr.class "ch-focus"
                        , Attr.attribute "x1" (n (xOf focus))
                        , Attr.attribute "x2" (n (xOf focus))
                        , Attr.attribute "y1" (n top_)
                        , Attr.attribute "y2" (n (chartH - bottom))
                        ]
                        []
                   , line "ch-human" human
                   , line "ch-both" combined
                   , dot "ch-dot-human" (human focus)
                   , dot "ch-dot-both" (combined focus)
                   ]
                ++ hits
            )
        , Html.p [ Attr.class "study-readout" ]
            [ Element.text ("At " ++ pct 1 focus ++ " upstream defects, people catch ")
            , Html.b [] [ Element.text (pct 0 (humanRecall focus)) ]
            , Element.text " of them and ship "
            , Html.b [] [ Element.text (pct 1 (human focus)) ]
            , Element.text " clean. With the vision layer: "
            , Html.b [ Attr.class "hot" ] [ Element.text (pct 2 (combined focus)) ]
            , Element.text "."
            ]
        , Html.p [ Attr.class "study-caption" ]
            [ Element.text "Hover or tap along the chart to read a point. The vertical line follows d₀ from the first figure otherwise. Both lines use the human curve, so the measured baseline switch doesn't apply here." ]
        ]


svgNs : String
svgNs =
    "http://www.w3.org/2000/svg"


svg : String -> List (Attr.Attribute msg) -> List (Element msg) -> Element msg
svg =
    Element.namespaced svgNs


svgText : String -> Float -> Float -> String -> String -> Element msg
svgText cls x y anchor label =
    svg "text"
        [ Attr.class cls
        , Attr.attribute "x" (n x)
        , Attr.attribute "y" (n y)
        , Attr.attribute "text-anchor" anchor
        ]
        [ Element.text label ]


n : Float -> String
n x =
    String.fromFloat (toFloat (round (x * 10)) / 10)



-- FIG 03: the overlap table


overlapTable : Model -> Result -> Element msg
overlapTable model r =
    let
        recalls =
            [ 0.8, 0.85, 0.88, 0.91, 0.94, 0.97, 0.99 ]

        rhos =
            [ 0, 0.1, 0.15, 0.2, 0.3, 0.4, 0.5 ]

        -- The grid is coarse, so mark the row and column closest to the
        -- current inputs, not only an exact match.
        nearest target values =
            values
                |> List.sortBy (\v -> abs (v - target))
                |> List.head
                |> Maybe.withDefault target

        rowAt =
            nearest model.rho rhos

        colAt =
            nearest model.recall recalls

        cell rho rec =
            Html.td
                [ Attr.classes
                    [ ( "is-here", rho == rowAt && rec == colAt )
                    , ( "in-row", rho == rowAt )
                    , ( "in-col", rec == colAt )
                    ]
                ]
                [ Element.text (pct 2 (1 - r.e0 * (1 - model.coverage * rec * (1 - rho)))) ]
    in
    Html.div [ Attr.class "study-table" ]
        [ Html.table []
            [ Html.thead []
                [ Html.tr []
                    (Html.th [ Attr.attribute "scope" "col" ] [ Element.text "ρ \\ R" ]
                        :: List.map
                            (\rec ->
                                Html.th
                                    [ Attr.attribute "scope" "col"
                                    , Attr.classes [ ( "is-col", rec == colAt ) ]
                                    ]
                                    [ Element.text (pct 0 rec) ]
                            )
                            recalls
                    )
                ]
            , Html.tbody []
                (List.map
                    (\rho ->
                        Html.tr [ Attr.classes [ ( "is-row", rho == rowAt ) ] ]
                            (Html.th [ Attr.attribute "scope" "row" ] [ Element.text (fixed 2 rho) ]
                                :: List.map (cell rho) recalls
                            )
                    )
                    rhos
                )
            ]
        ]



-- FORMATTING


{-| A number with d decimals and thousands separators. -}
fixed : Int -> Float -> String
fixed d x =
    let
        scale =
            10 ^ d

        units =
            round (abs x * toFloat scale)

        whole =
            units // scale

        frac =
            modBy scale units

        sign =
            if x < 0 && units /= 0 then
                "-"

            else
                ""
    in
    sign
        ++ commas whole
        ++ (if d == 0 then
                ""

            else
                "." ++ String.padLeft d '0' (String.fromInt frac)
           )


commas : Int -> String
commas i =
    if i < 1000 then
        String.fromInt i

    else
        commas (i // 1000) ++ "," ++ String.padLeft 3 '0' (String.fromInt (modBy 1000 i))


pct : Int -> Float -> String
pct d x =
    fixed d (x * 100) ++ "%"


{-| Axis labels: 0.5%, 1%, 50%. No trailing zeros. -}
pctTrim : Float -> String
pctTrim x =
    String.fromFloat (toFloat (round (x * 1000)) / 10) ++ "%"


money : Float -> String
money x =
    if x < 0 then
        "-$" ++ fixed 0 (abs x)

    else
        "$" ++ fixed 0 x
