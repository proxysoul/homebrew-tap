# typed: false
# frozen_string_literal: true

class Soulforge < Formula
  desc "Graph-powered code intelligence"
  homepage "https://github.com/ProxySoul/soulforge"
  version "1.3.2"
  license "BUSL-1.1"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/ProxySoul/soulforge/releases/download/v#{version}/soulforge-#{version}-darwin-arm64.tar.gz"
      sha256 "f3bfcc478a11a407185094d8cc734dd81f29b0729fe9f441d5a038cd530d61bd"
    end
    if Hardware::CPU.intel?
      url "https://github.com/ProxySoul/soulforge/releases/download/v#{version}/soulforge-#{version}-darwin-x64.tar.gz"
      sha256 "b73df7d1dc46e61dc38276221cc725f09a4cfc1fe281b9fdb7e76bb470e9500a"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/ProxySoul/soulforge/releases/download/v#{version}/soulforge-#{version}-linux-arm64.tar.gz"
      sha256 "29f029438e455ec27e6483a2d336a7dde278772e16c81afb7e96cbe1568570a5"
    end
    if Hardware::CPU.intel?
      url "https://github.com/ProxySoul/soulforge/releases/download/v#{version}/soulforge-#{version}-linux-x64.tar.gz"
      sha256 "233144b78002e85d829d249a749bc38f9d7b914a8a14cda585d2330a373491aa"
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
