class Snif < Formula
  desc "End-to-end TLS trust relay for devices behind NAT (SNI forwarder + CA proxy)"
  homepage "https://snif.host"
  # Built from the `make dist` tarball (ships a pre-generated ./configure, so no
  # autotools are needed at install time). Create a GitHub release tagged v1.04
  # with snif-1.04.tar.gz attached; the sha256 below is from:
  #   shasum -a 256 snif-1.04.tar.gz
  url "https://github.com/vesvault/snif/releases/download/v1.04/snif-1.04.tar.gz"
  sha256 "58639396e0c054ac0a37b9005236bc26e6d4c3b138c05335b300d6c528bf3452"
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

    # install-data-hook hardcodes /etc/snif and runs useradd + chown snif:snif —
    # both fail under Homebrew's unprivileged sandbox. Redirect the config dir
    # into Homebrew's etc and pre-create it so the hook's privileged branch is
    # skipped (its guard is `[ -d $snifd_etcdir ] || (useradd && mkdir && chown)`).
    (etc/"snif").mkpath
    system "make", "install", "snifd_etcdir=#{etc}/snif"
  end

  test do
    # snifd with an unknown/no arg prints its banner ("snifd v.<version>") and
    # exits non-zero; capture regardless of exit status.
    assert_match "snifd v.#{version}", shell_output("#{bin}/snifd -h 2>&1 || true")
  end
end
