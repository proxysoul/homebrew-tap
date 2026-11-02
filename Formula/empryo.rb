class Empryo < Formula
  desc "Multi-agent coding assistant with codebase-aware AI"
  homepage "https://empryo.com/"
  version "3.12.3-beta"
  license "BUSL-1.1"

  on_macos do
    on_arm do
      url "https://dl.empryo.com/v#{version}/empryo-#{version}-darwin-arm64.tar.gz"
      sha256 "c0d8071e1c55482fba0e9400e66646e242ce13c1a545220de4b7fb566694c56a"
    end
    on_intel do
      url "https://dl.empryo.com/v#{version}/empryo-#{version}-darwin-x64.tar.gz"
      sha256 "dc9dbd12c30344e7f46816bd39e10e14a69b700d4222b042c974c94303d99505"
    end
  end

  on_linux do
    on_arm do
      url "https://dl.empryo.com/v#{version}/empryo-#{version}-linux-arm64.tar.gz"
      sha256 "1a9142c170704acd2ccaebfd6c1a1d997ebecd80f90b78537d55631fe0f9cf6f"
    end
    on_intel do
      if Hardware::CPU.avx2?
        url "https://dl.empryo.com/v#{version}/empryo-#{version}-linux-x64.tar.gz"
        sha256 "627a9dcac6e280e843e4e30edf2673316dd7fc11cb8cf4169abbe6a37946d1ca"
      else
        url "https://dl.empryo.com/v#{version}/empryo-#{version}-linux-x64-baseline.tar.gz"
        sha256 "aabb5f439215971dd6509b83fc1b676c63ac6b3851d23c23d108894065c9addf"
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
