import DashboardCard from "@/components/dashboard-card";
import { DashboardGraph } from "@/components/dashboard-graph";
import prisma from "@/lib/prisma";

export default async function BroswseCampaignsHomePage() {
  const newCampaignsCount = await prisma.campaign.count({
    where: {
      submissionDate: {
        gte: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000), // new campaigns in the last 7 days
      },
    },
  });

  const lastWeekCampaignsCount = await prisma.campaign.findMany({
    where: {
      submissionDate: {
        gte: new Date(Date.now() - 14 * 24 * 60 * 60 * 1000), // campaigns in the week before that
        lte: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000), // new campaigns in the last 7 days
      },
    },
  });

  const totalCampaignsCount = await prisma.campaign.count();

  // Do the same for donations
  const newDonationsCount = await prisma.campaignDonation.count({
    where: {
      createdAt: {
        gte: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000), // new donations in the last 7 days
      },
    },
  });
  const lastWeekDonationsCount = await prisma.campaignDonation.findMany({
    where: {
      createdAt: {
        gte: new Date(Date.now() - 14 * 24 * 60 * 60 * 1000), // donations in the week before that
        lte: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000), // new donations in the last 7 days
      },
    },
  });

  const totalDonationsSum = await prisma.campaignDonation.aggregate({
    _sum: {
      grossAmount: true,
    },
  });

  // Do the same for live campaigns
  const newLiveCampaignsCount = await prisma.campaign.count({
    where: {
      submissionDate: {
        gte: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000), // new live campaigns in the last 7 days
      },
      status: "Live",
    },
  });

  const lastWeekLiveCampaignsCount = await prisma.campaign.findMany({
    where: {
      submissionDate: {
        gte: new Date(Date.now() - 14 * 24 * 60 * 60 * 1000), // live campaigns in the week before that
        lte: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000), // new live campaigns in the last 7 days
      },
      status: "Live",
    },
  });

  const totalLiveCampaignsCount = await prisma.campaign.count({
    where: {
      status: "Live",
    },
  });

  // create a dashboardCardsList with the data from the database
  const dashboardCardsListWithData = [
    {
      id: "campaigns",
      title: "Total Campaigns",
      amount: totalCampaignsCount,
      icon: "/icons/people-dashboard-icon.svg",
      trend:
        // if there are no last week campaigns, set the trend to 0
        lastWeekCampaignsCount.length === 0
          ? 0
          : ((newCampaignsCount - lastWeekCampaignsCount.length) /
              lastWeekCampaignsCount.length) *
            100,
    },
    {
      id: "donations",
      title: "Total Donations",
      amount: totalDonationsSum._sum.grossAmount || 0,
      icon: "/icons/graph-dashboard-icon.svg",
      trend:
        lastWeekDonationsCount.length === 0
          ? 0
          : ((newDonationsCount - lastWeekDonationsCount.length) /
              lastWeekDonationsCount.length) *
            100,
    },
    {
      id: "live-campaigns",
      title: "Total Live Campaigns",
      amount: totalLiveCampaignsCount,
      icon: "/icons/live-dashboard-icon.svg",
      trend:
        lastWeekLiveCampaignsCount.length === 0
          ? 0
          : ((newLiveCampaignsCount - lastWeekLiveCampaignsCount.length) /
              lastWeekLiveCampaignsCount.length) *
            100,
    },
  ];

  // get the chart data for the last 3 months
  const rawDonations = await prisma.campaignDonation.findMany({
    where: {
      createdAt: {
        gte: new Date(Date.now() - 90 * 24 * 60 * 60 * 1000), // donations in the last 3 months
      },
    },
    select: {
      createdAt: true,
      grossAmount: true,
    },
    orderBy: {
      createdAt: "asc",
    },
  });

  // convert the raw donations to a map with the date as key and the amount as value
  // and sum the amounts for each date
  const mapDonations = new Map<string, number>();
  for (const { createdAt, grossAmount } of rawDonations) {
    const day = createdAt.toISOString().slice(0, 10); // "2025-04-23"
    mapDonations.set(day, (mapDonations.get(day) ?? 0) + Number(grossAmount));
  }

  // convert the map to an array of objects with date and amount properties
  const aggregatedDonations = Array.from(mapDonations.entries())
    .map(([date, amount]) => ({ date, amount }))
    .sort((a, b) => a.date.localeCompare(b.date));

  return (
    <div>
      <div className="flex justify-between items-center">
        <h1 className="text-primary">Dashboard</h1>
      </div>

      <div className="flex justify-between">
        {dashboardCardsListWithData.map((card) => (
          <DashboardCard
            key={card.id}
            id={card.id}
            title={card.title}
            amount={card.amount}
            icon={card.icon}
            trend={card.trend}
          />
        ))}
      </div>

      <div className="mt-5">
        <DashboardGraph initialData={aggregatedDonations} />
      </div>
    </div>
  );
}
