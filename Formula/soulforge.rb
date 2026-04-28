# typed: false
# frozen_string_literal: true

class Soulforge < Formula
  desc "Graph-powered code intelligence"
  homepage "https://github.com/ProxySoul/soulforge"
  version "2.14.1"
  license "BUSL-1.1"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/ProxySoul/soulforge/releases/download/v#{version}/soulforge-#{version}-darwin-arm64.tar.gz"
      sha256 "0e1c8ee8248f15b36381c0a3e4e5f97144efab9c89a22a17f91f1cb78b596d29"
    end
    if Hardware::CPU.intel?
      url "https://github.com/ProxySoul/soulforge/releases/download/v#{version}/soulforge-#{version}-darwin-x64.tar.gz"
      sha256 "067ccc828d823253fab7725e8a79d3b9a60e94c8888adf4fa3071273a7c2c31a"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/ProxySoul/soulforge/releases/download/v#{version}/soulforge-#{version}-linux-arm64.tar.gz"
      sha256 "6585895428474d3eaab401692313156258cc3d9417e169bfa5d5863b66b937a7"
    end
    if Hardware::CPU.intel?
      # Use baseline build (no AVX) for pre-Sandy Bridge CPUs
      if 4.strip.to_i > 0
        url "https://github.com/ProxySoul/soulforge/releases/download/v#{version}/soulforge-#{version}-linux-x64.tar.gz"
        sha256 "374851f4787a33012ef9e9f66517149039abc880b26545cdf0a7d800ac18746f"
      else
        url "https://github.com/ProxySoul/soulforge/releases/download/v#{version}/soulforge-#{version}-linux-x64-baseline.tar.gz"
        sha256 "7c25f5f883217b51f7d1c45e7a9d28e3f3d15c9f2c4864deeefdda080fc23558"
      end
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
