cask "empryo-desktop" do
  arch arm: "arm64", intel: "x64"

  version "3.12.8-beta"
  sha256 arm:   "255d6a4c885040bdb0c61e781b0a1d7d66951d26ac438c7a59cec167a9a5cc30",
         intel: "0f2ab18a6168a3de520127000ec90d6836e41547d61b9fbf924f7781a0aaaa7d"

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
