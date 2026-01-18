---
title: Common React Mistakes
impact: CRITICAL
impactDescription: Prevents bugs, unnecessary re-renders, and poor UX
tags: react, hooks, state, useEffect, patterns
---

## Common React Mistakes

These are the most frequent mistakes developers make with React, based on official React documentation and real-world patterns.

---

### 1. Resetting State with useEffect on Prop Change

**Problem:** Using useEffect to reset state when a prop changes causes unnecessary re-renders.

```typescript
// ❌ WRONG - Extra re-render, complex for nested state
function ProfilePage({ userId }) {
  const [comment, setComment] = useState('')

  useEffect(() => {
    setComment('') // Reset on userId change
  }, [userId])

  return <CommentForm value={comment} onChange={setComment} />
}
```

**Solution:** Use `key` to tell React to treat it as a different component.

```typescript
// ✅ CORRECT - Use key to reset component instance
function ProfilePage({ userId }) {
  return <CommentForm key={userId} />
}

function CommentForm() {
  const [comment, setComment] = useState('')
  return <textarea value={comment} onChange={(e) => setComment(e.target.value)} />
}
```

---

### 2. Chaining useEffect Hooks

**Problem:** Multiple useEffects that trigger state changes which trigger other useEffects.

```typescript
// ❌ WRONG - Chain of effects causing multiple re-renders
function Game() {
  const [card, setCard] = useState(null)
  const [goldCardCount, setGoldCardCount] = useState(0)
  const [round, setRound] = useState(1)
  const [isGameOver, setIsGameOver] = useState(false)

  useEffect(() => {
    if (card !== null && card.gold) {
      setGoldCardCount(c => c + 1)
    }
  }, [card])

  useEffect(() => {
    if (goldCardCount > 3) {
      setRound(r => r + 1)
      setGoldCardCount(0)
    }
  }, [goldCardCount])

  useEffect(() => {
    if (round > 5) {
      setIsGameOver(true)
    }
  }, [round])
}
```

**Solution:** Calculate during render or in event handler.

```typescript
// ✅ CORRECT - Calculate everything in one place
function Game() {
  const [card, setCard] = useState(null)
  const [goldCardCount, setGoldCardCount] = useState(0)
  const [round, setRound] = useState(1)

  // Derived state - no useEffect needed
  const isGameOver = round > 5

  function handlePlaceCard(nextCard) {
    if (isGameOver) throw Error('Game already ended.')

    setCard(nextCard)
    if (nextCard.gold) {
      const newGoldCount = goldCardCount + 1
      setGoldCardCount(newGoldCount)
      if (newGoldCount > 3) {
        setRound(round + 1)
        setGoldCardCount(0)
      }
    }
  }
}
```

---

### 3. Mutating Nested Objects in State

**Problem:** Shallow copy doesn't protect nested objects.

```typescript
// ❌ WRONG - Mutates original state
const nextList = [...list]
nextList[0].seen = true // Still mutates list[0]!
setList(nextList)
```

**Solution:** Deep copy nested objects.

```typescript
// ✅ CORRECT - Create new object for nested changes
const nextList = list.map((item, i) =>
  i === 0 ? { ...item, seen: true } : item
)
setList(nextList)
```

---

### 4. Combining Unrelated Logic in One useEffect

**Problem:** Single useEffect synchronizing independent data.

```typescript
// ❌ WRONG - Two independent fetches in one effect
function ShippingForm({ country }) {
  const [cities, setCities] = useState(null)
  const [city, setCity] = useState(null)
  const [areas, setAreas] = useState(null)

  useEffect(() => {
    let ignore = false
    fetch(`/api/cities?country=${country}`)
      .then(res => res.json())
      .then(json => { if (!ignore) setCities(json) })

    // This fetch depends on city, not country!
    if (city) {
      fetch(`/api/areas?city=${city}`)
        .then(res => res.json())
        .then(json => { if (!ignore) setAreas(json) })
    }

    return () => { ignore = true }
  }, [country, city])
}
```

**Solution:** Separate into independent effects.

