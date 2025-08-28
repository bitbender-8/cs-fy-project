// components/CampaignDocumentsList.tsx
"use client";

import { FileTextIcon } from "lucide-react";
import { useCallback } from "react";

type CampaignDocumentsListProps = {
  campaignDocuments: {
    documentUrl: string;
    redactedDocumentUrl: string | null;
  }[];
};

export default function CampaignDocumentsList({
  campaignDocuments,
}: CampaignDocumentsListProps) {
  const downloadDocument = useCallback(async (fullUrl: string) => {
    // extract just the filename portion
    const filename = fullUrl;
    if (!fullUrl) return;

    try {
      const res = await fetch(
        `http://localhost:4000/files/campaign-documents/${filename}`,
        {
          headers: {
            Authorization: `Bearer ${process.env.NEXT_PUBLIC_ACCESS_TOKEN}`,
          },
        }
      );

      console.log("Fetching file:", fullUrl);

      if (!res.ok) {
        console.error("Failed to fetch file:", await res.text());
        return;
      }

      // turn it into a blob
      const blob = await res.blob();
      const blobUrl = window.URL.createObjectURL(blob);

      // create a temporary link to trigger download
      const link = document.createElement("a");
      link.href = blobUrl;
      link.download = filename!;
      document.body.appendChild(link);
      link.click();
      link.remove();
      window.URL.revokeObjectURL(blobUrl);
    } catch (err) {
      console.error("Error downloading document:", err);
    }
  }, []);

  return (
    <section className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-5">
      {campaignDocuments.map((doc, i) => (
        <div
          key={i}
          onClick={() => downloadDocument(doc.documentUrl)}
          className="group flex flex-col items-center justify-center gap-3 bg-slate-50 p-4 rounded-lg border border-slate-200 cursor-pointer hover:bg-slate-100 hover:shadow-md transition transform hover:-translate-y-1"
        >
          <FileTextIcon className="h-10 w-10 text-primary group-hover:text-primary-dark" />
          <h3 className="font-medium text-sm text-slate-700 group-hover:text-slate-900">
            Document {i + 1}
          </h3>
          <p className="text-xs text-slate-500">Click to download</p>
        </div>
      ))}
    </section>
  );
}
