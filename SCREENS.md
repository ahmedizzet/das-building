# SCREENS.md

## Global App Shell Constraints & Shell Route

```
+-----------------------------------+
|  [App Bar: Brand + Settings]      |
+-----------------------------------+
|                                   |
|  [Dynamic Feature Content Area]    |
|                                   |
+-----------------------------------+
|  [Persistent Bottom Navigation]   |
+-----------------------------------+
```

### 1. Global App Header (`PreferredSizeWidget`)
- **Height:** `56px`
- **Background:** `DESIGN.md -> background` (`#f8f9ff`)
- **Left Element:** Context-driven Profile Avatar / Brand Text string.
- **Right Element:** `IconButton` with `Icons.settings_outlined` mapped to `color: DESIGN.md -> on-surface` (`#0d1c2e`).
- **Divider:** None (uses pure elevation/whitespace differentiation).

### 2. Persistent Bottom Navigation Bar
- **Height:** `64px`
- **Background:** `DESIGN.md -> surface-container-lowest` (`#ffffff`)
- **Top Border:** `1px` solid `DESIGN.md -> outline-variant` (`#c4c5d5`)
- **Active State Indicator:** Pill-shaped background container using `DESIGN.md -> secondary-container` (`#6df5e1`) and text/icon using `DESIGN.md -> on-secondary-container` (`#006f64`).
- **Inactive State:** `DESIGN.md -> on-surface-variant` (`#444653`).
- **Items & Routing Matrix:**
  | Index | Label | Icon | Route Destination |
  | :--- | :--- | :--- | :--- |
  | 0 | Personal | `Icons.grid_view_rounded` | `/personal` |
  | 1 | Chat | `Icons.chat_bubble_outline_rounded` | `/chat` |
  | 2 | Tickets | `Icons.confirmation_number_outlined` | `/tickets` |
  | 3 | Booking | `Icons.calendar_today_rounded` | `/booking` |
  | 4 | Members | `Icons.people_outline_rounded` | `/members` |

---

## Screen Breakdown

### 1. Personal Screen (`/personal`)

#### Structural Grid & Layout Constraints
- **Scroll View:** Vertical `SingleChildScrollView` containing a constrained layout.
- **Padding:** `EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0)`

#### Component Hierarchy & Widgets
1. **Header Block:**
   - `Text("Financial Overview", style: typography.headline-lg)`
   - `SizedBox(height: 4)`
   - `Text("Building financial status and personal dues.", style: typography.body-sm.copyWith(color: colors.on-surface-variant))`
   - `SizedBox(height: 16)`

2. **Financial Hero Card:**
   - **Widget:** `Container` with gradient decoration.
   - **Decoration:** `BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF1E40AF), Color(0xFF00288E)]), borderRadius: BorderRadius.circular(16))`
   - **Internal Layout:** `Padding(padding: EdgeInsets.all(20))` containing a `Column(crossAxisAlignment: CrossAxisAlignment.start)`
   - **Children:**
     - `Text("Total Building Balance", style: typography.label-bold.copyWith(color: colors.on-primary-container))`
     - `Text("$1,245,600.00", style: typography.financial-display.copyWith(color: colors.on-primary))`
     - `SizedBox(height: 12)`
     - `Text("Monthly Income (Est)", style: typography.label-bold.copyWith(color: colors.on-primary-container))`
     - `Text("+$85,400.00", style: typography.headline-md.copyWith(color: colors.secondary-fixed))`
     - `SizedBox(height: 12)`
     - `Text("Monthly Expenses (YTD Avg)", style: typography.label-bold.copyWith(color: colors.on-primary-container))`
     - `Text(-"$62,100.00", style: typography.headline-md.copyWith(color: colors.error-container))`
     - `SizedBox(height: 16)`
     - `ElevatedButton.icon(onPressed: () => DISPATCH(DownloadReportAction), icon: Icon(Icons.download), label: Text("Download Report"))` styled with `colors.primary-container`.

3. **Recent Building Expenses Section:**
   - **Header:** `Row` containing `Text("Recent Building Expenses", style: typography.headline-md)` and an alignment/filter `IconButton`.
   - **List Stack:** `Card` containing a `ListView.separated` (`physics: NeverScrollableScrollPhysics()`, `shrinkWrap: true`).
   - **Item Template (`ListTile`):**
     - `leading: CircleAvatar(backgroundColor: colors.surface-container, child: Icon(...))`
     - `title: Text(expense.title, style: typography.body-lg.copyWith(fontWeight: FontWeight.w640))`
     - `subtitle: Text("${expense.date} • ${expense.category}", style: typography.body-sm)`
     - `trailing: Row(mainAxisSize: MainAxisSize.min, children: [Text(expense.amount, style: typography.body-lg), Icon(Icons.chevron_right)])`

