# CS final year project practice

A project to practice workflows, test dependencies, and discover pain points before starting the final year project.

## Working on the project

Before working on the project always run

1. `git pull` - to pull the latest changes
2. `npm install` - in the `/backend` and `/frontends/admin` directories to refresh project dependencies.

During development run in the `/frontends/admin` and `/backend` directories run `npm run dev` to run your project

Before pushing the project always run the following if you made changes to

1. The `/frontends/admin` and `/backend` directories

   - `npm run build`
   - `npm run format`
   - `npm run lint:fix`, some errors can't be fixed automatically you have to fix those yourself.

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

## Git conventions
