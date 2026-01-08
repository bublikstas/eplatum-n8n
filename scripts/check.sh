#!/usr/bin/env sh
set -eu

echo "🔍 Running pre-deploy checks..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

ERRORS=0

# 1. Validate package.json
echo "📦 Validating package.json..."
if python3 -m json.tool package.json > /dev/null 2>&1; then
    echo "${GREEN}✓${NC} package.json is valid JSON"
else
    echo "${RED}✗${NC} package.json is invalid JSON"
    ERRORS=$((ERRORS + 1))
fi

# 2. Check shell script syntax
echo "🔧 Checking shell script syntax..."
SCRIPTS="start-render.sh scripts/import_workflows.sh entrypoint.sh"
for script in $SCRIPTS; do
    if [ -f "$script" ]; then
        if sh -n "$script" 2>/dev/null; then
            echo "${GREEN}✓${NC} $script syntax OK"
        else
            echo "${RED}✗${NC} $script has syntax errors"
            ERRORS=$((ERRORS + 1))
        fi
    else
        echo "${YELLOW}⚠${NC} $script not found (skipping)"
    fi
done

# 3. Optional shellcheck
if command -v shellcheck >/dev/null 2>&1; then
    echo "🔍 Running shellcheck..."
    for script in $SCRIPTS; do
        if [ -f "$script" ]; then
            if shellcheck "$script" 2>/dev/null; then
                echo "${GREEN}✓${NC} $script passed shellcheck"
            else
                echo "${YELLOW}⚠${NC} $script has shellcheck warnings (non-fatal)"
            fi
        fi
    done
else
    echo "${YELLOW}⚠${NC} shellcheck not installed (skipping)"
fi

# 4. Build Docker image
if command -v docker >/dev/null 2>&1; then
    echo "🐳 Building Docker image..."
    if docker build -t eplatum-n8n:local . > /dev/null 2>&1; then
        echo "${GREEN}✓${NC} Docker image built successfully"
        
        # 5. Verify n8n in container
        echo "✅ Verifying n8n in container..."
        if docker run --rm eplatum-n8n:local sh -c "command -v n8n && n8n --version" > /dev/null 2>&1; then
            N8N_VERSION=$(docker run --rm eplatum-n8n:local sh -c "n8n --version" 2>/dev/null | head -1)
            echo "${GREEN}✓${NC} n8n is available: $N8N_VERSION"
        else
            echo "${RED}✗${NC} n8n not found or failed to run in container"
            ERRORS=$((ERRORS + 1))
        fi
    else
        echo "${RED}✗${NC} Docker build failed"
        ERRORS=$((ERRORS + 1))
    fi
else
    echo "${YELLOW}⚠${NC} Docker not available (skipping Docker checks)"
fi

# Summary
echo ""
if [ $ERRORS -eq 0 ]; then
    echo "${GREEN}✅ All checks passed!${NC}"
    exit 0
else
    echo "${RED}❌ $ERRORS check(s) failed${NC}"
    exit 1
fi
