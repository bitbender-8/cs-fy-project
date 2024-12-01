# CS final year project practice

A project to practice workflows, test dependencies, and discover pain points before starting the final year project.

## Working on the project

Before working on the project always run

1. `git pull` - to pull the latest changes
2. `npm install` - in the `/backend` and `/frontends/admin` directories to refresh project dependencies.

During development run in the `/frontends/admin` and `/backend` directories run `npm run dev` to run your project

Before pushing the project always run the following (in the order shown) if you made changes to

1. The `/frontends/admin` and `/backend` directories

   - `npm run format`
   - `npm run lint` some errors can't be fixed automatically. You have to fix those yourself.
   - `npm run build`

2. The `/frontends/mobile` directory

   - `dart format .`
   - `flutter analyze`
   - `flutter build apk`

## Dependency versions

The following dependencies' versions are not specified in a file (like package.json). Therefore, their versions are fixed to the following versions.

- `flutter --version`

```text
Flutter 3.24.5 • channel stable s• https://github.com/flutter/flutter.git
Framework • revision dec2ee5c1f (2 weeks ago) • 2024-11-13 11:13:06 -0800
Engine • revision a18df97ca5
Tools • Dart 3.5.4 • DevTools 2.37.3
```

## Git conventions and best practices

- **Commit frequently** regardless of how small each fix or task completed is. Doing this allows us to roll back changes easily and creates a clear history.
- **Make self-contained commits** that avoid bundling changes together and make it harder to identify issues.
- **Keep commits small** and make sure they are focused on specific changes.

### Branching strategy

We are using the Feature Workflow model. You can look it up for more info but here are the highlights.

- We are going to have a main branch that has unbroken code.
- When working on new features or fixes we will create new branches and merge them back to main once we fix issues.

### Commit messages

We have three separate apps in this repo. So we will structure our commit messages to reflect where the changes were made. We will use the following format for our messages

```text
<type>(<scope>): <subject>

<body>
```

- `<type>` is the type of commit and can be either of the following

  - `feat` - when working on a new feature.
  - `fix` - when fixing bugs or issues in the codebase.
  - `docs` - when making changes to the docs.
  - `revert` - when reverting to a prior commit.
  - `refactor` - when refactoring the codebase.

- `<scope>` is the app the change affects. If it affects multiple apps It can be either of the following
  - `mob` - for changes in `frontends/mobile` (flutter app)
  - `adm` - for changes in `frontends/admin` (nextjs admin app)
  - `bck` - for changes in `frontends/bck` and `db` (nodejs backend code)
  - `doc` - for changes in `docs` (top-level docs folder)
  - `ci` - for changes in `.github/workflows` (github actions)

When it comes to the subject and body we will follow the guidelines outlined below. You can find out more detailed explanations [here](https://cbea.ms/git-commit/).

- Separate the subject from body with a blank line.
- Limit the subject line to 50 characters
- Capitalize the subject line
- Do not end the subject line with a period
- Use the imperative mood in the subject line (e.g `Fix bug in Y` instead of `Fixed bug in Y`). A properly formatted Git message should always be able to complete the following line:
  - If applied, this commit will `____`.
- Wrap the body at 72 characters (use line guides in your editor to do so).
- If you need to have a body for details (when your diff is too large), use it to explain what and why.
