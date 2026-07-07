---
name: MapleJob Design System
colors:
  surface: '#f7f9fb'
  surface-dim: '#d8dadc'
  surface-bright: '#f7f9fb'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f2f4f6'
  surface-container: '#eceef0'
  surface-container-high: '#e6e8ea'
  surface-container-highest: '#e0e3e5'
  on-surface: '#191c1e'
  on-surface-variant: '#43474f'
  inverse-surface: '#2d3133'
  inverse-on-surface: '#eff1f3'
  outline: '#737780'
  outline-variant: '#c3c6d1'
  surface-tint: '#3a5f94'
  primary: '#001e40'
  on-primary: '#ffffff'
  primary-container: '#003366'
  on-primary-container: '#799dd6'
  inverse-primary: '#a7c8ff'
  secondary: '#005cba'
  on-secondary: '#ffffff'
  secondary-container: '#5095fe'
  on-secondary-container: '#002d61'
  tertiary: '#28035b'
  on-tertiary: '#ffffff'
  tertiary-container: '#3e2171'
  on-tertiary-container: '#aa8ce2'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#d5e3ff'
  primary-fixed-dim: '#a7c8ff'
  on-primary-fixed: '#001b3c'
  on-primary-fixed-variant: '#1f477b'
  secondary-fixed: '#d7e3ff'
  secondary-fixed-dim: '#aac7ff'
  on-secondary-fixed: '#001b3e'
  on-secondary-fixed-variant: '#00458e'
  tertiary-fixed: '#ebddff'
  tertiary-fixed-dim: '#d3bbff'
  on-tertiary-fixed: '#260059'
  on-tertiary-fixed-variant: '#533786'
  background: '#f7f9fb'
  on-background: '#191c1e'
  surface-variant: '#e0e3e5'
typography:
  display-lg:
    fontFamily: Inter
    fontSize: 57px
    fontWeight: '700'
    lineHeight: 64px
    letterSpacing: -0.25px
  headline-lg:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '600'
    lineHeight: 40px
  headline-lg-mobile:
    fontFamily: Inter
    fontSize: 28px
    fontWeight: '600'
    lineHeight: 36px
  title-lg:
    fontFamily: Inter
    fontSize: 22px
    fontWeight: '500'
    lineHeight: 28px
  title-md:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '500'
    lineHeight: 24px
    letterSpacing: 0.15px
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
    letterSpacing: 0.5px
  body-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
    letterSpacing: 0.25px
  label-lg:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '500'
    lineHeight: 20px
    letterSpacing: 0.1px
  label-sm:
    fontFamily: Inter
    fontSize: 11px
    fontWeight: '500'
    lineHeight: 16px
    letterSpacing: 0.5px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 4px
  xs: 4px
  sm: 8px
  md: 16px
  lg: 24px
  xl: 32px
  gutter: 16px
  margin-mobile: 16px
  margin-desktop: 32px
---

## Brand & Style

The design system is engineered for **MapleJob**, a premium recruitment platform. The brand personality is authoritative yet accessible, positioning itself as a high-end corporate tool that balances professionalism with a seamless user experience. 

The aesthetic follows a **Modern Corporate** style, heavily influenced by **Material Design 3 (MD3)** principles. It prioritizes clarity, generous whitespace (breathing room), and a structured information hierarchy. The emotional response should be one of "effortless productivity"—users should feel they are using a sophisticated, reliable tool that respects their time and cognitive load. 

Key stylistic pillars include:
- **Clarity over Decoration:** Every element serves a functional purpose.
- **Spaciousness:** Large touch targets and ample margins to reduce visual density.
- **Intentionality:** Use of color and motion to guide the user through the recruitment funnel.

## Colors

The palette is anchored by **Deep Corporate Blue**, conveying stability and trust. The **Action Blue** secondary color is reserved for interactive elements, primary call-to-actions, and focus states to ensure high visibility.

