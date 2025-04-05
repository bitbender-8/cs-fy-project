import Image from "next/image";

import { TrendingDownIcon, TrendingUpIcon } from "lucide-react";
import {
  Card,
  CardDescription,
  CardFooter,
  CardHeader,
  CardTitle,
} from "./ui/card";

type DashboardCardProps = {
  id: string;
  title: string;
  amount: number;
  icon: string;
  trend: number;
};

export default function DashboardCard({
  id,
  title,
  amount,
  icon,
  trend,
}: DashboardCardProps) {
  return (
    <Card className="@container/card w-[310px] rounded-xl py-4">
      <CardHeader className="relative">
        <CardDescription className="text-primary font-semibold">
          {title}
        </CardDescription>
        {/* CardTitle text color should be text-primary if id is campaign, should be text-[D99D81] if donations, and text-[FF8989] if liveCampaigns  */}
        <CardTitle
          className={`text-2xl font-bold mt-2 break-words ${
            id === "donations"
              ? "text-[#D99D81]"
              : id === "live-campaigns"
                ? "text-[#FF8989]"
                : "text-primary"
          }`}
        >
          {id === "donations" ? (
            <span className="font-bold">
              {amount.toLocaleString("en-US", {
                minimumFractionDigits: 2,
                maximumFractionDigits: 2,
              })}{" "}
              <span className="text-[10px]">ETB</span>
            </span>
          ) : (
            <span className="font-bold">{amount}</span>
          )}
        </CardTitle>
        <div className="absolute right-4">
          <Image
            aria-hidden
            src={icon}
            alt={icon}
            width={60}
            height={60}
            className="mx-auto"
          />
        </div>
      </CardHeader>
      <CardFooter className="items-center flex gap-2 font-semibold">
        {trend < 0 ? (
          <>
            <TrendingDownIcon size={24} color="red" /> {trend * -1} Down
          </>
        ) : (
          <>
            <TrendingUpIcon size={24} color="green" /> {trend} Up
          </>
        )}{" "}
        from last week
      </CardFooter>
    </Card>
  );
}
