cask "empryo-desktop" do
  arch arm: "arm64", intel: "x64"

  version "3.13.1-beta"
  sha256 arm:   "e6ebc9651bf4bec829c21e374b1f5c219eb768d9b0b6f2d2624072b1e55b591e",
         intel: "37f171568bdcf55b626d2f3edb8c07d2cdca98668364f82891892165dd1a501d"

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
