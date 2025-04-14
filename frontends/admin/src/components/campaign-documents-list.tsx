import { FilesIcon, ImageIcon, VideoIcon } from "lucide-react";

export default function CampaignDocumentsList() {
  return (
    <section className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4 mt-3">
      <div className="flex items-center gap-4 bg-amber-50 p-3 rounded-xl cursor-pointer hover:bg-amber-100">
        <FilesIcon className="h-6 w-6" />
        <div className="flex flex-col">
          <h3 className="font-semibold text-lg md:text-xl">Document.txt</h3>
          <p className="text-sm text-gray-500 dark:text-gray-400">Text File</p>
          <p className="text-sm text-gray-500 dark:text-gray-400">2 MB</p>
        </div>
      </div>
      <div className="flex items-center gap-4 bg-amber-50 p-3 rounded-xl cursor-pointer hover:bg-amber-100">
        <ImageIcon className="h-6 w-6" />
        <div className="flex flex-col">
          <h3 className="font-semibold text-lg md:text-xl ">Image.jpg</h3>
          <p className="text-sm text-gray-500 dark:text-gray-400">JPEG Image</p>
          <p className="text-sm text-gray-500 dark:text-gray-400">1.5 MB</p>
        </div>
      </div>

      <div className="flex items-center gap-4 bg-amber-50 p-3 rounded-xl cursor-pointer hover:bg-amber-100">
        <VideoIcon className="h-6 w-6" />
        <div className="flex flex-col">
          <h3 className="font-semibold text-lg md:text-xl">Video.mp4</h3>
          <p className="text-sm text-gray-500 dark:text-gray-400">MP4 Video</p>
          <p className="text-sm text-gray-500 dark:text-gray-400">20 MB</p>
        </div>
      </div>

      <div className="flex items-center gap-4 bg-amber-50 p-3 rounded-xl cursor-pointer hover:bg-amber-100">
        <FilesIcon className="h-6 w-6" />
        <div className="flex flex-col">
          <h3 className="font-semibold text-lg md:text-xl">Report.pdf</h3>
          <p className="text-sm text-gray-500 dark:text-gray-400">
            PDF Document
          </p>
          <p className="text-sm text-gray-500 dark:text-gray-400">3 MB</p>
        </div>
      </div>
    </section>
  );
}
