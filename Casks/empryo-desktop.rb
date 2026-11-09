cask "empryo-desktop" do
  arch arm: "arm64", intel: "x64"

  version "3.12.7-beta"
  sha256 arm:   "97a626cf698e48e57665cb5209f178b127a975608aba344c0ef1c5a364269dde",
         intel: "0203e08e0a3b1c496551f7baecb79489478cf8574c332872702e5eb7999f2631"

  url "https://dl.empryo.com/v#{version}/Empryo-#{version}-mac-#{arch}.dmg"
  name "Empryo"
  desc "Desktop app for the Empryo multi-agent coding assistant"
  homepage "https://empryo.com/"

  livecheck do
    url "https://empryo.com/latest.json"
    strategy :json do |json|
      json["version"]
    end
  end

  auto_updates true
  depends_on macos: :ventura

  app "Empryo.app"

  zap trash: [
    "~/Library/Application Support/Empryo",
    "~/Library/Caches/dev.empryo.desktop",
    "~/Library/Caches/dev.empryo.desktop.ShipIt",
    "~/Library/HTTPStorages/dev.empryo.desktop",
    "~/Library/Logs/Empryo",
    "~/Library/Preferences/dev.empryo.desktop.plist",
    "~/Library/Saved Application State/dev.empryo.desktop.savedState",
  ]
end
