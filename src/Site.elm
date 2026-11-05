port module Site exposing (main)

{-| The portfolio as a static site, which `jorn build` writes to `build/`:

  - the home page and a page for each piece of writing, each a whole
    document with the app's view already inside `#app`, so crawlers and link
    previews that never run JavaScript still get the whole page
  - the stylesheet, font, icons and crawler files from `public/`
  - the app, compiled to `/main.js`, next to Jorn's patcher at `/jorn.js`
  - a sitemap, made from the same list as the pages

`jorn build` adds a hash of each script and stylesheet to the URLs that
refer to it, so a returning visitor never gets new HTML with an old script.

In the browser, each page starts the app with the same flags its HTML was
built from, and Jorn mounts the same view over it, so nothing changes on
screen.

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
import Url


port toJorn : Value -> Cmd msg


site : String
site =
    "https://bazylhorsey.github.io"


main : Static.Program
main =
    Static.site toJorn
        { url = site
        , pages = List.map render pages
        , assets =
            [ Static.copy "public" "/"

            -- Older iOS asks for the -precomposed name first. Same image.
            , Static.copy "public/apple-touch-icon.png" "/apple-touch-icon-precomposed.png"
            , Static.compile "src/Main.elm" "/main.js"
            , Static.file "/sitemap.xml" sitemap
            ]
        }



-- PAGES


{-| One page: which page of the app it holds, and what its head tells search
engines and link previews. `updated` is the last time its content changed,
for the sitemap.
-}
type alias Page =
    { app : Main.Page
    , path : String
    , title : String
    , description : String
    , preview : String
    , imageAlt : String
    , kind : String
    , schema : String -> List Value
    , updated : String
    }


pages : List Page
pages =
    [ home
    , article Main.EssayPage
        { title = Essay.title
        , path = Essay.slug
        , published = Essay.date
        , updated = "2026-10-15"

        -- Words from the essay itself.
        , description =
            "A forward deployed engineer isn't defined by where they sit. They're "
                ++ "defined by where their attention goes when nobody is directing it."
        }
    , article Main.StudyPage
        { title = CaseStudy.title
        , path = CaseStudy.slug
        , published = CaseStudy.date
        , updated = "2026-10-19"
        , description =
            "How to analyze the ROI of computer vision working next to human "
                ++ "inspectors in industrial quality control. With a model you can push on."
        }
    , article Main.ZonePage
        { title = PhantomZone.title
        , path = PhantomZone.slug
        , published = PhantomZone.date
        , updated = "2026-10-19"
        , description =
            "How to boot an air-gapped GPU node so the model and the customer's "
                ++ "data never touch memory until the machine proves what it is."
        }
    ]


home : Page
home =
    { app = Main.Home
    , path = "/"
    , title = "Bazyl Horsey: applied AI, agentic systems, edge inference"
    , description =
        "Bazyl Horsey, serial startup executive and two-time VC-backed CTO in "
            ++ "Chicago. Applied AI, agentic systems and edge inference that has to "
            ++ "work in production."
    , preview =
        "Serial startup executive and two-time VC-backed CTO. I build AI that has "
            ++ "to work in production, not in a notebook. Chicago, IL."
    , imageAlt =
        "Bazyl Horsey. Serial startup executive and two-time VC-backed CTO. "
            ++ "Applied AI, agentic systems, edge inference."
    , kind = "website"
    , schema = \_ -> [ website, person ]
    , updated = "2026-11-05"
    }


{-| A piece of writing gets its own title in front of my name, its words as
the description, and one Article block in JSON-LD.
-}
article :
    Main.Page
    -> { title : String, path : String, published : String, updated : String, description : String }
    -> Page
article app piece =
    let
        full =
            piece.title ++ " | Bazyl Horsey"
    in
    { app = app
    , path = piece.path
    , title = full
    , description = piece.description
    , preview = piece.description
    , imageAlt = full
    , kind = "article"
    , schema =
        \address ->
            [ Encode.object
                [ ( "@context", Encode.string "https://schema.org" )
                , ( "@type", Encode.string "Article" )
                , ( "headline", Encode.string piece.title )
                , ( "description", Encode.string piece.description )
                , ( "datePublished", Encode.string piece.published )
                , ( "url", Encode.string address )
                , ( "mainEntityOfPage", Encode.string address )
                , ( "image", Encode.string (site ++ "/og.png") )
                , ( "author", author )
                ]
            ]
    , updated = piece.updated
    }



-- JSON-LD


website : Value
website =
    Encode.object
        [ ( "@context", Encode.string "https://schema.org" )
        , ( "@type", Encode.string "WebSite" )
        , ( "name", Encode.string "Bazyl Horsey" )
        , ( "alternateName", Encode.list Encode.string [ "Bazyl Horsey portfolio", "bazylhorsey" ] )
        , ( "url", Encode.string (site ++ "/") )
        ]


person : Value
person =
    Encode.object
        [ ( "@context", Encode.string "https://schema.org" )
        , ( "@type", Encode.string "Person" )
        , ( "name", Encode.string "Bazyl Horsey" )
        , ( "url", Encode.string (site ++ "/") )
        , ( "image", Encode.string (site ++ "/og.png") )
        , ( "jobTitle", Encode.string "Startup CTO" )
        , ( "description"
          , Encode.string
                ("Serial startup executive and two-time VC-backed CTO. Applied AI: "
                    ++ "agentic systems and edge inference."
                )
          )
        , ( "email", Encode.string "mailto:bhorsey16@gmail.com" )
        , ( "address"
          , Encode.object
                [ ( "@type", Encode.string "PostalAddress" )
                , ( "addressLocality", Encode.string "Chicago" )
                , ( "addressRegion", Encode.string "IL" )
                , ( "addressCountry", Encode.string "US" )
                ]
          )
        , ( "alumniOf"
          , Encode.object
                [ ( "@type", Encode.string "CollegeOrUniversity" )
                , ( "name", Encode.string "Buena Vista University" )
                ]
          )
        , ( "knowsAbout"
          , Encode.list Encode.string
                [ "Applied AI"
                , "Computer vision"
                , "Edge inference"
                , "Agentic systems"
                , "Elm"
                , "Gleam"
                , "Rust"
                , "ISO 27001"
                ]
          )
        , ( "sameAs"
          , Encode.list Encode.string
                [ "https://github.com/bazylhorsey"
                , "https://www.linkedin.com/in/bazyl-horsey-075506139"
                , "https://orcid.org/0009-0000-4566-0406"
                , "https://bazyl-25260.medium.com/"
                ]
          )
        ]


author : Value
author =
    Encode.object
        [ ( "@type", Encode.string "Person" )
        , ( "name", Encode.string "Bazyl Horsey" )
        , ( "url", Encode.string (site ++ "/") )
        ]



-- DOCUMENT


render : Page -> Static.Page
render page =
    Static.page page.path (\url -> document page (Url.toString url))


document : Page -> String -> Element Main.Msg
document page address =
    Html.html [ Attr.lang "en" ]
        [ Html.head [] (head page address)
        , Html.body []
            [ Html.div [ Attr.id "app" ] [ Main.view (Main.init (flags page)) ]
            , Html.script [ Attr.src "/main.js" ] []
            , Html.script [ Attr.type_ "module" ] [ Element.text (startScript page) ]
            ]
        ]


head : Page -> String -> List (Element msg)
head page address =
    [ Html.meta [ Attr.charset "utf-8" ]
    , named "viewport" "width=device-width, initial-scale=1"
    , Html.title [] [ Element.text page.title ]
    , named "description" page.description
    , named "author" "Bazyl Horsey"
    , named "google-site-verification" "pCBUs-DvRU_M1nsCISROveFNAPi69KRRPH-yuzxPv-k"
    , named "color-scheme" "light dark"
    , og "og:type" page.kind
    , og "og:site_name" "Bazyl Horsey"
    , og "og:title" page.title
    , og "og:description" page.preview
    , og "og:url" address
    , Html.link [ Attr.rel "canonical", Attr.href address ]
    , og "og:image" (site ++ "/og.png")
    , og "og:image:width" "1200"
    , og "og:image:height" "630"
    , og "og:image:alt" page.imageAlt
    , named "twitter:card" "summary_large_image"
    , named "theme-color" "#ebe8df"
    ]
        ++ List.map jsonLd (page.schema address)
        ++ [ Html.link [ Attr.rel "icon", Attr.href "/favicon.ico", Attr.sizes "48x48" ]
           , Html.link [ Attr.rel "icon", Attr.href "/favicon-192.png", Attr.type_ "image/png", Attr.sizes "192x192" ]
           , Html.link [ Attr.rel "icon", Attr.href "/favicon.svg", Attr.type_ "image/svg+xml" ]
           , Html.link [ Attr.rel "apple-touch-icon", Attr.href "/apple-touch-icon.png" ]
           , Html.link
                [ Attr.rel "preload"
                , Attr.href "/fonts/bigshoulders.woff2"
                , Attr.as_ "font"
                , Attr.type_ "font/woff2"
                , Attr.crossorigin "anonymous"
                ]
           , Html.link [ Attr.rel "stylesheet", Attr.href "/portfolio.css" ]
           , Html.script [] [ Element.text themeScript ]
           ]


named : String -> String -> Element msg
named key value =
    Html.meta [ Attr.name key, Attr.content value ]


og : String -> String -> Element msg
og key value =
    Html.meta [ Attr.attribute "property" key, Attr.content value ]


jsonLd : Value -> Element msg
jsonLd value =
    Html.script [ Attr.type_ "application/ld+json" ] [ Element.text (Encode.encode 2 value) ]


{-| What the page starts the app with, apart from the theme, which only the
visitor's browser knows. Each page's HTML is built from these too, on paper.
-}
flags : Page -> Value
flags page =
    Encode.object [ ( "page", Encode.string (Main.pageName page.app) ) ]


{-| Runs in the head, before anything paints, so the page is already in the
right theme when the body shows up.
-}
themeScript : String
themeScript =
    """
// Pick the theme before anything paints, so a dark-mode visitor never
// sees a flash of paper. A stored choice wins; otherwise follow the OS.
(function () {
  var stored = null;
  try {
    stored = localStorage.getItem("theme");
  } catch (e) {}
  var dark =
    stored === "night" ||
    (stored === null &&
      window.matchMedia &&
      matchMedia("(prefers-color-scheme: dark)").matches);
  document.documentElement.dataset.theme = dark ? "night" : "paper";
})();
"""


{-| Starts the app over the page, and registers the two client effects
`Main.update` sends: the theme on `<html>`, and scrolling the testimonials.
-}
startScript : Page -> String
startScript page =
    """
// Client mode: the Elm program runs right here in the page, and the same
// patcher a server component would use applies the diffs to the DOM.
// `start` is Jorn's runtime glue: mount, events, one render per frame.
import { start } from "/jorn.js";

const root = document.documentElement;
const themeColor = document.querySelector('meta[name="theme-color"]');
const paintChrome = (theme) => {
  root.dataset.theme = theme;
  themeColor.content = theme === "night" ? "#141210" : "#ebe8df";
};
paintChrome(root.dataset.theme === "night" ? "night" : "paper");

start(Elm.Main, document.getElementById("app"), {
  flags: { dark: root.dataset.theme === "night", page: """
        ++ Encode.encode 0 (Encode.string (Main.pageName page.app))
        ++ """ },
  effects: {
    // The theme lives in Elm. Mirror it onto <html> so the body
    // background, overscroll and browser chrome match, and remember
    // the visitor's choice.
    theme: (theme) => {
      paintChrome(theme);
      try {
        localStorage.setItem("theme", theme);
      } catch (e) {}
    },
    // Scrolling is the browser's job, not the tree's: move the
    // testimonial strip one card in the direction Elm asked for.
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



-- SITEMAP


sitemap : String
sitemap =
    "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
        ++ "<urlset xmlns=\"http://www.sitemaps.org/schemas/sitemap/0.9\">\n"
        ++ String.concat (List.map sitemapEntry pages)
        ++ "</urlset>\n"


sitemapEntry : Page -> String
sitemapEntry page =
    "  <url>\n"
        ++ ("    <loc>" ++ site ++ page.path ++ "</loc>\n")
        ++ ("    <lastmod>" ++ page.updated ++ "</lastmod>\n")
        ++ "  </url>\n"
