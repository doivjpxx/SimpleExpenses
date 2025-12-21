# Copilot Instructions - Expenses iOS App

## Architecture Overview

**MVVM + SwiftUI + SwiftData** expense tracker targeting iOS 18.0+. Vietnamese localization with VND currency.

### Folder Structure
```
Views/
  ├── Screens/      - Full screens: ContentView, ExpenseStatsView, MainTabView
  ├── Components/   - Reusable UI: ExpenseCellView, ExpenseFormView  
  └── Sheets/       - Modals: AddExpenseSheet, EditExpenseSheet
ViewModels/         - @Observable classes for business logic
Models/             - SwiftData @Model entities
Extensions/         - Color+Expense for category colors
Utilities/          - HapticManager singleton
```

## Critical Patterns

### SwiftData Context - NEVER Create Manually
```swift
// ✅ ALWAYS inject via @Environment
@Environment(\.modelContext) private var context
@Query(sort: \Expense.timestamp, order: .reverse) var expenses: [Expense]

// ❌ NEVER do this - causes context issues
let container = ModelContainer(for: Expense.self)
let context = ModelContext(container)
```
See `Views/Screens/ContentView.swift` for reference.

### State Management Philosophy
- **Screens**: Own UI state directly (no ViewModel in ContentView)
  - `@State private var isShowingAddSheet = false`
  - `@State private var selectedExpense: Expense?`
- **ViewModels**: Use `@Observable` (not `ObservableObject`), handle business logic only
- **Forms**: ViewModels validate and save/update

### Expense Model - No Unique Titles
```swift
@Model
final class Expense {
    var title: String        // NOT unique - users repeat names
    var value: Double        // VND amount
    var timestamp: Date
    var category: String     // "Food", "Transport", etc.
    var note: String?        // Optional
}
```
**Never add** `@Attribute(.unique)` to title.

## UI/UX Requirements

### Mandatory Haptic Feedback
Every user action needs haptics via `HapticManager.shared`:
```swift
// Delete/modify actions
HapticManager.shared.impact(style: .medium)

// Success/error notifications  
HapticManager.shared.notification(type: .success)
```

### Required Swipe Actions Pattern
All expense list items must have:
```swift
.swipeActions(edge: .trailing, allowsFullSwipe: true) {
    Button(role: .destructive) { deleteExpense(item) }
        label: { Label("Delete", systemImage: "trash") }
}
.swipeActions(edge: .leading, allowsFullSwipe: false) {
    Button { selectedExpense = item }
        label: { Label("Edit", systemImage: "pencil") }
        .tint(.blue)
}
```

### Error Handling - Always Show Alerts
```swift
// ❌ Never use print() for user errors
print("Error: \(error)")

// ✅ Always show alert
@State private var showingError = false
@State private var errorMessage = ""

.alert("Error", isPresented: $showingError) {
    Button("OK", role: .cancel) { }
} message: { Text(errorMessage) }
```

### Accessibility - Required on All Interactive Elements
```swift
.accessibilityLabel("Expense name")
.accessibilityHint("Tap to edit, swipe to delete")
.accessibilityValue("Amount: 100,000₫")
```

## Styling Conventions

### Category Colors (Extension-Based)
```swift
// Use Color.forCategory(_:) from Extensions/Color+Expense.swift
Color.forCategory(expense.category)  // Returns semantic color

// Categories: Food, Transport, Shopping, Entertainment, Health, Education, Other
```

### Currency Formatting (VND Only)
```swift
let formatter = NumberFormatter()
formatter.numberStyle = .currency
formatter.currencyCode = "VND"
formatter.maximumFractionDigits = 0  // No decimals
```

### Category Icons (SF Symbols)
```swift
// Standard mapping (see ExpenseCellView.swift)
"food" → "fork.knife"
"transport" → "car.fill"
"shopping" → "cart.fill"
// Always provide default: "questionmark.circle.fill"
```

## Localization

### String Key Convention: `{screen}.{element}`
```swift
"app.title"
"tab.list", "tab.stats"
"toolbar.addExpense", "toolbar.cancel", "toolbar.save"
"sheet.addExpense", "sheet.editExpense"
"stats.period.week", "stats.period.month"
```
All strings use `LocalizedStringKey` in `Localizable.xcstrings`.

### Date Formatting - Always Localized
```swift
// ✅ Use system formatters
Text(expense.timestamp, format: .dateTime.day().month().year())

// ❌ Never hard-code Vietnamese day names
let weekdays = ["CN", "T2", "T3", ...]  // Wrong

// ✅ Use Calendar symbols
DateFormatter().veryShortWeekdaySymbols  // Respects locale
```

## SwiftUI Conventions

### Navigation (iOS 16+)
Use `NavigationStack` only:
```swift
NavigationStack {
    List { ... }
    .navigationTitle("app.title")
    .navigationBarTitleDisplayMode(.large)
}
```

### Empty States (iOS 17+)
```swift
ContentUnavailableView(
    label: { Label("home.noExpenses", systemImage: "list.bullet.rectangle.portrait") },
    description: { Text("home.start") },
    actions: { Button("toolbar.addExpense") { ... } }
)
```

### Form Sheets Pattern
- `AddExpenseSheet` / `EditExpenseSheet` wrap `ExpenseFormView` (shared component)
- Always `.navigationBarTitleDisplayMode(.large)`
- Cancel button: `.topBarLeading`
- Save/Update button: `.topBarTrailing`, disabled if `!viewModel.isValid`

## Charts & Animations

### Swift Charts (ExpenseStatsView)
```swift
Chart {
    ForEach(viewModel.chartData) { item in
        BarMark(x: .value("Date", item.label),
                y: .value("Amount", item.amount))
            .foregroundStyle(.blue.gradient)
    }
}
```

### Value Transitions
```swift
.contentTransition(.numericText())  // For currency amounts
.animation(.easeInOut, value: viewModel.totalExpenses)
```

## Code Organization

### File Structure (MARK Comments)
```swift
// MARK: - Properties
// MARK: - Computed Properties
// MARK: - Initializers  
// MARK: - Methods
// MARK: - Private Methods
```

### Preview Providers (Required)
```swift
#Preview {
    ContentView()
        .modelContainer(for: Expense.self, inMemory: true)
}
```

## What NOT To Do

❌ Never use `fatalError()` except app initialization  
❌ Never force unwrap (`!`) - use `??` or `if let`  
❌ Don't create `ModelContext` manually  
❌ Don't use `@Published` - use `@Observable` macro  
❌ Don't hard-code colors - use `Color.forCategory()` or semantic colors  
❌ Don't skip haptic feedback  
❌ Don't use `print()` for user-facing errors  
❌ Don't hard-code Vietnamese text - use LocalizedStringKey

## Development Workflow

**Build**: Xcode 16+, iOS 18 Simulator  
**Testing**: Use in-memory SwiftData containers in previews  
**Localization**: Test both Vietnamese and English  
**Accessibility**: Verify with VoiceOver enabled  
**Dark Mode**: All views use semantic colors
