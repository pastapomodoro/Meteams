#!/bin/bash
DIR="$(cd "$(dirname "$0")" && pwd)"

echo ""
echo "╔══════════════════════════════╗"
echo "║     Meteo  —  Installer      ║"
echo "╚══════════════════════════════╝"
echo ""

# 1) Copia Meteo.app in /Applications
echo "▸ Copio Meteo.app in /Applications..."
cp -rf "$DIR/Meteo.app" /Applications/Meteo.app
xattr -cr /Applications/Meteo.app
codesign --force --deep --sign - /Applications/Meteo.app &>/dev/null
echo "  ✓ fatto"

# 2) Installa lo script daemon
echo "▸ Installo script..."
cp "$DIR/meteo_jiggle.py" ~/.meteo_jiggle.py
echo "  ✓ fatto"

# 3) Permesso Accessibilità
echo ""
echo "╔══════════════════════════════════════════════════╗"
echo "║  AZIONE RICHIESTA — una volta sola              ║"
echo "║                                                  ║"
echo "║  Si apre: Impostazioni → Privacy → Accessibilità║"
echo "║  1. Clicca  +                                    ║"
echo "║  2. Seleziona  /Applications/Meteo.app          ║"
echo "║  3. Attiva il toggle                             ║"
echo "╚══════════════════════════════════════════════════╝"
echo ""
open "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility"
sleep 2

# 4) Avvia Meteo
echo "▸ Avvio Meteo..."
open -a Meteo
sleep 2

echo ""
echo "✅  Installato!"
echo "   Icona 🌙 in alto a destra nella barra."
echo "   Clicca → Attiva per accenderlo."
echo ""
echo "   Premi Invio per chiudere."
read
