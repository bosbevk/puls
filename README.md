# Puls

Puls is an assistant for people in South Africa. It answers from the web itself and hands cooking to its cook, a
specialist that finds recipes and estimates what the shopping costs. Puls is paused for now, so its own app isn't deployed. Until it is, [mypuls.co.za](https://mypuls.co.za) shows a
coming-soon page, published from `coming-soon/` by this repository's workflow.

Puls is built on the [louis-agent](https://github.com/bosbevk/louis-agent) framework, and takes it as NuGet packages
from GitHub Packages. It holds no copy of the framework's code. Everything here is what makes Puls Puls:
- who it is (its identity and prompts);
- its three packs (recipes, shop prices and where to buy);
- its evals and judges;
- its web app, its API and its eval runner;
- its config, Docker files and Azure setup.

## How it is laid out

The code is in `src/`, one folder per project, each named for its namespace, such as `Puls.Identity` and
`Puls.Packs.Recipes`. Each project's tests sit in `tests/` under the same name with `.Tests` on the end, and the ones
that need a real MongoDB end in `.IntegrationTests`. `Puls.sln` holds them all. The docs are in [docs/](docs/README.md):
setting Puls up, changing it, how each part works, and the decisions only Puls needs. Everything about the framework
itself is in the [framework's docs](https://github.com/bosbevk/louis-agent/blob/main/src/docs/README.md).

## Building it

The framework's packages live on GitHub Packages, which asks for a token even to read a public package. So before the
first build, set `GITHUB_PACKAGES_TOKEN` to a GitHub token that can read packages (a classic token with
`read:packages`). `nuget.config` signs in to the feed with it. Then the usual commands work:

```
dotnet build Puls.sln
dotnet test Puls.sln --filter "Category!=Integration"
```

The integration tests run when `BENCHMARKS_MONGO_URL` names a MongoDB; without one they skip. CI runs all of them on
every pull request, with the workflow's own token and a throwaway MongoDB. To run Puls in Docker, see
[Setup](docs/SETUP.md). The image build takes the same token as a build secret, so no layer of the image keeps it.

## Where it came from

Puls was a demo inside louis-agent until it moved here on its own. Its history up to that day stays there, at the tag
[`puls-moved-out`](https://github.com/bosbevk/louis-agent/tree/puls-moved-out), and `tools/moved-from-louis-agent/`
holds the commands that made the move, kept as the record of what was done.

## Licence

Puls is free to use, change and share for any noncommercial purpose under the PolyForm Noncommercial License 1.0.0;
see [LICENSE](LICENSE). Commercial use needs a separate licence from the copyright holder first.
