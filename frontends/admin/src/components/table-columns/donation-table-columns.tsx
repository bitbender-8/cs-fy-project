"use client";

import { ColumnDef } from "@tanstack/react-table";

function TableHeaderFormatter({ headerName }: { headerName: string }) {
  return <p className="font-extrabold">{headerName}</p>;
}

export type DonationTableType = {
  id: string;
  grossAmount: bigint;
  serviceFee: bigint;
  createdAt: Date;
  transactionRef: string;
  campaignId: string;
  campaignTitle?: string;
  campaignRecipientFirstName?: string;
  campaignRecipientLastName?: string;
};

export const donationTableColumns: ColumnDef<DonationTableType>[] = [
  {
    accessorKey: "Campaign.title",
    header: () => <TableHeaderFormatter headerName="Campaign Title" />,
    filterFn: "includesString",
  },
  {
    accessorKey: "recipientFullName",
    header: () => <TableHeaderFormatter headerName="Recipient Name" />,
    filterFn: "includesString",
  },
  {
    accessorKey: "grossAmount",
    header: () => <TableHeaderFormatter headerName="Gross Amount" />,
    cell: ({ row }) => {
      const value = parseFloat(row.getValue("grossAmount"));
      let formattedValue: string;

      if (value >= 1_000_000) {
        formattedValue = `ETB ${(value / 1_000_000).toFixed(1)} M`;
      } else if (value >= 1_000) {
        formattedValue = `ETB ${(value / 1_000).toFixed(1)} K`;
      } else {
        formattedValue = `ETB ${value.toLocaleString()}`;
      }
      return <div>{formattedValue}</div>;
    },
  },
  {
    accessorKey: "serviceFee",
    header: () => <TableHeaderFormatter headerName="Service Fee" />,
    cell: ({ row }) => {
      const value = parseFloat(row.getValue("serviceFee"));
      let formattedValue: string;

      if (value >= 1_000_000) {
        formattedValue = `ETB ${(value / 1_000_000).toFixed(1)} M`;
      } else if (value >= 1_000) {
        formattedValue = `ETB ${(value / 1_000).toFixed(1)} K`;
      } else {
        formattedValue = `ETB ${value.toLocaleString()}`;
      }
      return <div>{formattedValue}</div>;
    },
  },
  {
    accessorKey: "createdAt",
    header: () => <TableHeaderFormatter headerName="Donation Date" />,
    cell: ({ row }) => {
      const date = new Date(row.getValue("createdAt"));
      return <div>{date.toLocaleDateString()}</div>; // Or any other date formatting you prefer
    },
  },
];

export const donationTableSpecificCampaignColumns: ColumnDef<DonationTableType>[] =
  [
    {
      accessorKey: "transactionRef",
      header: () => <TableHeaderFormatter headerName="Transaction Ref" />,
      filterFn: "includesString",
    },
    {
      accessorKey: "grossAmount",
      header: () => <TableHeaderFormatter headerName="Gross Amount" />,
      cell: ({ row }) => {
        const value = parseFloat(row.getValue("grossAmount"));
        let formattedValue: string;

        if (value >= 1_000_000) {
          formattedValue = `ETB ${(value / 1_000_000).toFixed(1)} M`;
        } else if (value >= 1_000) {
          formattedValue = `ETB ${(value / 1_000).toFixed(1)} K`;
        } else {
          formattedValue = `ETB ${value.toLocaleString()}`;
        }
        return <div>{formattedValue}</div>;
      },
    },
    {
      accessorKey: "serviceFee",
      header: () => <TableHeaderFormatter headerName="Service Fee" />,
      cell: ({ row }) => {
        const value = parseFloat(row.getValue("serviceFee"));
        let formattedValue: string;

        if (value >= 1_000_000) {
          formattedValue = `ETB ${(value / 1_000_000).toFixed(1)} M`;
        } else if (value >= 1_000) {
          formattedValue = `ETB ${(value / 1_000).toFixed(1)} K`;
        } else {
          formattedValue = `ETB ${value.toLocaleString()}`;
        }
        return <div>{formattedValue}</div>;
      },
    },
    {
      accessorKey: "createdAt",
      header: () => <TableHeaderFormatter headerName="Donation Date" />,
      cell: ({ row }) => {
        const date = new Date(row.getValue("createdAt"));
        return <div>{date.toLocaleDateString()}</div>;
      },
    },
  ];
