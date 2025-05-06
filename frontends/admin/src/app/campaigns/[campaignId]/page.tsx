import CampaignAdditionalDocumentsList from "@/components/campaign-additional-documents-list";
import CampaignDocumentsList from "@/components/campaign-documents-list";
import CampaignDocumentsListTemp from "@/components/campaign-documents-list-temp";
import ChangeCampaignVisibilityDropdownMenu from "@/components/change-campaign-visibility-dropdown-menu";
import { DialogDecline } from "@/components/dialog-decline";
import { Button } from "@/components/ui/button";
import { Progress } from "@/components/ui/progress";
import { Textarea } from "@/components/ui/textarea";
import { Campaign, CampaignDonation, Prisma } from "@/generated/prisma";
import prisma from "@/lib/prisma";
import { ArrowBigRight } from "lucide-react";

type CampaignPageProps = {
  params: Promise<{
    campaignId: string;
  }>;
};

type CampaignWithDonations = Prisma.CampaignGetPayload<{
  include: {
    CampaignDonation: true;
    CampaignDocuments: true;
    CampaignPost: true;
  };
}>;

export default async function CampaignPage({ params }: CampaignPageProps) {
  const { campaignId } = await params;

  let campaign: CampaignWithDonations | null;

  try {
    campaign = await prisma.campaign.findUnique({
      where: { id: campaignId },
      include: {
        CampaignDonation: true,
        CampaignDocuments: true,
        CampaignPost: true,
        EndDateExtensionRequest: true,
        GoalAdjustmentRequest: true,
        PostUpdateRequest: true,
        StatusChangeRequest: true,
      },
    });
  } catch (error) {
    console.error("Error fetching campaign:", error);
    return <p>Error fetching campaign data</p>;
  }

  if (!campaign) {
    return <p>Campaign not found</p>;
  }

  const {
    title,
    submissionDate,
    fundraisingGoal,
    endDate,
    CampaignDonation,
    status,
    CampaignDocuments,
    EndDateExtensionRequest,
    GoalAdjustmentRequest,
    PostUpdateRequest,
    StatusChangeRequest,
  } = campaign;

  let amountRaised = 0;
  CampaignDonation.forEach((donation) => {
    amountRaised += Number(donation.grossAmount);
  });

  const remaining = Number(fundraisingGoal) - amountRaised;
  const remainingAmount = remaining > 0 ? remaining : 0;

  const progressValue = (amountRaised / Number(fundraisingGoal)) * 100;

  return (
    <div className="flex flex-col gap-5">
      <div className="flex gap-3 justify-between">
        <h1 className="text-primary">Campaign Overview</h1>
        <ChangeCampaignVisibilityDropdownMenu
          status={status}
          campaignId={campaignId}
        />
      </div>

      <div className="flex justify-between">
        <div className="space-y-2 bg-gray-200 p-5">
          <p className="text-xl font-semibold">
            <span className="text-primary mr-2">Campaign Title: </span> {title}
          </p>
          <p className="text-xl font-semibold">
            <span className="text-primary mr-2">
              Campaign Submission Date:{" "}
            </span>
            {new Date(submissionDate).toLocaleDateString()}
          </p>
          <p className="text-xl font-semibold">
            <span className="text-primary mr-2">Fundraising Goal: </span>
            {fundraisingGoal.toLocaleString()} ETB
          </p>
          <p className="text-xl font-semibold">
            <span className="text-primary mr-2">Campaign End Date: </span>
            {endDate && new Date(endDate).toLocaleDateString()}
          </p>
        </div>

        <div className="w-1/2">
          <div className="flex items-center justify-between">
            <h3 className="text-primary text-xl font-semibold">
              Amount Raised
            </h3>
            <p>
              {" "}
              {amountRaised.toLocaleString()} /{" "}
              {fundraisingGoal.toLocaleString()} ETB
            </p>
          </div>
          <Progress value={progressValue} className="h-5" />
          <p className="text-right text-xs">
            Remaining: {remainingAmount.toLocaleString()} ETB
          </p>
        </div>
      </div>

      <hr />

      <div>
        <h2 className="text-primary">Campaign Documents</h2>

        {/* <CampaignDocumentsList /> */}
        <CampaignDocumentsListTemp campaignDocuments={CampaignDocuments} />
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
