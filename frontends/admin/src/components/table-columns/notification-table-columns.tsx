"use client";

import { ColumnDef } from "@tanstack/react-table";

export type Notification = {
  id: string;
  subject: string;
  body?: string | null;
  isRead: boolean;
  createdAt: Date;
  //   recipientId?: string | null;
  //   supervisorId?: string | null;
  // Optional: Add Recipient and Supervisor objects if you plan to populate them
  // Recipient?: { name: string; /* other recipient fields */ };
  // Supervisor?: { name: string; /* other supervisor fields */ };
};

function TableHeaderFormatter({ headerName }: { headerName: string }) {
  return <p className="font-extrabold">{headerName}</p>;
}

export const notificationTableColumns: ColumnDef<Notification>[] = [
  {
    accessorKey: "subject",
    header: () => <TableHeaderFormatter headerName="Subject" />,
  },
  {
    accessorKey: "body",
    header: () => <TableHeaderFormatter headerName="Body" />,
    cell: ({ row }) => {
      const body = row.getValue("body");
      return body ? (
        String(body)
      ) : (
        <span className="text-xs text-muted-foreground">N/A</span>
      );
    },
  },
  {
    accessorKey: "createdAt",
    header: () => <TableHeaderFormatter headerName="Created At" />,
    cell: ({ row }) => {
      const date = new Date(row.getValue("createdAt"));
      return date.toLocaleDateString() + " " + date.toLocaleTimeString();
    },
  },
  //   {
  //     accessorKey: "recipientId",
  //     header: "Recipient ID",
  //     cell: ({ row }) => {
  //       const recipientId = row.getValue("recipientId");
  //       return recipientId ? String(recipientId) : <span className="text-xs text-muted-foreground">N/A</span>;
  //     },
  //   },
  //   {
  //     accessorKey: "supervisorId",
  //     header: "Supervisor ID",
  //     cell: ({ row }) => {
  //       const supervisorId = row.getValue("supervisorId");
  //       return supervisorId ? String(supervisorId) : <span className="text-xs text-muted-foreground">N/A</span>;
  //     },
  //   },
];
