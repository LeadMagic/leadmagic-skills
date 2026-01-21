---
name: tanstack-table
description: TanStack Table for building powerful data tables and datagrids. Use when implementing sortable tables, filterable data grids, paginated lists, or column management. Triggers on "data table", "TanStack Table", "useReactTable", "sorting", "filtering", "pagination", "datagrid".
license: LeadMagic Proprietary
metadata:
  author: leadmagic
  version: "1.2.0"
---

# TanStack Table

Comprehensive guide for building powerful, headless data tables with TanStack Table v8. Covers sorting, filtering, pagination, column visibility, row selection, and integration with shadcn/ui.

## When to Apply

Reference these guidelines when:
- Building data tables with sorting/filtering
- Implementing server-side pagination
- Creating admin dashboards with data grids
- Adding column visibility toggles
- Implementing row selection
- Building exportable data views

## Rule Categories by Priority

| Priority | Category | Impact | Prefix |
|----------|----------|--------|--------|
| 1 | Table Setup | CRITICAL | `setup-` |
| 2 | Sorting & Filtering | HIGH | `filter-` |
| 3 | Pagination | HIGH | `pagination-` |
| 4 | Column Features | MEDIUM | `column-` |
| 5 | Row Selection | MEDIUM | `selection-` |

## Quick Reference

### 1. Table Setup (CRITICAL)

- `setup-columns` - Define columns with proper typing
- `setup-data` - Provide data with stable references

### 2. Sorting & Filtering (HIGH)

- `filter-column` - Column-level filtering
- `filter-global` - Global search across columns

### 3. Pagination (HIGH)

- `pagination-client` - Client-side pagination
- `pagination-server` - Server-side pagination with TanStack Query

---

## Installation

```bash
npm install @tanstack/react-table
```

---

## Basic Table Setup

### Define Columns

```typescript
// components/users/columns.tsx
'use client'

import { ColumnDef } from '@tanstack/react-table'
import { Badge } from '@/components/ui/badge'
import { Checkbox } from '@/components/ui/checkbox'
import { DataTableColumnHeader } from '@/components/ui/data-table-column-header'
import { DataTableRowActions } from './data-table-row-actions'

export type User = {
  id: string
  name: string
  email: string
  role: 'admin' | 'user' | 'viewer'
  status: 'active' | 'inactive'
  createdAt: Date
}

export const columns: ColumnDef<User>[] = [
  // Selection column
  {
    id: 'select',
    header: ({ table }) => (
      <Checkbox
        checked={
          table.getIsAllPageRowsSelected() ||
          (table.getIsSomePageRowsSelected() && 'indeterminate')
        }
        onCheckedChange={(value) => table.toggleAllPageRowsSelected(!!value)}
        aria-label="Select all"
      />
    ),
    cell: ({ row }) => (
      <Checkbox
        checked={row.getIsSelected()}
        onCheckedChange={(value) => row.toggleSelected(!!value)}
        aria-label="Select row"
      />
    ),
    enableSorting: false,
    enableHiding: false,
  },

  // Name column with sorting
  {
    accessorKey: 'name',
    header: ({ column }) => (
      <DataTableColumnHeader column={column} title="Name" />
    ),
    cell: ({ row }) => (
      <div className="font-medium">{row.getValue('name')}</div>
    ),
  },

  // Email column
  {
    accessorKey: 'email',
    header: ({ column }) => (
      <DataTableColumnHeader column={column} title="Email" />
    ),
    cell: ({ row }) => (
      <div className="lowercase">{row.getValue('email')}</div>
    ),
  },

  // Role column with badge and filter
  {
    accessorKey: 'role',
    header: 'Role',
    cell: ({ row }) => {
      const role = row.getValue('role') as string
      return (
        <Badge variant={role === 'admin' ? 'default' : 'secondary'}>
          {role}
        </Badge>
      )
    },
    filterFn: (row, id, value) => {
      return value.includes(row.getValue(id))
    },
  },

  // Actions column
  {
    id: 'actions',
    cell: ({ row }) => <DataTableRowActions row={row} />,
  },
]
```

### Create Data Table Component

