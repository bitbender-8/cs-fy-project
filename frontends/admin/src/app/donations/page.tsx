import { DataTableDonationList } from "@/components/data-tables/data-table-donation-list";
import { donationTableColumns } from "@/components/table-columns/donation-table-columns";
import prisma from "@/lib/prisma";

export default async function DonationsPage() {
  const donationsData = await prisma.campaignDonation.findMany({
    select: {
      id: true,
      grossAmount: true,
      serviceFee: true,
      createdAt: true,
      transactionRef: true,
      campaignId: true,
      Campaign: {
        select: {
          title: true,
          Recipient: {
            select: {
              firstName: true,
              lastName: true,
            },
          }
        },
      },
    },
    orderBy: {
      createdAt: "desc",
    },
  });

  const donations = donationsData.map(donation => ({
    ...donation,
    recipientFullName: `${donation.Campaign.Recipient.firstName} ${donation.Campaign.Recipient.lastName}`,
  }));

  return (
    <div>
      <div className="flex justify-between items-center">
        <h1 className="text-primary">Browse Donations</h1>
      </div>

      <DataTableDonationList columns={donationTableColumns} data={donations} />
    </div>
  );
}
