# typed: false
# frozen_string_literal: true

class Soulforge < Formula
  desc "Graph-powered code intelligence"
  homepage "https://github.com/ProxySoul/soulforge"
  version "1.4.0"
  license "BUSL-1.1"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/ProxySoul/soulforge/releases/download/v#{version}/soulforge-#{version}-darwin-arm64.tar.gz"
      sha256 "6e3a18c5563e1b5d946578d28f7fb53711949428fb982acbb8c86f855fc60db7"
    end
    if Hardware::CPU.intel?
      url "https://github.com/ProxySoul/soulforge/releases/download/v#{version}/soulforge-#{version}-darwin-x64.tar.gz"
      sha256 "64f78f137afac29b87f371990a28f68b92075e8a27abef4087fb27d02abd9787"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/ProxySoul/soulforge/releases/download/v#{version}/soulforge-#{version}-linux-arm64.tar.gz"
      sha256 "9f2671f2150e3b297dc1820c99c2e47e8c00c3c69e2919c92eb771ab97095b36"
    end
    if Hardware::CPU.intel?
      url "https://github.com/ProxySoul/soulforge/releases/download/v#{version}/soulforge-#{version}-linux-x64.tar.gz"
      sha256 "bc86fd9812b09e277843afbd77618a67275e48f3077732b370087e0840a0515f"
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

    # First-run wrapper: macOS App Management blocks Homebrew's
    # post_install from writing to ~/.soulforge/. The wrapper runs
    # install.sh on first invocation when the USER runs Terminal
    # (which has full permissions).
    (bin/"soulforge").write <<~SH
      #!/bin/bash
      SF="$HOME/.soulforge/bin/soulforge"
      if [ ! -x "$SF" ]; then
        echo "Setting up SoulForge..." >&2
        bash "#{libexec}/install.sh" --quiet
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
    # Only decompress — actual install happens on first user run
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
