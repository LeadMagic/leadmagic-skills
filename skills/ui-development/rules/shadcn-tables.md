---
title: Data Tables with TanStack Table
impact: HIGH
impactDescription: Feature-rich data tables with sorting, filtering, pagination
tags: tables, tanstack, data-grid, pagination
---

## Data Tables with TanStack Table

shadcn/ui uses TanStack Table (formerly React Table) for data tables.

**Installation:**

```bash
npm install @tanstack/react-table

# Add shadcn table components
npx shadcn@latest add table
```

**Basic Table Setup:**

```typescript
'use client'

import {
  ColumnDef,
  flexRender,
  getCoreRowModel,
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

interface DataTableProps<TData, TValue> {
  columns: ColumnDef<TData, TValue>[]
  data: TData[]
}

export function DataTable<TData, TValue>({
  columns,
  data,
}: DataTableProps<TData, TValue>) {
  const table = useReactTable({
    data,
    columns,
    getCoreRowModel: getCoreRowModel(),
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
              <TableRow key={row.id}>
                {row.getVisibleCells().map((cell) => (
                  <TableCell key={cell.id}>
                    {flexRender(cell.column.columnDef.cell, cell.getContext())}
                  </TableCell>
                ))}
              </TableRow>
            ))
          ) : (
            <TableRow>
              <TableCell colSpan={columns.length} className="h-24 text-center">
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

**Column Definitions:**

```typescript
import { ColumnDef } from '@tanstack/react-table'

interface User {
  id: string
  name: string
  email: string
  status: 'active' | 'inactive'
  createdAt: Date
}

export const columns: ColumnDef<User>[] = [
  // Simple column
  {
    accessorKey: 'name',
    header: 'Name',
  },

  // With custom cell
  {
    accessorKey: 'email',
    header: 'Email',
    cell: ({ row }) => (
      <a href={`mailto:${row.getValue('email')}`} className="text-primary">
        {row.getValue('email')}
      </a>
    ),
  },

  // With badge
  {
    accessorKey: 'status',
    header: 'Status',
    cell: ({ row }) => {
      const status = row.getValue('status') as string
      return (
        <Badge variant={status === 'active' ? 'default' : 'secondary'}>
          {status}
        </Badge>
      )
    },
  },

  // Formatted date
  {
    accessorKey: 'createdAt',
    header: 'Created',
    cell: ({ row }) => format(row.getValue('createdAt'), 'PPP'),
  },

  // Actions column
  {
    id: 'actions',
    cell: ({ row }) => {
      const user = row.original
      return (
        <DropdownMenu>
          <DropdownMenuTrigger asChild>
            <Button variant="ghost" size="icon">
              <MoreHorizontal className="h-4 w-4" />
            </Button>
          </DropdownMenuTrigger>
          <DropdownMenuContent align="end">
            <DropdownMenuItem onClick={() => copyId(user.id)}>
              Copy ID
            </DropdownMenuItem>
            <DropdownMenuItem onClick={() => editUser(user)}>
              Edit
            </DropdownMenuItem>
            <DropdownMenuSeparator />
            <DropdownMenuItem
              onClick={() => deleteUser(user.id)}
              className="text-destructive"
            >
              Delete
            </DropdownMenuItem>
          </DropdownMenuContent>
        </DropdownMenu>
      )
    },
  },
]
```

**Sorting:**

```typescript
import {
  getSortedRowModel,
  SortingState,
} from '@tanstack/react-table'
import { ArrowUpDown } from 'lucide-react'

export function DataTable({ columns, data }) {
  const [sorting, setSorting] = useState<SortingState>([])

  const table = useReactTable({
    data,
    columns,
    getCoreRowModel: getCoreRowModel(),
    getSortedRowModel: getSortedRowModel(),
    onSortingChange: setSorting,
    state: { sorting },
  })

  // ...
}

// Sortable column header
{
  accessorKey: 'name',
  header: ({ column }) => (
    <Button
      variant="ghost"
      onClick={() => column.toggleSorting(column.getIsSorted() === 'asc')}
    >
      Name
      <ArrowUpDown className="ml-2 h-4 w-4" />
    </Button>
  ),
}
```

**Filtering:**

```typescript
import {
  getFilteredRowModel,
  ColumnFiltersState,
} from '@tanstack/react-table'

export function DataTable({ columns, data }) {
  const [columnFilters, setColumnFilters] = useState<ColumnFiltersState>([])

  const table = useReactTable({
    data,
    columns,
    getCoreRowModel: getCoreRowModel(),
    getFilteredRowModel: getFilteredRowModel(),
    onColumnFiltersChange: setColumnFilters,
    state: { columnFilters },
  })

  return (
    <div>
      <div className="flex items-center py-4">
        <Input
          placeholder="Filter by email..."
          value={(table.getColumn('email')?.getFilterValue() as string) ?? ''}
          onChange={(e) =>
            table.getColumn('email')?.setFilterValue(e.target.value)
          }
          className="max-w-sm"
        />
      </div>
      {/* Table */}
    </div>
  )
}
```

**Pagination:**

```typescript
import { getPaginationRowModel } from '@tanstack/react-table'

export function DataTable({ columns, data }) {
  const table = useReactTable({
    data,
    columns,
    getCoreRowModel: getCoreRowModel(),
    getPaginationRowModel: getPaginationRowModel(),
  })

  return (
    <div>
      {/* Table */}

      <div className="flex items-center justify-end space-x-2 py-4">
        <div className="text-sm text-muted-foreground">
          Page {table.getState().pagination.pageIndex + 1} of{' '}
          {table.getPageCount()}
        </div>
        <Button
          variant="outline"
          size="sm"
          onClick={() => table.previousPage()}
          disabled={!table.getCanPreviousPage()}
        >
          Previous
        </Button>
        <Button
          variant="outline"
          size="sm"
          onClick={() => table.nextPage()}
          disabled={!table.getCanNextPage()}
        >
          Next
        </Button>
      </div>
    </div>
  )
}
```

**Row Selection:**

```typescript
import { Checkbox } from '@/components/ui/checkbox'

// Add selection column
const columns: ColumnDef<User>[] = [
  {
    id: 'select',
    header: ({ table }) => (
      <Checkbox
        checked={table.getIsAllPageRowsSelected()}
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
  // ... other columns
]

// Enable row selection
const table = useReactTable({
  data,
  columns,
  getCoreRowModel: getCoreRowModel(),
  onRowSelectionChange: setRowSelection,
  state: { rowSelection },
})

// Get selected rows
const selectedRows = table.getFilteredSelectedRowModel().rows
```

**Server-Side Pagination:**

```typescript
interface PaginatedResponse<T> {
  data: T[]
  pageCount: number
  total: number
}

export function DataTable({ fetchData }) {
  const [pagination, setPagination] = useState({ pageIndex: 0, pageSize: 10 })

  const { data, isLoading } = useQuery({
    queryKey: ['users', pagination],
    queryFn: () => fetchData(pagination),
  })

  const table = useReactTable({
    data: data?.data ?? [],
    columns,
    pageCount: data?.pageCount ?? -1,
    manualPagination: true, // Server-side pagination
    getCoreRowModel: getCoreRowModel(),
    onPaginationChange: setPagination,
    state: { pagination },
  })
}
```
