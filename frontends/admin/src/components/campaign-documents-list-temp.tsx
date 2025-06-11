import { FileTextIcon } from "lucide-react";

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
    <section className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-5">
      {campaignDocuments.map((doc, index) => (
        <a
          key={index}
          href={doc.documentUrl} // Consider using redactedDocumentUrl if available and appropriate
          target="_blank"
          rel="noopener noreferrer"
          className="group block" // Added group for hover effects
        >
          <div className="flex flex-col items-center justify-center text-center gap-3 bg-slate-50 p-4 rounded-lg border border-slate-200 cursor-pointer hover:bg-slate-100 hover:shadow-md transition-all duration-200 ease-in-out transform hover:-translate-y-1 h-full">
            <FileTextIcon className="h-10 w-10 text-primary group-hover:text-primary-dark transition-colors" />
            <div className="flex flex-col">
              <h3 className="font-medium text-sm text-slate-700 group-hover:text-slate-900">
                {/* You could use a document name here if available, e.g., doc.documentName || `Document ${index + 1}` */}
                Document {index + 1}
              </h3>
              <p className="text-xs text-slate-500">Click to view</p>
            </div>
          </div>
        </a>
      ))}
    </section>
  );
}
