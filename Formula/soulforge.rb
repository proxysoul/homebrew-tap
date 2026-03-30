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

    sf = Pathname.new(Dir.home)/".soulforge"
    sf_bin = sf/"bin"
    %w[bin installs wasm workers native opentui-assets init.lua].each { |d| rm_rf sf/d }
    sf_bin.mkpath

    cp libexec/"soulforge", sf_bin/"soulforge"
    chmod 0755, sf_bin/"soulforge"
    ln_sf sf_bin/"soulforge", sf_bin/"sf"

    %w[rg fd lazygit cli-proxy-api].each do |tool|
      cp libexec/"deps"/tool, sf_bin/tool
      chmod 0755, sf_bin/tool
    end

    nvim_dir = sf/"installs"/"nvim-bundled"
    (sf/"installs").mkpath
    cp_r libexec/"deps"/"nvim", nvim_dir
    ln_sf nvim_dir/"bin"/"nvim", sf_bin/"nvim"

    (sf/"wasm").mkpath
    (sf/"workers").mkpath
    cp Dir[libexec/"deps"/"wasm"/"*.wasm"], sf/"wasm"
    cp Dir[libexec/"deps"/"workers"/"*.js"], sf/"workers"
    cp_r libexec/"deps"/"native", sf/"native" if (libexec/"deps"/"native").exist?
    cp_r libexec/"deps"/"opentui-assets", sf/"opentui-assets"
    cp libexec/"deps"/"init.lua", sf/"init.lua"

    font_dir = OS.mac? ? Pathname.new(Dir.home)/"Library"/"Fonts" : Pathname.new(Dir.home)/".local"/"share"/"fonts"
    font_dir.mkpath
    Dir[libexec/"deps"/"nerd-fonts"/"*.ttf"].each { |f| cp f, font_dir rescue nil }

    system "xattr", "-cr", sf if OS.mac?

    config = sf/"config.json"
    config.write('{"nerdFont":true}') unless config.exist?
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
