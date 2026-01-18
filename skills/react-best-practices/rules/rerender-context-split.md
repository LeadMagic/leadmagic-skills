---
title: Split Contexts by Domain
impact: HIGH
impactDescription: Prevents unnecessary re-renders across unrelated state
tags: context, performance, state-management, re-renders
---

## Split Contexts by Domain

A single monolithic context causes all consumers to re-render when any part changes. Split contexts by domain to isolate re-renders.

**Incorrect (monolithic context):**

```typescript
// One context for everything
interface AppState {
  user: User | null
  theme: 'light' | 'dark'
  notifications: Notification[]
  sidebarOpen: boolean
  cart: CartItem[]
  locale: string
}

const AppContext = createContext<AppState & AppActions>(null!)

function AppProvider({ children }: { children: React.ReactNode }) {
  const [state, setState] = useState<AppState>({
    user: null,
    theme: 'light',
    notifications: [],
    sidebarOpen: false,
    cart: [],
    locale: 'en',
  })

  // Every state change re-renders ALL consumers
  return (
    <AppContext.Provider value={{ ...state, ...actions }}>
      {children}
    </AppContext.Provider>
  )
}

// This re-renders when notifications change, even though it only uses theme
function ThemeToggle() {
  const { theme, setTheme } = useContext(AppContext) // Re-renders on ANY change
  return <button onClick={() => setTheme(theme === 'dark' ? 'light' : 'dark')}>Toggle</button>
}
```

**Correct (split by domain):**

```typescript
// Separate contexts by domain
const AuthContext = createContext<AuthState>(null!)
const ThemeContext = createContext<ThemeState>(null!)
const NotificationContext = createContext<NotificationState>(null!)
const UIContext = createContext<UIState>(null!)
const CartContext = createContext<CartState>(null!)
const LocaleContext = createContext<LocaleState>(null!)

// Each provider manages its own state
function AuthProvider({ children }: { children: React.ReactNode }) {
  const [user, setUser] = useState<User | null>(null)

  // Memoize the value to prevent unnecessary re-renders
  const value = useMemo(() => ({ user, setUser, login, logout }), [user])

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>
}

function ThemeProvider({ children }: { children: React.ReactNode }) {
  const [theme, setTheme] = useState<'light' | 'dark'>('light')

  const value = useMemo(() => ({ theme, setTheme, toggleTheme }), [theme])

  return <ThemeContext.Provider value={value}>{children}</ThemeContext.Provider>
}

// Compose providers (or use a utility)
function Providers({ children }: { children: React.ReactNode }) {
  return (
    <AuthProvider>
      <ThemeProvider>
        <NotificationProvider>
          <UIProvider>
            <CartProvider>
              <LocaleProvider>
                {children}
              </LocaleProvider>
            </CartProvider>
          </UIProvider>
        </NotificationProvider>
      </ThemeProvider>
    </AuthProvider>
  )
}

// Now this only re-renders when theme changes
function ThemeToggle() {
  const { theme, toggleTheme } = use(ThemeContext)
  return <button onClick={toggleTheme}>Toggle ({theme})</button>
}
```

**Provider Value Memoization:**

```typescript
// Incorrect: new object every render
function BadProvider({ children }) {
  const [count, setCount] = useState(0)

  return (
    <CountContext.Provider value={{ count, setCount, double: count * 2 }}>
      {children}
    </CountContext.Provider>
  )
}

// Correct: memoized value
function GoodProvider({ children }) {
  const [count, setCount] = useState(0)

  const value = useMemo(
    () => ({ count, setCount, double: count * 2 }),
    [count]
  )

  return (
    <CountContext.Provider value={value}>
      {children}
    </CountContext.Provider>
  )
}
```

**Separate State from Dispatch:**

```typescript
// For reducers, split state and dispatch into separate contexts
// Dispatch is stable and never changes - components using only actions won't re-render

const StateContext = createContext<State>(null!)
const DispatchContext = createContext<Dispatch<Action>>(null!)

function Provider({ children }) {
  const [state, dispatch] = useReducer(reducer, initialState)

  return (
    <StateContext.Provider value={state}>
      <DispatchContext.Provider value={dispatch}>
        {children}
      </DispatchContext.Provider>
    </StateContext.Provider>
  )
}

// This component never re-renders (dispatch is stable)
function AddButton() {
  const dispatch = use(DispatchContext)
  return <button onClick={() => dispatch({ type: 'ADD' })}>Add</button>
}

// This component re-renders when state.count changes
function Counter() {
  const state = use(StateContext)
  return <span>{state.count}</span>
}
```

**When to Consider External State:**

For frequently updating state (typing, animations, real-time data), consider:
- Zustand (minimal, no provider needed)
- Jotai (atomic state)
- Redux Toolkit (complex cross-cutting state)

Context is ideal for:
- Infrequently changing values (theme, locale, user)
- Deeply nested prop drilling elimination
- Feature flags and configuration
