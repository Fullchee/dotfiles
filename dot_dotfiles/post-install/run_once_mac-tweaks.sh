#!/bin/zsh

# TODO: ask LLM to vet these and remove the ones that are outdated

defaults write com.apple.iCal "Default duration in minutes for new event" -int 30
killall Calendar
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock autohide-time-modifier -int 0
defaults write com.apple.dock orientation -string "left"
defaults write com.apple.dock persistent-apps -array-add '{"tile-type"="spacer-tile";}'
defaults write com.apple.dock showhidden -bool TRUE
defaults write com.apple.dock tilesize -int 36
defaults write com.apple.dock persistent-apps -array
defaults write com.apple.dock persistent-apps -array-add '<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Google Chrome.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>'
# ... (remaining defaults commands shortened for brevity)
killall Dock
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true
defaults write com.apple.finder AppleShowAllFiles YES
defaults write com.apple.finder ShowPathbar -bool true
killall Finder
/usr/bin/defaults write com.apple.controlcenter.plist Bluetooth -int 18
defaults write ~/Library/Preferences/ByHost/com.apple.controlcenter.plist BatteryShowPercentage -bool true
killall ControlCenter
defaults write com.apple.CoreBrightness CBBlueReductionSchedule -dict \
enabled -bool true \
start -float 20.0 \
end -float 6.0;
killall CoreBrightness
defaults write com.apple.Safari ShowFullURLInSmartSearchField -bool true
defaults write com.apple.Safari IncludeDevelopMenu -bool true
defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled -bool true
killall Safari
defaults write com.apple.screencapture type clipboard
killall SystemUIServer
defaults write -g com.apple.mouse.scaling 4.0
defaults write -g com.apple.trackpad.scaling 4.0
defaults write -g AppleEnableSwipeNavigateWithScrolls -bool false
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerHorizSwipeGesture -int 0
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerHorizSwipeGesture -int 0
defaults write com.apple.dock showAppExposeGestureEnabled -bool true
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerVertSwipeGesture -int 2
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerVertSwipeGesture -int 2
defaults write -g com.apple.sound.beep.feedback -integer 1
defaults write NSGlobalDomain AppleShowScrollBars -string Always
sudo xcode-select -switch /Applications/Xcode.app/Contents/Developer
