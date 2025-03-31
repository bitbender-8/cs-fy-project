import { campaigns, campaignTableColumns } from "@/components/campaigns-table/columns";
import { DataTable } from "@/components/data-table";

export default function BroswseCampaignsHomePage() {
  return (
    <div>
      <div className="flex justify-between items-center">
        <h1 className="text-primary">Browse Campaigns</h1>
      </div>

      <div className="flex justify-between mt-5 space-x-11">
        <div className="relative inline-block group cursor-pointer shadow-lg">
          <div className="px-38 py-6 bg-red-500 rounded-sm opacity-20 blur-[2px] group-hover:opacity-60 group-hover:blur-none"></div>
          <span className="absolute inset-0 flex items-center justify-center text-2xl text-red-500 hover:text-white font-bold">
            To Review (9)
          </span>
        </div>

        <div className="relative inline-block group cursor-pointer shadow-lg">
          <div className="px-38 py-6 bg-[#CF754B] rounded-sm opacity-20 blur-[2px] group-hover:opacity-60 group-hover:blur-none"></div>
          <span className="absolute inset-0 flex items-center justify-center text-2xl text-[#CF754B] hover:text-white font-bold">
            To Launch (9)
          </span>
        </div>

        <div className="relative inline-block group cursor-pointer shadow-lg">
          <div className="px-38 py-6 bg-primary rounded-sm opacity-20 blur-[2px] group-hover:opacity-60 group-hover:blur-none"></div>
          <span className="absolute inset-0 flex items-center justify-center text-2xl text-primary hover:text-white font-bold">
            Live (9)
          </span>
        </div>
      </div>

      <div>
        <DataTable columns={campaignTableColumns} data={campaigns} />
      </div>
    </div>
  );
}
