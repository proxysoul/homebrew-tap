# typed: false
# frozen_string_literal: true

class Soulforge < Formula
  desc "Graph-powered code intelligence"
  homepage "https://github.com/ProxySoul/soulforge"
  version "1.9.0"
  license "BUSL-1.1"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/ProxySoul/soulforge/releases/download/v#{version}/soulforge-#{version}-darwin-arm64.tar.gz"
      sha256 "38ed15f30a80e99c14c6e86c60bf80efbc41044010b287986970c99177004711"
    end
    if Hardware::CPU.intel?
      url "https://github.com/ProxySoul/soulforge/releases/download/v#{version}/soulforge-#{version}-darwin-x64.tar.gz"
      sha256 "6a80efc5ffa17ee80070ef981ea29016c51c87bfdfb19bf4693556a4bd297edf"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/ProxySoul/soulforge/releases/download/v#{version}/soulforge-#{version}-linux-arm64.tar.gz"
      sha256 "a537980fa622a82946fae705064427958b11e6f64af3d8b80ee2580c6acfcf78"
    end
    if Hardware::CPU.intel?
      url "https://github.com/ProxySoul/soulforge/releases/download/v#{version}/soulforge-#{version}-linux-x64.tar.gz"
      sha256 "a27f9f897c4426082469161209dfbd33b2ca85a2f9733727cff5420ea568ec53"
    end
  end

  def install
    libexec.install Dir["*"]

    # Gzip ALL Mach-O files so Homebrew's keg_relocate can't detect them.
    # It scans by magic bytes, not extension — renaming alone doesn't work.
    system "gzip", libexec/"soulforge"
    Dir.glob(libexec/"deps/native/**/*.{node,dylib,so}").each do |f|
      system "gzip", f
    end

    # First-run wrapper: macOS App Management blocks Homebrew's
    # post_install from writing to ~/.soulforge/. The wrapper runs
    # install.sh on first invocation when the USER runs Terminal
    # (which has full permissions).
    (bin/"soulforge").write <<~SH
      #!/bin/bash
      set -euo pipefail
      CELLAR="#{libexec}"
      SF="$HOME/.soulforge/bin/soulforge"

      # post_install may have failed — decompress if still gzipped
      if [ -f "$CELLAR/soulforge.gz" ] && [ ! -f "$CELLAR/soulforge" ]; then
        gunzip "$CELLAR/soulforge.gz" 2>/dev/null || true
        find "$CELLAR/deps/native" -name "*.gz" -exec gunzip {} \; 2>/dev/null || true
        chmod +x "$CELLAR/soulforge" 2>/dev/null || true
      fi

      # Verify cellar binary exists
      if [ ! -x "$CELLAR/soulforge" ]; then
        echo "Error: SoulForge binary not found at $CELLAR/soulforge" >&2
        echo "Try: brew reinstall soulforge" >&2
        exit 1
      fi

      # Run install.sh if missing or outdated
      if [ ! -x "$SF" ] || [ "$CELLAR/soulforge" -nt "$SF" ]; then
        echo "Setting up SoulForge..." >&2
        if ! bash "$CELLAR/install.sh" --quiet; then
          echo "" >&2
          echo "Install failed. Run manually:" >&2
          echo "  bash $CELLAR/install.sh" >&2
          exit 1
        fi
      fi

      exec "$SF" "$@"
    SH
    (bin/"sf").write <<~SH
      #!/bin/bash
      exec "$(dirname "$0")/soulforge" "$@"
    SH
    chmod 0755, bin/"soulforge"
    chmod 0755, bin/"sf"
  end

  def post_install
    # Decompress — if this fails, the wrapper handles it on first run
    system "gunzip", libexec/"soulforge.gz" if File.exist?(libexec/"soulforge.gz")
    Dir.glob(libexec/"deps/native/**/*.gz").each { |f| system "gunzip", f }
    system "chmod", "+x", libexec/"soulforge"
  end

  def caveats
    <<~EOS
      SoulForge installed to ~/.soulforge/
      Run 'soulforge' or 'sf' to start.
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/soulforge --version")
  end
end
