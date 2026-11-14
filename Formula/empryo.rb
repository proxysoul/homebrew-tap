class Empryo < Formula
  desc "Multi-agent coding assistant with codebase-aware AI"
  homepage "https://empryo.com/"
  version "3.12.9-beta"
  license "BUSL-1.1"

  on_macos do
    on_arm do
      url "https://dl.empryo.com/v#{version}/empryo-#{version}-darwin-arm64.tar.gz"
      sha256 "0f441b6dc143ad03cfbfbab738f0e9f469563bfc2ea453ca536db3bd12b1bf6b"
    end
    on_intel do
      url "https://dl.empryo.com/v#{version}/empryo-#{version}-darwin-x64.tar.gz"
      sha256 "23d0ffc0f949006dc9b8f9a2734fbb83a4f2ea960a3c5f63ff7bb7fccd60581b"
    end
  end

  on_linux do
    on_arm do
      url "https://dl.empryo.com/v#{version}/empryo-#{version}-linux-arm64.tar.gz"
      sha256 "5bd31a09dd160d4e218c26fad457ecaf15dfeb1cbd2ce65b65d50f5a8620a98b"
    end
    on_intel do
      if Hardware::CPU.avx2?
        url "https://dl.empryo.com/v#{version}/empryo-#{version}-linux-x64.tar.gz"
        sha256 "c3c52d9440c26ba8bcf97d5e47024b601409bd2c1169086c553cf41cfd2c078e"
      else
        url "https://dl.empryo.com/v#{version}/empryo-#{version}-linux-x64-baseline.tar.gz"
        sha256 "b79fc6cd4b99844eaffb205f473e7c67a304cedd02fd52d8b93ed366ae23cfda"
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
