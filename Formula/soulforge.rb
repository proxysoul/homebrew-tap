# typed: false
# frozen_string_literal: true

class Soulforge < Formula
  desc "Graph-powered code intelligence"
  homepage "https://github.com/ProxySoul/soulforge"
  version "1.0.3"
  license "BUSL-1.1"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/ProxySoul/soulforge/releases/download/v#{version}/soulforge-#{version}-darwin-arm64.tar.gz"
      sha256 "12faebb6e86688d1a1db7e15abd3eb964594e796b647749791b33f04ee624a7c"
    end
    if Hardware::CPU.intel?
      url "https://github.com/ProxySoul/soulforge/releases/download/v#{version}/soulforge-#{version}-darwin-x64.tar.gz"
      sha256 "07ea6de54a958dd21b1d9fc49c5d8569d57d4bf36098082f82024679c8b31cff"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/ProxySoul/soulforge/releases/download/v#{version}/soulforge-#{version}-linux-arm64.tar.gz"
      sha256 "fc1e9ea2d8380c013693d6e8b02291092136119106dd8e9be1a954271f2c6993"
    end
    if Hardware::CPU.intel?
      url "https://github.com/ProxySoul/soulforge/releases/download/v#{version}/soulforge-#{version}-linux-x64.tar.gz"
      sha256 "f2b70fc3b4b91a6107271b5e06216643f71caeaba9d6fd8ea1f9e644cea7de83"
    end
  end

  def install
    system "./install.sh"
    # Symlink into Homebrew's bin so it's on PATH
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
