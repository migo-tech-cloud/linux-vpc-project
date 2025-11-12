#!/bin/bash
echo "🛑 Stopping all Python HTTP servers..."
pkill -f "python3 -m http.server"
echo "✅ All servers stopped"
