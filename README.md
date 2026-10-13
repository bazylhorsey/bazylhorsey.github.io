# bazylhorsey.github.io

https://bazylhorsey.github.io/

My portfolio. Written in Elm and rendered by
[Jorn](https://github.com/bazylhorsey/jorn), running in production.

The page is prerendered from the same Elm view at build time so crawlers get
real HTML, then Jorn mounts in the browser and owns every update after that:
the theme toggle and the work filters are Jorn diffs and patches.

The root of this repo is the built site, which is what GitHub Pages serves.
The source is in [`source/`](source/), and `source/README.md` covers building
and deploying.
