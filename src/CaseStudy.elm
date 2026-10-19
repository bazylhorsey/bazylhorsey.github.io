module CaseStudy exposing (Model, Msg, date, dateLabel, init, slug, title, update, view)

{-| "Escapes Multiply", a case study on pricing a vision layer next to the
people who already inspect a dock.

An open assessment built only from published research: a layered escape
model where every number on the page moves when you drag an input. Outside
numbers are published benchmarks, cited at the bottom. Defaults are round,
illustrative values, not any company's data.

Equations are real MathML, built with Jorn's MathMl elements (v0.2.1).

-}

import Jorn.Attribute as Attr
import Jorn.Element as Element exposing (Element)
import Jorn.Element.Html as Html
import Jorn.Element.MathMl as M
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
    , claims : Float
    , fix : Float
    , useMeasured : Bool
    , measured : Float
    , cost : Float
    , volume : Float
    , fpr : Float
    , minutes : Float
    , wage : Float
    , hover : Maybe Int
    }


{-| Round, illustrative defaults. -}
init : Model
init =
    { d0 = 0.02
    , coverage = 1
    , recall = 0.9
    , rho = 0.2
    , claims = 0.5
    , fix = 20
    , useMeasured = False
    , measured = 0.994
    , cost = 150
    , volume = 250000
    , fpr = 0.03
    , minutes = 3
    , wage = 28
    , hover = Nothing
    }


type Field
    = D0
    | Coverage
    | Recall
    | Rho
    | Claims
    | Fix
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

        Claims ->
            m.claims

        Fix ->
            m.fix

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

        Claims ->
            { m | claims = v }

        Fix ->
            { m | fix = v }

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
-- Layered escapes. Miss overlap stays inside what the two recalls allow, and
-- footage recovers money, not defects.


{-| Human recall at prevalence d, fitted to Wolfe's 2005 single-target
experiment: 7% missed at 50%, 16% at 10%, 30% at 1%. The mixed experiment's
25% and 52% are per-type rates inside a design where some target showed on
half the trials, so they don't map onto one defect rate. Below 1% it's an
extrapolation.
-}
humanRecall : Float -> Float
humanRecall d =
    clamp 0 1 (0.973 + 0.0589 * logBase e d)


{-| Escape rate with people only, at prevalence d. -}
humanEscape : Float -> Float
humanEscape d =
    d * (1 - humanRecall d)


{-| Share of the defects people miss that the vision layer catches, given
people's miss rate m.

The model's miss rate on those defects, mu, runs from 1 - R when the two
fail independently (rho = 0) to the most overlap the recalls allow
(rho = 1): every model miss is also a human miss, so the pair is no better
than the model alone. Discounting recall by (1 - rho) instead goes past that
bound, and at high rho made people plus model worse than the model alone.
-}
catchWith : Float -> Float -> Float -> Float -> Float
catchWith coverage recall rho m =
    let
        nested =
            if m <= 0 then
                1

            else
                min 1 ((1 - recall) / m)

        mu =
            (1 - rho) * (1 - recall) + rho * nested
    in
    coverage * (1 - mu)


catch : Model -> Float -> Float
catch model m =
    catchWith model.coverage model.recall model.rho m


