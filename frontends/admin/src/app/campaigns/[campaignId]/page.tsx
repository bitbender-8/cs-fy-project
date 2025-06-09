import CampaignDocumentsListTemp from "@/components/campaign-documents-list-temp";
import CampaignRequestAccepterAndDenier from "@/components/campaign-request-acceptor-and-denier";
import ChangeCampaignVisibilityDropdownMenu from "@/components/change-campaign-visibility-dropdown-menu";
import { DataTableDonationList } from "@/components/data-tables/data-table-donation-list";
import { donationTableSpecificCampaignColumns } from "@/components/table-columns/donation-table-columns";
import { Button } from "@/components/ui/button";
import { Progress } from "@/components/ui/progress";
import { Textarea } from "@/components/ui/textarea";
import { Prisma } from "@/generated/prisma";
import { submitCampaignUpdate } from "@/lib/actions";
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
    EndDateExtensionRequest: true;
    GoalAdjustmentRequest: true;
    PostUpdateRequest: {
      include: {
        CampaignPost: true;
      };
    };
    StatusChangeRequest: true;
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
        EndDateExtensionRequest: {
          where: {
            resolutionType: null,
          },
        },
        GoalAdjustmentRequest: {
          where: {
            resolutionType: null,
          },
        },
        PostUpdateRequest: {
          include: {
            CampaignPost: true,
          },
          where: {
            resolutionType: null,
          },
        },
        StatusChangeRequest: {
          where: {
            resolutionType: null,
          },
        },
      },
    });

    console.log("Campaign donations:", campaign?.CampaignDonation);
  } catch (error) {
    console.error("Error fetching campaign:", error);
    return <p>Error fetching campaign data</p>;
  }

  // try {
  //   // fetch campaign donations
  //   const donations = await prisma.campaignDonation.findMany({
  //     where: { campaignId },
  //   });
  // } catch (error) {
  //   console.error("Error fetching campaign donations:", error);
  //   return <p>Error fetching campaign donations</p>;
  // }

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

  // Gather all requests, annotate with type, and sort by requestDate descending
  const allRequests = [
    ...EndDateExtensionRequest.map((req) => ({
      ...req,
      type: "endDateExtension" as const,
      header: "End Date Extension" as const,
      oldEndDate: endDate,
    })),
    ...GoalAdjustmentRequest.map((req) => ({
      ...req,
      type: "goalAdjustment" as const,
      header: "Goal Adjustment" as const,
      oldGoal: fundraisingGoal,
    })),
    ...PostUpdateRequest.map((req) => ({
      ...req,
      type: "postUpdate" as const,
      header: "New Post" as const,
    })),
    ...StatusChangeRequest.map((req) => ({
      ...req,
      type: "statusChange" as const,
      header: "Change Campaign Status" as const,
    })),
  ].sort(
    (a, b) =>
      new Date(b.requestDate).getTime() - new Date(a.requestDate).getTime()
  );

  // const sampleAllRequests = [
  //   {
  //     id: "r1",
  //     title: "Extend Campaign End",
  //     campaignId: "c1",
  //     requestDate: new Date("2025-04-15T10:30:00Z"),
  //     justification: "Additional time needed for late pledges",
  //     resolutionDate: null,
  //     oldEndDate: new Date("2025-06-30"),
  //     newEndDate: new Date("2025-12-31"),
  //     type: "endDateExtension" as const,
  //   },
  //   {
  //     id: "r2",
  //     title: "Adjust Fundraising Goal",
  //     campaignId: "c1",
  //     requestDate: new Date("2025-03-20T14:00:00Z"),
  //     justification: "Strong donor interest – let’s aim higher",
  //     resolutionDate: new Date("2025-03-25T09:00:00Z"),
  //     oldGoal: BigInt(500_000),
  //     newGoal: BigInt(750_000),
  //     type: "goalAdjustment" as const,
  //   },
  //   {
  //     id: "r3",
  //     title: "Post Campaign Update",
  //     campaignId: "c1",
  //     requestDate: new Date("2025-02-10T08:15:00Z"),
  //     justification: "Share recent milestones with backers",
  //     resolutionDate: null,
  //     newPostId: "post_12345",
  //     type: "postUpdate" as const,
  //   },
  //   {
  //     id: "r4",
  //     title: "Change Status to Archived",
  //     campaignId: "c1",
  //     requestDate: new Date("2025-01-05T16:45:00Z"),
  //     justification: "Campaign completed successfully",
  //     resolutionDate: new Date("2025-01-10T11:00:00Z"),
  //     newStatus: "archived" as CampaignStatus,
  //     type: "statusChange" as const,
  //   },
  // ];

  // // If you want them sorted by requestDate descending:
  // const sortedSampleRequests = sampleAllRequests.sort(
  //   (a, b) => b.requestDate.getTime() - a.requestDate.getTime()
  // );

  return (
    <div className="flex flex-col gap-5">
      <div className="flex gap-3 justify-between">
        <h1 className="text-primary">Campaign Overview</h1>
        <ChangeCampaignVisibilityDropdownMenu
          status={status}
          campaignId={campaignId}
          title={title}
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
        {allRequests.map((req) => (
          <div key={req.id} className="flex justify-between items-center">
            <div>
              <h3 className="text-lg font-semibold mb-0">{req.header}</h3>
              <p className="text-xs text-gray-500">
                Requested on {new Date(req.requestDate).toLocaleDateString()}
              </p>

              <br />
              <h3 className="text-lg font-semibold mb-0 underline">Reason</h3>
              <p className="w-full pr-5">{req.justification}</p>

              {req.type === "postUpdate" && (
                <>
                  <br />
                  <h3 className="text-lg font-semibold mb-0">
                    New Post Content
                  </h3>
                  <p className="w-full pr-5">{req.CampaignPost.content}</p>
                </>
              )}
            </div>

            <div className="flex gap-5 ml-auto items-center">
              {req.type === "goalAdjustment" && (
                <div className="flex gap-1">
                  <p>{Number(req.oldGoal).toLocaleString()}</p>
                  <ArrowBigRight />
                  <p>{Number(req.newGoal).toLocaleString()} ETB</p>
                </div>
              )}

              {req.type === "endDateExtension" && (
                <div className="flex gap-1">
                  <p>{new Date(req.oldEndDate!).toLocaleDateString()}</p>
                  <ArrowBigRight />
                  <p>{new Date(req.newEndDate).toLocaleDateString()}</p>
                </div>
              )}

              {req.type === "statusChange" && (
                <p>New status: {req.newStatus}</p>
              )}

              <CampaignRequestAccepterAndDenier
                requestType={req.type}
                campaignId={campaignId}
                requestId={req.id}
              />
            </div>
          </div>
        ))}
      </div>

      <hr />

      <form action={submitCampaignUpdate} className="flex flex-col gap-3">
        <h2 className="text-primary">Update campaign</h2>

        <input type="hidden" name="campaignId" value={campaignId} />

        <Textarea
          name="updateContent"
          placeholder="Enter new updates about the campaign..."
          className="h-32"
        />

        <Button type="submit" className="cursor-pointer w-fit ml-auto">
          Submit
        </Button>
      </form>

      {/* Campaign donations table */}
      <div>
        <h2 className="text-primary mb-3">Campaign Donations</h2>
        <DataTableDonationList columns={donationTableSpecificCampaignColumns} data={campaign.CampaignDonation} source="specific-campaign"/>
      </div>
      <hr />
    </div>
  );
}
