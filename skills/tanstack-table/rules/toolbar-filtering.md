# Toolbar with Filtering

Data table toolbar with search input, faceted filters, and view options.

## Implementation

```typescript
// components/ui/data-table-toolbar.tsx
'use client'

import { Table } from '@tanstack/react-table'
import { X } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { DataTableViewOptions } from './data-table-view-options'
import { DataTableFacetedFilter } from './data-table-faceted-filter'

interface DataTableToolbarProps<TData> {
  table: Table<TData>
}

const statuses = [
  { label: 'Active', value: 'active' },
  { label: 'Inactive', value: 'inactive' },
]

const roles = [
  { label: 'Admin', value: 'admin' },
  { label: 'User', value: 'user' },
  { label: 'Viewer', value: 'viewer' },
]

export function DataTableToolbar<TData>({
  table,
}: DataTableToolbarProps<TData>) {
  const isFiltered = table.getState().columnFilters.length > 0

  return (
    <div className="flex items-center justify-between">
      <div className="flex flex-1 items-center space-x-2">
        {/* Global search */}
        <Input
          placeholder="Search by name..."
          value={(table.getColumn('name')?.getFilterValue() as string) ?? ''}
          onChange={(event) =>
            table.getColumn('name')?.setFilterValue(event.target.value)
          }
          className="h-8 w-[150px] lg:w-[250px]"
        />

        {/* Faceted filters */}
        {table.getColumn('status') && (
          <DataTableFacetedFilter
            column={table.getColumn('status')}
            title="Status"
            options={statuses}
          />
        )}
        {table.getColumn('role') && (
          <DataTableFacetedFilter
            column={table.getColumn('role')}
            title="Role"
            options={roles}
          />
        )}

        {/* Reset filters */}
        {isFiltered && (
          <Button
            variant="ghost"
            onClick={() => table.resetColumnFilters()}
            className="h-8 px-2 lg:px-3"
          >
            Reset
            <X className="ml-2 h-4 w-4" />
          </Button>
        )}
      </div>

      {/* Column visibility */}
      <DataTableViewOptions table={table} />
    </div>
  )
}
```

## Global Filter Pattern

For searching across all columns:

```typescript
const [globalFilter, setGlobalFilter] = useState('')

const table = useReactTable({
  // ...
  globalFilterFn: 'includesString',
  onGlobalFilterChange: setGlobalFilter,
  state: {
    globalFilter,
  },
})

// Search input
<Input
  value={globalFilter ?? ''}
  onChange={(e) => setGlobalFilter(e.target.value)}
  placeholder="Search all columns..."
/>
```