```typescript
// components/ui/data-table.tsx
'use client'

import {
  ColumnDef,
  ColumnFiltersState,
  SortingState,
  VisibilityState,
  flexRender,
  getCoreRowModel,
  getFilteredRowModel,
  getPaginationRowModel,
  getSortedRowModel,
  useReactTable,
} from '@tanstack/react-table'
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table'
import { useState } from 'react'

interface DataTableProps<TData, TValue> {
  columns: ColumnDef<TData, TValue>[]
  data: TData[]
}

export function DataTable<TData, TValue>({
  columns,
  data,
}: DataTableProps<TData, TValue>) {
  const [sorting, setSorting] = useState<SortingState>([])
  const [columnFilters, setColumnFilters] = useState<ColumnFiltersState>([])
  const [columnVisibility, setColumnVisibility] = useState<VisibilityState>({})
  const [rowSelection, setRowSelection] = useState({})

  const table = useReactTable({
    data,
    columns,
    getCoreRowModel: getCoreRowModel(),
    getPaginationRowModel: getPaginationRowModel(),
    getSortedRowModel: getSortedRowModel(),
    getFilteredRowModel: getFilteredRowModel(),
    onSortingChange: setSorting,
    onColumnFiltersChange: setColumnFilters,
    onColumnVisibilityChange: setColumnVisibility,
    onRowSelectionChange: setRowSelection,
    state: {
      sorting,
      columnFilters,
      columnVisibility,
      rowSelection,
    },
  })

  return (
    <div className="rounded-md border">
      <Table>
        <TableHeader>
          {table.getHeaderGroups().map((headerGroup) => (
            <TableRow key={headerGroup.id}>
              {headerGroup.headers.map((header) => (
                <TableHead key={header.id}>
                  {header.isPlaceholder
                    ? null
                    : flexRender(
                        header.column.columnDef.header,
                        header.getContext()
                      )}
                </TableHead>
              ))}
            </TableRow>
          ))}
        </TableHeader>
        <TableBody>
          {table.getRowModel().rows?.length ? (
            table.getRowModel().rows.map((row) => (
              <TableRow
                key={row.id}
                data-state={row.getIsSelected() && 'selected'}
              >
                {row.getVisibleCells().map((cell) => (
                  <TableCell key={cell.id}>
                    {flexRender(
                      cell.column.columnDef.cell,
                      cell.getContext()
                    )}
                  </TableCell>
                ))}
              </TableRow>
            ))
          ) : (
            <TableRow>
              <TableCell
                colSpan={columns.length}
                className="h-24 text-center"
              >
                No results.
              </TableCell>
            </TableRow>
          )}
        </TableBody>
      </Table>
    </div>
  )
}
```

---

## Common Mistakes

| Mistake | Problem | Fix |
|---------|---------|-----|
| Unstable data reference | Infinite re-renders | Memoize data or use stable source |
| Missing `accessorKey` | Can't access cell value | Add accessorKey or accessorFn |
| Wrong filter function | Filtering doesn't work | Match filterFn to data type |
| No manual flags for server | Client/server mismatch | Set manualPagination/Sorting/Filtering |
| Large datasets client-side | Performance issues | Use server-side pagination |

---

## Best Practices

### Do

- Use query key factories with TanStack Query
- Memoize column definitions with `useMemo`
- Implement server-side operations for large datasets
- Provide loading states during fetches
- Use proper TypeScript types for columns
- Add keyboard navigation for accessibility

### Don't

- Don't mutate data directly
- Don't skip loading/error states
- Don't use client pagination for >1000 rows
- Don't forget to handle empty states
- Don't ignore mobile responsiveness

---

## How to Use

Read individual rule files for detailed patterns:

```
rules/column-header.md      - Sortable column headers
rules/toolbar-filtering.md  - Toolbar with filters
rules/faceted-filter.md     - Multi-select faceted filters
rules/pagination.md         - Client & server pagination
rules/server-side.md        - Server-side with TanStack Query
rules/row-actions.md        - Row action menus
rules/column-visibility.md  - Column show/hide
rules/bulk-actions.md       - Bulk operations with selection
```

## Resources

- [TanStack Table Documentation](https://tanstack.com/table/latest)
- [shadcn/ui Data Table](https://ui.shadcn.com/docs/components/data-table)
- [Column Definitions](https://tanstack.com/table/latest/docs/guide/column-defs)
- [Pagination Guide](https://tanstack.com/table/latest/docs/guide/pagination)
