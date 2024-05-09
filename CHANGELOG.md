# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

# JMS Exporter
## [1.0.7] - 2024-05-08
### Fixed
- Better error messages for the user, no root node, too many root nodes, no geometry, etc
- Error messages not cancelling the export process
- Script getting stuck when crashing in the middle of the export process (renabling scene drawing)
- Saving file dialog defaulting to hardcoded directory

### Added
- Error message when geometry has invalid Material ID assigned
- Error message when objects in the scene are not an Editable Mesh or Editable Poly
- Check box to enable/disable the "Turn to Mesh" modifier

### Removed
- Automatically adding "Turn to Mesh" modifier to objects in the scene
