import { FilesIcon } from "lucide-react";

type CampaignDocumentsList = {
  campaignDocuments: {
    documentUrl: string;
    redactedDocumentUrl: string | null;
    campaignId: string;
  }[];
};

export default function CampaignDocumentsListTemp({
  campaignDocuments,
}: CampaignDocumentsList) {
  return (
    <section className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4 mt-3">
      {campaignDocuments.map((doc, index) => (
        <a
          key={index}
          href={doc.documentUrl}
          target="_blank"
          rel="noopener noreferrer"
        >
          <div className="flex items-center gap-4 bg-amber-50 p-3 rounded-xl cursor-pointer hover:bg-amber-100">
            <FilesIcon className="h-6 w-6" />
            <div className="flex flex-col">
              <h3 className="font-semibold text-lg md:text-xl">
                File {index + 1}
              </h3>
            </div>
          </div>
        </a>
      ))}
    </section>
  );
}
