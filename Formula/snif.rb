class Snif < Formula
  desc "End-to-end TLS trust relay for devices behind NAT (SNI forwarder + CA proxy)"
  homepage "https://snif.host"
  # Built from the release tarball (ships a pre-generated ./configure, so no
  # autotools are needed at install time). From 1.19 snif's release workflow
  # builds it from the tag with `make dist-reproducible` and attests it; the
  # sha256 below is from the maintainers' own rebuild of the tag, and is pinned
  # only once it equals the tarball on the release:
  #   shasum -a 256 snif-1.19.tar.gz
  url "https://github.com/vesvault/snif/releases/download/v1.19/snif-1.19.tar.gz"
  sha256 "1d700d5c727a35a8f3b5045bcff818dfc87a5439802e5f33b77b5949ca07ed75"
  license "Apache-2.0"

  depends_on "openssl@3"
  uses_from_macos "curl"

  def install
    # configure probes OpenSSL with -lssl/-lcrypto (not pkg-config) and openssl@3
    # is keg-only, so point the compiler/linker at it explicitly (as in ves.rb).
    ENV.append "CPPFLAGS", "-I#{Formula["openssl@3"].opt_include}"
    ENV.append "LDFLAGS",  "-L#{Formula["openssl@3"].opt_lib}"

    system "./configure", "--prefix=#{prefix}", "--disable-dependency-tracking"
    system "make"

    # install-data-hook puts snif.conf in /etc/snif by default; redirect it into
    # Homebrew's etc. The hook makes the snif user, chowns and installs systemd
    # units only when run as root, so Homebrew's unprivileged install skips them.
    (etc/"snif").mkpath
    system "make", "install", "snifd_etcdir=#{etc}/snif"
  end

  test do
    # snifd with an unknown/no arg prints its banner ("snifd v.<version>") and
    # exits non-zero; capture regardless of exit status.
    assert_match "snifd v.#{version}", shell_output("#{bin}/snifd -h 2>&1 || true")
  end
end