```typescript
// ✅ CORRECT - Separate concerns
function ShippingForm({ country }) {
  const [cities, setCities] = useState(null)
  const [city, setCity] = useState(null)
  const [areas, setAreas] = useState(null)

  useEffect(() => {
    let ignore = false
    fetch(`/api/cities?country=${country}`)
      .then(res => res.json())
      .then(json => { if (!ignore) setCities(json) })
    return () => { ignore = true }
  }, [country])

  useEffect(() => {
    if (!city) return
    let ignore = false
    fetch(`/api/areas?city=${city}`)
      .then(res => res.json())
      .then(json => { if (!ignore) setAreas(json) })
    return () => { ignore = true }
  }, [city])
}
```

---

### 5. Suppressing the Linter

**Problem:** Ignoring exhaustive-deps warnings.

```typescript
// ❌ WRONG - Hides bugs caused by stale closures
useEffect(() => {
  doSomething(count)
  // eslint-ignore-next-line react-hooks/exhaustive-deps
}, [])
```

**Solution:** Fix the root cause.

```typescript
// ✅ CORRECT - If you don't want it to re-run, move the value
// into the effect or use a ref
const countRef = useRef(count)
countRef.current = count

useEffect(() => {
  // Use ref if you need latest value without re-running
  doSomething(countRef.current)
}, [])

// Or include it properly
useEffect(() => {
  doSomething(count)
}, [count])
```

---

### 6. Overusing useMemo and useCallback

**Problem:** Adding memoization everywhere.

```typescript
// ❌ OVERKILL - Simple computation doesn't need memo
const fullName = useMemo(() => {
  return `${firstName} ${lastName}`
}, [firstName, lastName])

// ❌ OVERKILL - Inline function in non-memoized child
<Button onClick={useCallback(() => setCount(c => c + 1), [])} />
```

**Solution:** Only memoize when needed.

```typescript
// ✅ BETTER - Simple computation is fine
const fullName = `${firstName} ${lastName}`

// ✅ USE MEMO WHEN:
// 1. Expensive computation
const sortedItems = useMemo(() => items.sort(expensiveSort), [items])

// 2. Passed to memoized child
const MemoChild = memo(Child)
const handleClick = useCallback(() => setCount(c => c + 1), [])
<MemoChild onClick={handleClick} />

// 3. Used as dependency in another hook
const config = useMemo(() => ({ id, name }), [id, name])
useEffect(() => { /* uses config */ }, [config])
```

---

### 7. Not Cleaning Up Effects

**Problem:** Effects that don't clean up subscriptions or async operations.

```typescript
// ❌ WRONG - Memory leak, stale updates
useEffect(() => {
  const interval = setInterval(() => setCount(c => c + 1), 1000)
  // No cleanup!
}, [])

// ❌ WRONG - Race condition with async
useEffect(() => {
  fetch(`/api/user/${id}`).then(res => res.json()).then(setUser)
}, [id])
```

**Solution:** Always clean up.

```typescript
// ✅ CORRECT - Clean up interval
useEffect(() => {
  const interval = setInterval(() => setCount(c => c + 1), 1000)
  return () => clearInterval(interval)
}, [])

// ✅ CORRECT - Ignore stale async results
useEffect(() => {
  let ignore = false
  fetch(`/api/user/${id}`)
    .then(res => res.json())
    .then(data => { if (!ignore) setUser(data) })
  return () => { ignore = true }
}, [id])
```

---

### 8. Fetching in useEffect When Server Components Work

**Problem:** Client-side fetching when server-side would be better.

```typescript
// ❌ WRONG in Next.js App Router - unnecessary client fetch
'use client'
function UserProfile({ userId }) {
  const [user, setUser] = useState(null)

  useEffect(() => {
    fetch(`/api/users/${userId}`).then(r => r.json()).then(setUser)
  }, [userId])

  return user ? <div>{user.name}</div> : <Loading />
}
```

**Solution:** Use Server Components.

```typescript
// ✅ CORRECT - Server Component fetches directly
async function UserProfile({ userId }) {
  const user = await db.query.users.findFirst({
    where: eq(users.id, userId)
  })
  return <div>{user.name}</div>
}
```

---

## Quick Reference

| Mistake | Solution |
|---------|----------|
| Reset state with useEffect | Use `key` prop |
| Chained useEffects | Calculate in event handlers |
| Mutate nested objects | Deep copy with map/spread |
| Unrelated logic in one effect | Split into multiple effects |
| Suppress linter warnings | Fix root cause |
| Memoize everything | Only when needed |
| Forget cleanup | Always return cleanup function |
| Client fetch in Next.js | Use Server Components |
