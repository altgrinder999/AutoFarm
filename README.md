# ⚔️ Bridge Duels AutoFarm

![Version](https://img.shields.io/badge/version-v1.1-blue)
![Status](https://img.shields.io/badge/status-beta-orange)
![Made by](https://img.shields.io/badge/made%20by-AltFarmer-purple)

Modern autofarm script for Bridge Duels with Discord webhooks integration and glassmorphism UI.

## ✨ Features

- 🏆 Automatic win farming
- 📊 Stats tracking (saves between sessions)
- 💬 Discord webhook notifications
- 🎨 Modern glassmorphism UI
- ⚡ Smooth animations
- 💾 Data persistence
- 📍 Place ID detection (Lobby/In-Game)

## 📦 Installation

### Quick Load (Recommended)
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/altgrinder999/AutoFarm/main/script.lua"))()
```

### Manual Install
1. Download `script.lua`
2. Paste in your executor
3. Execute in Bridge Duels

## ⚙️ Configuration

**Webhook Setup (Optional):**
1. Create a Discord webhook
2. Edit line 20 in `script.lua`:
```lua
local webhookURL = "YOUR_WEBHOOK_URL_HERE"
```

## 🎮 How to Use

1. Join Bridge Duels (BedWars game)
2. Execute the script
3. Script will automatically:
   - ⏳ Wait 20 seconds
   - ⚔️ Touch enemy touchdown zone
   - 🔄 Rejoin and repeat
4. Track your wins in the modern UI!

## 🎨 UI Features

- **Modern Design:** Glassmorphism effects with blur
- **Stats Cards:** Real-time wins and runtime tracking
- **Smooth Animations:** Tweened transitions
- **Hidden Username:** Privacy mode by default
- **Minimizable:** Close to a small circular button

## 📸 Screenshots

*Coming soon!*

## ⚠️ Disclaimer

This script is for **educational purposes only**. Use at your own risk. I am not responsible for any bans or issues.

## 📝 Changelog

### v1.1 (Beta) - Current
- ✅ Complete UI redesign with glassmorphism
- ✅ Smooth animations and transitions
- ✅ Discord webhook integration
- ✅ Place ID detection (Lobby/In-Game)
- ✅ Stats cards for Wins and Runtime
- ✅ Minimizable interface

### v1.0
- Initial release
- Basic autofarm functionality

## 🐛 Known Issues

- Script may not work if executor doesn't support `firetouchinterest`
- Requires executor with `writefile`/`readfile` for data saving

## 💡 Troubleshooting

**Script not working?**
- Make sure you're in Bridge Duels (BedWars game)
- Check if your executor supports required functions
- Try rejoining the game

**Webhook not sending?**
- Verify your webhook URL is correct
- Check if your executor supports HTTP requests

## 👨‍💻 Author

**AltGrinder**
- GitHub: [@altgrinder999](https://github.com/altgrinder999)

## 📄 License

MIT License - Feel free to modify and distribute!

---

⭐ **Star this repository if you found it helpful!**

Made with ❤️ by altgrinder
