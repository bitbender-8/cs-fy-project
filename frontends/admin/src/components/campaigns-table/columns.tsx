"use client";

import { $Enums } from "@/generated/prisma";
import { ColumnDef } from "@tanstack/react-table";

export type CampaignTableType = {
  id: string;
  title: string;
  fundraisingGoal: bigint;
  status: $Enums.CampaignStatus;
  category: string;
  endDate: Date | null;
  recipient: string;
};

function TableHeaderFormatter({ headerName }: { headerName: string }) {
  return <p className="font-extrabold">{headerName}</p>;
}

export const campaignTableColumns: ColumnDef<CampaignTableType>[] = [
  {
    accessorKey: "id",
    header: () => <TableHeaderFormatter headerName="ID" />,
    cell: ({ row }) => (
      // row.index is zero‐based, so +1 to start from 1
      <div className="mr-5">{row.index + 1}</div>
    ),
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