4. **My Payment History Section:**
   - **Header:** `Text("My Payment History", style: typography.headline-md)`
   - **Horizontal Month Selector:** `SizedBox(height: 40)` -> `ListView.builder(scrollDirection: Axis.horizontal)` displaying selectable capsule pills (`Aug`, `Sep`, `Oct`, `Nov`).
   - **Payment List Stacking:** Vertical column of discrete internal containers matching the specified `12px` or `16px` border radii.
   - **Action Footer:** Primary Call-to-Action button matching the `DESIGN.md` spec: `colors.surface-container` container with deep text execution for `Make a Payment`.

#### User Flow Destinations
- **Download Report Click:** Dispatches asynchronous platform print binary channel export.
- **Expense Item Click:** Routes to `/personal/expenses/:id`.
- **View All Expenses Click:** Routes to `/personal/expenses`.
- **Make a Payment Click:** Routes to `/personal/pay`.

---

### 2. Community Chat Screen (`/chat`)

#### Structural Grid & Layout Constraints
- **Layout Structure:** Multi-segment layout containing fixed top toggles and scrolling structural item templates.
- **Global Padding:** Edge margins structured uniformly at `20px`.

#### Component Hierarchy & Widgets
1. **Screen Title:** `Text("Community Chat", style: typography.headline-lg)`
2. **Segmented Control Switcher:**
   - **Container:** `Row` nested in a surface layout wrapping two interaction targets: `Announcements` (Active) and `Lounge` (Inactive).
   - **Active Element Decor:** White background structural container with clean `rounded.DEFAULT` lines.
3. **Pinned Announcement Card:**
   - **Decor:** Built on top of `colors.surface-container-low` with explicit left accent border layout lines matching `colors.primary`.
   - **Context Typography Mapping:**
     - Prefix Flag: `Row(children: [Icon(Icons.pin_drop), Text("PINNED ANNOUNCEMENT", style: typography.label-bold)])`
     - Title Text: `Text("Elevator Maintenance Notice", style: typography.headline-md)`
     - Body Context Block: `Text("...", style: typography.body-lg)`
     - Footer Metadata Row: `CircleAvatar(radius: 12)` + `Text("Property Management • 2 days ago", style: typography.body-sm)`
4. **Feed Event Card:**
   - **Structure:** `Card` layout containing explicit image blocks.
   - **Header Layer:** Component rows matching group assignments, scheduling time indicators, and bold contextual header strings.
   - **Embedded Asset Render:** Container processing an architectural terrace visual block with an explicit `12px` border radius layer config (`ClipRRect`).

#### User Flow Destinations
- **Segment Switcher (Lounge Clicks):** Updates state machine to dynamic group messaging views (`/chat/lounge`).
- **Announcement Drill Down:** Item tap routes straight into structural markdown expansion logs (`/chat/announcements/:id`).

---

### 3. Maintenance Tickets Screen (`/tickets`)

#### Structural Grid & Layout Constraints
- **Layout Framework:** Stack-based screen utilizing a floating primary constructor button.
- **List Container Layout:** `ListView.builder` configured with default item padding lines separated by clear structural gaps (`12px`).

