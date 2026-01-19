# Row Actions

Dropdown menu for row-level actions like edit, delete, copy.

## Implementation

```typescript
// components/users/data-table-row-actions.tsx
import { Row } from '@tanstack/react-table'
import { MoreHorizontal, Pencil, Trash, Copy } from 'lucide-react'
import { Button } from '@/components/ui/button'
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu'
import { User } from './columns'

interface DataTableRowActionsProps {
  row: Row<User>
}

export function DataTableRowActions({ row }: DataTableRowActionsProps) {
  const user = row.original

  return (
    <DropdownMenu>
      <DropdownMenuTrigger asChild>
        <Button variant="ghost" className="h-8 w-8 p-0">
          <span className="sr-only">Open menu</span>
          <MoreHorizontal className="h-4 w-4" />
        </Button>
      </DropdownMenuTrigger>
      <DropdownMenuContent align="end">
        <DropdownMenuItem
          onClick={() => navigator.clipboard.writeText(user.id)}
        >
          <Copy className="mr-2 h-4 w-4" />
          Copy ID
        </DropdownMenuItem>
        <DropdownMenuSeparator />
        <DropdownMenuItem>
          <Pencil className="mr-2 h-4 w-4" />
          Edit
        </DropdownMenuItem>
        <DropdownMenuItem className="text-destructive">
          <Trash className="mr-2 h-4 w-4" />
          Delete
        </DropdownMenuItem>
      </DropdownMenuContent>
    </DropdownMenu>
  )
}
```

## Column Definition

```typescript
// In columns.tsx
{
  id: 'actions',
  cell: ({ row }) => <DataTableRowActions row={row} />,
}
```
