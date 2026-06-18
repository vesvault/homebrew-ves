# VESvault Homebrew Tap

Homebrew formulae for [VES](https://ves.host) — recoverable end-to-end
encryption: encrypt everything without fear of losing the key.

## Install

```sh
brew tap vesvault/ves
brew install ves
```

This installs the **`ves`** command-line tool and the **libVES** C library
(headers + `libVES.pc`), built with **post-quantum** key exchange enabled
(liboqs — ML-KEM, Kyber, BIKE, FrodoKEM, …).

Verify:

```sh
ves --version
ves -Gl          # list supported Vault Key algorithms (incl. ML-KEM)
```

## Formulae

| Formula | Provides |
|---|---|
| **ves** | the `ves` CLI and the `libVES` library (with `--with-oqs`) |

## Releasing (maintainers)

The `ves` formula builds from the autotools `make dist` tarball, which bundles a
pre-generated `./configure` (no autotools needed by end users):

1. On a build host: `autoreconf -fi && ./configure && make dist` → `libves-<v>.tar.gz`
2. Create a GitHub release on `vesvault/libVES.c` tagged `v<v>` and attach the tarball.
3. Update `url` + `sha256` (`shasum -a 256 libves-<v>.tar.gz`) in `Formula/ves.rb`.

## License

Apache-2.0, matching [libVES.c](https://github.com/vesvault/libVES.c).
