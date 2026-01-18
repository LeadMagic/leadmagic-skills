---
title: Use Discriminated Unions for Variants
impact: CRITICAL
impactDescription: Type-safe handling of different states/variants
tags: types, unions, patterns
---

## Use Discriminated Unions for Variants

Use discriminated unions (tagged unions) to represent values that can be in different states. TypeScript will narrow the type based on the discriminant.

**Incorrect (optional properties, unclear what exists when):**

```typescript
interface ApiResponse {
  success: boolean
  data?: User
  error?: string
  errorCode?: number
}

function handleResponse(response: ApiResponse) {
  // ❌ TypeScript doesn't know which properties exist
  if (response.success) {
    console.log(response.data.email)  // Error: 'data' is possibly undefined
  } else {
    console.log(response.error)       // Error: 'error' is possibly undefined
  }
}

interface LoadingState {
  isLoading: boolean
  isError: boolean
  data?: User[]
  error?: Error
}

// ❌ Invalid states are possible
const badState: LoadingState = {
  isLoading: true,
  isError: true,  // Loading AND error at same time?
  data: [],       // Has data while loading?
  error: new Error('...')
}
```

**Correct (discriminated unions with type narrowing):**

```typescript
// ✅ Discriminant property: 'success'
type ApiResponse<T> =
  | { success: true; data: T }
  | { success: false; error: string; errorCode: number }

function handleResponse(response: ApiResponse<User>) {
  if (response.success) {
    // ✅ TypeScript knows: response.data exists
    console.log(response.data.email)
  } else {
    // ✅ TypeScript knows: response.error and response.errorCode exist
    console.log(`Error ${response.errorCode}: ${response.error}`)
  }
}

// ✅ Discriminant property: 'status'
type LoadingState<T> =
  | { status: 'idle' }
  | { status: 'loading' }
  | { status: 'success'; data: T }
  | { status: 'error'; error: Error }

function renderUsers(state: LoadingState<User[]>) {
  switch (state.status) {
    case 'idle':
      return <div>Click to load</div>

    case 'loading':
      return <div>Loading...</div>

    case 'success':
      // ✅ TypeScript knows: state.data exists
      return <ul>{state.data.map(u => <li key={u.id}>{u.name}</li>)}</ul>

    case 'error':
      // ✅ TypeScript knows: state.error exists
      return <div>Error: {state.error.message}</div>

    default:
      // ✅ Exhaustive check - TypeScript error if case missed
      const _exhaustive: never = state
      throw new Error(`Unhandled state: ${_exhaustive}`)
  }
}

// ✅ Event types with discriminant
type WebSocketEvent =
  | { type: 'message'; data: string; timestamp: number }
  | { type: 'error'; error: Error }
  | { type: 'close'; code: number; reason: string }
  | { type: 'open' }

function handleEvent(event: WebSocketEvent) {
  switch (event.type) {
    case 'message':
      console.log(`Received: ${event.data} at ${event.timestamp}`)
      break
    case 'error':
      console.error(event.error)
      break
    case 'close':
      console.log(`Closed: ${event.code} - ${event.reason}`)
      break
    case 'open':
      console.log('Connected')
      break
  }
}

// ✅ Action types (Redux-style)
type UserAction =
  | { type: 'USER_LOGIN'; payload: { email: string; password: string } }
  | { type: 'USER_LOGOUT' }
  | { type: 'USER_UPDATE'; payload: Partial<User> }

function userReducer(state: UserState, action: UserAction): UserState {
  switch (action.type) {
    case 'USER_LOGIN':
      // action.payload is { email: string; password: string }
      return { ...state, isLoggingIn: true }

    case 'USER_LOGOUT':
      // No payload
      return { ...state, user: null }

    case 'USER_UPDATE':
      // action.payload is Partial<User>
      return { ...state, user: { ...state.user!, ...action.payload } }
  }
}
```

**Rules for discriminated unions:**
1. Each variant has a common property (discriminant) with a literal type
2. TypeScript narrows based on the discriminant value
3. Use `never` in default case for exhaustive checking
