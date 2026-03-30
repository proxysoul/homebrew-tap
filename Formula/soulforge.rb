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

    # Rename native Mach-O addons (.node, .dylib, .so) so Homebrew's
    # keg_relocate pass doesn't try to rewrite their dylib IDs/rpaths.
    # The header padding in these files is too small for Homebrew's
    # absolute paths, causing "Updated load commands do not fit" errors.
    # Restored in post_install before running install.sh.
    Dir.glob(libexec/"deps/native/**/*.{node,dylib,so}").each do |f|
      File.rename(f, "#{f}.brew-hide")
    end

    # Wrapper scripts — $HOME expands at runtime, not install time
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
    # Restore native addons hidden from Homebrew's dylib relinking
    Dir.glob(libexec/"deps/native/**/*.brew-hide").each do |f|
      File.rename(f, f.sub(/\.brew-hide$/, ""))
    end
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
