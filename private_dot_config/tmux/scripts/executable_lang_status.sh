#!/bin/bash
# ============================================
# Language/Technology Detector for Tmux
# Shows Nerd Font glyphs
# ============================================

PANE_PATH="$1"
if [ -z "$PANE_PATH" ]; then
    PANE_PATH="$(pwd)"
fi

cd "$PANE_PATH" 2>/dev/null || exit 0

# Function to count files by extension
count_files() {
    find . -maxdepth 2 -type f -name "$1" 2>/dev/null | wc -l
}

# Detect technology stack and return Nerd Font glyph
detect_tech_glyph() {
    # Check for specific config files (high priority)
    if [ -f "Cargo.toml" ]; then
        echo ""  # Rust
        return
    elif [ -f "package.json" ]; then
        # Check if it's a specific JS framework
        if [ -f "angular.json" ]; then
            echo ""  # Angular
        elif [ -f "svelte.config.js" ] || [ -f "svelte.config.ts" ]; then
            echo ""  # Svelte
        elif [ -f "vite.config.ts" ] || [ -f "vite.config.js" ]; then
            echo "󱐋"  # Vite (lightning bolt)
        elif [ -f "next.config.js" ] || [ -f "next.config.ts" ]; then
            echo "▲"   # Next.js
        elif [ -f "nuxt.config.ts" ] || [ -f "nuxt.config.js" ]; then
            echo "󱄆"  # Nuxt (green n)
        elif grep -q "react" package.json 2>/dev/null; then
            echo ""  # React
        elif grep -q "vue" package.json 2>/dev/null; then
            echo "󰡄"  # Vue
        else
            # Count TypeScript vs JavaScript
            TS_COUNT=$(find . -maxdepth 2 -name "*.ts" -o -name "*.tsx" 2>/dev/null | wc -l)
            JS_COUNT=$(find . -maxdepth 2 -name "*.js" -o -name "*.jsx" 2>/dev/null | wc -l)
            if [ "$TS_COUNT" -gt "$JS_COUNT" ]; then
                echo ""  # TypeScript (Seti icon)
            else
                echo ""  # JavaScript (Seti icon)
            fi
        fi
        return
    elif [ -f "go.mod" ]; then
        echo ""  # Go
        return
    elif [ -f "pyproject.toml" ] || [ -f "setup.py" ] || [ -f "requirements.txt" ]; then
        # Check for frameworks
        if [ -f "manage.py" ]; then
            echo ""  # Django (python with D)
        elif grep -q "fastapi" requirements.txt pyproject.toml 2>/dev/null; then
            echo "󱐋"  # FastAPI (lightning)
        elif grep -q "flask" requirements.txt pyproject.toml 2>/dev/null; then
            echo ""  # Flask
        else
            echo ""  # Python
        fi
        return
    elif [ -f "Gemfile" ]; then
        echo ""  # Ruby
        return
    elif [ -f "pom.xml" ] || [ -f "build.gradle" ] || [ -f "build.gradle.kts" ]; then
        echo ""  # Java
        return
    elif [ -f "pubspec.yaml" ]; then
        echo ""  # Flutter/Dart
        return
    elif [ -f "composer.json" ]; then
        echo ""  # PHP
        return
    elif [ -f "mix.exs" ]; then
        echo ""  # Elixir
        return
    elif [ -f "stack.yaml" ] || [ -f "package.yaml" ]; then
        echo ""  # Haskell
        return
    elif [ -f "CMakeLists.txt" ]; then
        echo ""  # C++
        return
    elif [ -f "Makefile" ] || [ -f "makefile" ]; then
        echo ""  # Make
        return
    elif [ -f "*.swift" ] 2>/dev/null || ls *.swift 2>/dev/null | head -1 | grep -q .; then
        echo ""  # Swift
        return
    elif [ -f "*.csproj" ] 2>/dev/null || ls *.csproj 2>/dev/null | head -1 | grep -q .; then
        echo "󰌛"  # C#
        return
    fi

    # Check by file extensions (medium priority)
    declare -A counts
    counts["rs"]=$(count_files "*.rs")
    counts["go"]=$(count_files "*.go")
    counts["py"]=$(count_files "*.py")
    counts["js"]=$(count_files "*.js")
    counts["ts"]=$(count_files "*.ts")
    counts["tsx"]=$(count_files "*.tsx")
    counts["jsx"]=$(count_files "*.jsx")
    counts["rb"]=$(count_files "*.rb")
    counts["java"]=$(count_files "*.java")
    counts["kt"]=$(count_files "*.kt")
    counts["swift"]=$(count_files "*.swift")
    counts["c"]=$(count_files "*.c")
    counts["cpp"]=$(count_files "*.cpp")
    counts["cc"]=$(count_files "*.cc")
    counts["h"]=$(count_files "*.h")
    counts["hpp"]=$(count_files "*.hpp")
    counts["php"]=$(count_files "*.php")
    counts["ex"]=$(count_files "*.ex")
    counts["exs"]=$(count_files "*.exs")
    counts["hs"]=$(count_files "*.hs")
    counts["scala"]=$(count_files "*.scala")
    counts["cs"]=$(count_files "*.cs")

    # Find dominant language
    local max_count=0
    local dominant=""

    for ext in rs go py rb java kt swift c cpp php ex exs hs scala cs; do
        if [ "${counts[$ext]}" -gt "$max_count" ]; then
            max_count=${counts[$ext]}
            dominant=$ext
        fi
    done

    # TypeScript special case (combine .ts and .tsx)
    TS_TOTAL=$((counts["ts"] + counts["tsx"]))
    JS_TOTAL=$((counts["js"] + counts["jsx"]))

    if [ "$TS_TOTAL" -gt "$max_count" ] && [ "$TS_TOTAL" -gt 0 ]; then
        dominant="ts"
        max_count=$TS_TOTAL
    elif [ "$JS_TOTAL" -gt "$max_count" ] && [ "$JS_TOTAL" -gt 0 ]; then
        dominant="js"
        max_count=$JS_TOTAL
    fi

    # Output glyph based on dominant language
    case $dominant in
        rs) echo "" ;;   # Rust
        go) echo "" ;;   # Go
        py) echo "" ;;   # Python
        js) echo "" ;;   # JavaScript (Seti icon)
        ts) echo "" ;;   # TypeScript (Seti icon)
        rb) echo "" ;;   # Ruby
        java) echo "" ;; # Java
        kt) echo "" ;;   # Kotlin
        swift) echo "" ;; # Swift
        c) echo "" ;;    # C
        cpp) echo "" ;;  # C++
        php) echo "" ;;  # PHP
        ex|exs) echo "" ;; # Elixir
        hs) echo "" ;;   # Haskell
        scala) echo "" ;; # Scala
        cs) echo "󰌛" ;;   # C#
        *) echo "" ;;
    esac
}

# Only output if we're in a git repo or have recognizable files
if git rev-parse --git-dir > /dev/null 2>&1 || [ -n "$(ls *.rs *.go *.py *.js *.ts 2>/dev/null | head -1)" ]; then
    GLYPH=$(detect_tech_glyph)
    if [ -n "$GLYPH" ]; then
        echo "#[bg=#89b4fa,fg=#1e1e2e] $GLYPH #[fg=#89b4fa,bg=default]"
    fi
fi
