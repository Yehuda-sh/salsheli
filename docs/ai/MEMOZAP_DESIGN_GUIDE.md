For AI agent internal use only – not intended for human reading.

🖼️ Design Philosophy

UI first → functionality second.
Always render a full, consistent visual before connecting logic.
Every screen must feel part of the same system — light, fluid, and RTL-native.

🇮🇱 RTL & Language Rules

Text alignment → Right by default.

Icons → Mirror horizontally when needed.

Padding and margins → EdgeInsetsDirectional only.

No hardcoded Hebrew; use translation constants (AppStrings).

🎨 Color & Typography

Primary color: #007AFF

Accent gradients: use consistent 2-tone palette.

Font: GoogleFonts Assistant / Montserrat.

Contrast ratio: 4.5:1 minimum for accessibility.

Theme support: light + dark mandatory.

🧱 Components & Layout

All buttons, cards, and dialogs derive from shared components.

Use grid or column spacing — never manual pixel alignment.

Minimum touch target: 48px.

Each widget must support empty, loading, and error states.

✨ Animations & Feedback

Use micro-animations: fade, slide, shimmer.

Keep duration under 250ms.

Snackbar for undo actions.

Skeleton loaders instead of spinners.

🧩 UI Patterns

Empty State: simple icon + short hint text + CTA button.

Error State: retry button with emoji (e.g. 🔄).

Dialogs: confirm before destructive actions.

Icons: use consistent library (Lucide / Ionicons).

📋 Visual Consistency Checklist

✅ Same button radius & shadows across screens
✅ No text overflow (RTL + ellipsis check)
✅ Translations from AppStrings only
✅ Test both light & dark modes

🔗 Cross References

Logic Implementation → MEMOZAP_DEVELOPER_GUIDE.md

Tooling → MEMOZAP_MCP_GUIDE.md
