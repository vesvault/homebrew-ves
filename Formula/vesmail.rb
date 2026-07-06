class Vesmail < Formula
  desc "Transparent IMAP/SMTP proxy that end-to-end encrypts email"
  homepage "https://vesmail.email"
  # Built from the `make dist` tarball (ships a pre-generated ./configure, so
  # no autotools are needed at install time). Create a GitHub release tagged
  # v1.68 with vesmail-1.68.tar.gz attached; the sha256 below is from:
  #   shasum -a 256 vesmail-1.68.tar.gz
  url "https://github.com/vesvault/VESmail/releases/download/v1.68/vesmail-1.68.tar.gz"
  sha256 "8f09510594737597e77f44eba7226fff88636ce0bf062d3872e0266f860285e8"
  license "Apache-2.0"

  # libVES (the `ves` formula) brings in liboqs and the VES key exchange;
  # VESmail links -lVES -lssl -lcrypto -lcurl directly.
  depends_on "openssl@3"
  depends_on "vesvault/ves/ves"
  uses_from_macos "curl"

  def install
    # configure probes OpenSSL with -lcrypto (not pkg-config), and openssl@3 is
    # keg-only, so point the compiler/linker at it explicitly. libVES and curl
    # are made discoverable by Homebrew's superenv via the dependencies above.
    ENV.append "CPPFLAGS", "-I#{Formula["openssl@3"].opt_include}"
    ENV.append "LDFLAGS",  "-L#{Formula["openssl@3"].opt_lib}"

    system "./configure", "--prefix=#{prefix}",
                          "--disable-dependency-tracking"
    system "make"
    system "make", "install"
  end

  test do
    # --version prints "VESmail 1.68 (c) 2020-2026 VESvault Corp"
    assert_match version.to_s, shell_output("#{bin}/vesmail --version")
  end
end
