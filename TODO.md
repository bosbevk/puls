# What's next for Puls

This is the list of what Puls still has to do, kept with Puls since it moved to its own repository. Each row keeps the
id it had in the framework's TODO, so an older plan, commit or doc that names one still finds it here. Puls is paused
while the framework and its site come first, so the phases count from the day it resumes. *Now* is what it starts
with, *Next* follows, and *Later* after that. *Cleanups* are small tidy-ups taken when the code beside them is
touched. A few rows were found through Puls but change the framework's own code, such as CL62's `Words` method on
the site builder. Their work is done in the framework's repository, and they're tracked here because Puls is what
needs them. What the framework itself still has to do, including two fixes Puls found in the engine, is in the
[framework's TODO](https://github.com/bosbevk/louis-agent/blob/main/TODO.md).

## Open (31)

| Id | What | Phase | Detail |
|---|---|---|---|
| F65 | After F35, the cook's answer | Now | — |
| F68 | The cook scales wrongly | Now | — |
| F72 | Open from the recipes evals | Now | — |
| F48 | Recipe maths and a teaching cook | Next | [plan](docs/plans/F48-cook-and-teacher.md) |
| F50 | Puls's local specialists | Next | — |
| F107 | A guest is sent to sign in before the chat: no composer for nobody (Louis, 2026-11-08, on mypuls.co.za: "I need to log in first"); today the gate answers 401 and the page sends them then; the guide in the site's corner is open on purpose (F109.3, ADR 0099), only the chat is behind the sign-in | Next | — |
| FX66 | Both Azure apps keep their data-protection keys (which sign the sign-in cookie) in the container, so every cold start after scaling to zero makes new keys and signs everyone out (the start-up log warns); the keys go to each app's share, one setting (found 2026-11-08, F109.2) | Now | — |
| CL50 | Remove `PULS_API`, the eval runner's old name for the API's address | Cleanups | — |
| CL62 | A site's own words win only when registered before `AddSiteAreas` (the builder adds its defaults with `TryAdd`), which is wiring by order: give the builder a `Words(chatText, accountText)` method and have Puls pass its Afrikaans through it, so order never matters (ADR 0120, found in F127.6 step 10) | Cleanups | — |
| F75 | Puls local spec | Next | — |
| F76 | Cook for the week | Next | [spec](docs/specs/PULS_COOK.md) |
| CL16 | Reusable roles | Next | — |
| F77 | A domain stop-list for the browser | Next | [doc](docs/SITE_OWNERS.md) |
| F78 | Sources as data | Next | — |
| F79 | Places | Next | — |
| F80 | Local businesses | Next | — |
| F81 | Vision: `ScreenshotPage(url)` and images as input | Next | — |
| F82 | Local lookups | Next | — |
| F23 | Credits | Next | — |
| F83 | The cook's unconfirmed prices | Next | [feature doc](https://github.com/bosbevk/louis-agent/blob/pre-cl24/docs/features/F25-local-cook.md) |
| F84 | A shorter cook report | Next | — |
| F21 | Louis's corrections to the Afrikaans | Next | [feature doc](https://github.com/bosbevk/louis-agent/blob/pre-cl24/docs/features/F21-personalities.md) |
| F28 | Team talk, the rest | Next | [feature doc](docs/features/F28-team-talk.md) |
| F135 | Puls on `AskAgent`, measured when Puls resumes: the recipes eval before and after (F127.3.1 moved it with no run, since Puls is paused), and its stored replays recorded again, since they name the old tools | Next | [ADR 0117](https://github.com/bosbevk/louis-agent/blob/main/src/docs/adr/0117-one-address-for-every-agent-call.md) |
| F85 | A retailer's own prices, only with its permission or feed | Next | — |
| F86 | Our own Nominatim, or a paid geocoder, before Puls is public | Next | — |
| F87 | The open feeds have no key and no limit | Next | — |
| F60 | Search by meaning | Later | — |
| F88 | The cook's wave 3 | Later | [spec](docs/specs/PULS_COOK.md) |
| F89 | A Puls-owned set of a few hundred South African recipes | Later | — |
| F91 | The eleven official languages, measured | Later | — |
