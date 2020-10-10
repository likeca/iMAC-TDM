my add_item_to_dock(choose file of type {"APPL"} with prompt "Choose an application to add to the Dock:")

on add_item_to_dock(item_path)
   try
       get item_path as alias -- you need a POSIX path so this coerces the path in case it's an HFS path, alias, file ref, etc.        set item_path to POSIX path of item_path
   end try
   try
       tell application "Dock" to quit
   end try
   do shell script "defaults write com.apple.dock persistent-apps -array-add '<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>" & item_path & "</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>'"
   try
       tell application "Dock" to activate
   end try
end add_item_to_dock
