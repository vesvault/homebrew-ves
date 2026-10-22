class Snif < Formula
  desc "End-to-end TLS trust relay for devices behind NAT (SNI forwarder + CA proxy)"
  homepage "https://snif.host"
  # Built from the `make dist` tarball (ships a pre-generated ./configure, so no
  # autotools are needed at install time). Create a GitHub release tagged v1.08
  # with snif-1.08.tar.gz attached; the sha256 below is from:
  #   shasum -a 256 snif-1.08.tar.gz
  url "https://github.com/vesvault/snif/releases/download/v1.08/snif-1.08.tar.gz"
  sha256 "9481a30f78b2154f39a61083afa5b924726ffed75383d5d501f5ab7452d967e1"
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
