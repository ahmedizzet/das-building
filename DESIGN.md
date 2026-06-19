---
name: Civic Hearth
colors:
  surface: '#f8f9ff'
  surface-dim: '#ccdbf3'
  surface-bright: '#f8f9ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#eff4ff'
  surface-container: '#e6eeff'
  surface-container-high: '#dce9ff'
  surface-container-highest: '#d5e3fc'
  on-surface: '#0d1c2e'
  on-surface-variant: '#444653'
  inverse-surface: '#233144'
  inverse-on-surface: '#eaf1ff'
  outline: '#757684'
  outline-variant: '#c4c5d5'
  surface-tint: '#3755c3'
  primary: '#00288e'
  on-primary: '#ffffff'
  primary-container: '#1e40af'
  on-primary-container: '#a8b8ff'
  inverse-primary: '#b8c4ff'
  secondary: '#006b5f'
  on-secondary: '#ffffff'
  secondary-container: '#6df5e1'
  on-secondary-container: '#006f64'
  tertiary: '#323537'
  on-tertiary: '#ffffff'
  tertiary-container: '#484c4e'
  on-tertiary-container: '#b9bcbe'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#dde1ff'
  primary-fixed-dim: '#b8c4ff'
  on-primary-fixed: '#001453'
  on-primary-fixed-variant: '#173bab'
  secondary-fixed: '#71f8e4'
  secondary-fixed-dim: '#4fdbc8'
  on-secondary-fixed: '#00201c'
  on-secondary-fixed-variant: '#005048'
  tertiary-fixed: '#e0e3e5'
  tertiary-fixed-dim: '#c4c7c9'
  on-tertiary-fixed: '#191c1e'
  on-tertiary-fixed-variant: '#444749'
  background: '#f8f9ff'
  on-background: '#0d1c2e'
  surface-variant: '#d5e3fc'
typography:
  headline-lg:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.02em
  headline-lg-mobile:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '700'
    lineHeight: 32px
    letterSpacing: -0.01em
  headline-md:
    fontFamily: Inter
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-sm:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-bold:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.05em
  financial-display:
    fontFamily: Inter
    fontSize: 28px
    fontWeight: '700'
    lineHeight: 34px
    letterSpacing: -1px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 4px
  xs: 8px
  sm: 12px
  md: 16px
  lg: 24px
  xl: 32px
  margin-mobile: 20px
  gutter-mobile: 12px
---

## Brand & Style

The design system is built on the principles of **approachability, transparency, and architectural clarity**. It targets a multi-generational demographic of residents, property managers, and service providers. The goal is to transform the often-stressful experience of home management into a seamless, community-oriented dialogue.

The design style is **Corporate Modern with a Soft Edge**. It avoids the sterility of traditional enterprise software by utilizing generous whitespace, soft-touch geometry, and a "Humanist Professional" aesthetic. Every interaction should feel secure and stable, yet welcoming.

## Colors

The palette is anchored by **Deep Harbor Blue** (#1E40AF) to establish trust and institutional reliability, particularly for financial transactions and official notices. This is balanced by **Calm Teal** (#14B8A6), used for success states, active community features, and positive status updates.

- **Primary (Harbor Blue):** Used for primary buttons, active navigation states, and brand headers.
- **Secondary (Calm Teal):** Used for accent elements, "resolved" statuses, and lifestyle features.
- **Neutral (Slate):** A range of cool grays used for body text, borders, and icon states to maintain a clean, high-contrast reading environment.
- **Surface:** The background relies on white and a very light cool-gray (Slate 50) to differentiate content blocks without using harsh lines.

## Typography

This design system utilizes **Inter** exclusively to leverage its exceptional legibility and systematic weights. The hierarchy is strictly enforced to ensure complex information, such as financial ledger entries or maintenance logs, remains scannable.

- **Headlines:** Use Semi-Bold and Bold weights with slight negative letter spacing for a modern, compact feel.
- **Body Text:** Standardized on a 16px base for accessibility on mobile devices.
- **Labels:** Small caps or bolded 12px type are used for metadata like "Building A" or "Dues Overdue" to differentiate them from interactive content.
- **Financials:** Large, high-weight numbers are used for balance overviews to ensure immediate clarity.

## Layout & Spacing

The layout follows a **Fluid Grid** model optimized for mobile-first consumption. It uses an 8pt spatial system to maintain vertical rhythm.

- **Margins:** A standard 20px horizontal margin is applied to the screen edges to provide "breathing room."
- **Stacking:** Elements within cards use 8px (XS) or 12px (SM) gaps. Large sections or distinct cards use 16px (MD) or 24px (LG) gaps.
- **Financial Grids:** In-table or in-list financial data should use tight 12px gutters to keep related values visually connected.

## Elevation & Depth

To create a friendly, approachable atmosphere, the design system uses **Ambient Shadows** rather than flat lines.

- **Surface Levels:** 
    - **Level 0 (Background):** Slate 50 (#F8FAFC).
    - **Level 1 (Cards):** Pure White (#FFFFFF) with a 4px blur, 2% opacity black shadow.
    - **Level 2 (Interactive/Floating):** Pure White with a 12px blur, 6% opacity black shadow, used for active modals or bottom sheets.
- **Dividers:** Use very subtle 1px lines in Slate 100, but only when spacing alone cannot define the boundary.

## Shapes

The shape language is defined by **Friendly Geometry**. 

- **Primary Cards & Buttons:** Use a radius of 12px to 16px to feel soft to the touch and less industrial. 
- **Input Fields:** Match the 12px radius to maintain a consistent container language. 
- **Icons:** Use a 2px stroke weight with rounded caps and joins to mirror the typography's softness.

## Components

- **Buttons:** Primary buttons are solid Harbor Blue with white text, featuring 16px vertical padding. Secondary buttons use a light teal tint with teal text.
- **Cards:** The central container for all content. Every card must have a 12px-16px corner radius and a subtle ambient shadow.
- **Status Chips:** Small, rounded-full pill shapes.
    - *Pending:* Soft Blue background / Dark Blue text.
    - *In Progress:* Light Amber background / Brown text.
    - *Resolved:* Light Teal background / Dark Teal text.
- **Input Fields:** Inset borders (1px Slate 200) that transition to Harbor Blue on focus. Labels sit clearly above the field in `label-bold` style.
- **Ticketing Lists:** Use "Chevron-right" indicators on list items to signify drill-down capability. Progress is indicated by a vertical stepped-progress bar within the ticket detail view.
- **Financial Overviews:** Use a distinct "Hero Card" style at the top of the screen with a subtle gradient (Deep Blue to Navy) to separate the most important data from the scrollable list.