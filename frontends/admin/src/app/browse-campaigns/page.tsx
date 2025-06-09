import BroswseCampaignsTableHolder from "@/components/browse-campaigns-table-holder";
import { CampaignTableType } from "@/components/table-columns/campaign-table-columns";
import prisma from "@/lib/prisma";

export default async function BroswseCampaignsHomePage() {
  const rawCampaigns = await prisma.campaign.findMany({
    select: {
      id: true,
      title: true,
      category: true,
      fundraisingGoal: true,
      status: true,
      endDate: true,

      Recipient: {
        select: {
          firstName: true,
          middleName: true,
          lastName: true,
        },
      },
    },
    orderBy: {
      endDate: "desc",
    },
  });

  const campaigns: CampaignTableType[] = rawCampaigns.map(
    ({ Recipient, ...rest }) => ({
      ...rest,
      recipient:
        Recipient.firstName +
        " " +
        Recipient.middleName +
        " " +
        Recipient.lastName,
    }),
  );

  return (
    <div>
      <div className="flex justify-between items-center">
        <h1 className="text-primary">Browse Campaigns</h1>
      </div>

      <BroswseCampaignsTableHolder campaigns={campaigns} />
    </div>
  );
}
