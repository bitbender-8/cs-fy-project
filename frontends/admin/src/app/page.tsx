import DashboardCard from "@/components/dashboard-card";
import { DashboardGraph } from "@/components/dashboard-graph";

const dashboardCardsList = [
  {
    id: "campaigns",
    title: "Total Campaigns",
    amount: 398,
    icon: "/icons/people-dashboard-icon.svg",
    trend: 8.5,
  },
  {
    id: "donations",
    title: "Total Donations",
    amount: 3578987,
    icon: "/icons/graph-dashboard-icon.svg",
    trend: 2.5,
  },
  {
    id: "live-campaigns",
    title: "Total Live Campaigns",
    amount: 15,
    icon: "/icons/live-dashboard-icon.svg",
    trend: -4.3,
  },
];

export default function BroswseCampaignsHomePage() {
  return (
    <div>
      <div className="flex justify-between items-center">
        <h1 className="text-primary">Dashboard</h1>
      </div>

      <div className="flex justify-between">
        {dashboardCardsList.map((card) => (
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
        <DashboardGraph />
      </div>
    </div>
  );
}
