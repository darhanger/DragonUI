# 🐉 DragonUI for 3.3.5a

<div align="center">

![Interface Version](https://img.shields.io/badge/Interface-30300-blue)
![WoW Version](https://img.shields.io/badge/WoW-3.3.5a-orange)
![Status](https://img.shields.io/badge/Status-Work%20in%20Progress-yellow)

**Bringing the retail WoW look to 3.3.5a, inspired by Dragonflight UI Classic**

Created and maintained by **Neticsoul**, with community contributions.

</div>

---

## 📌 Project Status

DragonUI is still in active development. Expect some bugs — feel free to report them.

## ✨ Features

- 🧩 Modular system — enable or disable any major UI component independently.
- 🎯 Custom action bars with configurable layouts, visibility rules, fat bar mode, and retail-style presentation.
- 💚 Reworked unit frames for player, target, focus, party, pet, boss, ToT and ToF — with elite decorations on player frame.
- 🎒 Auto-sort for bags and bank, plus integrated Combuctor for unified inventory browsing.
- 🗺️ Custom minimap, micro menu, cast bars, buff frame, loot roll, quest tracker, tooltips, and editor mode.
- 🌙 Dark mode to tone down the default UI colors.
- ⌨️ Hover-and-press keybinding workflow on supported buttons.
- ⚙️ In-game configuration panel with profile support and per-module controls.
- 🌍 Localization support for multiple client languages.

## 📦 Installation

1. Download the latest release archive.
2. Extract the archive.
3. Copy `DragonUI` and `DragonUI_Options` into your client's `Interface\AddOns\` folder.
4. Check that the addon is active from the AddOns button on the character selection screen.

> 💡 **Clean reset:** delete `WTF\Account\<AccountName>\` to wipe all saved settings for all addons on that account.

## 🔧 Commands

| Command | Action |
|---|---|
| `/dragonui` or `/dui` | Opens the configuration UI |
| `/dragonui edit` | Toggles editor mode |
| `/dragonui help` | Shows available commands |

## ⚠️ Known Issues

- Party and raid scenarios still need broader real-world validation.
- Some compatibility paths with third-party addons may still require manual module disablement or extra cleanup.
- Found a bug or something weird? Report it in the [issues](https://github.com/NeticSoul/DragonUI/issues).

## 📜 Legal And Licensing Summary

- DragonUI code is released under the [MIT License](LICENSE).
- Bundled third-party components have their own licenses — see [`THIRD_PARTY_NOTICES.md`](THIRD_PARTY_NOTICES.md) and [`LICENSES/`](LICENSES/).

## 🙏 Credits And References

DragonUI combines original work with adapted ideas, ports, and implementation references from multiple addon authors and projects.

- [Dragonflight UI (Classic)](https://github.com/Karl-HeinzSchneider) by Karl-HeinzSchneider
- [pretty_actionbar and pretty_minimap](https://github.com/s0h2x) by s0h2x
- [RetailUI](https://github.com/a3st) by a3st (Dmitriy)
- [KPack](https://github.com/bkader/KPack) by bkader
- [Combuctor](https://github.com/Jaliborc) by Jaliborc
- [BankStack](https://github.com/kemayo/) by kemayo
- [UnitFrameLayers](https://github.com/RomanSpector) by RomanSpector
- [oGlow](https://github.com/haste) by haste
- [ElvUI-WotLK](https://github.com/ElvUI-WotLK/) as a pattern reference in selected areas.

## ☕ Support The Project

DragonUI will remain free to use.

Support is voluntary and goes towards maintenance, testing, and continued development.

- ☕ Buy Me a Coffee: pending final public link
- 🪙 Bitcoin: `bc1q8yavz8857lzdfttas584892gf82y0u3wdfjz0a`

## 📎 Disclaimer

DragonUI is an unofficial, fan-made addon for World of Warcraft.

This project is non-commercial and non-profit. It is developed and maintained by members of the community, with no financial compensation involved.

DragonUI is not affiliated with, endorsed by, or sponsored by Blizzard Entertainment. World of Warcraft and all related trademarks are the property of Blizzard Entertainment.

## 💛 Special Thanks

- Everyone who tested early builds, reported bugs, and helped shape the addon into what it is today.
- Translators who contributed localizations and caught string issues across different clients.
- The addon authors listed in Credits, whose open work made this project possible.
- Players who took the time to open issues, share screenshots, and suggest improvements.