- **Primary (#003366):** Used for Top App Bars, branding, and high-emphasis headers.
- **Secondary (#0066CC):** The active accent for buttons, links, and selection indicators.
- **Backgrounds:** A crisp white (#FFFFFF) is used for the main canvas, with a very light slate (#F8FAFC) for surface-level differentiation (e.g., card backgrounds on a white page).
- **Status Tints:** Semantic colors for recruitment stages use mid-tone saturations to ensure readability against light backgrounds while maintaining a professional "office-ready" appearance.

## Typography

This design system utilizes **Inter** for its exceptional legibility and systematic weight distribution. The hierarchy is strictly categorized into MD3 roles:

- **Display/Headline:** Used for marketing hero sections and major screen titles. Always use bold or semi-bold weights to ground the page.
- **Title:** Used for job titles and card headers. These provide the primary scannable information.
- **Body:** Optimized for long-form reading such as job descriptions. Uses a standard 16px base for accessibility.
- **Label:** Used for status chips, buttons, and form captions.

Letter spacing is slightly tightened for larger displays to maintain a premium "editorial" feel, while body text uses standard tracking for maximum readability.

## Layout & Spacing

The design system employs a **4px baseline grid** to ensure mathematical harmony across all components. 

- **Fluid Grid Model:** For mobile and tablet, use a fluid grid with 4 columns (mobile) and 8 columns (tablet). 
- **Fixed/Max Width:** On desktop, the main content area should be constrained to 1200px to maintain line-length readability for job descriptions.
- **Rhythm:** Use `16px (md)` for standard padding within cards and containers. Use `24px (lg)` or `32px (xl)` to separate distinct sections of a page (e.g., separating "Company Info" from "Job Requirements").
- **Safe Areas:** Adhere to 16px minimum side margins on mobile to prevent content from hitting screen edges.

## Elevation & Depth

In alignment with Material 3, depth is communicated through both **tonal layering** and **ambient shadows**.

- **Level 0 (Flat):** The main background.
- **Level 1 (Surface):** Cards and search bars. Use a very soft, diffused shadow: `0px 1px 3px rgba(0,0,0,0.05), 0px 4px 6px rgba(0,0,0,0.02)`.
- **Level 2 (Hover/Active):** Elevated cards or active menus. Shadow becomes slightly deeper and more spread to indicate "lift."
- **Overlays:** Modals and bottom sheets use a 20% opacity black backdrop blur to maintain focus on the task at hand.

Avoid harsh, high-opacity shadows. The goal is to make elements feel like they are gently resting on the surface, not floating high above it.

## Shapes

The shape language is "Rounded" to soften the corporate edge and make the application feel modern and approachable.

- **Standard (8px):** Used for small components like checkboxes and tooltips.
- **Large (12px - 16px):** The signature radius for Primary Buttons and Job Cards. This creates a distinct, premium look.
- **Full (Pill):** Reserved for Status Chips and Search Bars to differentiate them from actionable rectangular buttons.

## Components

### Buttons
- **Primary:** Deep Corporate Blue background, white text, 12px corner radius.
- **Secondary:** Transparent background, Action Blue border (1.5px), Action Blue text.
- **Focus State:** 2px Action Blue outer ring with a 2px offset.

### Status Chips
- **Style:** Pill-shaped, low-saturation background with high-saturation text for contrast.
- **Example:** "Applied" uses a light tint of Action Blue background with dark blue text.

### Input Fields
- **Container-based:** Use a light slate background (#F1F5F9) with a bottom-only border or a full subtle outline (1px).
- **Focus:** The border transitions to Action Blue (#0066CC) with a 2px stroke width.

### Cards
- **Job Cards:** 16px rounded corners, 1px light slate border, and Level 1 elevation. Include clear slotting for the company logo, title, and "Applied" status chip.

### Navigation
- **Top App Bar:** Primary Blue background with white icons. Titles are aligned left for a modern Android/MD3 feel.
- **Bottom Nav:** Active states use a tonal "pill" indicator behind the icon, consistent with Material 3 patterns.