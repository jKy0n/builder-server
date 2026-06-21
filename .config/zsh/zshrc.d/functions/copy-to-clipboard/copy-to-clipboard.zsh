#!/bin/zsh

# copy-to-clipboard 2.0 - Zsh Function
# Dual-output: Terminal (humanized) + Clipboard (IA-optimized)
# Logic: 0=IA, 1=Humanized

# ========== PREEXEC HOOK ==========
# Captures the full command line BEFORE execution (so fc isn't needed)
if ! (( ${+functions[__ctc_preexec]} )); then
    __ctc_preexec() { __CTC_LAST_CMD="$1"; }
    autoload -Uz add-zsh-hook
    add-zsh-hook preexec __ctc_preexec
fi

function copy-to-clipboard() {
    # ========== VERSION & HELP ==========

    local version="2.0"

    # Check for help/version first
    for arg in "$@"; do
        case "$arg" in
            -h|--help)
                cat << 'EOF'
copy-to-clipboard 2.0 - Dual-Output Clipboard Manager

USAGE:
    copy-to-clipboard [OPTIONS] [COMMAND]
    command | copy-to-clipboard [OPTIONS]

OPTIONS:
    -h, --help              Show this help message
    -v, --version           Show version information
    -H, --human             Humanized output (terminal + clipboard)
    -s, --silent            No terminal output (only confirmation)
    -e, --export            Save to file + IA-format output

LOGIC:
    0 = IA-optimized (structured, parseable)
    1 = Humanized (visual, readable)

DEFAULTS:
    - Terminal: 1 (humanized - you debug)
    - Clipboard: 0 (IA-format - AI analyzes)

EXAMPLES:
    # Copy for AI (default - best for debugging)
    docker logs app | copy-to-clipboard

    # Humanized everywhere
    docker logs app | copy-to-clipboard --human

    # Silent mode (for scripts)
    docker logs app | copy-to-clipboard --silent

    # Export to file + IA-format
    docker logs app | copy-to-clipboard --export

    # Combine flags
    docker logs app | copy-to-clipboard --silent --export

FEATURES:
    ✓ Dual-output: humanized terminal + IA-optimized clipboard
    ✓ Automatic fallback: xclip → OSC 52 → file
    ✓ SSH-friendly (X11 forwarding support)
    ✓ Silent mode for scripts
    ✓ File export for emergencies
    ✓ Metadata in IA-format (status, method, size, timestamp)

ENVIRONMENT:
    DISPLAY             X11 display (for xclip)
    TERM                Terminal type (for OSC 52 support)

CLIPBOARD BACKENDS:
    1. xclip (primary)
    2. OSC 52 (SSH-friendly)
    3. File export (fallback)

For more info: https://github.com/jKy0n/TheseusMachine-dotfiles/tree/main/.config/zsh
EOF
                return 0
                ;;
            -v|--version)
                if command -v xclip &> /dev/null; then
                    local xclip_version=$(xclip -version 2>&1 | head -n1 | grep -oE '[0-9]+\.[0-9]+' || echo "unknown")
                    echo "copy-to-clipboard version $version (with xclip v$xclip_version)"
                else
                    echo "copy-to-clipboard version $version (xclip not found)"
                fi
                return 0
                ;;
        esac
    done

    # ========== VERIFY XCLIP ==========

    if ! command -v xclip &> /dev/null; then
        echo "❌ Erro: xclip não está instalado"
        echo "   Instale com: sudo pacman -S xclip"
        return 1
    fi

    # ========== PARSE FLAGS ==========

    local human=0
    local silent=0
    local export_flag=0
    local input=""

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -H|--human)
                human=1
                shift
                ;;
            -s|--silent)
                silent=1
                shift
                ;;
            -e|--export)
                export_flag=1
                shift
                ;;
            *)
                input="$*"
                break
                ;;
        esac
    done

    # ========== SAVE COMMAND STRING ==========

    # Use the preexec-captured command line, strip copy-to-clipboard from it
    local command_str=""

    if [[ -n "$__CTC_LAST_CMD" ]]; then
        # Remove "| copy-to-clipboard..." (pipe usage)
        # Remove "copy-to-clipboard " at the start (direct usage)
        # Remove flags like --silent, --human, --export
        command_str="$(echo "$__CTC_LAST_CMD" | sed 's/|[[:space:]]*copy-to-clipboard.*//' | sed 's/^[[:space:]]*copy-to-clipboard[[:space:]]*//' | sed 's/--\(silent\|human\|export\|help\|version\)[[:space:]]*//g' | sed 's/-[sHedhv][[:space:]]*//g' | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')"
    fi

    [[ -z "$command_str" ]] && command_str="(unknown)"

    # ========== DERIVE FORMATS ==========

    local terminal_format=$human
    local clipboard_format=$human

    # If --export, terminal also becomes IA-format (0)
    if [[ $export_flag -eq 1 ]]; then
        terminal_format=0
    fi

    # ========== READ INPUT ==========

    if [[ -z "$input" ]]; then
        if [[ ! -t 0 ]]; then
            # Read from stdin (pipe)
            input="$(cat)"
        else
            # No input and no pipe
            echo "❌ Uso: comando | copy-to-clipboard [OPTIONS]"
            echo "   Use 'copy-to-clipboard --help' para mais informações"
            return 1
        fi
    else
        # Execute command passed as argument
        input="$(eval "$input" 2>&1)"
    fi

    local content_size=$(echo -n "$input" | wc -c)
    local timestamp=$(date -u +%Y-%m-%dT%H:%M:%S.000Z)

    # ========== BUILD CLIPBOARD CONTENT ==========

    local clipboard_content=""

    if [[ $clipboard_format -eq 0 ]]; then
        # IA-format (0)
        clipboard_content="[COPY_STATUS] success
