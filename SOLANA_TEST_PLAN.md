# Solana Integration Test Plan

## Overview
This document outlines the complete test plan for verifying the zero.nix Solana integration after refactoring the code into `packages/solana-tools.nix`.

## Test Structure

### 1. Basic Syntax and Build Tests

#### 1.1 Flake Check
```bash
nix flake check
```
**Expected Result**: No syntax errors, all checks pass

#### 1.2 Individual Package Builds
```bash
nix build .#solana-node
nix build .#anchor
nix build .#setup-solana
nix build .#nightly-rust
nix build .#anchor-wrapper
nix build .#solana-tools
```
**Expected Result**: All packages build successfully

#### 1.3 Template Registration
```bash
nix flake show --json | jq '.templates'
```
**Expected Result**: Shows `solana-dev` template is registered

### 2. Development Environment Tests

#### 2.1 Basic Development Shell
```bash
nix develop --command bash -c "echo 'Dev environment loaded'"
```
**Expected Result**: Environment loads without errors

#### 2.2 Environment Variables Check
```bash
nix develop --command bash -c 'echo "PLATFORM_TOOLS_DIR: $PLATFORM_TOOLS_DIR"'
nix develop --command bash -c 'echo "SBF_SDK_PATH: $SBF_SDK_PATH"'
nix develop --command bash -c 'echo "CARGO_HOME: $CARGO_HOME"'
nix develop --command bash -c 'echo "RUSTUP_HOME: $RUSTUP_HOME"'
```
**Expected Result**: All environment variables are set correctly

### 3. Solana CLI Tests

#### 3.1 Solana Version
```bash
nix develop --command bash -c "solana --version"
```
**Expected Result**: Shows `solana-cli 2.0.22`

#### 3.2 Solana Keygen
```bash
nix develop --command bash -c "solana-keygen --version"
```
**Expected Result**: Shows version information

#### 3.3 Solana Test Validator
```bash
nix develop --command bash -c "solana-test-validator --version"
```
**Expected Result**: Shows version information

### 4. Anchor CLI Tests

#### 4.1 Anchor Version
```bash
nix develop --command bash -c "anchor --version"
```
**Expected Result**: Shows `anchor-cli 0.31.1`

#### 4.2 Anchor Init (Test Project)
```bash
nix develop --command bash -c "cd /tmp && anchor init test-project --no-git && echo 'Anchor init successful'"
```
**Expected Result**: Creates new Anchor project successfully

### 5. Platform Tools Tests

#### 5.1 Cargo Build SBF Version
```bash
nix develop --command bash -c "cargo-build-sbf --version"
```
**Expected Result**: Shows version information

#### 5.2 Platform Tools Rust
```bash
nix develop --command bash -c "which rustc && rustc --print target-list | grep sbf"
```
**Expected Result**: Shows platform tools rustc and sbf-solana-solana target

### 6. Setup Script Tests

#### 6.1 Setup Solana
```bash
nix develop --command bash -c "setup-solana"
```
**Expected Result**: Creates cache directories and shows setup complete message

### 7. Complete Anchor Workflow Tests

#### 7.1 Anchor Build (SBF Compilation)
```bash
nix develop --command bash -c "cd /tmp && anchor init test-build --no-git && cd test-build && anchor build --no-idl"
```
**Expected Result**: Builds SBF programs successfully without permission errors

#### 7.2 Anchor IDL Generation
```bash
nix develop --command bash -c "cd /tmp/test-build && anchor idl build"
```
**Expected Result**: Generates IDL using nightly rust

#### 7.3 Full Anchor Build
```bash
nix develop --command bash -c "cd /tmp/test-build && anchor build"
```
**Expected Result**: Complete build including IDL generation

### 8. Template Tests

#### 8.1 Template Creation
```bash
nix flake new -t .#solana-dev /tmp/test-template
```
**Expected Result**: Creates new project from template

#### 8.2 Template Development Environment
```bash
cd /tmp/test-template && nix develop --command bash -c "echo 'Template environment loaded'"
```
**Expected Result**: Template environment loads successfully

### 9. Platform-Specific Tests

#### 9.1 macOS-Specific Environment
```bash
nix develop --command bash -c 'echo "MACOSX_DEPLOYMENT_TARGET: $MACOSX_DEPLOYMENT_TARGET"'
nix develop --command bash -c 'echo "CARGO_BUILD_TARGET: $CARGO_BUILD_TARGET"'
nix develop --command bash -c 'echo "RUSTFLAGS: $RUSTFLAGS"'
```
**Expected Result**: macOS-specific variables are set correctly

#### 9.2 Linux Compatibility Check
```bash
# On Linux system
nix develop --command bash -c 'echo "CARGO_BUILD_TARGET: $CARGO_BUILD_TARGET"'
```
**Expected Result**: Linux-specific target is set

### 10. Error Handling Tests

#### 10.1 Missing Dependencies
```bash
nix develop --command bash -c "cd /tmp/test-build && unset PLATFORM_TOOLS_DIR && anchor build"
```
**Expected Result**: Should fail gracefully with clear error message

#### 10.2 Platform Tools Access
```bash
nix develop --command bash -c "ls -la \$PLATFORM_TOOLS_DIR/rust/bin"
```
**Expected Result**: Platform tools are accessible

## Test Results Documentation

### Expected File Structure After Refactoring
```
packages/
├── default.nix          # Main packages file (imports solana-tools.nix)
├── solana-tools.nix     # All Solana-specific derivations
├── local-ic.nix         # Existing pattern
├── sp1-rust.nix         # Existing pattern
├── sp1.nix              # Existing pattern
├── valence-contracts.nix # Existing pattern
└── upload-contract/     # Existing pattern
```

### Package Structure
- `solana-node`: Combined Solana CLI + platform tools
- `anchor`: Anchor CLI built from source
- `setup-solana`: Environment setup script
- `nightly-rust`: Nightly rust for IDL generation
- `anchor-wrapper`: Smart wrapper with platform-specific environment
- `solana-tools`: Combined package with all tools

### Key Features Verified
1. **No Permission Errors**: SBF compilation works without downloading platform tools
2. **Linux Compatibility**: Platform-specific environment variables
3. **Proper Caching**: Cargo/rustup use cached platform tools
4. **IDL Generation**: Nightly rust for IDL generation
5. **Template Integration**: Solana development template works
6. **Environment Setup**: All tools accessible in development environment

## Success Criteria
- All build commands succeed
- No "Permission denied" errors during anchor build
- Platform tools are accessible and functional
- Environment variables are correctly set
- Template creates working development environment
- IDL generation works with nightly rust
- SBF compilation uses pre-installed platform tools

## Known Issues to Address
1. **Linux Hashes**: Need correct SHA256 hashes for Linux releases
2. **Platform Tools Version**: Ensure compatibility across platforms
3. **Cache Directory Permissions**: Verify cache directories are properly created

## Performance Improvements
- Pre-installed platform tools avoid redownloading
- Cached cargo/rustup configuration
- Optimized build process for SBF programs
- Faster development environment startup 