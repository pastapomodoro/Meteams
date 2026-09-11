#!/bin/bash
# Questo file va trascinato nel Terminale e si avvia con Invio
DIR="$(cd "$(dirname "$0")" && pwd)"

echo ""
echo "╔══════════════════════════════╗"
echo "║     Meteo  —  Installer      ║"
echo "╚══════════════════════════════╝"
echo ""

# Sblocca Gatekeeper su tutta la cartella
echo "▸ Sblocco quarantena..."
xattr -dr com.apple.quarantine "$DIR" 2>/dev/null
echo "  ✓ fatto"

# Avvia l'installer normale
bash "$DIR/Installa Meteo.command"
