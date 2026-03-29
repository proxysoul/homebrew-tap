# typed: false
# frozen_string_literal: true

class Soulforge < Formula
  desc "Graph-powered code intelligence"
  homepage "https://github.com/ProxySoul/soulforge"
  version "1.2.0"
  license "BUSL-1.1"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/ProxySoul/soulforge/releases/download/v#{version}/soulforge-#{version}-darwin-arm64.tar.gz"
      sha256 "4b9999f5daabc9a45f63088fd2baabeec07b4a3b62e4ca25b231484f9f8482a2"
    end
    if Hardware::CPU.intel?
      url "https://github.com/ProxySoul/soulforge/releases/download/v#{version}/soulforge-#{version}-darwin-x64.tar.gz"
      sha256 "45d8fdffcaa62f1a3bf142dcd501865157ff0bdf668d3f71c9a82593d73a57c2"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/ProxySoul/soulforge/releases/download/v#{version}/soulforge-#{version}-linux-arm64.tar.gz"
      sha256 "1f5967e6ad069111d55d64a9406b4e4ed213661d9de253a6ad06239123f27f79"
    end
    if Hardware::CPU.intel?
      url "https://github.com/ProxySoul/soulforge/releases/download/v#{version}/soulforge-#{version}-linux-x64.tar.gz"
      sha256 "63bb02a4b8176978ddc6d66d4eab621c9abc327521e11e348e4cd21f6885c028"
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
