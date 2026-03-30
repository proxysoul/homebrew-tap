# typed: false
# frozen_string_literal: true

class Soulforge < Formula
  desc "Graph-powered code intelligence"
  homepage "https://github.com/ProxySoul/soulforge"
  version "1.3.7"
  license "BUSL-1.1"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/ProxySoul/soulforge/releases/download/v#{version}/soulforge-#{version}-darwin-arm64.tar.gz"
      sha256 "a74a0570217e67472071304a5fb0a698c863050850e05a130e0e797f50a046de"
    end
    if Hardware::CPU.intel?
      url "https://github.com/ProxySoul/soulforge/releases/download/v#{version}/soulforge-#{version}-darwin-x64.tar.gz"
      sha256 "6880ba8b76f2a78fdf16dd45730ff7c850800e5961ff967fa92347b63553e80c"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/ProxySoul/soulforge/releases/download/v#{version}/soulforge-#{version}-linux-arm64.tar.gz"
      sha256 "2e7b45ee169ab23c1cb708bb9e16f2e7da9bd781d4f55d93d03ce57d93e9b97e"
    end
    if Hardware::CPU.intel?
      url "https://github.com/ProxySoul/soulforge/releases/download/v#{version}/soulforge-#{version}-linux-x64.tar.gz"
      sha256 "a7d251ace7e864414a8c6dae14d27b44edf5759b432c861935e7ae11587a368a"
    end
  end

  livecheck do
    url :stable
    strategy :github_latest
  end

  def install
    libexec.install Dir["*"]

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

    # Inline bash — both install.sh and Ruby file ops fail silently
    # under Homebrew's post_install context. bash -c works reliably.
    system "bash", "-c", <<~SH
      set -euo pipefail
      SF="$HOME/.soulforge"
      BIN="$SF/bin"
      SRC="#{libexec}"

      # macOS App Management blocks modifying files created by other processes.
      # Clear quarantine attrs first, then remove.
      [ -d "$SF" ] && xattr -cr "$SF" 2>/dev/null || true
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

      if [ "$(uname)" = "Darwin" ]; then
        mkdir -p "$HOME/Library/Fonts"
        cp "$SRC/deps/nerd-fonts/"*.ttf "$HOME/Library/Fonts/" 2>/dev/null || true
        xattr -cr "$SF" 2>/dev/null || true
      else
        FONT_DIR="$HOME/.local/share/fonts"
        mkdir -p "$FONT_DIR"
        cp "$SRC/deps/nerd-fonts/"*.ttf "$FONT_DIR/" 2>/dev/null || true
      fi

      [ ! -f "$SF/config.json" ] && echo '{"nerdFont":true}' > "$SF/config.json"
      true
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
