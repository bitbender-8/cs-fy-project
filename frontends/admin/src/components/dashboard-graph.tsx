"use client";

import * as React from "react";
import { CartesianGrid, Line, LineChart, XAxis, YAxis } from "recharts";

import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import {
  ChartConfig,
  ChartContainer,
  ChartTooltip,
  ChartTooltipContent,
} from "@/components/ui/chart";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";

const chartData = [
  { date: "2024-04-01", amount: 22232 },
  { date: "2024-04-02", amount: 9712 },
  { date: "2024-04-03", amount: 16732 },
  { date: "2024-04-04", amount: 24221 },
  { date: "2024-04-05", amount: 373123 },
  { date: "2024-04-06", amount: 30211 },
  { date: "2024-04-07", amount: 24521 },
  { date: "2024-04-08", amount: 409312 },
  { date: "2024-04-09", amount: 59213 },
  { date: "2024-04-10", amount: 261213 },
  { date: "2024-04-11", amount: 327321 },
  { date: "2024-04-12", amount: 292213 },
  { date: "2024-04-13", amount: 342123 },
  { date: "2024-04-14", amount: 13721 },
  { date: "2024-04-15", amount: 12021 },
  { date: "2024-04-16", amount: 13832 },
  { date: "2024-04-17", amount: 446312 },
  { date: "2024-04-18", amount: 364213 },
  { date: "2024-04-19", amount: 24312 },
  { date: "2024-04-20", amount: 8912 },
  { date: "2024-04-21", amount: 13721 },
  { date: "2024-04-22", amount: 22421 },
  { date: "2024-04-23", amount: 13832 },
  { date: "2024-04-24", amount: 387213 },
  { date: "2024-04-25", amount: 21521 },
  { date: "2024-04-26", amount: 7512 },
  { date: "2024-04-27", amount: 383312 },
  { date: "2024-04-28", amount: 12221 },
  { date: "2024-04-29", amount: 31521 },
  { date: "2024-04-30", amount: 454312 },
  { date: "2024-05-01", amount: 16521 },
  { date: "2024-05-02", amount: 29321 },
  { date: "2024-05-03", amount: 24721 },
  { date: "2024-05-04", amount: 385312 },
  { date: "2024-05-05", amount: 481312 },
  { date: "2024-05-06", amount: 498312 },
  { date: "2024-05-07", amount: 38821 },
  { date: "2024-05-08", amount: 14921 },
  { date: "2024-05-09", amount: 22721 },
  { date: "2024-05-10", amount: 29332 },
  { date: "2024-05-11", amount: 33512 },
  { date: "2024-05-12", amount: 19721 },
  { date: "2024-05-13", amount: 19732 },
  { date: "2024-05-14", amount: 448312 },
  { date: "2024-05-15", amount: 473312 },
  { date: "2024-05-16", amount: 33812 },
  { date: "2024-05-17", amount: 499312 },
  { date: "2024-05-18", amount: 31512 },
  { date: "2024-05-19", amount: 23512 },
  { date: "2024-05-20", amount: 17732 },
  { date: "2024-05-21", amount: 8212 },
  { date: "2024-05-22", amount: 8121 },
  { date: "2024-05-23", amount: 252213 },
  { date: "2024-05-24", amount: 294213 },
  { date: "2024-05-25", amount: 20121 },
  { date: "2024-05-26", amount: 21321 },
  { date: "2024-05-27", amount: 420312 },
  { date: "2024-05-28", amount: 23321 },
  { date: "2024-05-29", amount: 7812 },
  { date: "2024-05-30", amount: 340213 },
  { date: "2024-05-31", amount: 17821 },
  { date: "2024-06-01", amount: 17821 },
  { date: "2024-06-02", amount: 470312 },
  { date: "2024-06-03", amount: 10321 },
  { date: "2024-06-04", amount: 439312 },
  { date: "2024-06-05", amount: 8121 },
  { date: "2024-06-06", amount: 294213 },
  { date: "2024-06-07", amount: 323312 },
  { date: "2024-06-08", amount: 385213 },
  { date: "2024-06-09", amount: 438312 },
  { date: "2024-06-10", amount: 15521 },
  { date: "2024-06-11", amount: 9212 },
  { date: "2024-06-12", amount: 492312 },
  { date: "2024-06-13", amount: 8121 },
  { date: "2024-06-14", amount: 426312 },
  { date: "2024-06-15", amount: 30721 },
  { date: "2024-06-16", amount: 37121 },
  { date: "2024-06-17", amount: 475312 },
  { date: "2024-06-18", amount: 10721 },
  { date: "2024-06-19", amount: 34121 },
  { date: "2024-06-20", amount: 408312 },
  { date: "2024-06-21", amount: 16912 },
  { date: "2024-06-22", amount: 31721 },
  { date: "2024-06-23", amount: 480312 },
  { date: "2024-06-24", amount: 13221 },
  { date: "2024-06-25", amount: 14121 },
  { date: "2024-06-26", amount: 434312 },
  { date: "2024-06-27", amount: 448312 },
  { date: "2024-06-28", amount: 14921 },
  { date: "2024-06-29", amount: 10321 },
  { date: "2024-06-30", amount: 446312 },
];

