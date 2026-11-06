# GitHub Actions experiment and deployment

This guide describes how to test the RDF validation and GitHub Pages workflows
in an isolated repository before proposing their use in `w3c/dx-dcat`.

For the repository-side GitHub configuration (Actions permissions, Pages
source, and required status checks), see
[Deployment on GitHub: Instructions](./DEPLOYMENT-ON-GITHUB-INSTRUCTIONS.md).

## Scope and repository layout

The validator runs on pull requests, but only sets up Jena and checks RDF when
`TR/rdf/dcat3.ttl` changes. The Pages publisher runs on every push to
`gh-pages`, prepares the complete source tree, regenerates
`TR/rdf/dcat3.jsonld` and `TR/rdf/dcat3.rdf` from the canonical Turtle, then
builds the site with GitHub Pages' Jekyll action. The repository has no custom
Jekyll configuration, matching the current `w3c/dx-dcat` setup. This preserves
the Jekyll-rendered root README and existing HTML under `/TR/`.

The files ported from the prepared sandbox are:

- `.github/workflows/validate-rdf.yml`
- `.github/workflows/publish-rdf-pages.yml`
- `scripts/generate-rdf.sh`
- `scripts/build-publication.sh`

The workflows and scripts are adapted from `dcat/rdf/dcat3.ttl` to the W3C
repository's `TR/rdf/dcat3.ttl`.

Keep these repositories separate:

- `dx-dcat-upstream.git`: local bare mirror/reference only.
- `dx-dcat-sandbox`: editable local working copy.
- A personal GitHub fork or test repository: hosted Actions and Pages testing.

Do not push test changes to `w3c/dx-dcat`. The mirror and working copy are
local; hosted GitHub Actions and Pages require a separate remote repository
where you have administrative access.

## Local verification

Use Java 21 and Apache Jena 6.2.0, matching the workflows. Put Jena's `bin`
directory on `PATH`, then prepare the Jekyll source from the working copy:

```sh
riot --validate TR/rdf/dcat3.ttl
scripts/build-publication.sh .pages-source
```

The preparation step copies the complete tree and generates RDF in
`.pages-source/TR/rdf/`. The generator validates the Turtle source, generates
JSON-LD and RDF/XML, validates both outputs, and compares their graphs with
`rdfcompare`. To preview locally, build that prepared source with the same
GitHub Pages Jekyll environment used by the workflow; inspect the resulting
root page, `/TR/`, RDF endpoints, redirects, and other site content. The
preparation step recreates its destination, so use only the dedicated
`.pages-source` path for it.

## Hosted test in a separate repository

1. Create a personal fork or a separate GitHub repository from `w3c/dx-dcat`;
   do not use the W3C repository as the experiment target.
2. Add that repository as a test-only remote (replace the placeholder with
   your GitHub account/repository), then push a testing branch:

   ```sh
   git remote add test https://github.com/<account>/<test-repo>.git
   git push test HEAD:actions-experiment
   ```

   Open a pull request from `actions-experiment` to the test repository's
   `gh-pages` branch. This bootstrap pull request may not run the newly added
   validator because it is not yet present on the base branch. Do not push to
   `w3c/dx-dcat`.
3. In the test repository's **Settings → Pages**, select **GitHub Actions** as
   the build/deployment source. Confirm that Actions are enabled. Merge the
   bootstrap pull request only in this isolated test repository; its
   `gh-pages` update intentionally exercises the publication workflow.
4. Open one follow-up test pull request with a change to `TR/rdf/dcat3.ttl`;
   confirm **Validate DCAT Turtle** passes. Open another changing a non-Turtle
   file; confirm the validation workflow reports success while skipping the
   Jena steps. This keeps a stable required check available for branch
   protection.
5. Confirm that the publisher declares `contents: read`, `pages: write`, and
   `id-token: write`, and uses the `github-pages` environment with
   `actions/deploy-pages`. Every push to `gh-pages` should run the build and
   deploy jobs, including changes to HTML, styles, images, redirects, README,
   or Turtle.
6. Open the deployment URL from the Actions run and verify the document and
   RDF resources, especially `/TR/`, `/TR/rdf/dcat3.ttl`,
   `/TR/rdf/dcat3.jsonld`, and `/TR/rdf/dcat3.rdf`. Confirm expected redirects
   still exist.

Do not use the `w3c/dx-dcat` repository as the deployment test. Its Pages
publication currently uses GitHub's dynamic `pages-build-deployment`
workflow. Moving it to a custom Actions workflow requires W3C repository
maintainer approval and a coordinated Pages configuration change.

## Handoff for deployment to `w3c/dx-dcat`

After hosted tests pass, prepare a pull request against the W3C repository
containing the adapted workflow and helper scripts plus this testing guide.
Ask repository maintainers to review compatibility with existing Pages
behavior before merging. In particular:

- Keep the current Pages deployment enabled until maintainers choose and
  schedule a switch to the Actions source.
- Confirm the custom workflow can publish the complete site, preserving URLs,
  redirects, and generated RDF resources; do not publish only a partial
  artifact.
- Confirm GitHub Pages is configured to build/deploy using GitHub Actions,
  required Actions permissions are available, and the `github-pages`
  environment can deploy.
- Make the switch with a maintainer present; verify the resulting
  `https://w3c.github.io/dx-dcat/` URLs and monitor the Actions run.
- Agree on a rollback before the switch: restore the prior Pages source and
  workflow configuration if the deployment fails or site URLs/content differ.

This experiment does not change the W3C repository settings or deploy to its
Pages site.
