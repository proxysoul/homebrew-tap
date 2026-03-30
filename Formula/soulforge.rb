# typed: false
# frozen_string_literal: true

class Soulforge < Formula
  desc "Graph-powered code intelligence"
  homepage "https://github.com/ProxySoul/soulforge"
  version "1.3.5"
  license "BUSL-1.1"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/ProxySoul/soulforge/releases/download/v#{version}/soulforge-#{version}-darwin-arm64.tar.gz"
      sha256 "4d600ac7e629d9699267da728ef8781d948e993757abadab22f9c5b8512fcc6a"
    end
    if Hardware::CPU.intel?
      url "https://github.com/ProxySoul/soulforge/releases/download/v#{version}/soulforge-#{version}-darwin-x64.tar.gz"
      sha256 "9f07f7a94c42293396057def1b7e850224741c953fd14d58c0a5c90b70eb314b"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/ProxySoul/soulforge/releases/download/v#{version}/soulforge-#{version}-linux-arm64.tar.gz"
      sha256 "e29bc244f590f1c044c1666411d708206712a3b6153b4d72cebad3eb78c19f8b"
    end
    if Hardware::CPU.intel?
      url "https://github.com/ProxySoul/soulforge/releases/download/v#{version}/soulforge-#{version}-linux-x64.tar.gz"
      sha256 "6f8a624927c571db1d0e409b2f36fc680dfb1be8a34e571f1d6edc107bf9221b"
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
    system "#{libexec}/install.sh", "--quiet"
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
