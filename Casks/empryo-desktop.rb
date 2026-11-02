cask "empryo-desktop" do
  arch arm: "arm64", intel: "x64"

  version "3.12.3-beta"
  sha256 arm:   "dd57125044ba4c1aef78371b78c4193f86531d972ca537a6361f578503856b88",
         intel: "6c61f9c58a6287fa8391c68360c9483bb388e16abefe2361b7baf73d97fbd4a6"

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
