port module Site exposing (main)

{-| The portfolio as a static site, which `jorn build` writes to `build/`.

Every page is the same app, `Main`, rendered at build time inside the same
shell, with its own `<head>`: title, description, canonical link, Open Graph
tags and JSON-LD. In the browser, `start` mounts the app over that HTML, so
nothing changes on screen. Search engines and link previews that never run
JavaScript still get the whole page.

-}

import CaseStudy
import Essay
import Jorn.Attribute as Attr
import Jorn.Element as Element exposing (Element)
import Jorn.Element.Html as Html
import Jorn.Static as Static
import Json.Encode as Encode exposing (Value)
import Main
import PhantomZone
import Url exposing (Url)


port toJorn : Value -> Cmd msg


url : String
url =
    "https://bazylhorsey.github.io"


main : Static.Program
main =
    Static.site toJorn
        { url = url
        , pages = List.map sitePage pages
        , assets =
            [ Static.copy "public" "/"

            -- Older iOS asks for the -precomposed name first; same image.
            , Static.copy "public/apple-touch-icon.png" "/apple-touch-icon-precomposed.png"
            , Static.compile "src/Main.elm" "/main.js"
            , Static.file "/sitemap.xml" sitemap
            ]
        }



-- PAGES


type alias Meta =
    { path : String
    , flag : Maybe String
    , title : String
    , description : String
    , article : Maybe String
    }


home : Meta
home =
    { path = "/"
    , flag = Nothing
    , title = "Bazyl Horsey: applied AI, agentic systems, edge inference"
    , description = "Bazyl Horsey, serial startup executive and two-time VC-backed CTO in Chicago. Applied AI, agentic systems and edge inference that has to work in production."
    , article = Nothing
    }


{-| An article is the home page's app with a `page` flag, under its own title
and description. `article` is its publication date.
-}
pages : List Meta
pages =
    [ home
    , { path = Essay.slug
      , flag = Just "essay"
      , title = Essay.title
      , description = "A forward deployed engineer isn't defined by where they sit. They're defined by where their attention goes when nobody is directing it."
      , article = Just Essay.date
      }
    , { path = CaseStudy.slug
      , flag = Just "study"
      , title = CaseStudy.title
      , description = "How to analyze the ROI of computer vision working next to human inspectors in industrial quality control. With a model you can push on."
      , article = Just CaseStudy.date
      }
    , { path = PhantomZone.slug
      , flag = Just "zone"
      , title = PhantomZone.title
      , description = "How to boot an air-gapped GPU node so the model and the customer's data never touch memory until the machine proves what it is."
      , article = Just PhantomZone.date
      }
    ]


sitePage : Meta -> Static.Page
sitePage meta =
    Static.page meta.path (shell meta)


{-| The flags the page starts the app with. The build renders the light
theme; the page passes the visitor's.
-}
flags : Meta -> Bool -> Value
flags meta dark =
    Encode.object
        (( "dark", Encode.bool dark )
            :: (case meta.flag of
                    Just name ->
                        [ ( "page", Encode.string name ) ]

                    Nothing ->
                        []
               )
        )



-- SHELL


shell : Meta -> Url -> Element Main.Msg
shell meta pageUrl =
    Html.html [ Attr.lang "en" ]
        [ Html.head [] (head meta (Url.toString pageUrl))
        , Html.body []
            [ Html.div [ Attr.id "app" ] [ Main.view (Main.init (flags meta False)) ]
            , Html.script [ Attr.src "/main.js" ] []
            , Html.script [ Attr.type_ "module" ] [ Element.text (glue meta) ]
            ]
        ]


