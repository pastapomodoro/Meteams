#!/bin/bash
echo ""
echo "▸ Rimozione Meteo..."
pkill -f "meteo_jiggle" 2>/dev/null
rm -rf /Applications/Meteo.app
rm -f ~/.meteo_jiggle.pid
rm -f ~/.meteo_jiggle.py
echo "✅  Rimosso."
echo ""
echo "   Premi Invio per chiudere."
read
