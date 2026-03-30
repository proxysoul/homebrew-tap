# typed: false
# frozen_string_literal: true

class Soulforge < Formula
  desc "Graph-powered code intelligence"
  homepage "https://github.com/ProxySoul/soulforge"
  version "1.3.6"
  license "BUSL-1.1"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/ProxySoul/soulforge/releases/download/v#{version}/soulforge-#{version}-darwin-arm64.tar.gz"
      sha256 "941e7e536bdfe3afc9698151c7d2c8316dce6f4b7f1a37d62d3b9bb8b94858a7"
    end
    if Hardware::CPU.intel?
      url "https://github.com/ProxySoul/soulforge/releases/download/v#{version}/soulforge-#{version}-darwin-x64.tar.gz"
      sha256 "f80841fa9cac4b811ce0e9fc825e47be66f45c2afc7c745e8474f2e7412c9bb3"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/ProxySoul/soulforge/releases/download/v#{version}/soulforge-#{version}-linux-arm64.tar.gz"
      sha256 "0c86283c2d15ed4e5d8d49025a0ed7d20b95ec646a83463c414264b68941185c"
    end
    if Hardware::CPU.intel?
      url "https://github.com/ProxySoul/soulforge/releases/download/v#{version}/soulforge-#{version}-linux-x64.tar.gz"
      sha256 "74c36ab07f7a04db0d2456b4ca2d3b5e0015a1979f4b5710225dce06e4afa708"
    end
  end

  livecheck do
    url :stable
    strategy :github_latest
  end

  def install
    libexec.install Dir["*"]

    # Gzip ALL Mach-O files so Homebrew's keg_relocate can't detect them.
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
    # Decompress Mach-O files hidden from keg_relocate
    system "gunzip", libexec/"soulforge.gz" if File.exist?(libexec/"soulforge.gz")
    Dir.glob(libexec/"deps/native/**/*.gz").each { |f| system "gunzip", f }
    system "chmod", "+x", libexec/"soulforge"

    # Install directly in Ruby — install.sh fails under Homebrew's system()
    # despite working perfectly when run manually (likely env/signal differences).
    sf = Pathname.new(Dir.home)/".soulforge"
    sf_bin = sf/"bin"

    # Clean previous install (preserve config, sessions, DBs)
    %w[bin installs wasm workers native opentui-assets init.lua].each do |d|
      rm_rf sf/d
    end

    sf_bin.mkpath

    # Main binary + symlink
    cp libexec/"soulforge", sf_bin/"soulforge"
    chmod 0755, sf_bin/"soulforge"
    ln_sf sf_bin/"soulforge", sf_bin/"sf"

    # CLI tools
    %w[rg fd lazygit cli-proxy-api].each do |tool|
      cp libexec/"deps"/tool, sf_bin/tool
      chmod 0755, sf_bin/tool
    end

    # Neovim
    nvim_dir = sf/"installs"/"nvim-bundled"
    (sf/"installs").mkpath
    cp_r libexec/"deps"/"nvim", nvim_dir
    ln_sf nvim_dir/"bin"/"nvim", sf_bin/"nvim"

    # Tree-sitter WASMs, workers, native addons, assets
    (sf/"wasm").mkpath
    (sf/"workers").mkpath
    cp Dir[libexec/"deps"/"wasm"/"*.wasm"], sf/"wasm"
    cp Dir[libexec/"deps"/"workers"/"*.js"], sf/"workers"
    cp_r libexec/"deps"/"native", sf/"native" if (libexec/"deps"/"native").exist?
    cp_r libexec/"deps"/"opentui-assets", sf/"opentui-assets"
    cp libexec/"deps"/"init.lua", sf/"init.lua"

    # Nerd fonts
    font_dir = if OS.mac?
      Pathname.new(Dir.home)/"Library"/"Fonts"
    else
      Pathname.new(Dir.home)/".local"/"share"/"fonts"
    end
    font_dir.mkpath
    Dir[libexec/"deps"/"nerd-fonts"/"*.ttf"].each { |f| cp f, font_dir rescue nil }

    # Remove quarantine on macOS
    system "xattr", "-cr", sf if OS.mac?

    # Ensure nerdFont config
    config = sf/"config.json"
    unless config.exist?
      config.write('{"nerdFont":true}')
    end
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
