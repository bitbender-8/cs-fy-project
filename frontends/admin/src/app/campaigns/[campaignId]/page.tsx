import CampaignDocumentsListTemp from "@/components/campaign-documents-list-temp";
import CampaignRequestAccepterAndDenier from "@/components/campaign-request-acceptor-and-denier";
import CampaignUpdateForm from "@/components/campaign-update-form";
import ChangeCampaignVisibilityDropdownMenu from "@/components/change-campaign-visibility-dropdown-menu";
import { DataTableDonationList } from "@/components/data-tables/data-table-donation-list";
import { donationTableSpecificCampaignColumns } from "@/components/table-columns/donation-table-columns";

import { Progress } from "@/components/ui/progress";
import { Prisma } from "@/generated/prisma";
import prisma from "@/lib/prisma";
import { ArrowBigRight, FilesIcon } from "lucide-react";

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
          // No 'where' clause, fetch all
        },
        GoalAdjustmentRequest: {
          // No 'where' clause, fetch all
        },
        PostUpdateRequest: {
          include: {
            CampaignPost: true,
          },
          // No 'where' clause, fetch all
        },
        StatusChangeRequest: {
          // No 'where' clause, fetch all
        },
      },
    });
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

  console.log("Campaign Data:", PostUpdateRequest);

  let amountRaised = 0;
  CampaignDonation.forEach((donation) => {
    amountRaised += Number(donation.grossAmount);
  });

  const remaining = Number(fundraisingGoal) - amountRaised;
  const remainingAmount = remaining > 0 ? remaining : 0;

  const progressValue = (amountRaised / Number(fundraisingGoal)) * 100;

  // Gather all requests, annotate with type, and sort by requestDate descending
  const combinedAllRequests = [
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

  const pendingRequests = combinedAllRequests.filter(
    (req) => req.resolutionType === null
  );
  const resolvedRequests = combinedAllRequests.filter(
    (req) => req.resolutionType !== null
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
        <h2 className="text-primary mb-3">Campaign Documents</h2>

        {/* <CampaignDocumentsList /> */}
        {CampaignDocuments && CampaignDocuments.length > 0 ? (
          <CampaignDocumentsListTemp campaignDocuments={CampaignDocuments} />
        ) : (
          <div className="text-center py-8 text-gray-500">
            <FilesIcon className="mx-auto h-10 w-10 mb-2" />
            <p>No documents have been uploaded for this campaign yet.</p>
          </div>
        )}
      </div>

      <hr />

      <div className="flex flex-col gap-5">
        <h2 className="text-primary">Requested Updates</h2>
        {pendingRequests.length > 0 ? (
          pendingRequests.map((req) => (
            <div
              key={req.id}
              className="bg-white shadow-lg rounded-xl p-6 border border-gray-200 hover:shadow-xl transition-shadow duration-300 ease-in-out"
            >
              <div className="flex flex-col md:flex-row justify-between items-start gap-y-4 md:gap-x-6">
                {/* Left Section: Request Details */}
                <div className="flex-grow space-y-4">
                  <div>
                    <h3 className="text-xl font-bold text-gray-800">
                      {req.header}
                    </h3>
                    <p className="text-xs text-gray-500 mt-1">
                      Requested on:{" "}
                      {new Date(req.requestDate).toLocaleDateString()}
                    </p>
                  </div>

                  <div>
                    <h4 className="text-md font-semibold text-gray-700 mb-1">
                      Reason for Request:
                    </h4>
                    <p className="text-gray-600 text-sm leading-relaxed bg-gray-50 p-3 rounded-md border">
                      {req.justification}
                    </p>
                  </div>

                  {req.type === "postUpdate" && req.CampaignPost && (
                    <div>
                      <h4 className="text-md font-semibold text-gray-700 mb-1">
                        New Post Content:
                      </h4>
                      <div className="text-gray-600 text-sm leading-relaxed bg-gray-50 p-3 rounded-md border prose prose-sm max-w-none">
                        {/* Using prose for potential markdown content if applicable, or just for styling */}
                        <p>{req.CampaignPost.content}</p>
                      </div>
                    </div>
                  )}
                </div>

                {/* Right Section: Specific Info & Actions */}
                <div className="flex flex-col items-start md:items-end gap-3 w-full md:w-auto md:min-w-[280px] flex-shrink-0 pt-2 md:pt-0">
                  {req.type === "goalAdjustment" && (
                    <div className="flex items-center gap-2 text-sm text-gray-700 w-full justify-between md:justify-end">
                      <span className="font-medium">Goal Change:</span>
                      <div className="flex items-center gap-1">
                        <span className="bg-red-100 text-red-700 px-2 py-1 rounded-md line-through">
                          {Number(req.oldGoal).toLocaleString()}
                        </span>
                        <ArrowBigRight size={20} className="text-gray-500" />
                        <span className="bg-green-100 text-green-700 px-2 py-1 rounded-md">
                          {Number(req.newGoal).toLocaleString()} ETB
                        </span>
                      </div>
                    </div>
                  )}

                  {req.type === "endDateExtension" &&
                    req.oldEndDate &&
                    req.newEndDate && (
                      <div className="flex items-center gap-2 text-sm text-gray-700 w-full justify-between md:justify-end">
                        <span className="font-medium">End Date Change:</span>
                        <div className="flex items-center gap-1">
                          <span className="bg-red-100 text-red-700 px-2 py-1 rounded-md line-through">
                            {new Date(req.oldEndDate).toLocaleDateString()}
                          </span>
                          <ArrowBigRight size={20} className="text-gray-500" />
                          <span className="bg-green-100 text-green-700 px-2 py-1 rounded-md">
                            {new Date(req.newEndDate).toLocaleDateString()}
                          </span>
                        </div>
                      </div>
                    )}

                  {req.type === "statusChange" && (
                    <div className="text-sm text-gray-700 w-full flex justify-between md:justify-end items-center">
                      <span className="font-medium">New Status:</span>
                      <span className="ml-2 bg-blue-100 text-blue-700 px-3 py-1.5 rounded-full text-xs font-semibold uppercase tracking-wider">
                        {req.newStatus}
                      </span>
                    </div>
                  )}

                  <div className="mt-3 md:mt-2 w-full md:w-auto flex justify-end gap-3">
                    <CampaignRequestAccepterAndDenier
                      requestType={req.type}
                      campaignId={campaignId}
                      requestId={req.id}
                    />
                  </div>
                </div>
              </div>
            </div>
          ))
        ) : (
          <div className="text-center py-10">
            <svg
              xmlns="http://www.w3.org/2000/svg"
              className="mx-auto h-12 w-12 text-gray-400"
              fill="none"
              viewBox="0 0 24 24"
              stroke="currentColor"
            >
              <path
                strokeLinecap="round"
                strokeLinejoin="round"
                strokeWidth={2}
                d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"
              />
            </svg>
            <h3 className="mt-2 text-sm font-medium text-gray-900">
              No Pending Requests
            </h3>
            <p className="mt-1 text-sm text-gray-500">
              There are currently no pending update requests for this campaign.
            </p>
          </div>
        )}
      </div>
      <hr />

      <div className="flex flex-col gap-5">
        <h2 className="text-primary">Previous Requests</h2>
      {resolvedRequests.length > 0 ? (
        resolvedRequests.map((req) => (
          <div
            key={req.id}
            className="bg-white shadow-md rounded-xl p-6 border border-gray-200"
          >
            {/* Header section: title, dates, justification, and status badge */}
            <div className="flex justify-between items-start">
              <div className="space-y-2">
                <h3 className="text-xl font-semibold text-gray-700">{req.header}</h3>
                <p className="text-xs text-gray-500">
                  Requested on: {new Date(req.requestDate).toLocaleDateString()}
                </p>
                <div>
                  <h4 className="text-sm font-semibold text-gray-700">Justification:</h4>
                  <p className="text-gray-600 text-sm bg-gray-50 p-3 rounded-md border">
                    {req.justification}
                  </p>
                </div>
              </div>

              {/* Status badge at top-right */}
              <div>
                <span
                  className={`px-3 py-1.5 rounded-full text-xs font-semibold uppercase tracking-wider ${
                    req.resolutionType === 'Accepted'
                      ? 'bg-green-100 text-green-700'
                      : 'bg-red-100 text-red-700'
                  }`}
                >
                  {req.resolutionType}
                </span>
              </div>
            </div>

            {/* For postUpdate requests show post content and rejection reason side by side */}
            {req.type === 'postUpdate' && req.CampaignPost && (
              <div className="mt-6 grid grid-cols-1 md:grid-cols-2 gap-6">
                {/* Post Content Column */}
                <div>
                  <h4 className="text-md font-semibold text-gray-700 mb-1">Post Content:</h4>
                  <div className="text-gray-600 text-sm leading-relaxed bg-gray-50 p-3 rounded-md border prose prose-sm max-w-none">
                    <p>{req.CampaignPost.content}</p>
                  </div>
                </div>


              </div>
            )}
          </div>
        ))
      ) : (
        <div className="text-center py-10">
          <svg
            xmlns="http://www.w3.org/2000/svg"
            className="mx-auto h-12 w-12 text-gray-400"
            fill="none"
            viewBox="0 0 24 24"
            stroke="currentColor"
          >
            <path
              strokeLinecap="round"
              strokeLinejoin="round"
              strokeWidth={2}
              d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"
            />
          </svg>
          <h3 className="mt-2 text-sm font-medium text-gray-900">No Previous Requests</h3>
          <p className="mt-1 text-sm text-gray-500">
            There are no resolved requests for this campaign.
          </p>
        </div>
      )}

      </div>
      <hr />

      <CampaignUpdateForm campaignId={campaignId} />

      {/* Campaign donations table */}
      <div>
        <h2 className="text-primary mb-3">Campaign Donations</h2>
        <DataTableDonationList
          columns={donationTableSpecificCampaignColumns}
          data={campaign.CampaignDonation}
          source="specific-campaign"
        />
      </div>
      <hr />
    </div>
  );
}
