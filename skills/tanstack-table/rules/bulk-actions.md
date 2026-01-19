# Bulk Actions with Row Selection

Perform operations on multiple selected rows.

## Implementation

```typescript
function DataTableWithBulkActions<TData>({ table }: { table: Table<TData> }) {
  const selectedRows = table.getFilteredSelectedRowModel().rows

  const handleBulkDelete = async () => {
    const ids = selectedRows.map((row) => row.original.id)
    await deleteUsers(ids)
    table.resetRowSelection()
  }

  const handleBulkExport = () => {
    const data = selectedRows.map((row) => row.original)
    exportToCSV(data)
  }

  return (
    <div className="flex items-center gap-2">
      {selectedRows.length > 0 && (
        <>
          <span className="text-sm text-muted-foreground">
            {selectedRows.length} selected
          </span>
          <Button variant="outline" size="sm" onClick={handleBulkExport}>
            Export
          </Button>
          <Button variant="destructive" size="sm" onClick={handleBulkDelete}>
            Delete
          </Button>
        </>
      )}
    </div>
  )
}
```

## Selection Column

```typescript
// In columns definition
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
}
```

## Expandable Rows

For showing additional details:

```typescript
const columns: ColumnDef<Order>[] = [
  {
    id: 'expander',
    header: () => null,
    cell: ({ row }) => (
      <Button
        variant="ghost"
        size="sm"
        onClick={() => row.toggleExpanded()}
      >
        {row.getIsExpanded() ? '▼' : '▶'}
      </Button>
    ),
  },
  // ... other columns
]

// In table body
{row.getIsExpanded() && (
  <TableRow>
    <TableCell colSpan={columns.length}>
      <OrderDetails order={row.original} />
    </TableCell>
  </TableRow>
)}
```
