module CaseStudy exposing (Model, Msg, date, dateLabel, init, slug, title, update, view)

{-| "Escapes Multiply", an analysis of pricing a vision layer next to the
people who already do industrial quality inspection.

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
    , review : Float
    , drop : Float
    , fix : Float
    , useMeasured : Bool
    , measured : Float
    , cost : Float
    , volume : Float
    , fpr : Float
    , minutes : Float
    , wage : Float
    , hover : Maybe Int
    , answer : Answer
    }


{-| Round, illustrative defaults. -}
init : Model
init =
    { d0 = 0.02
    , coverage = 1
    , recall = 0.9
    , rho = 0.2
    , review = 0.9
    , drop = 0
    , fix = 20
    , useMeasured = False
    , measured = 0.994
    , cost = 150
    , volume = 250000
    , fpr = 0.03
    , minutes = 3
    , wage = 28
    , hover = Nothing
    , answer = ShareRemoved
    }


type Field
    = D0
    | Coverage
    | Recall
    | Rho
    | Review
    | Drop
    | Fix
    | Measured
    | Cost
    | Volume
    | Fpr
    | Minutes
    | Wage


{-| Which answer the sensitivity figure shows. -}
type Answer
    = ShareRemoved
    | NetPerYear


type Msg
    = Set Field String
    | UseMeasured Bool
    | Hover Int
    | Unhover
    | ShowAnswer Answer
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

        ShowAnswer answer ->
            { model | answer = answer }

        Reset ->
            { init | answer = model.answer }


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

        Review ->
            m.review

        Drop ->
            m.drop

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

        Review ->
            { m | review = v }

        Drop ->
            { m | drop = v }

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
-- Layered escapes. Miss overlap stays inside what the two recalls allow,
-- review lets some real flags go, and people can lean on the cameras.


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


type alias Layers =
    { missed : Float
    , flagged : Float
    , escapes : Float
    }


{-| What gets past each layer at prevalence d, from people's escape rate e0
and miss rate m before the cameras go in.

People who lean on the cameras miss s more, capped at missing everything.
That's added onto e0 rather than rebuilt from d, so with no drop it's e0
exactly, even when a measured baseline caps m. The vision layer flags its
share of what people miss, review confirms v of the real flags, and the
rest ship.
-}
layers : Model -> Float -> Float -> Float -> Layers
layers model d e0 m =
    let
        leaned =
            min 1 (m + model.drop)

        missed =
            e0 + d * (leaned - m)

        flagged =
            catch model leaned
    in
    { missed = missed
    , flagged = flagged
    , escapes = missed * (1 - flagged * model.review)
    }


