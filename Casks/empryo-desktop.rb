cask "empryo-desktop" do
  arch arm: "arm64", intel: "x64"

  version "3.12.9-beta"
  sha256 arm:   "7e985f67dc7afa70d699af8bb2e9d0bd3a9000da5fc37304831fc2250f7b5b8c",
         intel: "d4b7565c9f082e72c79bd32d65846facc2ed5a12423c8456937e24b1b8add5dc"

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