#### Component Hierarchy & Widgets
1. **Context Headers:** Main screen title string stacked with system tracking subtext lines.
2. **Filter Filter Pills:** Horizontal line matching filter matrices (`All Tickets`, `Open`, `In Progress`, `Resolved`).
3. **Ticket Entity Card Template:**
   - **Component Class:** `Container` built on surface structural level 1 configs.
   - **Left Status Indicator Bar:** Micro operational width line matching contextual item status metrics (e.g., Green/Teal for resolved, Orange for in-progress).
   - **Internal Horizontal Core Design Pattern:**
     - `Leading Element`: Square box graphic containing item domain markers (e.g., plumbing water drops or electrical light bolts).
     - `Center Column Text Stacking`: Title element, tracking subtitle data summary, and custom dynamic text badge structures.
     - `Status Chip Specification Matrix:**
       | Component State | Background Token | Foreground Color Token |
       | :--- | :--- | :--- |
       | **Pending** | Soft Blue Tint | Dark Deep Blue Text |
       | **In Progress** | Light Amber | Brown Text |
       | **Resolved** | Light Teal | Dark Teal Text |
     - `Trailing Link Indicator`: `Icon(Icons.chevron_right_rounded, color: colors.outline-variant)`.
4. **Floating Content Creator FAB:**
   - **Widget Target:** `FloatingActionButton` pinned to the bottom right segment corner.
   - **Color Spec:** Solid background setting mapping `colors.primary-container` with an internal white plus graphic sign icon.

#### User Flow Destinations
- **Ticket Item Target Click:** Explicit transition routing paths straight to item detail sequences (`/tickets/detail/:id`).
- **FAB Click Action:** Screen transitions over to creation input fields (`/tickets/new`).

---

### 4. Reserve an Amenity Screen (`/booking`)

#### Structural Grid & Layout Constraints
- **Scroll Alignment:** Top-to-bottom layout processing separate horizontal calendar layouts and data grids.
- **Structural Margins:** Standardized spacing margins setting up clean structural layout flows.

#### Component Hierarchy & Widgets
1. **System Policy Banner Notice:**
   - **Widget:** Alert notice matching a soft background framework layer.
   - **Internal Layout:** Row formatting combining info graphic iconography side-by-side with semantic text tracking instructions.
2. **Amenity Carousel Blocks:**
   - **Layout Design:** Horizontal axis list displaying card elements with embedded asset context layers.
   - **Checkmark Active Selection State:** Selected elements display a clear visual check symbol badge over a circular backing container overlay layer.
3. **Horizontal Strip Processing Date Calendars:**
   - **Layout Matrix:** Structural horizontal card rows displaying target weekday characters combined with bold calendar dates stacked directly below.
4. **Interactive Time Slots Matrix:**
   - **Layout Blueprint:** Dual grid category layout zones separating afternoon slots from evening targets.
   - **Slot UI Styling Rules Matrix:**
     | Item Slot State | Background Vector | Text Color Token | Structural Interaction Decor |
     | :--- | :--- | :--- | :--- |
     | **Selected State** | `colors.primary` | Pure White Text | Solid bounding container geometry |
     | **Available State** | `colors.background` | `colors.on-surface` | Outlined subtle border lines |
     | **Booked Out State** | Transparent Alpha | Muted Silver Gray | Striking crossing line marks |
5. **Fixed Summary Bottom Processing Banner Container:**
   - **Structure:** Bottom row card pinning amenity selection metadata details right next to a prominent primary solid `Book Now` submission execution button element.

#### User Flow Destinations
- **Book Now Action Processing Click:** Triggers submission pipelines before displaying verification alerts (`/booking/confirmation`).

---

### 5. Members/Collections Screen (`/members`)

#### Structural Grid & Layout Constraints
- **Layout Mode:** Complex financial statistics visual overview dashboards connected to resident lookup rosters.

```
+----------------------------------------+
|  [October Overview: Statistics Card]   |
+----------------------------------------+
|  [Collections Trend: Spline Chart]     |
+----------------------------------------+
|  [Search Input & Status Filter Row]   |
+----------------------------------------+
|  [Scrollable Member Ledger List]       |
+----------------------------------------+
```

#### Component Hierarchy & Widgets
1. **Overview Financial Metrics Banner:**
   - **Widget Structure:** Flat container card processing a linear progress line indicator mapping collection percentages completed (e.g., `84% Collected`).
2. **Collections Trend Visual Graph:**
   - **Widget Class:** Built around custom canvas components or charting engine dependencies (`fl_chart`).
   - **Graph Parameters:** Smooth bezier curve lines connecting chronological historical nodes.
3. **Query Engine Filter Controls:**
   - **Search Asset Box:** Inline clean searching widget formatting text indicators wrapped by smooth rounded border lines.
   - **Roster Selection Pills:** Filter toggles isolating groups (`All`, `Paid`, `Unpaid`, `Late`).
4. **Resident Billing Roster Ledger Cards:**
   - **Item Architecture Type:** White canvas containers hosting specific individual resident layout blocks.
   - **Individual Row Anatomy Specifications:**
     - Left Content Group: Circular profile headshots side-by-side with vertical text columns showing resident identity names and apartment address units.
     - Right Content Group: Balance tracking information data flags directly supported by transactional context elements.
     - Urgent Action Interaction Targets: Account entries marked unpaid include distinct call-to-action layout buttons labeled `Nudge` utilizing high-contrast styling layers (`colors.secondary`).

#### User Flow Destinations
- **Nudge Button Press Trigger:** Dispatches notification signals directly targeting specific remote application destinations (`/members/nudge/:resident_id`).
- **Resident Profile Row Selection:** Routes tracking perspectives deeper into separate accounting history logs (`/members/ledger/:resident_id`).
