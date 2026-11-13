class Empryo < Formula
  desc "Multi-agent coding assistant with codebase-aware AI"
  homepage "https://empryo.com/"
  version "3.12.8-beta"
  license "BUSL-1.1"

  on_macos do
    on_arm do
      url "https://dl.empryo.com/v#{version}/empryo-#{version}-darwin-arm64.tar.gz"
      sha256 "afb5dda01687e00a71b46f27fc096e70a07b6b77f04fc21df403cf372404b4ce"
    end
    on_intel do
      url "https://dl.empryo.com/v#{version}/empryo-#{version}-darwin-x64.tar.gz"
      sha256 "616cc4a37bf9d811218c62bc4c90d732605136e96a5987e69d80128c2ad62de6"
    end
  end

  on_linux do
    on_arm do
      url "https://dl.empryo.com/v#{version}/empryo-#{version}-linux-arm64.tar.gz"
      sha256 "db9054f4f8ad0325a50ddc921204ea7cf1556f843adabb90c60474b2de40df91"
    end
    on_intel do
      if Hardware::CPU.avx2?
        url "https://dl.empryo.com/v#{version}/empryo-#{version}-linux-x64.tar.gz"
        sha256 "f9b95754cdf9170f1ef28511cc854c801c96954153821f1479c8c7433d413cb4"
      else
        url "https://dl.empryo.com/v#{version}/empryo-#{version}-linux-x64-baseline.tar.gz"
        sha256 "6958364896c00f88ade81470432487fc0942339c7d9102279d45a700424faf00"
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
