#!/usr/bin/env bash
# ============================================================
#  Smart Agri-Togo — GitHub Repository Setup Script
#  Run this ONCE on your local machine after downloading
#  the project zip from Claude.
#
#  Usage:
#    chmod +x scripts/setup/setup_github.sh
#    ./scripts/setup/setup_github.sh
#
#  You will need:
#    1. A GitHub account
#    2. A GitHub Personal Access Token (PAT)
#       → github.com → Settings → Developer settings
#         → Personal access tokens → Tokens (classic)
#         → Generate new token → check "repo" scope
# ============================================================

set -e  # exit on any error

# ── Configuration ─────────────────────────────────────────
REPO_NAME="smart-agri-togo"
REPO_DESCRIPTION="Intelligent counter-season irrigation system — Togo"
REPO_PRIVATE=false    # set to true if you want a private repo

# ── Ask for credentials ───────────────────────────────────
echo ""
echo "🌱 Smart Agri-Togo — GitHub Repository Setup"
echo "=============================================="
echo ""
GITHUB_USER="djabelo712"
echo "GitHub user: $GITHUB_USER"
read -s -p "Enter your GitHub Personal Access Token (PAT): " GITHUB_TOKEN
echo ""
echo ""

# ── Create the repo via GitHub API ────────────────────────
echo "📦 Creating GitHub repository: $GITHUB_USER/$REPO_NAME ..."

HTTP_STATUS=$(curl -s -o /tmp/gh_response.json -w "%{http_code}" \
  -X POST \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/user/repos \
  -d "{
    \"name\": \"$REPO_NAME\",
    \"description\": \"$REPO_DESCRIPTION\",
    \"private\": $REPO_PRIVATE,
    \"auto_init\": false,
    \"has_issues\": true,
    \"has_projects\": true,
    \"has_wiki\": true
  }")

if [ "$HTTP_STATUS" = "201" ]; then
  echo "✓ Repository created successfully!"
elif [ "$HTTP_STATUS" = "422" ]; then
  echo "⚠  Repository already exists — will push to existing repo."
else
  echo "✗ Failed to create repository (HTTP $HTTP_STATUS)"
  cat /tmp/gh_response.json
  exit 1
fi

REPO_URL="https://github.com/$GITHUB_USER/$REPO_NAME.git"
echo "   → $REPO_URL"
echo ""

# ── Initialize git and push ───────────────────────────────
echo "🔧 Initializing local git repository ..."

# Go to project root (script is in scripts/setup/)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$SCRIPT_DIR/../.."
cd "$PROJECT_ROOT"

git init
git config user.name "$GITHUB_USER"

# Stage all files
git add -A
git commit -m "🌱 Initial commit — Smart Agri-Togo project structure

Full project scaffold including:
- Complete directory structure (software, data, docs, hardware, energy, fertilization, research)
- Weather data logger (Open-Meteo API + FAO-56 ET₀)
- System configuration (config.py)
- Project documentation (feasibility report + technical course)
- Interactive farm simulation
- README with full project overview

Next: fill in your GitHub token in .env and run the weather logger."

# Set main branch and push
git branch -M main
git remote add origin "https://$GITHUB_USER:$GITHUB_TOKEN@${REPO_URL#https://}"
git push -u origin main

echo ""
echo "🎉 Done! Your repository is live at:"
echo "   https://github.com/djabelo712/$REPO_NAME"
echo ""
echo "📋 Next steps:"
echo "   1. Go to github.com/djabelo712/$REPO_NAME"
echo "   2. Check that all files are there"
echo "   3. Run the weather logger:"
echo "      cd software/data_logger"
echo "      pip install requests pandas"
echo "      python weather_logger.py --location Lome_Togo"
echo ""
