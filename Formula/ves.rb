class Ves < Formula
  desc "Recoverable end-to-end encryption CLI and C library"
  homepage "https://ves.host"
  # Built from the `make dist` tarball (ships a pre-generated ./configure, so
  # no autotools are needed at install time). Create a GitHub release tagged
  # v1.35 with libves-1.35.tar.gz attached; the sha256 below is from:
  #   shasum -a 256 libves-1.35.tar.gz
  url "https://github.com/vesvault/libVES.c/releases/download/v1.35/libves-1.35.tar.gz"
  sha256 "520f0aadc6f7b767607d9015f55ff0e2b3811a544770af8387e317b42bedf521"
  license "Apache-2.0"

  # Post-quantum key exchange is a required feature of these packages.
  depends_on "liboqs"
  depends_on "openssl@3"
  uses_from_macos "curl"

  def install
    # configure probes OpenSSL with -lcrypto (not pkg-config), and openssl@3 is
    # keg-only, so point the compiler/linker at it explicitly. liboqs and curl
    # are made discoverable by Homebrew's superenv via the dependencies above.
    ENV.append "CPPFLAGS", "-I#{Formula["openssl@3"].opt_include}"
    ENV.append "LDFLAGS",  "-L#{Formula["openssl@3"].opt_lib}"

    system "./configure", "--prefix=#{prefix}",
                          "--with-oqs",
                          "--disable-dependency-tracking"
    system "make"
    system "make", "install"
  end

  test do
    # --version prints "VES CLI <x> (libVES.c 1.35) ..."
    assert_match "1.35", shell_output("#{bin}/ves --version")

    # -Gl lists the compiled-in Vault Key algorithms; ML-KEM proves the
    # post-quantum (liboqs) suite is linked in.
    algos = shell_output("#{bin}/ves -Gl")
    assert_match "RSA", algos
    assert_match "ML-KEM", algos
  end
end
