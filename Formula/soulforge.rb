# typed: false
# frozen_string_literal: true

class Soulforge < Formula
  desc "Graph-powered code intelligence"
  homepage "https://github.com/ProxySoul/soulforge"
  version "2.18.5"
  license "BUSL-1.1"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/ProxySoul/soulforge/releases/download/v#{version}/soulforge-#{version}-darwin-arm64.tar.gz"
      sha256 "10bb260a9dac345c32e6717575aff8dfd3de17e6100dae9e5de57e69f4059c45"
    end
    if Hardware::CPU.intel?
      url "https://github.com/ProxySoul/soulforge/releases/download/v#{version}/soulforge-#{version}-darwin-x64.tar.gz"
      sha256 "ee71cc79a06cd1a22940447c9b786fffb708038d0f9ec605ba06d90f02d37f3d"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/ProxySoul/soulforge/releases/download/v#{version}/soulforge-#{version}-linux-arm64.tar.gz"
      sha256 "79cf395bbab479fc4206ecd1f1a5b417962492d7309ac5a793473cefc1bddc70"
    end
    if Hardware::CPU.intel?
      # AVX detection: pre-Sandy Bridge CPUs need the baseline (SSE2-only) build.
      if Hardware::CPU.flags.include?("avx")
        url "https://github.com/ProxySoul/soulforge/releases/download/v#{version}/soulforge-#{version}-linux-x64.tar.gz"
        sha256 "23a011caf2306ebe7a337a6accbb077afa40b9b05177060a064953ab5b259fd0"
      else
        url "https://github.com/ProxySoul/soulforge/releases/download/v#{version}/soulforge-#{version}-linux-x64-baseline.tar.gz"
        sha256 "34f66883dc3d7249a6ccddee52a1e144f746f8c4a5c3a9625bed764a35105e48"
      end
    end
  end

  def install
    libexec.install Dir["*"]

    # Gzip ALL Mach-O files so Homebrew's keg_relocate can't detect them.
    # It scans by magic bytes, not extension — renaming alone doesn't work.
    # Covers deps/native (intentional bundled binaries) AND deps/workers
    # (Bun may emit hash-named .node chunks during worker bundling).
    system "gzip", libexec/"soulforge"
    Dir.glob(libexec/"deps/**/*.{node,dylib,so}").each do |f|
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
      SF_DIR="$HOME/.soulforge"
      SF="$SF_DIR/bin/soulforge"
      STAMP="$SF_DIR/.brew-version"
      EXPECTED="#{version}"

      # post_install may have failed — decompress if still gzipped
      if [ -f "$CELLAR/soulforge.gz" ] && [ ! -f "$CELLAR/soulforge" ]; then
        gunzip "$CELLAR/soulforge.gz" 2>/dev/null || true
        find "$CELLAR/deps" -name "*.gz" -exec gunzip {} + 2>/dev/null || true
        chmod +x "$CELLAR/soulforge" 2>/dev/null || true
      fi

      # Verify cellar binary exists
      if [ ! -x "$CELLAR/soulforge" ]; then
        echo "Error: SoulForge binary not found at $CELLAR/soulforge" >&2
        echo "Try: brew reinstall soulforge" >&2
        exit 1
      fi

      # Run install.sh if missing or version stamp doesn't match the keg.
      # Version stamp is authoritative — mtime checks are unreliable on
      # brew upgrade (Homebrew preserves source mtimes).
      INSTALLED=""
      [ -r "$STAMP" ] && INSTALLED="$(cat "$STAMP" 2>/dev/null || true)"
      if [ ! -x "$SF" ] || [ "$INSTALLED" != "$EXPECTED" ]; then
        echo "Setting up SoulForge $EXPECTED..." >&2
        if ! bash "$CELLAR/install.sh" --quiet; then
          echo "" >&2
          echo "Install failed. Run manually:" >&2
          echo "  bash $CELLAR/install.sh" >&2
          exit 1
        fi
        mkdir -p "$SF_DIR"
        printf '%s\n' "$EXPECTED" > "$STAMP"
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
    Dir.glob(libexec/"deps/**/*.gz").each { |f| system "gunzip", f }
    system "chmod", "+x", libexec/"soulforge"
  end

  def uninstall_postflight
    # brew uninstall removes the keg, but our first-run wrapper
    # hydrated ~/.soulforge/{bin,wasm,workers,native,opentui-assets,init.lua}
    # outside the prefix. Remove only what we own; preserve user data
    # (config.json, history.db, memory.db, sessions, installs/, presets/).
    sf = "#{Dir.home}/.soulforge"
    %w[bin wasm workers native opentui-assets].each do |sub|
      FileUtils.rm_rf("#{sf}/#{sub}")
    end
    %w[init.lua .brew-version].each do |f|
      FileUtils.rm_f("#{sf}/#{f}")
    end
  rescue StandardError => e
    opoo "Cleanup of ~/.soulforge failed: #{e.message}"
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
