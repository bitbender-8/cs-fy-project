"use client";

import { ColumnDef } from "@tanstack/react-table";

export type Campaign = {
  id: string;
  title: string;
  recipient: string;
  category: string;
  fundraisingGoal: number;
  endDate: string;
};

export const campaigns: Campaign[] = [
  {
    id: "1",
    title: "Campaign 1",
    recipient: "Recipient 1",
    category: "Health",
    fundraisingGoal: 10000,
    endDate: "2023-12-31",
  },
  {
    id: "2",
    title: "Campaign 2",
    recipient: "Recipient 2",
    category: "Education",
    fundraisingGoal: 20000,
    endDate: "2024-01-15",
  },
  {
    id: "3",
    title: "Campaign 3",
    recipient: "Recipient 3",
    category: "Environment",
    fundraisingGoal: 15000,
    endDate: "2024-02-28",
  },
  {
    id: "1",
    title: "Campaign 1",
    recipient: "Recipient 1",
    category: "Health",
    fundraisingGoal: 10000,
    endDate: "2023-12-31",
  },
  {
    id: "2",
    title: "Campaign 2",
    recipient: "Recipient 2",
    category: "Education",
    fundraisingGoal: 20000,
    endDate: "2024-01-15",
  },
  {
    id: "3",
    title: "Campaign 3",
    recipient: "Recipient 3",
    category: "Environment",
    fundraisingGoal: 15000,
    endDate: "2024-02-28",
  },
  {
    id: "1",
    title: "Campaign 1",
    recipient: "Recipient 1",
    category: "Health",
    fundraisingGoal: 10000,
    endDate: "2023-12-31",
  },
  {
    id: "2",
    title: "Campaign 2",
    recipient: "Recipient 2",
    category: "Education",
    fundraisingGoal: 20000,
    endDate: "2024-01-15",
  },
  {
    id: "3",
    title: "Campaign 3",
    recipient: "Recipient 3",
    category: "Environment",
    fundraisingGoal: 15000,
    endDate: "2024-02-28",
  },
  {
    id: "1",
    title: "Campaign 1",
    recipient: "Recipient 1",
    category: "Health",
    fundraisingGoal: 10000,
    endDate: "2023-12-31",
  },
  {
    id: "2",
    title: "Campaign 2",
    recipient: "Recipient 2",
    category: "Education",
    fundraisingGoal: 20000,
    endDate: "2024-01-15",
  },
  {
    id: "3",
    title: "Campaign 2 Campaign 3",
    recipient: "Recipient 3",
    category: "Environment Environment",
    fundraisingGoal: 15000,
    endDate: "2024-02-28",
  },
  {
    id: "1",
    title: "Campaign 1",
    recipient: "Recipient 1",
    category: "Health",
    fundraisingGoal: 10000,
    endDate: "2023-12-31",
  },
  {
    id: "2",
    title: "Campaign 2",
    recipient: "Recipient 2",
    category: "Education",
    fundraisingGoal: 20000,
    endDate: "2024-01-15",
  },
  {
    id: "3",
    title: "Campaign 3",
    recipient: "Recipient 3",
    category: "Environment",
    fundraisingGoal: 15000,
    endDate: "2024-02-28",
  },
  {
    id: "1",
    title: "Campaign 1",
    recipient: "Recipient 1",
    category: "Health",
    fundraisingGoal: 10000,
    endDate: "2023-12-31",
  },
  {
    id: "2",
    title: "Campaign 2",
    recipient: "Recipient 2",
    category: "Education",
    fundraisingGoal: 20000,
    endDate: "2024-01-15",
  },
  {
    id: "3",
    title: "Campaign 3",
    recipient: "Recipient 3",
    category: "Environment",
    fundraisingGoal: 15000,
    endDate: "2024-02-28",
  },
  {
    id: "1",
    title: "Campaign 1",
    recipient: "Recipient 1",
    category: "Health",
    fundraisingGoal: 10000,
    endDate: "2023-12-31",
  },
  {
    id: "2",
    title: "Campaign 2",
    recipient: "Recipient 2",
    category: "Education",
    fundraisingGoal: 20000,
    endDate: "2024-01-15",
  },
  {
    id: "3",
    title: "Campaign 3",
    recipient: "Recipient 3",
    category: "Environment",
    fundraisingGoal: 15000,
    endDate: "2024-02-28",
  },
  {
    id: "1",
    title: "Campaign 1",
    recipient: "Recipient 1",
    category: "Health",
    fundraisingGoal: 10000,
    endDate: "2023-12-31",
  },
  {
    id: "2",
    title: "Campaign 2",
    recipient: "Recipient 2",
    category: "Education",
    fundraisingGoal: 20000,
    endDate: "2024-01-15",
  },
  {
    id: "3",
    title: "Campaign 3",
    recipient: "Recipient 3",
    category: "Environment",
    fundraisingGoal: 15000,
    endDate: "2024-02-28",
  },
];

function TableHeaderFormatter({ headerName }: { headerName: string }) {
  return <p className="font-extrabold">{headerName}</p>;
}

export const campaignTableColumns: ColumnDef<Campaign>[] = [
  {
    accessorKey: "id",
    header: () => <TableHeaderFormatter headerName="ID" />,
  },
  {
    accessorKey: "title",
    header: () => <TableHeaderFormatter headerName="Title" />,
    filterFn: "includesString",
  },
  {
    accessorKey: "recipient",
    header: () => <TableHeaderFormatter headerName="Recipient" />,
    filterFn: "includesString",
  },
  {
    accessorKey: "category",
    header: () => <TableHeaderFormatter headerName="Category" />,
  },
  {
    accessorKey: "fundraisingGoal",

    header: () => <TableHeaderFormatter headerName="Fundraising Goal" />,
    cell: ({ row }) => {
      const value = parseFloat(row.getValue("fundraisingGoal"));
      let formattedValue: string;

      if (value >= 1_000_000) {
        // If the value is 1 million or more, format as "X M"
        formattedValue = `${(value / 1_000_000).toFixed(1)} M`;
      } else if (value >= 1_000) {
        // If the value is 1 thousand or more but less than 1 million, format as "X K"
        formattedValue = `${(value / 1_000).toFixed(1)} K`;
      } else {
        // Otherwise, just show the number with a dollar sign
        formattedValue = `ETB ${value.toLocaleString()}`;
      }

      return <div>{formattedValue}</div>;
    },
  },
  {
    accessorKey: "endDate",
    header: () => <TableHeaderFormatter headerName="End Date" />,
  },
];
