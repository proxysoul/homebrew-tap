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

  livecheck do
    url :stable
    strategy :github_latest
  end

  def install
    libexec.install Dir["*"]

    # Gzip Mach-O files to hide from Homebrew's keg_relocate
    system "gzip", libexec/"soulforge"
    Dir.glob(libexec/"deps/native/**/*.{node,dylib,so}").each do |f|
      system "gzip", f
    end

    # Wrapper scripts that install on first run.
    # macOS App Management blocks Homebrew's post_install from writing to
    # ~/.soulforge/ (created by a different process). Moving the install to
    # first user-run avoids this — Terminal has the user's full permissions.
    (bin/"soulforge").write <<~SH
      #!/bin/bash
      CELLAR="$(cd "$(dirname "$0")/../libexec" 2>/dev/null && pwd)"
      SF="$HOME/.soulforge/bin/soulforge"
      if [ ! -x "$SF" ]; then
        echo "Setting up SoulForge..." >&2
        # Decompress if needed (first install or reinstall)
        [ -f "$CELLAR/soulforge.gz" ] && gunzip "$CELLAR/soulforge.gz" && chmod +x "$CELLAR/soulforge"
        find "$CELLAR/deps/native" -name "*.gz" -exec gunzip {} \\; 2>/dev/null
        bash "$CELLAR/install.sh" --quiet
      fi
      exec "$SF" "$@"
    SH
    (bin/"sf").write <<~SH
      #!/bin/bash
      exec "$(dirname "$0")/soulforge" "$@"
    SH
    chmod 0755, bin/"soulforge"
    chmod 0755, bin/"sf"
  end

  def post_install
    # Decompress Mach-O files so they're ready for install.sh on first run
    system "gunzip", libexec/"soulforge.gz" if File.exist?(libexec/"soulforge.gz")
    Dir.glob(libexec/"deps/native/**/*.gz").each { |f| system "gunzip", f }
    system "chmod", "+x", libexec/"soulforge"
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
