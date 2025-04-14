import CampaignAdditionalDocumentsList from "@/components/campaign-additional-documents-list";
import CampaignDocumentsList from "@/components/campaign-documents-list";
import ChangeCampaignVisibilityDropdownMenu from "@/components/change-campaign-visibility-dropdown-menu";
import { DialogDecline } from "@/components/dialog-decline";
import { Button } from "@/components/ui/button";
import { Progress } from "@/components/ui/progress";
import { Textarea } from "@/components/ui/textarea";
import { ArrowBigRight } from "lucide-react";

type CampaignPageProps = {
  params: Promise<{
    id: string;
  }>;
};

export default async function CampaignPage({ params }: CampaignPageProps) {
  const { id } = await params;

  // TODO: To be deleted later
  console.log("Campaign Id: ", id);
  return (
    <div className="flex flex-col gap-5">
      <div className="flex gap-3 justify-between">
        <h1 className="text-primary">Campaign Overview</h1>
        <ChangeCampaignVisibilityDropdownMenu />
      </div>

      <div className="flex justify-between">
        <div className="space-y-2 bg-gray-200 p-5">
          <p className="text-xl font-semibold">
            <span className="text-primary mr-2">Campaign Title: </span>Kaleb
            Kidney Transplant
          </p>
          <p className="text-xl font-semibold">
            <span className="text-primary mr-2">
              Campaign Submission Date:{" "}
            </span>
            Jan. 5, 2024
          </p>
          <p className="text-xl font-semibold">
            <span className="text-primary mr-2">Fundraising Goal: </span>
            2,500,000 ETB
          </p>
          <p className="text-xl font-semibold">
            <span className="text-primary mr-2">Campaign End Date: </span>Mar.
            29, 2024
          </p>
        </div>

        <div className="w-1/2">
          <div className="flex items-center justify-between">
            <h3 className="text-primary text-xl font-semibold">
              Amount Raised
            </h3>
            <p>400,000 / 2,500,000 ETB</p>
          </div>
          <Progress value={33} className="h-5" />
          <p className="text-right text-xs">Remaining: 1,500,000 ETB</p>
        </div>
      </div>

      <hr />

      <div>
        <h2 className="text-primary">Campaign Documents</h2>

        <CampaignDocumentsList />
      </div>

      <hr />

      <div className="flex flex-col gap-5">
        <h2 className="text-primary">Requested Updates</h2>

        {/* Campaign Goal Adjustment */}
        <div className="flex justify-between">
          <div>
            <h3 className="text-lg font-semibold mb-0">
              Campaign Goal Adjustment
            </h3>
            <p className="text-xs text-gray-500 items-end">
              Requested on Jan. 5, 2024
            </p>
          </div>

          <div className="flex gap-5 ml-auto items-center">
            <div className="flex gap-1">
              <p>100,000</p>
              <ArrowBigRight />
              <p>200,000 ETB</p>
            </div>
            <Button className="cursor-pointer" variant="default">
              Approve
            </Button>
            <DialogDecline />
          </div>
        </div>

        {/* Additional Documents Update */}
        <div>
          <div>
            <h3 className="text-lg font-semibold mb-0">
              Additional Campaign Documents
            </h3>
            <p className="text-xs text-gray-500 items-end">
              Requested on Jan. 5, 2024
            </p>
          </div>

          <CampaignAdditionalDocumentsList />

          <div className="flex gap-5 ml-auto items-center mt-2 justify-end">
            <Button className="cursor-pointer" variant="default">
              Approve
            </Button>
            <DialogDecline />
          </div>
        </div>

        {/* Extend campaign end */}
        <div className="flex justify-between">
          <div>
            <h3 className="text-lg font-semibold mb-0">Extend Campaign End</h3>
            <p className="text-xs text-gray-500 items-end">
              Requested on Jan. 5, 2024
            </p>
          </div>

          <div className="flex gap-5 ml-auto items-center">
            <div className="flex gap-1">
              <p>Mar. 29, 2024</p>
              <ArrowBigRight />
              <p>Decemeber 2, 2024</p>
            </div>
            <Button className="cursor-pointer" variant="default">
              Approve
            </Button>
            <DialogDecline />
          </div>
        </div>
      </div>

      <hr />

      <div className="flex flex-col gap-3">
        <h2 className="text-primary">Update campaign</h2>

        <Textarea
          placeholder="Enter new updates about the campaign..."
          className="h-32"
        />
        <Button className="cursor-pointer w-fit ml-auto" variant="default">
          Submit
        </Button>
      </div>

      <hr />
    </div>
  );
}
