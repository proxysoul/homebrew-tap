class Empryo < Formula
  desc "Multi-agent coding assistant with codebase-aware AI"
  homepage "https://empryo.com/"
  version "3.12.1-beta"
  license "BUSL-1.1"

  on_macos do
    on_arm do
      url "https://dl.empryo.com/v#{version}/empryo-#{version}-darwin-arm64.tar.gz"
      sha256 "46460efe58ec1dce758e0e7388536a64e346e8feaf11411a04bb322b115531eb"
    end
    on_intel do
      url "https://dl.empryo.com/v#{version}/empryo-#{version}-darwin-x64.tar.gz"
      sha256 "b50bdda0f068b92376e0ad80a00a39a08b6f709b75357e8a5e177acf36b9bcf7"
    end
  end

  on_linux do
    on_arm do
      url "https://dl.empryo.com/v#{version}/empryo-#{version}-linux-arm64.tar.gz"
      sha256 "24a260c2a1e8be2c605a25dfc2e490a9c2653bbbeef58f415ac5a86bc6c05fa3"
    end
    on_intel do
      if Hardware::CPU.avx2?
        url "https://dl.empryo.com/v#{version}/empryo-#{version}-linux-x64.tar.gz"
        sha256 "244395dba57d20ec2e74ed327c8406ca1fa26575ade1290725f31fa4bea1a834"
      else
        url "https://dl.empryo.com/v#{version}/empryo-#{version}-linux-x64-baseline.tar.gz"
        sha256 "366fc34001dede06d0c8eb354ffd498d98fe95d6b9b2e561ae04cf467fdf7ad0"
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
