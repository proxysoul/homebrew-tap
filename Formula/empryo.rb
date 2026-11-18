class Empryo < Formula
  desc "Multi-agent coding assistant with codebase-aware AI"
  homepage "https://empryo.com/"
  version "3.13.1-beta"
  license "BUSL-1.1"

  on_macos do
    on_arm do
      url "https://dl.empryo.com/v#{version}/empryo-#{version}-darwin-arm64.tar.gz"
      sha256 "e3f432e1091d8880d110903312b076880e70ad2d0a79fe27d5dae06b4e666dee"
    end
    on_intel do
      url "https://dl.empryo.com/v#{version}/empryo-#{version}-darwin-x64.tar.gz"
      sha256 "1345d823b34f86dee0785470618ef28f2d9d2a74431a9f50dddd5ad4514be372"
    end
  end

  on_linux do
    on_arm do
      url "https://dl.empryo.com/v#{version}/empryo-#{version}-linux-arm64.tar.gz"
      sha256 "c686c6e3d15b6c49bbf542b61e9ded176bd3c0429feed944c8f06f5eb4629835"
    end
    on_intel do
      if Hardware::CPU.avx2?
        url "https://dl.empryo.com/v#{version}/empryo-#{version}-linux-x64.tar.gz"
        sha256 "ed8bb93b9d9222734225457cd636e2b4963912beee2364cedcb0792b8f469f18"
      else
        url "https://dl.empryo.com/v#{version}/empryo-#{version}-linux-x64-baseline.tar.gz"
        sha256 "4f2df1f2401f77cfca93cfece4bd905dc0deb2c055b9c063d421578ea24c8fb8"
      end
    end
  end

  def install
    libexec.install Dir["*"]
    (bin/"empryo").write <<~SH
      #!/bin/bash
      set -euo pipefail
      runtime="${HOME}/.empryo/bin/empryo"
      if [ ! -x "${runtime}" ] || [ "#{libexec}/empryo" -nt "${runtime}" ]; then
        bash "#{libexec}/install.sh" --quiet
      fi
      exec "${runtime}" "$@"
    SH
    bin.install_symlink bin/"empryo" => "em"
  end

  def caveats
    <<~EOS
      Empryo sets up its runtime in ~/.empryo the first time you run it.
      Start it with: empryo
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{libexec}/empryo --version")
  end
end
