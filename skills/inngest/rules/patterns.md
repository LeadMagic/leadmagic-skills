# Common Patterns

Workflow patterns for common use cases.

## Fan-out / Fan-in

```typescript
export const processItems = inngest.createFunction(
  { id: 'process-items' },
  { event: 'batch/process' },
  async ({ event, step }) => {
    const items = event.data.items

    // Fan-out: Process items in parallel
    const results = await Promise.all(
      items.map((item, i) =>
        step.run(`process-item-${i}`, async () => {
          return await processItem(item)
        })
      )
    )

    // Fan-in: Aggregate results
    await step.run('aggregate', async () => {
      return await aggregateResults(results)
    })
  }
)
```

## Saga Pattern (Compensating Transactions)

```typescript
export const bookTrip = inngest.createFunction(
  { id: 'book-trip' },
  { event: 'trip/book' },
  async ({ event, step }) => {
    const { flightId, hotelId, carId } = event.data

    // Book flight
    const flight = await step.run('book-flight', async () => {
      return await bookFlight(flightId)
    })

    // Book hotel with compensation
    let hotel
    try {
      hotel = await step.run('book-hotel', async () => {
        return await bookHotel(hotelId)
      })
    } catch (error) {
      // Compensate: Cancel flight
      await step.run('cancel-flight', async () => {
        await cancelFlight(flight.confirmationId)
      })
      throw error
    }

    // Book car with compensation
    try {
      const car = await step.run('book-car', async () => {
        return await bookCar(carId)
      })
      return { flight, hotel, car }
    } catch (error) {
      // Compensate: Cancel both
      await step.run('cancel-hotel', () => cancelHotel(hotel.confirmationId))
      await step.run('cancel-flight', () => cancelFlight(flight.confirmationId))
      throw error
    }
  }
)
```

## Loops with Pagination

```typescript
export const importProducts = inngest.createFunction(
  { id: 'shopify-product-import' },
  { event: 'shopify/import.requested' },
  async ({ event, step }) => {
    const allProducts = []
    let cursor = null
    let hasMore = true

    while (hasMore) {
      const page = await step.run(`fetch-products-${cursor ?? 'start'}`, async () => {
        return await shopify.rest.Product.all({
          session,
          since_id: cursor,
        })
      })

      allProducts.push(...page.products)

      if (page.products.length === 50) {
        cursor = page.products[49].id
      } else {
        hasMore = false
      }
    }

    return { imported: allProducts.length }
  }
)
```

## Scheduled Jobs (Cron)

```typescript
export const dailyCleanup = inngest.createFunction(
  { id: 'daily-cleanup' },
  { cron: '0 3 * * *' }, // 3 AM daily
  async ({ step }) => {
    await step.run('cleanup-expired-sessions', async () => {
      await db.sessions.deleteMany({
        where: { expiresAt: { lt: new Date() } },
      })
    })

    await step.run('cleanup-old-logs', async () => {
      const thirtyDaysAgo = new Date(Date.now() - 30 * 24 * 60 * 60 * 1000)
      await db.logs.deleteMany({
        where: { createdAt: { lt: thirtyDaysAgo } },
      })
    })
  }
)
```

## Function Configuration

```typescript
export const criticalJob = inngest.createFunction(
  {
    id: 'critical-job',
    retries: 5,
    concurrency: {
      limit: 10,
      key: 'event.data.tenantId', // Per-tenant limit
    },
    rateLimit: {
      limit: 100,
      period: '1m',
    },
    cancelOn: [{ event: 'job/cancelled', match: 'data.jobId' }],
  },
  { event: 'job/start' },
  async ({ event, step }) => {
    // Function body
  }
)
```
