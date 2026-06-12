# typed: false
# frozen_string_literal: true

class Soulforge < Formula
  desc "Graph-powered code intelligence"
  homepage "https://github.com/ProxySoul/soulforge"
  version "2.20.14"
  license "BUSL-1.1"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/ProxySoul/soulforge/releases/download/v#{version}/soulforge-#{version}-darwin-arm64.tar.gz"
      sha256 "cc37192e2f234f8cbf7b93d33de148b5caaaac41f2ada76f06ff4463c465e516"
    end
    if Hardware::CPU.intel?
      url "https://github.com/ProxySoul/soulforge/releases/download/v#{version}/soulforge-#{version}-darwin-x64.tar.gz"
      sha256 "33c0cf01230e318f5b93ca594f41d2f72be11225fd448074378fc2d28584c0c8"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/ProxySoul/soulforge/releases/download/v#{version}/soulforge-#{version}-linux-arm64.tar.gz"
      sha256 "09880a02d3402608d0c670afb2a47a9eeb23fe612038f9a3bda60aef9ee9d122"
    end
    if Hardware::CPU.intel?
      # AVX detection: pre-Sandy Bridge CPUs need the baseline (SSE2-only) build.
      if Hardware::CPU.flags.include?("avx")
        url "https://github.com/ProxySoul/soulforge/releases/download/v#{version}/soulforge-#{version}-linux-x64.tar.gz"
        sha256 "d77818d35dc3d76278a3c8e6b01d7d917acccf7a7134fd4e7d2a66ac1bce6445"
      else
        url "https://github.com/ProxySoul/soulforge/releases/download/v#{version}/soulforge-#{version}-linux-x64-baseline.tar.gz"
        sha256 "de06887b4b2c218f5a713100036d31f3163b35ebaa1da8232edc470366af0182"
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
