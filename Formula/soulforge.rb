# typed: false
# frozen_string_literal: true

class Soulforge < Formula
  desc "Graph-powered code intelligence"
  homepage "https://github.com/ProxySoul/soulforge"
  version "1.3.3"
  license "BUSL-1.1"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/ProxySoul/soulforge/releases/download/v#{version}/soulforge-#{version}-darwin-arm64.tar.gz"
      sha256 "ecb2df9f2a9b41549a7462b02cd9523e8db9a92bc7fafc95acc3c4f7ffd47bcf"
    end
    if Hardware::CPU.intel?
      url "https://github.com/ProxySoul/soulforge/releases/download/v#{version}/soulforge-#{version}-darwin-x64.tar.gz"
      sha256 "f9eec66f11f80a48795e1155693fbb1b3dac9eed3c1c66f2d00e7e503e547878"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/ProxySoul/soulforge/releases/download/v#{version}/soulforge-#{version}-linux-arm64.tar.gz"
      sha256 "f582f52b8361b750982169da9a9296ab91d4f6fc22a756f16e5d2742838622ee"
    end
    if Hardware::CPU.intel?
      url "https://github.com/ProxySoul/soulforge/releases/download/v#{version}/soulforge-#{version}-linux-x64.tar.gz"
      sha256 "710ba65971bd5ddf5847055989c2619b2504e3c4c9168d3300a7f6340930ff16"
    end
  end

  livecheck do
    url :stable
    strategy :github_latest
  end

  def install
    # Stage everything in libexec
    libexec.install Dir["*"]

    # Gzip ALL Mach-O files so Homebrew's keg_relocate can't detect them.
    # It scans by magic bytes, not extension — renaming alone doesn't work.
    # The compiled binary and native addons (.node, .dylib, .so) all have
    # @rpath or internal headers that Homebrew tries to rewrite, corrupting them.
    system "gzip", libexec/"soulforge"
    Dir.glob(libexec/"deps/native/**/*.{node,dylib,so}").each do |f|
      system "gzip", f
    end

    # Wrapper scripts — $HOME/$@ expand at runtime
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
    # Decompress Mach-O files hidden from Homebrew's keg_relocate
    system "gunzip", libexec/"soulforge.gz" if File.exist?(libexec/"soulforge.gz")
    Dir.glob(libexec/"deps/native/**/*.gz").each do |f|
      system "gunzip", f
    end
    system "chmod", "+x", libexec/"soulforge"
    # Run install.sh to copy everything to ~/.soulforge/
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
