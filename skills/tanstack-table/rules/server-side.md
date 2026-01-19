# Server-Side Pagination with TanStack Query

For large datasets, implement server-side pagination, sorting, and filtering.

## Custom Hook

```typescript
// hooks/use-users-table.ts
import { useQuery } from '@tanstack/react-query'
import {
  PaginationState,
  SortingState,
  ColumnFiltersState,
} from '@tanstack/react-table'
import { useState } from 'react'

interface UseUsersTableOptions {
  initialPageSize?: number
}

export function useUsersTable({ initialPageSize = 10 }: UseUsersTableOptions = {}) {
  const [sorting, setSorting] = useState<SortingState>([])
  const [columnFilters, setColumnFilters] = useState<ColumnFiltersState>([])
  const [pagination, setPagination] = useState<PaginationState>({
    pageIndex: 0,
    pageSize: initialPageSize,
  })

  // Build query params from table state
  const queryParams = {
    page: pagination.pageIndex + 1,
    pageSize: pagination.pageSize,
    sortBy: sorting[0]?.id,
    sortOrder: sorting[0]?.desc ? 'desc' : 'asc',
    filters: columnFilters.reduce((acc, filter) => {
      acc[filter.id] = filter.value
      return acc
    }, {} as Record<string, unknown>),
  }

  const { data, isLoading, isFetching } = useQuery({
    queryKey: ['users', queryParams],
    queryFn: () => fetchUsers(queryParams),
    placeholderData: (previousData) => previousData,
  })

  return {
    data: data?.users ?? [],
    pageCount: data?.pageCount ?? 0,
    totalCount: data?.totalCount ?? 0,
    isLoading,
    isFetching,
    // Table state
    sorting,
    setSorting,
    columnFilters,
    setColumnFilters,
    pagination,
    setPagination,
  }
}
```

## Table Component

```typescript
// components/users/users-table.tsx
'use client'

import { useUsersTable } from '@/hooks/use-users-table'
import { useReactTable, getCoreRowModel } from '@tanstack/react-table'
import { columns } from './columns'

export function UsersTable() {
  const {
    data,
    pageCount,
    isLoading,
    isFetching,
    sorting,
    setSorting,
    columnFilters,
    setColumnFilters,
    pagination,
    setPagination,
  } = useUsersTable()

  const table = useReactTable({
    data,
    columns,
    pageCount,
    state: {
      sorting,
      columnFilters,
      pagination,
    },
    onSortingChange: setSorting,
    onColumnFiltersChange: setColumnFilters,
    onPaginationChange: setPagination,
    getCoreRowModel: getCoreRowModel(),
    manualPagination: true, // Server-side pagination
    manualSorting: true, // Server-side sorting
    manualFiltering: true, // Server-side filtering
  })

  if (isLoading) return <TableSkeleton />

  return (
    <div className="relative">
      {isFetching && (
        <div className="absolute inset-0 bg-background/50 flex items-center justify-center">
          <Spinner />
        </div>
      )}
      <DataTable table={table} columns={columns} />
    </div>
  )
}
```

## Key Configuration

The critical flags for server-side operations:

```typescript
const table = useReactTable({
  manualPagination: true, // Server handles pagination
  manualSorting: true,    // Server handles sorting
  manualFiltering: true,  // Server handles filtering
  pageCount,              // Total pages from server
})
```
