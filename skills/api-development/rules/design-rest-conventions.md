---
title: RESTful Naming and HTTP Methods
impact: CRITICAL
impactDescription: Consistent, intuitive API surface
tags: rest, design, naming, http-methods
---

## RESTful Naming and HTTP Methods

Use nouns for resources and HTTP methods for actions. This creates a predictable, intuitive API surface.

**Incorrect (verbs in URLs, inconsistent methods):**

```typescript
// Using verbs in URLs
GET  /api/getUsers
POST /api/createUser
GET  /api/deleteUser/:id
POST /api/updateUserStatus

// Inconsistent resource naming
GET /api/user/:id          // singular
GET /api/orders            // plural
GET /api/product_items     // snake_case
GET /api/CustomerAddresses // PascalCase
```

**Correct (resource-based with HTTP methods):**

```typescript
// Users resource
GET    /api/v1/users           // List users
GET    /api/v1/users/:id       // Get user
POST   /api/v1/users           // Create user
PATCH  /api/v1/users/:id       // Update user (partial)
PUT    /api/v1/users/:id       // Replace user (full)
DELETE /api/v1/users/:id       // Delete user

// Nested resources
GET    /api/v1/users/:id/orders
POST   /api/v1/users/:id/orders
GET    /api/v1/users/:id/orders/:orderId

// Consistent naming: plural, lowercase, kebab-case
GET /api/v1/users
GET /api/v1/orders
GET /api/v1/product-items
GET /api/v1/customer-addresses
```

**HTTP Method Semantics:**

| Method | Idempotent | Safe | Use For |
|--------|------------|------|---------|
| GET | Yes | Yes | Retrieve resource(s) |
| POST | No | No | Create resource |
| PUT | Yes | No | Replace entire resource |
| PATCH | No* | No | Partial update |
| DELETE | Yes | No | Remove resource |

*PATCH can be idempotent if designed carefully

**Query Parameters for Filtering:**

```typescript
// Filtering, sorting, pagination
GET /api/v1/users?status=active&role=admin
GET /api/v1/users?sort=-created_at,name
GET /api/v1/users?limit=20&offset=40
GET /api/v1/users?fields=id,name,email

// Search
GET /api/v1/users?q=john

// Date ranges
GET /api/v1/orders?created_after=2024-01-01&created_before=2024-12-31
```

**Actions That Don't Fit CRUD:**

```typescript
// Use sub-resources or verbs sparingly for non-CRUD actions
POST /api/v1/users/:id/verify-email
POST /api/v1/orders/:id/cancel
POST /api/v1/payments/:id/refund

// Or use the resource state approach
PATCH /api/v1/orders/:id { "status": "cancelled" }
```