const chartConfig = {
  amount: {
    label: "Donations",
  },
} satisfies ChartConfig;

export function DashboardGraph() {
  const [timeRange, setTimeRange] = React.useState("90d");

  const filteredData = chartData.filter((item) => {
    const date = new Date(item.date);
    const referenceDate = new Date("2024-06-30");
    let daysToSubtract = 90;
    if (timeRange === "30d") {
      daysToSubtract = 30;
    } else if (timeRange === "7d") {
      daysToSubtract = 7;
    }
    const startDate = new Date(referenceDate);
    startDate.setDate(startDate.getDate() - daysToSubtract);
    return date >= startDate;
  });

  return (
    <Card className="py-2">
      <CardHeader className="flex items-center gap-2 space-y-0 border-b py-5 sm:flex-row">
        <CardTitle className="text-primary">
          <h2>Donation Chart</h2>
        </CardTitle>
        <Select value={timeRange} onValueChange={setTimeRange}>
          <SelectTrigger
            className="w-[160px] rounded-lg sm:ml-auto"
            aria-label="Select a value"
          >
            <SelectValue placeholder="Last 3 months" />
          </SelectTrigger>
          <SelectContent className="rounded-xl">
            <SelectItem value="90d" className="rounded-lg">
              Last 3 months
            </SelectItem>
            <SelectItem value="30d" className="rounded-lg">
              Last 30 days
            </SelectItem>
            <SelectItem value="7d" className="rounded-lg">
              Last 7 days
            </SelectItem>
          </SelectContent>
        </Select>
      </CardHeader>
      <CardContent className="px-2 sm:px-6 sm:pt-6">
        <ChartContainer
          config={chartConfig}
          className="aspect-auto h-[250px] w-full"
        >
          <LineChart data={filteredData}>
            <CartesianGrid vertical={false} />
            <XAxis
              dataKey="date"
              tickLine={false}
              axisLine={false}
              tickMargin={8}
              minTickGap={32}
              tickFormatter={(value) => {
                const date = new Date(value);
                return date.toLocaleDateString("en-US", {
                  month: "short",
                  day: "numeric",
                });
              }}
            />
            <YAxis
              tickLine={false}
              axisLine={false}
              tickMargin={8}
              tickFormatter={(value) => `${(value / 1000).toFixed(0)}k`}
            />
            <ChartTooltip
              cursor={false}
              content={
                <ChartTooltipContent
                  labelFormatter={(value) => {
                    return new Date(value).toLocaleDateString("en-US", {
                      month: "short",
                      day: "numeric",
                    });
                  }}
                  hideIndicator
                />
              }
            />
            <Line
              dataKey="amount"
              type="linear"
              stroke="green"
              strokeWidth={2}
              dot={false}
            />
          </LineChart>
        </ChartContainer>
      </CardContent>
    </Card>
  );
}