[COPY_METHOD] xclip
[CONTENT_SIZE] $content_size bytes
[TIMESTAMP] $timestamp
[COMMAND] $command_str
---
$input
---"
    else
        # Humanized (1)
        clipboard_content="$input"
    fi

    # ========== COPY TO CLIPBOARD ==========

    local clipboard_success=0

    # Try xclip first
    if echo -n "$clipboard_content" | xclip -selection clipboard 2>/dev/null; then
        clipboard_success=1
    # Try OSC 52 if xclip fails
    elif [[ -n "$TERM" ]] && echo "$TERM" | grep -qE "(alacritty|kitty|wezterm|tmux)"; then
        local encoded=$(echo -n "$clipboard_content" | base64 -w0)
        printf '\033]52;c;%s\033\\' "$encoded"
        clipboard_success=1
    # Fallback: save to file
    else
        export_flag=1
        clipboard_success=0
    fi

    # ========== TERMINAL OUTPUT ==========

    if [[ $silent -eq 0 ]]; then
        if [[ $terminal_format -eq 0 ]]; then
            # IA-format (0)
            if [[ $clipboard_success -eq 1 ]]; then
                echo "$clipboard_content"
            else
                # Fallback message
                echo "[COPY_STATUS] fallback"
                echo "[COPY_METHOD] file"
                echo "[CONTENT_SIZE] $content_size bytes"
                echo "[TIMESTAMP] $timestamp"
                echo "[COMMAND] $command_str"
                echo "---"
                echo "$input"
                echo "---"
            fi
        else
            # Humanized (1)
            if [[ $clipboard_success -eq 1 ]]; then
                echo "✅ Copiado com xclip"
            else
                echo "⚠️  Clipboard indisponível (SSH sem X11?)"
                echo "   Ativando fallback: --export automático"
            fi

            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo "📋 Comando: $command_str"
            echo "📋 Conteúdo ($content_size bytes):"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo "$input"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        fi
    else
        echo "✅ Copiado (--silent)"
    fi

    # ========== EXPORT (FILE) ==========

    if [[ $export_flag -eq 1 ]]; then
        local export_timestamp=$(date +%Y-%m-%d_%H-%M-%S)
        local export_file="$HOME/clipboard_${export_timestamp}.txt"

        # Save to file
        echo -n "$clipboard_content" > "$export_file"

        if [[ $silent -eq 0 ]]; then
            if [[ $terminal_format -eq 1 ]]; then
                echo "📄 Salvo em: $export_file"
            else
                echo "[EXPORT_FILE] $export_file"
            fi
        fi

        # If clipboard failed, try to copy from file
        if [[ $clipboard_success -eq 0 ]]; then
            if [[ $silent -eq 0 ]] && [[ $terminal_format -eq 1 ]]; then
                echo ""
                echo "💡 Dica: Para copiar do arquivo para clipboard:"
                echo "   cat $export_file | xclip -selection clipboard"
            fi
        fi
    fi
}