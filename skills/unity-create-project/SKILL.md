---
name: unity-create-project
description: Use when creating a new minimal Unity project.
allowed-tools:
  - Bash
---

# New bare minimum project

Use this when asked to create an empty project.

The `unity` CLI recognizes a directory as a Unity project when it contains the following:

- An `Assets` directory
- A `ProjectSettings/ProjectVersion.txt` file (may be empty)

```bash
mkdir -p MyProject/Assets MyProject/ProjectSettings
touch MyProject/ProjectSettings/ProjectVersion.txt
```

# New project from the minimal template

The `github.com/keijiro/UnityProjectTemplate` repository is itself a single minimal template: a 3D URP project with UI Toolkit and the Input System set up.

Use it when asked to create a new Unity project that fits this category. To instantiate it, shallow-clone the repository into the destination directory and remove the `.git` directory.

```bash
git clone --depth 1 https://github.com/keijiro/UnityProjectTemplate MyProject
rm -rf MyProject/.git
```
