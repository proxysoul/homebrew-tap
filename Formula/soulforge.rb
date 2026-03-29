# typed: false
# frozen_string_literal: true

class Soulforge < Formula
  desc "Graph-powered code intelligence"
  homepage "https://github.com/ProxySoul/soulforge"
  version "1.0.0"
  license "BUSL-1.1"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/ProxySoul/soulforge/releases/download/v#{version}/soulforge-#{version}-darwin-arm64.tar.gz"
      sha256 "5b5b7387ba379f6b74a2b3201cd06c0a15cc6a5089fe3f2cb96c588ccf2cbefa"
    end
    if Hardware::CPU.intel?
      url "https://github.com/ProxySoul/soulforge/releases/download/v#{version}/soulforge-#{version}-darwin-x64.tar.gz"
      sha256 "01016425f5c04132a6157bb9ac3f139c198f0dce39062e8b40ec7328b1e76f2b"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/ProxySoul/soulforge/releases/download/v#{version}/soulforge-#{version}-linux-arm64.tar.gz"
      sha256 "64613b5a0c8ffaf6ea7d0f58e66a240fff9bf9ed1976ed14e397c0a75799d59e"
    end
    if Hardware::CPU.intel?
      url "https://github.com/ProxySoul/soulforge/releases/download/v#{version}/soulforge-#{version}-linux-x64.tar.gz"
      sha256 "97a45630ca45ada02d17c0f0c51d441bc7c3670d29a16c77b473d5b4da80533f"
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