type alias Result =
    { e0 : Float
    , e1 : Float
    , reduction : Float
    , prevented : Float
    , avoided : Float
    , recovered : Float
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

        -- People's miss rate. With a measured baseline it comes from the
        -- measured escapes over d0, capped at missing everything.
        miss =
            clamp 0 1 (safeDiv e0 m.d0)

        k =
            catch m miss

        e1 =
            e0 * (1 - k)

        -- A caught defect still costs a re-pick or repack.
        avoided =
            (e0 - e1) * m.volume * (m.cost - m.fix)

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
    , reduction = safeDiv (e0 - e1) e0
    , prevented = (e0 - e1) * 10000
    , avoided = avoided
    , recovered = m.coverage * e1 * m.volume * m.cost * m.claims
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
    | Eq (List (Element Never)) String
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
    [ ( "The obvious question"
      , [ Note "An independent case study, built only from peer-reviewed research and public industry sources, to show how you might estimate the ROI of pairing people with computer vision. It contains no proprietary data and doesn't describe any company's product, customers or results."
        , P "It's the obvious question about computer vision on a warehouse dock. If people already check every shipment, what does a camera add?"
        , P "The honest answer isn't a percentage. It's a model. This page is that model. Every outside number has its source at the bottom. Every other number is a round, illustrative assumption, and you can drag it."
        , P "The short version: people and machines fail in different ways, and on a dock that difference is where the money is."
        ]
      )
    , ( "Escapes multiply"
      , [ P "A defect only reaches the customer if every inspection layer misses it. That one sentence does most of the work. Escapes multiply. They don't average."
        , Eq
            [ eq [ mi "e", mo "=", d0, mi "m", mo "[", mn "1", mo "−", mi "c", paren [ mn "1", mo "−", mi "μ" ], mo "]" ]
            , eq [ mi "m", mo "=", mn "1", mo "−", eh, paren [ d0 ] ]
            , eq [ mi "Q", mo "=", mn "1", mo "−", mi "e" ]
            ]
            ""
        , Defs
            [ ( "d₀", "upstream defect rate: the share of shipments with any defect before anyone looks." )
            , ( "Eₕ(d₀)", "human recall at that prevalence. Not a constant, more on that below." )
            , ( "m", "the share of defects people miss." )
            , ( "c", "coverage: the share of shipments the cameras actually see." )
            , ( "R", "model recall: the share of present defects the model catches, measured in the field." )
            , ( "μ", "how often the model misses a defect people already missed. It depends on R and on ρ, below." )
            , ( "Q", "outbound accuracy: the share of shipments that leave without a defect." )
            ]
        , P "If you averaged, a 90% model and a team that catches about three quarters of defects would land around 82%. Multiply instead and the picture changes. People let about a quarter of defects through, the model catches most of those, and what's left is small. Push the inputs around and watch where the defects go."
        , Figure Funnel
        ]
      )
    , ( "People get worse as the floor gets cleaner"
      , [ P "The big assumption in the model is that human recall isn't a constant. It falls as defects get rarer. Researchers call it the low prevalence effect, and it's one of the most replicated results in visual search."
        , P "In Jeremy Wolfe's lab, observers searching for one kind of target missed about 7% of them when half the displays had one, 16% when one in ten did, and 30% when one in a hundred did. It isn't laziness. The cause is a shift in criterion, not a loss of sensitivity: when something is rare, people want more evidence before they call it. Trained airport screeners show it too, and procedural fixes only partly help. Even letting people take back their last answer leaves some kinds of rare targets missed often."
        , Eq
            [ eq [ eh, paren [ mi "d" ], mo "=", mn "0.973", mo "+", mn "0.0589", fn "ln", mi "d" ] ]
            "fitted to 1%, 10% and 50% prevalence"
        , P "Lab numbers vary a lot by task. At 1 to 2% prevalence, other experiments put misses anywhere from about a quarter to a half. I fit the curve to the single-target experiment because it matches this model's one-kind-of-defect setup, and because it sits closest to factory inspection studies, where people catch around 80% of defects. If your people miss more than that, the vision layer is worth more than this page says."
        , P "Machine recall has no prevalence term. A model looks at the ten thousandth clean pallet with the same attention it gave the first one. That asymmetry is the whole argument for putting the two together."
        , Figure Ceiling
        , P "Here's the check I'd want before trusting the curve on a dock. WERC's DC Measures benchmark puts order picking accuracy at about 99.4% on average, between 99.0% and 99.6% for most companies, and 99.89% or better for the best. Give the curve an upstream defect rate between about 1.5% and 4.5%, and people-only accuracy lands in that same band. That's a consistency check, not proof. Nobody publishes upstream defect rates, so I can't confirm the 2% default, and a different curve with a different defect rate could land in the same place. What it does show is that the curve and a plausible defect rate end up where real warehouses report."
        , P "It also shows why the last half a percent is so hard. As an operation gets cleaner, people catch a smaller share of what's left: about 84% of defects at 10% upstream, 74% at 2%, and 66% at 0.5%. Getting from the median to best in class takes either a much cleaner process upstream or a second layer whose attention doesn't depend on how rare the defect is."
        , P "Perfect order rate is a different number. Its medians sit lower, around 93 to 96%, because it also counts late shipments, paperwork and damage in transit, which a dock inspection never sees. Picking accuracy is a slightly different denominator too. This model is about the inspection layer only."
        , Note "Above about 5% upstream defects, people-only accuracy drops below 99%: 98.4% at 10% and 97.6% at 20%. That's an operation with a real upstream problem, and it's where a vision layer pays back fastest. One more caveat: in a mixed experiment from the same 2005 paper, where some target showed up on half the trials, a target type that showed up 1% of the time was missed 52% of the time. That design doesn't map onto a single defect rate, so the fit leaves it out."
        ]
      )
    , ( "The number nobody has measured"
      , [ P "ρ is the most important input in the model and the one with the least evidence behind it. It asks a simple question. When the model misses something, is it the same thing a person would have missed?"
        , P "If the model and your people fail on different things, the model's recall counts in full. If every miss the model makes is one your people made too, the pair is no better than the model alone. ρ slides between those two ends."
        , P "Full overlap doesn't take you back to people alone. At the defaults the model catches 90 of every 100 defects and people catch 74, so at least 16 of the model's catches are ones people missed. At ρ = 1 the pair equals whichever layer is better on its own."
        , Eq
            [ eq
                [ mi "μ"
                , mo "="
                , paren [ mn "1", mo "−", mi "ρ" ]
                , paren [ mn "1", mo "−", mi "R" ]
                , mo "+"
                , mi "ρ"
                , fn "min"
                , paren [ mn "1", mo ",", over [ mn "1", mo "−", mi "R" ] [ mi "m" ] ]
                ]
            ]
            ""
        , Figure Overlap
        , P "You can't measure ρ from flags alone. The defects both layers miss are exactly the ones nobody flagged, so they never show up in a query. It takes ground truth: pull a random sample of shipments that passed both layers, inspect them carefully, and count the real defects people missed and how many of those the model missed too. That share is μ, and the equation above gives you ρ. The 0.2 default here is a placeholder until somebody does that."
        ]
      )
    , ( "Coverage or recall"
      , [ P "Coverage and recall multiply, so they trade almost one for one. When misses are independent, a model that sees every shipment at 88% recall catches more than one that sees 80% of shipments at 99%: 0.88 against 0.79."
        , P "Overlap changes that, because it hits the weaker model harder, and it hits harder the more defects people already catch. At this page's defaults the order holds, 0.81 against 0.79. Push upstream defects past about 5%, where people catch more of them, and the same ρ of 0.2 flips it: at 20% it's 0.71 against 0.78. So the rule of thumb only holds when misses are close to independent or people miss a lot, which is one more reason to measure ρ before you pick where to spend."
        , P "Coverage is still the first thing I'd check. It's the one you can count today, and an uncovered dock door catches nothing no matter how good the model is."
        ]
      )
    , ( "Good operations gain less, and that's fine"
      , [ P "If you plug in an operation's measured accuracy instead of the curve, the share of escapes removed is easy to read off."
        , Eq
            [ eq [ mn "1", mo "−", over [ sub "e" "1" ] [ sub "e" "0" ], mo "=", mi "c", paren [ mn "1", mo "−", mi "μ" ] ] ]
            "which is c·R when ρ = 0"
        , P "With no overlap the baseline drops out: an operation at 90% and one at 99% cut escapes by the same share. Overlap changes that. A team that already catches most defects is left with the hard ones, and those are the ones a model is most likely to miss too. So the honest expectation for a strong operation is a smaller relative gain, not the same one. Turn on the measured baseline switch in the first figure, leave ρ above zero, and watch the reduction shrink as the baseline climbs."
        ]
      )
    , ( "False positives move labor, not quality"
      , [ P "Accuracy is only half the question. The other half is labor: what does it cost people to clear the flags?"
        , P "False positives don't change what ships. They change how many minutes somebody spends looking at a clean pallet. So I track them on their own line."
        , Eq
            [ eq [ mi "FP", mo "=", paren [ mn "1", mo "−", d0 ], mi "N", mi "c", mi "FPR" ]
            , eq [ mi "TP", mo "=", sub "e" "0", mi "N", mi "c", paren [ mn "1", mo "−", mi "μ" ] ]
            , eq [ mi "precision", mo "=", over [ mi "TP" ] [ mi "TP", mo "+", mi "FP" ] ]
            ]
            ""
        , Figure Burden
        , P "That assumes the model's flags only get reviewed on shipments your people passed. If every model flag goes to review, including defects people already caught, the queue is bigger. Price the workflow you'll actually run."
        , P "At the defaults, only about one flag in eight is real, because clean shipments outnumber defective ones 49 to 1. That sounds bad until you price it. Clearing every flag still costs about a twelfth of what the prevented escapes are worth. The $28 an hour default is the BLS median for hand laborers and material movers, $18.38 in May 2025, with benefits and overhead on top."
        , Note "People raise false alarms too: 2% in a classic study of circuit inspection, and 35% of good parts in a recent study of precision manufactured parts, where the same inspectors caught 85% of defects. The fair comparison is against that, not against zero."
        ]
      )
    , ( "Putting a dollar on an escape"
      , [ P "An escaped defect costs labor, return freight and goodwill. Vendor estimates put one shipping error somewhere between $50 and $250, without saying where the range comes from. The default here is $150. If an operation tracks its own cost per error, use that instead."
        , P "Catching a defect isn't free either. Somebody re-picks or repacks it, so the saving per catch is the escape cost minus the cost to fix it in house. The $20 default is a placeholder."
        , P "Footage is the last layer, and it's easy to oversell. It doesn't stop an escape or find one nobody flagged. What it does is help you get money back on the escapes you do ship, because concealed damage claims are among the hardest freight claims to resolve, and the burden of proof shifts to the receiver. So I count claim recovery as money, not accuracy, and only on shipments the cameras covered."
        , P "One more thing to keep in front of you: the dollars scale with d₀. At 2% upstream defects the base case stops about 43 escapes per 10,000 shipments. At 10% it stops about 130. A slightly smaller relative gain, three times the money. Use a real defect rate before you trust the dollars."
        , Figure Dollars
        ]
      )
    , ( "Checking it against a real operation"
      , [ Steps
            [ ( "Pick one denominator.", "Pick-line, order and retail-compliance accuracy are three different numbers. Agree on one before you measure anything." )
            , ( "Measure the baseline at two prevalences.", "The human curve comes from lab studies. Check it against one operation at two different defect rates before relying on it." )
            , ( "Measure ρ.", "Ground truth on a random sample of shipments both layers passed. Flags alone can't show it." )
            , ( "Count coverage honestly.", "The shipments the cameras actually see, not the doors that have cameras." )
            , ( "Count false positives and the minutes to clear one.", "That's the labor line, which the accuracy numbers never show." )
            , ( "Price an escape with the operation's own numbers.", "Net of the cost to fix a catch. Then report quality and claim recovery as two lines, not one." )
            ]
        ]
      )
    , ( "What this doesn't claim"
      , [ P "It doesn't say any particular model hits 90%. That's a round figure for the math, not a measured result. Vendors claim 97 to 99.5% for vision inspection without publishing the data behind it, and I'd assume less until field data shows otherwise."
        , P "It doesn't say the human curve is a measurement of your floor. It's lab data, checked against factory studies and warehouse benchmarks but never measured on a dock. Directionally sound, worth validating."
        , P "It treats every defect as one kind. On a real dock people and models look for several kinds at once, each rarer than the total, so the prevalence each search runs at is lower than d₀. Run it per defect class when you have the data."
        , P "It gives point estimates. Every input here has a range, and the overlap table is the quickest way to see how much the answer moves."
        , P "And it doesn't say AI replaces inspectors. The whole point of the math is that two different kinds of failure, stacked, beat either one alone. The best number on this page needs both."
        ]
      )
    ]


sources : List ( String, String )
sources =
    [ ( "Wolfe, Horowitz and Kenner, \"Rare items often missed in visual searches,\" Nature 2005, supplement", "https://search.bwh.harvard.edu/new/pubs/Nature_suppl.pdf" )
    , ( "Rich, Kunar, Van Wert, Hidalgo-Sotelo, Horowitz and Wolfe, \"Why do we miss rare targets?\" Journal of Vision 2008", "https://jov.arvojournals.org/article.aspx?articleid=2193138" )
    , ( "Wolfe, Horowitz, Van Wert, Kenner, Place and Kibbi, \"Low target prevalence is a stubborn source of errors in visual search tasks,\" Journal of Experimental Psychology: General 2007", "https://pmc.ncbi.nlm.nih.gov/articles/PMC2662480/" )
    , ( "Wolfe, Brunelli, Rubinstein and Horowitz, \"Prevalence effects in newly trained airport checkpoint screeners,\" Journal of Vision 2013", "https://pubmed.ncbi.nlm.nih.gov/24297778/" )
    , ( "Van Wert, Horowitz and Wolfe, \"Even in correctable search, some types of rare targets are frequently missed,\" Attention, Perception & Psychophysics 2009", "https://link.springer.com/article/10.3758/APP.71.3.541" )
    , ( "See, \"Visual inspection reliability for precision manufactured parts,\" Human Factors 2015", "https://www.sandia.gov/research/publications/details/visual-inspection-reliability-for-precision-manufactured-parts-2015-12-01/" )
    , ( "Schoonard, Gould and Miller, \"Studies of visual inspection,\" Ergonomics 1973, as summarized on Wikipedia", "https://en.wikipedia.org/wiki/Visual_inspection" )
    , ( "Perfect order rate median and top quartile, Warehouse Revolution, citing CSCMP", "https://warehouserevolution.net/warehouse-kpis/" )
    , ( "WERC DC Measures order picking accuracy, as summarized by RF-SMART", "https://www.rfsmart.com/blog/warehouse-metrics-that-matter-for-netsuite-customers" )
    , ( "Pick-line, order and compliance accuracy as different denominators", "https://openskygroup.com/warehouse-kpis/" )
    , ( "Cost of one shipping mistake, $50 to $250, a vendor estimate from Wisys", "https://wisys.com/blog/warehouse-scanner-roi-what-the-data-actually-shows" )
    , ( "Vision inspection accuracy and false positive claims, a vendor page from OXmaint", "https://oxmaint.com/industries/steel-plant/computer-vision-vs-manual-inspection-in-manufacturing" )
    , ( "Median pay for hand laborers and material movers, BLS Occupational Outlook Handbook", "https://www.bls.gov/ooh/transportation-and-material-moving/hand-laborers-and-material-movers.htm" )
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

        Eq rows note ->
            Html.div [ Attr.class "study-eq" ]
                (List.map (Element.map never) rows
                    ++ (if note == "" then
                            []

                        else
                            [ Html.p [ Attr.class "study-eq-note" ] [ Element.text note ] ]
                       )
                )

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



-- EQUATIONS
-- Small builders so each equation above reads close to how it's written.


eq : List (Element msg) -> Element msg
eq parts =
    M.math [ Attr.attribute "display" "block" ] [ M.mrow [] parts ]


mi : String -> Element msg
mi name =
    M.mi [] [ Element.text name ]


mn : String -> Element msg
mn value =
    M.mn [] [ Element.text value ]


mo : String -> Element msg
mo op =
    M.mo [] [ Element.text op ]


{-| A named function like ln or min, upright and spaced from its argument. -}
fn : String -> Element msg
fn name =
    M.mrow [] [ M.mi [] [ Element.text name ], M.mo [ Attr.attribute "rspace" "0.17em" ] [ Element.text "\u{2061}" ] ]


sub : String -> String -> Element msg
sub base script =
    M.msub [] [ mi base, mn script ]


paren : List (Element msg) -> Element msg
paren parts =
    M.mrow [] (mo "(" :: parts ++ [ mo ")" ])


over : List (Element msg) -> List (Element msg) -> Element msg
over num den =
    M.mfrac [] [ M.mrow [] num, M.mrow [] den ]


d0 : Element msg
d0 =
    sub "d" "0"


eh : Element msg
eh =
    M.msub [] [ mi "E", mi "h" ]



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
                [ controls model [ D0, Coverage, Recall, Rho ]
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
                    [ Element.text "Columns are model recall R, rows are miss overlap ρ. The grid follows your inputs, so the filled cell is exactly what the sliders say. Each step out is 3 points of recall or 0.1 of overlap. Coverage and baseline come from the first figure." ]
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
                [ controls model [ Cost, Fix, Volume, Claims ]
                , tiles
                    [ ( money r.avoided, "escapes avoided, net of fixing them" )
                    , ( money r.recovered, "recovered on claims with footage" )
                    , ( money r.net, "net of review labor" )
                    , ( fixed 0 r.ratio ++ "x", "benefit to review cost" )
                    ]
                , Html.p [ Attr.class "study-caption" ]
                    [ Element.text "Net and ratio leave claim recovery out on purpose. It's money back on escapes that still happened, not fewer escapes." ]
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
            Spec "upstream defect rate" "d₀" 0.005 0.5 0.001 (pct 1)

        Coverage ->
            Spec "coverage" "c" 0.3 1 0.01 (pct 0)

        Recall ->
            Spec "model recall" "R" 0.5 0.99 0.01 (pct 0)

        Rho ->
            Spec "miss overlap" "ρ" 0 1 0.01 (fixed 2)

        Claims ->
            Spec "escape cost recovered on claims" "a" 0 0.95 0.05 (pct 0)

        Fix ->
            Spec "cost to fix a caught defect" "$" 0 100 5 money

        Measured ->
            Spec "measured baseline accuracy" "Q₀" 0.85 0.999 0.001 (pct 1)

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
        human d =
            1 - humanEscape d

        combined d =
            1 - humanEscape d * (1 - catch model (1 - humanRecall d))

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
                , Attr.attribute "x" (n left)
                , Attr.attribute "y" (n (yOf 0.996))
                , Attr.attribute "width" (n (chartW - left - right))
                , Attr.attribute "height" (n (yOf 0.99 - yOf 0.996))
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
            , Html.li [] [ Html.span [ Attr.class "sw sw-band" ] [], Element.text "WERC typical picking accuracy, 99.0 to 99.6%" ]
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
        -- The grid follows the sliders: the middle row and column are the
        -- current inputs exactly, with steps either side, so the highlighted
        -- cell always matches what's set above.
        -- Near a limit the window slides instead of shrinking, so the grid
        -- stays seven by seven and the current value stays on it.
        around value step lo hi =
            let
                fits limit =
                    floor (abs (limit - value) / step + 0.000001)

                below =
                    min (fits lo) (max 3 (6 - fits hi))

                above =
                    min (fits hi) (6 - below)
            in
            List.map (\i -> value + toFloat i * step) (List.range -below above)

        recalls =
            around model.recall 0.03 0.5 0.99

        rhos =
            around model.rho 0.1 0 1

        miss =
            clamp 0 1 (safeDiv r.e0 model.d0)

        rowAt =
            model.rho

        colAt =
            model.recall

        cell rho rec =
            Html.td
                [ Attr.classes
                    [ ( "is-here", rho == rowAt && rec == colAt )
                    , ( "in-row", rho == rowAt )
                    , ( "in-col", rec == colAt )
                    ]
                ]
                [ Element.text (pct 2 (1 - r.e0 * (1 - catchWith model.coverage rec rho miss))) ]
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
