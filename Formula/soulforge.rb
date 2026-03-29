# typed: false
# frozen_string_literal: true

class Soulforge < Formula
  desc "Graph-powered code intelligence"
  homepage "https://github.com/ProxySoul/soulforge"
  version "1.1.0"
  license "BUSL-1.1"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/ProxySoul/soulforge/releases/download/v#{version}/soulforge-#{version}-darwin-arm64.tar.gz"
      sha256 "a2563c545050c33fc6cb9ef3d0822fb1991346eebceedac07c72928d6698f164"
    end
    if Hardware::CPU.intel?
      url "https://github.com/ProxySoul/soulforge/releases/download/v#{version}/soulforge-#{version}-darwin-x64.tar.gz"
      sha256 "c1f63731312d28295538f695c636222e3cf44ff755cec850c46e2f2136472e02"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/ProxySoul/soulforge/releases/download/v#{version}/soulforge-#{version}-linux-arm64.tar.gz"
      sha256 "aa40c384d0e5b669dcf0ad0ca56535bedc616d891b52c58d1fe3156db960a3ae"
    end
    if Hardware::CPU.intel?
      url "https://github.com/ProxySoul/soulforge/releases/download/v#{version}/soulforge-#{version}-linux-x64.tar.gz"
      sha256 "53fccdc7d7f76b3ff3dd28e79d616aa48dec1be2b97effb922dfd2d2a6237572"
    end
  end

  def install
    system "./install.sh", "--quiet"
    bin.install_symlink "#{Dir.home}/.soulforge/bin/soulforge"
    bin.install_symlink "#{Dir.home}/.soulforge/bin/soulforge" => "sf"
  end

  def caveats
    <<~EOS
      SoulForge installed to ~/.soulforge/
      Run 'soulforge' to start, or 'soulforge --help' for options.
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/soulforge --version")
  end
end
