# typed: false
# frozen_string_literal: true

class Soulforge < Formula
  desc "Graph-powered code intelligence"
  homepage "https://github.com/ProxySoul/soulforge"
  version "1.3.8"
  license "BUSL-1.1"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/ProxySoul/soulforge/releases/download/v#{version}/soulforge-#{version}-darwin-arm64.tar.gz"
      sha256 "0c53663a7a3f46a71c81272494a8dd40ba852f3fa6f12a5b17721239f16aad49"
    end
    if Hardware::CPU.intel?
      url "https://github.com/ProxySoul/soulforge/releases/download/v#{version}/soulforge-#{version}-darwin-x64.tar.gz"
      sha256 "2ab75c5d320d1692d25bfbd23c2dbe1e5a27512eb20dea38c3bc260a2cfbbce2"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/ProxySoul/soulforge/releases/download/v#{version}/soulforge-#{version}-linux-arm64.tar.gz"
      sha256 "58b97e28fdb4de0558df9668216fca25cc90a01891fb1741866ad67348cb1a82"
    end
    if Hardware::CPU.intel?
      url "https://github.com/ProxySoul/soulforge/releases/download/v#{version}/soulforge-#{version}-linux-x64.tar.gz"
      sha256 "15fcca769504630cd392029dc404ae9935033cc828995cf86a57e862a5d69012"
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

    (bin/"soulforge").write <<~SH
      #!/bin/bash
      exec "$HOME/.soulforge/bin/soulforge" "$@"
    SH
    (bin/"sf").write <<~SH
      #!/bin/bash
      exec "$HOME/.soulforge/bin/soulforge" "$@"
    SH
    chmod 0755, bin/"soulforge"
    chmod 0755, bin/"sf"
  end

  def post_install
    system "gunzip", libexec/"soulforge.gz" if File.exist?(libexec/"soulforge.gz")
    Dir.glob(libexec/"deps/native/**/*.gz").each { |f| system "gunzip", f }
    system "chmod", "+x", libexec/"soulforge"

    # Use inline bash instead of Ruby file ops or install.sh —
    # both fail silently under Homebrew's post_install context.
    system "bash", "-c", <<~SH
      set -euo pipefail
      SF="$HOME/.soulforge"
      BIN="$SF/bin"
      SRC="#{libexec}"

      rm -rf "$SF/bin" "$SF/installs" "$SF/wasm" "$SF/workers" "$SF/native" "$SF/opentui-assets" "$SF/init.lua" 2>/dev/null || true
      mkdir -p "$BIN"

      cp "$SRC/soulforge" "$BIN/soulforge"
      chmod +x "$BIN/soulforge"
      ln -sf "$BIN/soulforge" "$BIN/sf"

      for tool in rg fd lazygit cli-proxy-api; do
        cp "$SRC/deps/$tool" "$BIN/$tool"
        chmod +x "$BIN/$tool"
      done

      mkdir -p "$SF/installs"
      cp -r "$SRC/deps/nvim" "$SF/installs/nvim-bundled"
      ln -sf "$SF/installs/nvim-bundled/bin/nvim" "$BIN/nvim"

      mkdir -p "$SF/wasm" "$SF/workers"
      cp "$SRC/deps/wasm/"*.wasm "$SF/wasm/"
      cp "$SRC/deps/workers/"*.js "$SF/workers/"
      [ -d "$SRC/deps/native" ] && cp -r "$SRC/deps/native" "$SF/native"
      rm -rf "$SF/opentui-assets"
      cp -r "$SRC/deps/opentui-assets" "$SF/opentui-assets"
      cp "$SRC/deps/init.lua" "$SF/init.lua"

      FONT_DIR="$HOME/Library/Fonts"
      [ "Linux" != "Darwin" ] && FONT_DIR="$HOME/.local/share/fonts"
      mkdir -p "$FONT_DIR"
      cp "$SRC/deps/nerd-fonts/"*.ttf "$FONT_DIR/" 2>/dev/null || true

      [ "Linux" = "Darwin" ] && xattr -cr "$SF" 2>/dev/null || true

      [ ! -f "$SF/config.json" ] && echo '{"nerdFont":true}' > "$SF/config.json"
    SH
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