head : Meta -> String -> List (Element msg)
head meta address =
    let
        full =
            case meta.article of
                Just _ ->
                    meta.title ++ " | Bazyl Horsey"

                Nothing ->
                    meta.title

        property name value =
            Html.meta [ Attr.attribute "property" name, Attr.content value ]

        named name value =
            Html.meta [ Attr.name name, Attr.content value ]
    in
    [ Html.meta [ Attr.charset "utf-8" ]
    , named "viewport" "width=device-width, initial-scale=1"
    , Html.title [] [ Element.text full ]
    , named "description" meta.description
    , named "author" "Bazyl Horsey"
    , named "google-site-verification" "pCBUs-DvRU_M1nsCISROveFNAPi69KRRPH-yuzxPv-k"
    , named "color-scheme" "light dark"
    , property "og:type"
        (if meta.article == Nothing then
            "website"

         else
            "article"
        )
    , property "og:site_name" "Bazyl Horsey"
    , property "og:title" full
    , property "og:description"
        (if meta.article == Nothing then
            "Serial startup executive and two-time VC-backed CTO. I build AI that has to work in production, not in a notebook. Chicago, IL."

         else
            meta.description
        )
    , property "og:url" address
    , Html.link [ Attr.rel "canonical", Attr.href address ]
    , property "og:image" (url ++ "/og.png")
    , property "og:image:width" "1200"
    , property "og:image:height" "630"
    , property "og:image:alt"
        (if meta.article == Nothing then
            "Bazyl Horsey. Serial startup executive and two-time VC-backed CTO. Applied AI, agentic systems, edge inference."

         else
            full
        )
    , named "twitter:card" "summary_large_image"
    , named "theme-color" "#ebe8df"
    ]
        ++ List.map jsonLd (schema meta address)
        ++ [ Html.link [ Attr.rel "icon", Attr.href "/favicon.ico", Attr.attribute "sizes" "48x48" ]
           , Html.link [ Attr.rel "icon", Attr.href "/favicon-192.png", Attr.type_ "image/png", Attr.attribute "sizes" "192x192" ]
           , Html.link [ Attr.rel "icon", Attr.href "/favicon.svg", Attr.type_ "image/svg+xml" ]
           , Html.link [ Attr.rel "apple-touch-icon", Attr.href "/apple-touch-icon.png" ]
           , Html.link
                [ Attr.rel "preload"
                , Attr.href "/fonts/bigshoulders.woff2"
                , Attr.attribute "as" "font"
                , Attr.type_ "font/woff2"
                , Attr.attribute "crossorigin" ""
                ]
           , Html.link [ Attr.rel "stylesheet", Attr.href "/portfolio.css" ]
           , Html.script [] [ Element.text pickTheme ]
           ]


jsonLd : Value -> Element msg
jsonLd value =
    Html.script [ Attr.type_ "application/ld+json" ] [ Element.text (Encode.encode 2 value) ]


