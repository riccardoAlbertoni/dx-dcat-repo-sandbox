# Deployment on GitHub: Instructions

This document describes the GitHub repository settings needed for the
DCAT Turtle validation and GitHub Pages publication workflows in this
repository. Configure these settings first in the isolated test repository
(`riccardoAlbertoni/dx-dcat-repo-sandbox`). Do not use these instructions to
change `w3c/dx-dcat` without approval from its repository maintainers.

## What the workflows do

- **Validate DCAT Turtle** runs for every pull request. It always reports a
  `validate` check, but sets up Apache Jena and validates syntax only when
  `TR/rdf/dcat3.ttl` changes.
- **Publish GitHub RDF Pages** runs only for pushes to `gh-pages` that change
  `TR/rdf/dcat3.ttl`. It builds the complete publication site, regenerates
  `TR/rdf/dcat3.jsonld` and `TR/rdf/dcat3.rdf`, and deploys the site to GitHub
  Pages.

The workflows are in
[`.github/workflows/validate-rdf.yml`](./.github/workflows/validate-rdf.yml)
and
[`.github/workflows/publish-rdf-pages.yml`](./.github/workflows/publish-rdf-pages.yml).

## 1. Enable GitHub Actions and permit the workflow actions

In the repository, open **Settings → Actions → General**.

1. Under **Actions permissions**, enable Actions. If using an allow-list,
   allow the external actions used by these workflows:
   - `actions/checkout`
   - `actions/setup-java`
   - `actions/cache`
   - `dorny/paths-filter`
   - `actions/upload-pages-artifact`
   - `actions/deploy-pages`
2. Ensure the policy permits the versions referenced by the workflow files
   (`v4` and `v5` tags). If an organization-level policy applies, a repository
   administrator may need to adjust it.
3. Under **Workflow permissions**, read-only access is sufficient for the
   validation workflow. The publishing workflow declares its own required
   `contents: read`, `pages: write`, and `id-token: write` permissions.
   Avoid granting all workflows broad write permissions.
4. The workflows currently reference action version tags rather than full
   commit SHAs. Do not enable **Require actions to be pinned to a full-length
   commit SHA** unless the action references are first changed to verified
   full-length SHAs.

Apache Jena is downloaded from the Apache archive by the workflow; it is not
a GitHub Action that needs to be added to the allowed-actions list.

## 2. Configure GitHub Pages

Open **Settings → Pages** and set the build and deployment source to
**GitHub Actions**. Do not select **Deploy from a branch** for this workflow.

The publishing workflow uses the `github-pages` environment and GitHub's
Pages deployment actions. The workflow declares the required permissions;
do not add a long-lived deployment token or repository secret.

If the repository already publishes a site, verify the current deployment
behavior and URLs before changing this setting. For `w3c/dx-dcat`, keep its
existing Pages setup until W3C maintainers approve and coordinate a switch.

## 3. Require pull requests and the validation check on `gh-pages`

Open **Settings → Rules → Rulesets** and create or edit a **branch ruleset**:

1. Give it a recognizable name, such as `validation gh-pages`, and set
   **Enforcement status** to **Active**.
2. Under **Target branches**, include only `gh-pages`. Check the displayed
   target summary before saving; it should say the ruleset applies to
   `gh-pages`.
3. Under **Branch rules**, enable **Require a pull request before merging**.
   Set the required approval count to the repository's review policy. For the
   experiment, zero approvals were configured; that allows a PR without
   another review but does not bypass the required status check.
4. Enable **Require status checks to pass**. Choose **Add checks**, search for
   `validate`, and select the `validate` check from **GitHub Actions**.
   Confirm it appears in **Status checks that are required**.
5. Leave **Do not require status checks on creation** disabled. Consider
   **Require branches to be up to date before merging** separately; it is not
   needed for the tested configuration.
6. Keep the **Bypass list** empty if the rule should apply to repository
   administrators as well as other contributors. Adding a bypass actor permits
   that actor to evade the ruleset.
7. Save the ruleset and confirm its status is **Active** and target is
   `gh-pages`.

The validator is intentionally triggered for every PR, including PRs that do
not edit the Turtle file. This keeps the `validate` status check available for
the ruleset to require. On a non-Turtle PR, Jena validation is skipped but the
check should still finish successfully.

## 4. Verify the configuration

Use pull requests in the test repository; do not merge deliberately invalid
Turtle into `gh-pages`.

1. Open a PR that changes a non-Turtle file. Confirm the `validate` check
   completes successfully and Jena steps are skipped.
2. Open a PR that changes `TR/rdf/dcat3.ttl` with valid Turtle. Confirm
   `validate` runs and succeeds.
3. For a controlled negative test, open a PR with invalid Turtle. Confirm
   `validate` fails and GitHub marks the check as required, with the merge
   button disabled. Leave the invalid PR unmerged and restore or close it only
   after its evidence is recorded.
4. After a valid change to `TR/rdf/dcat3.ttl` reaches `gh-pages`, confirm the
   **Publish GitHub RDF Pages** workflow runs through build and deploy. A push
   changing only other files should not trigger this publisher.
5. Open the Pages deployment URL from the completed run and check the
   publication page and `/TR/rdf/dcat3.ttl`, `/TR/rdf/dcat3.jsonld`, and
   `/TR/rdf/dcat3.rdf`. Confirm expected redirects and the rest of the site
   remain present.

The test repository's `gh-pages` ruleset has been configured to require the
`validate` check. PR #30 is the retained invalid-Turtle example; its failed
check is expected and it must remain unmerged.

## 5. Deployment to `w3c/dx-dcat`

The settings in the test repository do not change the W3C repository. Before
deploying there:

- Have W3C repository maintainers review and approve the workflow and settings
  change.
- Confirm the complete publication artifact preserves existing site content,
  redirects, and URLs.
- Coordinate the change of **Settings → Pages** to **GitHub Actions** with
  maintainers; do not disable or replace the existing deployment prematurely.
- Confirm the required Actions policy, Pages permissions, `github-pages`
  environment, and branch rules are compatible with W3C's governance.
- Agree on a rollback plan, then verify the deployed `https://w3c.github.io/dx-dcat/`
  pages and RDF endpoints after the change.

No W3C repository settings or Pages deployments have been changed as part of
this experiment.
