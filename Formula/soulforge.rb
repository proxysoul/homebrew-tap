# typed: false
# frozen_string_literal: true

class Soulforge < Formula
  desc "Graph-powered code intelligence"
  homepage "https://github.com/ProxySoul/soulforge"
  version "1.3.0"
  license "BUSL-1.1"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/ProxySoul/soulforge/releases/download/v#{version}/soulforge-#{version}-darwin-arm64.tar.gz"
      sha256 "c6846cdb92b16e31193cd34afb4b3fb72dfbe6cb658b358ad7d2710c47e17cf8"
    end
    if Hardware::CPU.intel?
      url "https://github.com/ProxySoul/soulforge/releases/download/v#{version}/soulforge-#{version}-darwin-x64.tar.gz"
      sha256 "43cd7421845bce1879d754850b1af0a9ab0f1fea535f5e0dd2bb6bfc67e18445"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/ProxySoul/soulforge/releases/download/v#{version}/soulforge-#{version}-linux-arm64.tar.gz"
      sha256 "04222cf271c5482552c12ff4cc004bf0ef92cc51a4f792e7aa38f7d74df157c7"
    end
    if Hardware::CPU.intel?
      url "https://github.com/ProxySoul/soulforge/releases/download/v#{version}/soulforge-#{version}-linux-x64.tar.gz"
      sha256 "b138c46138b3c63b16710d7e513648bf3986085a208fb9edba8790060d4c5bbf"
    end
  end

  def install
    system "./install.sh", "--quiet"
    # Create wrapper scripts instead of symlinks — symlinks to ~/.soulforge/
    # fail because brew validates targets during link phase
    (bin/"soulforge").write <<~SH
      #!/bin/bash
      exec "#{Dir.home}/.soulforge/bin/soulforge" ""
    SH
    (bin/"sf").write <<~SH
      #!/bin/bash
      exec "#{Dir.home}/.soulforge/bin/soulforge" ""
    SH
    chmod 0755, bin/"soulforge"
    chmod 0755, bin/"sf"
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
