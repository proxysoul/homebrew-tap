# typed: false
# frozen_string_literal: true

class Soulforge < Formula
  desc "Graph-powered code intelligence"
  homepage "https://github.com/ProxySoul/soulforge"
  version "1.3.1"
  license "BUSL-1.1"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/ProxySoul/soulforge/releases/download/v#{version}/soulforge-#{version}-darwin-arm64.tar.gz"
      sha256 "91ef9c566836c6317f1e394764e8d259683d359f11279d44de65012e0b78ff70"
    end
    if Hardware::CPU.intel?
      url "https://github.com/ProxySoul/soulforge/releases/download/v#{version}/soulforge-#{version}-darwin-x64.tar.gz"
      sha256 "572256fd0d27aba9ba061ff62ed8a13fd24ec35e86b248e658edc5d329010b8d"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/ProxySoul/soulforge/releases/download/v#{version}/soulforge-#{version}-linux-arm64.tar.gz"
      sha256 "8d6a13e7583642f42627ae01bc041def8c8d49c4e4a4861a72990dd8c618b358"
    end
    if Hardware::CPU.intel?
      url "https://github.com/ProxySoul/soulforge/releases/download/v#{version}/soulforge-#{version}-linux-x64.tar.gz"
      sha256 "42760d7a5278870e8e23d6ea6e7a28b39b1ac08ce00dc2fe05d61db1adf3f342"
    end
  end

  def install
    # Stage everything in libexec — install phase runs in a sandbox
    # where HOME is a temp dir, so we can't write to ~/.soulforge/ here
    libexec.install Dir["*"]

    # Wrapper scripts use /home/runner (shell expansion at runtime, not Ruby
    # interpolation at install time) so they resolve to the real home dir
    (bin/"soulforge").write <<~SH
      #!/bin/bash
      exec "/home/runner/.soulforge/bin/soulforge" ""
    SH
    (bin/"sf").write <<~SH
      #!/bin/bash
      exec "/home/runner/.soulforge/bin/soulforge" ""
    SH
    chmod 0755, bin/"soulforge"
    chmod 0755, bin/"sf"
  end

  def post_install
    # post_install runs outside the sandbox with the real HOME
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