type alias Result =
    { e0 : Float
    , missed : Float
    , flagged : Float
    , e1 : Float
    , reduction : Float
    , prevented : Float
    , caught : Float
    , avoided : Float
    , tp : Float
    , cleared : Float
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

        after =
            layers m m.d0 e0 miss

        e1 =
            after.escapes

        -- Against the baseline before the cameras. A caught defect still
        -- costs a rework or repack, whoever catches it.
        avoided =
            (e0 - e1) * m.volume * (m.cost - m.fix)

        tp =
            after.missed * m.volume * after.flagged

        fp =
            (1 - m.d0) * m.volume * m.coverage * m.fpr

        hours =
            (tp + fp) * m.minutes / 60

        reviewCost =
            hours * m.wage
    in
    { e0 = e0
    , missed = after.missed
    , flagged = after.flagged
    , e1 = e1
    , reduction = safeDiv (e0 - e1) e0
    , prevented = (e0 - e1) * 10000
    , caught = after.missed * after.flagged * m.review * 10000
    , avoided = avoided
    , tp = tp
    , cleared = tp * (1 - m.review)
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
    | Sensitivity


sections : List ( String, List Block )
sections =
    [ ( "The obvious question"
      , [ Note "An independent analysis, built only from peer-reviewed research and public industry sources, to show how you might estimate the ROI of pairing people with computer vision. It contains no proprietary data and doesn't describe any company's product, customers or results."
        , P "It's the obvious question about computer vision in industrial quality control. If people already inspect every unit, what does a camera add?"
        , P "The honest answer isn't a percentage. It's a model. This page is that model. Every outside number has its source at the bottom. Every other number is a round, illustrative assumption, and you can drag it."
        , P "The math holds anywhere people inspect and a camera checks behind them: final inspection on a production line, incoming inspection of supplier parts, a packaging line, the last check before an order ships. The defaults lean on shipping, where public numbers for a people-only baseline and the cost of an escape are easiest to find. Swap in your own."
        , P "The short version: people and machines fail in different ways, and that difference is where the money is."
        , P "At the defaults, that's about 39 escapes stopped per 10,000 units and about $115,000 a year net of review labor on 250,000 units, roughly 11 times what the review costs. With every input drawn at random across its range, the vision layer still covers its review labor in 82% of 200,000 draws. Two inputs, how much the two layers' misses overlap and how many real flags review confirms, have the least evidence behind them, and the second matters more. Several studies find people clearing alarms let a lot of real ones go, and review recall moves the money about as much as what an escape costs or how much your people miss. Measure those three first."
        ]
      )
    , ( "Escapes multiply"
      , [ P "A defect only reaches the customer if every inspection layer misses it. That one sentence does most of the work. Escapes multiply. They don't average."
        , Eq
            [ eq [ mi "e", mo "=", d0, mi "m", mo "[", mn "1", mo "−", mi "c", paren [ mn "1", mo "−", mi "μ" ], mi "v", mo "]" ]
            , eq [ mi "m", mo "=", mn "1", mo "−", eh, paren [ d0 ] ]
            , eq [ mi "Q", mo "=", mn "1", mo "−", mi "e" ]
            ]
            ""
        , Defs
            [ ( "d₀", "upstream defect rate: the share of units with any defect before anyone looks." )
            , ( "Eₕ(d₀)", "human recall at that prevalence. Not a constant, more on that below." )
            , ( "m", "the share of defects people miss." )
            , ( "c", "coverage: the share of units the cameras actually see." )
            , ( "R", "model recall: the share of present defects the model catches, measured in the field." )
            , ( "μ", "how often the model misses a defect people already missed. It depends on R and on ρ, below." )
            , ( "v", "review recall, the share of real flags the reviewer confirms. A placeholder, more on that below." )
            , ( "Q", "accuracy: the share of units that leave without a defect." )
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
        , P "Machine recall has no prevalence term. A model looks at the ten thousandth clean unit with the same attention it gave the first one. That asymmetry is the whole argument for putting the two together. Its precision is another matter, and that comes back as labor further down."
        , Figure Ceiling
        , P "Here's the check I'd want before trusting the curve on a real line. The best public benchmark I know of for what people manage alone comes from warehousing: WERC's 2019 DC Measures puts the median for order picking accuracy at 99.4%, with the middle fifth of companies between 99.0% and 99.6% and the top fifth at 99.89% or better. Give the curve an upstream defect rate between about 1.5% and 4.5%, and people-only accuracy lands in that same band. That's a consistency check, not proof. Nobody publishes upstream defect rates, so I can't confirm the 2% default, and a different curve with a different defect rate could land in the same place. What it does show is that the curve and a plausible defect rate end up where real warehouses report."
        , P "It also shows why the last half a percent is so hard. As an operation gets cleaner, people catch a smaller share of what's left: about 84% of defects at 10% upstream, 74% at 2%, and 66% at 0.5%. Getting from the median to best in class takes either a much cleaner process upstream or a second layer whose attention doesn't depend on how rare the defect is."
        , P "Perfect order rate is a different number. Its medians sit lower, around 93 to 96%, because it also counts late shipments, paperwork and damage in transit, which an inspection before shipping never sees. Picking accuracy is a slightly different denominator too. This model is about the inspection layer only."
        , Note "Above about 5% upstream defects, people-only accuracy drops below 99%: 98.4% at 10% and 97.6% at 20%. That's an operation with a real upstream problem, and it's where a vision layer pays back fastest. One more caveat: in a mixed experiment from the same 2005 paper, where some target showed up on half the trials, a target type that showed up 1% of the time was missed 52% of the time. That design doesn't map onto a single defect rate, so the fit leaves it out."
        ]
      )
    , ( "The number nobody has measured"
      , [ P "At the defaults, ρ swings the share of escapes removed further than any input but review recall, and it has the least evidence behind it. It asks a simple question. When the model misses something, is it the same thing a person would have missed?"
        , P "If the model and your people fail on different things, the model's recall counts in full. If every miss the model makes is one your people made too, the pair is no better than the model alone. ρ slides between those two ends."
        , P "Full overlap doesn't take you back to people alone. At the defaults the model catches 90 of every 100 defects and people catch 74, so at least 16 of the model's catches are ones people missed. At ρ = 1 and perfect review, the pair equals whichever layer is better on its own."
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
        , P "Formally, ρ is the correlation between the two layers' misses divided by the largest correlation their miss rates allow. Zero means independent; one means as overlapped as the rates permit. It isn't a raw correlation: at the defaults, ρ = 0.2 is a raw correlation of about 0.11, so don't plug in one measured some other way."
        , Figure Overlap
        , P "You can't measure ρ from flags alone. The defects both layers miss are exactly the ones nobody flagged, so they never show up in a query. You need ground truth, and it has to come from the right place. A sample of units that passed both layers can't give it to you: every defect in that sample got past both, so it can't show what share the model missed. Draw a random sample of units your people passed instead, whatever the model said about them, and re-inspect them carefully. Add back any defect in the sample that review already confirmed and fixed. For each real defect, note whether the model flagged it. The share it never flagged is μ, and the equation above turns μ into ρ. A defect the model flagged and review cleared is a review miss, not a model miss, and it counts toward v."
        , P "Plan for the volume. At the defaults, about 50 of every 10,000 units people pass have a defect, and about 8 of those get past the model too. Ten thousand careful re-inspections pin ρ down to roughly ±0.35, most of the table above. And careful re-inspection is still people searching at about half a percent prevalence, where the curve says they miss about a third. The cheaper, cleaner route is to seed known defects, the way airports project fictional threat images into real bag scans to score screeners. You know the truth, you control the rate, and you can score people, the model and their overlap on the same items. The catch is that seeded defects have to look real. Airport screeners sometimes spot projected threats just because they look pasted in. The 0.2 default here is a placeholder until somebody does that."
        ]
      )
    , ( "Coverage or recall"
      , [ P "Coverage and recall multiply, so they trade almost one for one. When misses are independent, a model that sees every unit at 88% recall catches more than one that sees 80% of units at 99%: 0.88 against 0.79."
        , P "Overlap changes that, because it hits the weaker model harder, and it hits harder the more defects people already catch. At this page's defaults the order holds, 0.81 against 0.79. Push upstream defects past about 5%, where people catch more of them, and the same ρ of 0.2 flips it: at 20% it's 0.71 against 0.78. So the rule of thumb only holds when misses are close to independent or people miss a lot, which is one more reason to measure ρ before you pick where to spend."
        , P "Coverage is still the first thing I'd check. It's the one you can count today, and a station with no camera catches nothing no matter how good the model is."
        , P "These are catch shares before review. Review recall multiplies both sides by the same v, so it never changes which one wins."
        ]
      )
    , ( "Cleaner floors gain more, better teams gain less"
      , [ P "\"Good\" can mean two things here, and they move the relative gain in opposite directions."
        , P "A cleaner floor means a lower d₀. Under the curve, people catch a smaller share of a rarer defect, so the vision layer removes a bigger share of what they miss: at the defaults, about 77% of escapes at 0.5% upstream defects, 76% at 2%, and 72% at 10%."
        , P "A better team means higher recall at the same d₀, which is what the measured baseline switch sets."
        , Eq
            [ eq [ mn "1", mo "−", over [ sub "e" "1" ] [ sub "e" "0" ], mo "=", mi "c", paren [ mn "1", mo "−", mi "μ" ], mi "v" ] ]
            "which is c·R·v when ρ = 0"
        , P "With no overlap the baseline drops out: an operation at 90% and one at 99% cut escapes by the same share. Overlap changes that. A team that already catches most defects is left with the hard ones, and those are the ones a model is most likely to miss too. So the honest expectation for a strong operation is a smaller relative gain, not the same one. Turn on the measured baseline switch in the first figure, leave ρ above zero, and watch the reduction shrink as the baseline climbs."
        , P "Neither share is the number to decide on. The money runs on escapes avoided times what each one costs, and a cleaner floor stops fewer escapes even when it stops a bigger share of them. Judge the layer on the last figure, not this one."
        ]
      )
    , ( "False positives move labor, not quality"
      , [ P "Accuracy is only half the question. The other half is labor: what does it cost people to clear the flags?"
        , P "False positives don't change what ships. They change how many minutes somebody spends looking at a clean unit. So I track them on their own line."
        , Eq
            [ eq [ mi "FP", mo "=", paren [ mn "1", mo "−", d0 ], mi "N", mi "c", mi "FPR" ]
            , eq [ mi "TP", mo "=", sub "e" "0", mi "N", mi "c", paren [ mn "1", mo "−", mi "μ" ] ]
            , eq [ mi "precision", mo "=", over [ mi "TP" ] [ mi "TP", mo "+", mi "FP" ] ]
            ]
            ""
        , Figure Burden
        , P "That assumes the model's flags only get reviewed on units your people passed. If every model flag goes to review, including defects people already caught, the queue is bigger. Price the workflow you'll actually run."
        , P "Among the units people pass, clean ones outnumber defective ones about 190 to 1. That's what's left after people do their job, not the upstream mix of 49 to 1, and it's why a 3% false positive rate buries the real flags. If the model looked before people did, about 38% of its flags would be real. The model's recall doesn't care about prevalence, but its precision does: the better your people are, the cleaner the stream it sees. So at the defaults, only about 13% of flags are real. That sounds bad until you price it. Clearing every flag still costs a little under a tenth of what the prevented escapes are worth. The $28 an hour default is the BLS median for hand laborers and material movers, $18.38 in May 2025, with benefits and overhead on top."
        , P "Somebody has to clear those flags, and their queue is the setup this page started with, pointed at a new person. Seven of every eight flags are false, so the bar for calling one real drifts up. Read the curve at the queue's 13% and a reviewer confirms about 85% of real flags. Checking a flag is easier than searching a unit cold, so I use 90% as a placeholder and carry it through every figure as v. Studies of people clearing real alarm queues often find worse, so the sensitivity figure further down runs it as low as 30%. At the defaults, about 108 real defects a year get flagged and cleared anyway. They ship, and they count as escapes."
        , Note "People raise false alarms too: 2% in a classic study of circuit inspection, and 35% of good parts in a recent study of precision manufactured parts, where the same inspectors caught 85% of defects. The fair comparison is against that, not against zero."
        ]
      )
    , ( "Putting a dollar on an escape"
      , [ P "An escaped defect costs labor, returns and goodwill. For shipping, vendor estimates put one error somewhere between $50 and $250, without saying where the range comes from. The default here is $150. What an escape costs varies a lot by industry, so if an operation tracks its own cost per escape, use that instead."
        , P "Catching a defect isn't free either. Somebody reworks, replaces or repacks it, so the saving per catch is the escape cost minus the cost to fix it in house. The $20 default is a placeholder."
        , P "Footage is the last layer, and it's easy to oversell. It doesn't stop an escape or find one nobody flagged. It doesn't get money back on one either. Footage of a real escape either shows the defect, which sinks the claim, or misses it, and then using it against whoever handled the unit next means billing them for your mistake. What it's worth comes from damage and disputes after a unit leaves, which this model doesn't size, so it stays out of the figure below."
        , P "One more thing to keep in front of you: the dollars scale with d₀. At 2% upstream defects the base case stops about 39 escapes per 10,000 units. At 10% it stops about 117. A slightly smaller relative gain, three times the money. Use a real defect rate before you trust the dollars."
        , Figure Dollars
        ]
      )
    , ( "What moves the answer"
      , [ P "Every input on this page is a number somebody could argue with. So I gave each one a range and pushed on all of them. The figure below moves one input at a time to each end of its range, with everything else where you've set it."
        , Figure Sensitivity
        , P "The ranges come from the sources where there are any. People's miss rate runs from 15%, what inspectors missed in the precision parts study, to 50%, the high end of lab studies at 1 to 2% prevalence. Model recall runs from 80% up to 97%, where vendor claims start. Review recall runs from 30%, about how often radiologists acted on correct prompts for cancers they had missed, up to 100%. ρ gets its whole range, because nobody has measured it. Upstream defects run from 1.5% to 4.5%, where people-only accuracy lands in WERC's typical band, and cost per escape covers the vendor range of $50 to $250. The rest are judgment calls pushed both ways."
        , P "Then I drew every input at once, anywhere in its range, 200,000 times. The layer covers its review labor in 82% of those draws. At the defaults, it breaks even when an escape costs about $32: roughly $12 of review labor per escape stopped, plus the $20 to fix it. With review recall at 30%, it takes about $56. The inputs behind review labor barely move the money: the false positive rate, minutes per flag and wage together explain about 2% of its spread."
        , P "Review recall is the biggest unknown. It explains about 60% of the spread in the share of escapes removed, far more than model recall, how much people miss or ρ. It also explains about a third of the spread in the money, as much as what an escape costs or how much people miss, while ρ explains about 3%. Two of the money's big inputs can be measured before anyone buys a camera: what an escape costs from the operation's own books, and how much people miss from seeded defects or a careful re-inspection. Review recall can't be measured until there are flags to review, so it's the first thing I'd audit in a pilot."
        , P "The defaults also lean favorable. With everything moving at once, the median is 34% fewer escapes, not 76%. About half of that gap is review recall, whose 90% default sits near the top of its range. Most of the rest comes from two more defaults: cameras that see every unit, and people who don't lean on them. The worst case is a model that misses more than your people do, with every one of its misses overlapping theirs. It adds nothing. Put everything else at the bad end of its range too, including people missing 10 points more once the cameras are in, and escapes go up 59%. That's why the checklist below measures people again after the cameras go in."
        ]
      )
    , ( "Checking it against a real operation"
      , [ Steps
            [ ( "Pick one denominator.", "Unit, order and customer-compliance accuracy are three different numbers. Agree on one before you measure anything." )
            , ( "Measure the baseline at two prevalences, before and after.", "The human curve comes from lab studies. Check it against one operation at two different defect rates before relying on it. Then measure it again once the cameras are in, since people lean on a backstop." )
            , ( "Measure ρ from what people passed.", "Re-inspect a random sample of what people passed, regardless of the model's call, or seed defects with known answers. Flags can't reveal it, and a sample of what both layers passed can't either." )
            , ( "Measure review recall.", "Audit a random sample of the flags review cleared, and scale the real defects you find to all cleared flags. Then divide confirmed defects by confirmed plus that number." )
            , ( "Count coverage honestly.", "The units the cameras actually see, not the stations that have cameras." )
            , ( "Count false positives and the minutes to clear one.", "That's the labor line, which the accuracy numbers never show." )
            , ( "Price an escape with the operation's own numbers.", "Net of the cost to fix a catch. If footage goes in at all, it goes in on damage claims and disputes, as its own line." )
            ]
        ]
      )
    , ( "What this doesn't claim"
      , [ P "It doesn't say any particular model hits 90%. That's a round figure for the math, not a measured result. Vendors claim 97 to 99.5% for vision inspection without publishing the data behind it, and I'd assume less until field data shows otherwise."
        , P "It doesn't say review confirms 90% of real flags either. That's a placeholder between what the curve predicts at the queue's prevalence, about 85%, and a perfect 100%, and studies of people clearing alarms say it could be much lower. Airport screeners ignored about half of true alarms on hard targets when 3 in 10 alarms were real, and radiologists ignored 71% of correct prompts on cancers they had missed. Air traffic controllers, with nearly half their alerts false, showed no such drop. It's the one human step the vision layer adds, and it's much cheaper to measure than ρ, because a flag tells the auditor where to look."
        , P "It doesn't say the human curve is a measurement of your floor. It's lab data, checked against factory studies and warehouse benchmarks, not measured on your line. Directionally sound, worth validating."
        , P "It holds your people's recall fixed once the cameras go in. People tend to check less carefully when automation is checking too, and if yours do, the vision layer's catch count goes up while escapes go up too. At the defaults, a 5-point drop in inspector recall takes the layer from 39 catches per 10,000 units to 47, while escapes rise from 12 to 14. Against the old baseline the real gain is 37, not 47. So judge the layer on escapes against a pre-deployment baseline, never on what it catches."
        , P "It treats every defect as one kind. On a real line people and models look for several kinds at once, each rarer than the total, so the prevalence each search runs at is lower than d₀. Run it per defect class when you have the data."
        , P "The 82% isn't the odds that a real deployment covers its review labor. The ranges behind it are judgment calls, from the sources where there are any, and the draws treat every input as independent, with every value in its range equally likely. Inputs that move together on a real line can make the spread wider."
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
    , ( "Riz à Porta, Sterchi and Schwaninger, \"How realistic is threat image projection for X-ray baggage screening?\" Sensors 2022", "https://doi.org/10.3390/s22062220" )
    , ( "Van Wert, Horowitz and Wolfe, \"Even in correctable search, some types of rare targets are frequently missed,\" Attention, Perception & Psychophysics 2009", "https://link.springer.com/article/10.3758/APP.71.3.541" )
    , ( "See, \"Visual inspection reliability for precision manufactured parts,\" Human Factors 2015", "https://www.sandia.gov/research/publications/details/visual-inspection-reliability-for-precision-manufactured-parts-2015-12-01/" )
    , ( "Schoonard, Gould and Miller, \"Studies of visual inspection,\" Ergonomics 1973", "https://doi.org/10.1080/00140137308924528" )
    , ( "Parasuraman and Manzey, \"Complacency and bias in human use of automation: an attentional integration,\" Human Factors 2010", "https://doi.org/10.1177/0018720810376055" )
    , ( "Hügli, Merks and Schwaninger, \"Automation reliability, human-machine system performance, and operator compliance: a study with airport security screeners supported by automated explosives detection systems for cabin baggage screening,\" Applied Ergonomics 2020", "https://doi.org/10.1016/j.apergo.2020.103094" )
    , ( "Nishikawa, Schmidt, Linver, Edwards, Papaioannou and Stull, \"Clinically missed cancer: how effectively can radiologists use computer-aided detection?\" American Journal of Roentgenology 2012", "https://doi.org/10.2214/AJR.11.6423" )
    , ( "Wickens, Rice, Keller, Hutchins, Hughes and Clayton, \"False alerts in air traffic control conflict alerting system: is there a 'cry wolf' effect?\" Human Factors 2009", "https://doi.org/10.1177/0018720809344720" )
    , ( "Perfect order rate median and top quartile, Warehouse Revolution, citing CSCMP", "https://warehouserevolution.net/warehouse-kpis/" )
    , ( "Tillman, Manrodt and Williams, \"DC Measures 2019,\" WERC, order picking accuracy by order, from the report's handout", "https://www.rfsmart.com/hubfs/Whitepapers/2019_WERC_DC_Measures%202019_Handout.pdf" )
    , ( "Pick-line, order and compliance accuracy as different denominators", "https://openskygroup.com/warehouse-kpis/" )
    , ( "Cost of one shipping mistake, $50 to $250, a vendor estimate from Wisys", "https://wisys.com/blog/warehouse-scanner-roi-what-the-data-actually-shows" )
    , ( "Vision inspection accuracy and false positive claims, a vendor page from OXmaint", "https://oxmaint.com/industries/steel-plant/computer-vision-vs-manual-inspection-in-manufacturing" )
    , ( "Median pay for hand laborers and material movers, BLS Occupational Outlook Handbook", "https://www.bls.gov/ooh/transportation-and-material-moving/hand-laborers-and-material-movers.htm" )
    ]



-- VIEW


view : Model -> Element Msg
view model =
    Html.article
        [ Attr.class "essay study wrap" ]
        [ Html.header [ Attr.class "essay-head" ]
            [ Html.p [ Attr.class "eyebrow" ]
                [ Element.text ("analysis / " ++ dateLabel) ]
            , Html.h1 [ Attr.class "essay-title" ] [ Element.text title ]
            , Html.p [ Attr.class "study-dek" ]
                [ Element.text "How to analyze the ROI of computer vision working next to human inspectors in industrial quality control. With a model you can push on." ]
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
            figure "fig 01 / where the defects go, per 10,000 units"
                [ controls model [ D0, Coverage, Recall, Rho, Review, Drop ]
                , measuredSwitch model
                , funnel model r
                , tiles
                    [ ( pct 1 (1 - r.e0), "accuracy, people only" )
                    , ( pct 2 (1 - r.e1), "with the vision layer" )
                    , ( pct 1 r.reduction, "fewer escapes" )
                    , ( fixed 0 r.prevented, "defects stopped per 10,000 units" )
                    , ( fixed 0 r.caught, "caught by the vision layer per 10,000 units" )
                    ]
                , Html.button [ Attr.class "btn study-reset", Attr.type_ "button", Events.onClick Reset ]
                    [ Element.text "reset to the base case" ]
                ]

        Ceiling ->
            figure "fig 02 / accuracy across upstream defect rates"
                [ ceiling model ]

        Overlap ->
            figure "fig 03 / combined accuracy by model recall and miss overlap"
                [ controls model [ Recall, Rho ]
                , overlapTable model r
                , Html.p [ Attr.class "study-caption" ]
                    [ Element.text "Columns are model recall R, rows are miss overlap ρ. The grid follows your inputs, so the filled cell is exactly what the sliders say. Each step out is 3 points of recall or 0.1 of overlap. Coverage, baseline, review recall v and the recall drop s come from the first figure. With review below 100%, more recall runs into a ceiling. At the defaults and 90% review, no model gets past about 99.95%, because one real flag in ten still gets cleared." ]
                ]

        Burden ->
            figure "fig 04 / review burden per year"
                [ controls model [ Fpr, Minutes, Wage ]
                , tiles
                    [ ( fixed 0 (r.tp + r.fp), "flags to review" )
                    , ( pct 0 r.precision, "of flags are real" )
                    , ( fixed 0 r.hours, "review hours" )
                    , ( money r.reviewCost, "review labor" )
                    , ( fixed 0 r.cleared, "real flags cleared in review" )
                    ]
                ]

        Dollars ->
            figure "fig 05 / what it's worth per year"
                [ controls model [ Cost, Fix, Volume ]
                , tiles
                    [ ( money r.avoided, "escapes avoided, net of fixing them" )
                    , ( money r.net, "net of review labor" )
                    , ( fixed 0 r.ratio ++ "x", "benefit to review cost" )
                    ]
                , Html.p [ Attr.class "study-caption" ]
                    [ Element.text "Net and ratio count escapes avoided and review labor, nothing else." ]
                ]

        Sensitivity ->
            figure "fig 06 / each input at the ends of its range"
                [ swingChart model ]


figure : String -> List (Element msg) -> Element msg
figure caption children =
    Html.figure [ Attr.class "study-fig" ]
        (Html.figcaption [ Attr.class "study-fig-cap" ] [ Element.text caption ] :: children)


tiles : List ( String, String ) -> Element msg
tiles items =
    Html.div [ Attr.class ("nums nums--inline study-tiles study-tiles--" ++ String.fromInt (List.length items)) ]
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

        Review ->
            Spec "review recall" "v" 0.3 1 0.01 (pct 0)

        Drop ->
            Spec "inspector recall drop after cameras" "s" 0 0.15 0.01 points

        Fix ->
            Spec "cost to fix a caught defect" "$" 0 100 5 money

        Measured ->
            Spec "measured baseline accuracy" "Q₀" 0.85 0.999 0.001 (pct 1)

        Cost ->
            Spec "cost per escape" "$" 25 400 5 money

        Volume ->
            Spec "units per year" "N" 10000 2000000 10000 (fixed 0)

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
        -- The last two rows are the ones that ship.
        rows =
            (if model.useMeasured then
                []

             else
                [ ( "arrive with a defect", model.d0, False ) ]
            )
                ++ [ ( "missed by people", r.missed, False )
                   , ( "not flagged by the vision layer", r.missed * (1 - r.flagged), True )
                   , ( "flagged, then cleared in review", r.missed * r.flagged * (1 - model.review), True )
                   ]

        top =
            List.head rows |> Maybe.map (\( _, share, _ ) -> share) |> Maybe.withDefault 1
    in
    Html.ol [ Attr.class "study-funnel" ]
        (List.map
            (\( label, share, ships ) ->
                Html.li [ Attr.classes [ ( "ships", ships ) ] ]
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
            1 - (layers model d (humanEscape d) (1 - humanRecall d)).escapes

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
            , Attr.attribute "aria-label" "Accuracy against upstream defect rate, people only and with the vision layer"
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
                [ Element.text (pct 2 (1 - (layers { model | recall = rec, rho = rho } model.d0 r.e0 miss).escapes)) ]
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



-- FIG 06: what moves the answer


{-| One input pushed to each end of its range. The ranges match the
sensitivity analysis the section quotes.
-}
type alias Swing =
    { label : String
    , symbol : String
    , low : String
    , high : String
    , atLow : Model -> Model
    , atHigh : Model -> Model
    }


swings : List Swing
swings =
    let
        field f lo hi low high =
            let
                s =
                    spec f
            in
            Swing s.label s.symbol low high (put f lo) (put f hi)
    in
    [ field Rho 0 1 "0" "1"
    , Swing "share of defects people miss" "m" "15%" "50%" (missing 0.15) (missing 0.5)
    , field Recall 0.8 0.97 "80%" "97%"
    , field Review 0.3 1 "30%" "100%"
    , field Coverage 0.8 1 "80%" "100%"
    , field Drop 0 0.1 "0" "10 points"
    , field D0 0.015 0.045 "1.5%" "4.5%"
    , field Fpr 0.01 0.08 "1%" "8%"
    , field Minutes 1 6 "1" "6"
    , field Wage 24 35 "$24" "$35"
    , field Cost 50 250 "$50" "$250"
    , field Fix 10 40 "$10" "$40"
    ]


{-| People's miss rate set directly, through a measured baseline, so it
holds whatever the curve says at d0.
-}
missing : Float -> Model -> Model
missing share model =
    { model | useMeasured = True, measured = 1 - model.d0 * share }


swingChart : Model -> Element Msg
swingChart model =
    let
        pick =
            case model.answer of
                ShareRemoved ->
                    .reduction

                NetPerYear ->
                    .net

        show =
            case model.answer of
                ShareRemoved ->
                    pct 1

                NetPerYear ->
                    money

        now =
            pick (results model)

        -- Biggest swing first. Inputs that can't move this answer drop out.
        rows =
            swings
                |> List.map (\s -> ( s, pick (results (s.atLow model)), pick (results (s.atHigh model)) ))
                |> List.filter (\( _, lo, hi ) -> abs (hi - lo) > 1.0e-9)
                |> List.sortBy (\( _, lo, hi ) -> negate (abs (hi - lo)))

        -- One scale for every row, centered on the current answer.
        reach =
            rows
                |> List.map (\( _, lo, hi ) -> max (abs (lo - now)) (abs (hi - now)))
                |> List.maximum
                |> Maybe.withDefault 0

        -- Percent of the track, rounded so a swing of nothing reads as 0.
        bar cls x =
            let
                offset =
                    toFloat (round (5000 * safeDiv (x - now) reach)) / 100
            in
            Html.span
                [ Attr.classes [ ( "study-swing-bar", True ), ( cls, True ), ( "is-down", offset < 0 ) ]
                , Attr.styles
                    [ ( "left", String.fromFloat (50 + min 0 offset) ++ "%" )
                    , ( "width", String.fromFloat (abs offset) ++ "%" )
                    ]
                ]
                []

        value x at =
            Html.b []
                [ Element.text (show x)
                , Html.span [ Attr.class "study-sr" ] [ Element.text (" at " ++ at) ]
                ]

        row ( s, lo, hi ) =
            Html.li []
                [ Html.span [ Attr.class "study-swing-k" ]
                    [ Element.text s.label
                    , Html.i [] [ Element.text s.symbol ]
                    , Html.small [] [ Element.text (s.low ++ " to " ++ s.high) ]
                    ]
                , Html.span [ Attr.class "study-swing-track", Attr.attribute "aria-hidden" "true" ]
                    [ bar "is-low" lo, bar "is-high" hi ]
                , Html.span [ Attr.class "study-swing-v" ] [ value lo s.low, value hi s.high ]
                ]

        axis =
            Html.li [ Attr.class "study-swing-head", Attr.attribute "aria-hidden" "true" ]
                [ Html.span [ Attr.class "study-swing-k" ] []
                , Html.span [ Attr.class "study-swing-axis" ]
                    [ Html.span [] [ Element.text "lower" ]
                    , Html.b [] [ Element.text ("now " ++ show now) ]
                    , Html.span [] [ Element.text "higher" ]
                    ]
                , Html.span [] []
                ]

        hot x =
            Html.b [ Attr.class "hot" ] [ Element.text x ]

        current =
            case model.answer of
                ShareRemoved ->
                    if now < 0 then
                        [ Element.text "At your settings escapes go up ", hot (pct 1 (negate now)), Element.text " with the vision layer." ]

                    else
                        [ Element.text "At your settings the vision layer removes ", hot (pct 1 now), Element.text " of escapes." ]

                NetPerYear ->
                    [ Element.text "At your settings it nets ", hot (money now), Element.text " a year after review labor." ]

        biggest =
            case rows of
                ( s, lo, hi ) :: _ ->
                    [ Element.text (" The biggest swing is " ++ s.label ++ ": ")
                    , Html.b [] [ Element.text (show lo) ]
                    , Element.text (" at " ++ s.low ++ " and ")
                    , Html.b [] [ Element.text (show hi) ]
                    , Element.text (" at " ++ s.high ++ ".")
                    ]

                [] ->
                    []
    in
    Html.div [ Attr.class "study-swings" ]
        [ Html.div [ Attr.class "filters study-filters" ]
            (List.map (answerButton model.answer)
                [ ( ShareRemoved, "fewer escapes" )
                , ( NetPerYear, "net per year" )
                ]
            )
        , Html.ul [ Attr.class "study-legend" ]
            [ Html.li [] [ Html.span [ Attr.class "sw sw-low" ] [], Element.text "input at the low end of its range" ]
            , Html.li [] [ Html.span [ Attr.class "sw sw-high" ] [], Element.text "at the high end" ]
            ]
        , Html.ol [ Attr.class "study-swing" ] (axis :: List.map row rows)
        , Html.p [ Attr.class "study-readout" ] (current ++ biggest)
        , Html.p [ Attr.class "study-caption" ]
            [ Element.text "Each input moves to both ends of its range while everything else stays where you've set it, biggest swing at the top. The dashed line is your current answer. The share of defects people miss is set directly here, in place of the curve or a measured baseline. Labor and dollar inputs don't change the share of escapes removed, so that view leaves them out." ]
        ]


answerButton : Answer -> ( Answer, String ) -> Element Msg
answerButton current ( answer, label ) =
    Html.button
        [ Attr.class
            (if answer == current then
                "filter is-on"

             else
                "filter"
            )
        , Attr.type_ "button"
        , Attr.attribute "aria-pressed"
            (if answer == current then
                "true"

             else
                "false"
            )
        , Events.onClick (ShowAnswer answer)
        ]
        [ Element.text label ]



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


{-| Recall points: 0.05 reads as 5 points. -}
points : Float -> String
points x =
    let
        p =
            fixed 0 (x * 100)
    in
    p
        ++ (if p == "1" then
                " point"

            else
                " points"
           )


money : Float -> String
money x =
    if x < 0 then
        "-$" ++ fixed 0 (abs x)

    else
        "$" ++ fixed 0 x