{-| Home has WebSite and Person blocks; an article gets one Article block.
-}
schema : Meta -> String -> List Value
schema meta address =
    let
        string =
            Encode.string

        strings =
            Encode.list Encode.string
    in
    case meta.article of
        Nothing ->
            [ Encode.object
                [ ( "@context", string "https://schema.org" )
                , ( "@type", string "WebSite" )
                , ( "name", string "Bazyl Horsey" )
                , ( "alternateName", strings [ "Bazyl Horsey portfolio", "bazylhorsey" ] )
                , ( "url", string address )
                ]
            , Encode.object
                [ ( "@context", string "https://schema.org" )
                , ( "@type", string "Person" )
                , ( "name", string "Bazyl Horsey" )
                , ( "url", string address )
                , ( "image", string (url ++ "/og.png") )
                , ( "jobTitle", string "Startup CTO" )
                , ( "description", string "Serial startup executive and two-time VC-backed CTO. Applied AI: agentic systems and edge inference." )
                , ( "email", string "mailto:bhorsey16@gmail.com" )
                , ( "address"
                  , Encode.object
                        [ ( "@type", string "PostalAddress" )
                        , ( "addressLocality", string "Chicago" )
                        , ( "addressRegion", string "IL" )
                        , ( "addressCountry", string "US" )
                        ]
                  )
                , ( "alumniOf"
                  , Encode.object
                        [ ( "@type", string "CollegeOrUniversity" )
                        , ( "name", string "Buena Vista University" )
                        ]
                  )
                , ( "knowsAbout", strings [ "Applied AI", "Computer vision", "Edge inference", "Agentic systems", "Elm", "Gleam", "Rust", "ISO 27001" ] )
                , ( "sameAs"
                  , strings
                        [ "https://github.com/bazylhorsey"
                        , "https://www.linkedin.com/in/bazyl-horsey-075506139"
                        , "https://orcid.org/0009-0000-4566-0406"
                        , "https://bazyl-25260.medium.com/"
                        ]
                  )
                ]
            ]

        Just date ->
            [ Encode.object
                [ ( "@context", string "https://schema.org" )
                , ( "@type", string "Article" )
                , ( "headline", string meta.title )
                , ( "description", string meta.description )
                , ( "datePublished", string date )
                , ( "url", string address )
                , ( "mainEntityOfPage", string address )
                , ( "image", string (url ++ "/og.png") )
                , ( "author"
                  , Encode.object
                        [ ( "@type", string "Person" )
                        , ( "name", string "Bazyl Horsey" )
                        , ( "url", string (url ++ "/") )
                        ]
                  )
                ]
            ]


{-| Pick the theme before anything paints, so a dark-mode visitor never sees
a flash of paper. A stored choice wins; otherwise follow the OS.
-}
pickTheme : String
pickTheme =
    """
(function () {
  var stored = null;
  try {
    stored = localStorage.getItem("theme");
  } catch (e) {}
  var dark =
    stored === "night" ||
    (stored === null && window.matchMedia && matchMedia("(prefers-color-scheme: dark)").matches);
  document.documentElement.dataset.theme = dark ? "night" : "paper";
})();
"""


{-| Client mode: the Elm program runs right here in the page, and `start`
mounts it over the HTML the build wrote. The theme lives in Elm and is
mirrored onto `<html>` so the body background, overscroll and browser chrome
match. Scrolling the testimonial strip is the browser's job, not the tree's.
-}
glue : Meta -> String
glue meta =
    String.replace "PAGE" (pageFlag meta) <|
    """
import { start } from "/jorn.js";

const root = document.documentElement;
const themeColor = document.querySelector('meta[name="theme-color"]');
const paintChrome = (theme) => {
  root.dataset.theme = theme;
  themeColor.content = theme === "night" ? "#141210" : "#ebe8df";
};
paintChrome(root.dataset.theme === "night" ? "night" : "paper");

start(Elm.Main, document.getElementById("app"), {
  flags: { dark: root.dataset.theme === "night"PAGE },
  effects: {
    theme: (theme) => {
      paintChrome(theme);
      try {
        localStorage.setItem("theme", theme);
      } catch (e) {}
    },
    nudgeSaid: (direction, { container }) => {
      const track = container.querySelector(".said-track");
      const card = track && track.querySelector(".said-card");
      if (!card) return;
      const step = card.getBoundingClientRect().width + parseFloat(getComputedStyle(track).columnGap || 0);
      const still = matchMedia("(prefers-reduced-motion: reduce)").matches;
      track.scrollBy({ left: direction * step, behavior: still ? "auto" : "smooth" });
    },
  },
});
"""


pageFlag : Meta -> String
pageFlag meta =
    case meta.flag of
        Just name ->
            ", page: \"" ++ name ++ "\""

        Nothing ->
            ""


sitemap : String
sitemap =
    "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<urlset xmlns=\"http://www.sitemaps.org/schemas/sitemap/0.9\">\n"
        ++ String.concat (List.map (\meta -> "  <url><loc>" ++ url ++ meta.path ++ "</loc></url>\n") pages)
        ++ "</urlset>\n"
