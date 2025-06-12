"use client";

import { useRef } from "react";
import { toast } from "sonner";
import { Input } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import { Button } from "@/components/ui/button";
import { submitCampaignUpdate } from "@/lib/actions"; // Ensure this path is correct

type CampaignUpdateFormProps = {
  campaignId: string;
};

export default function CampaignUpdateForm({ campaignId }: CampaignUpdateFormProps) {
  const formRef = useRef<HTMLFormElement>(null);

  const handleFormSubmit = async (formData: FormData) => {
    // Add campaignId to formData if it's not already reliably there via hidden input for server action
    // formData.append('campaignId', campaignId); // The hidden input should handle this.

    const toastId = toast.loading("Submitting update...");
    console.log("Toast id:", toastId);
    try {
      const result = await submitCampaignUpdate(formData);

      if (result.success) {
        toast.success(result.message || "Update posted successfully!", { id: toastId });
        console.log("Update posted successfully:", result);
        formRef.current?.reset(); // Reset the form fields
      } else {
        toast.error(result.message || "Failed to post update.", { id: toastId });
      }
    } catch (error) {
      toast.error("An unexpected error occurred while submitting the update.", { id: toastId });
      console.error("Form submission error:", error);
    }
  };

  return (
    <form
      ref={formRef}
      action={handleFormSubmit} // Use the client-side handler
      className="flex flex-col gap-4 p-6 border border-gray-200 rounded-lg shadow-md bg-white"
    >
      <h2 className="text-2xl font-semibold text-primary border-b pb-3 mb-2">
        Post a New Update
      </h2>

      <input type="hidden" name="campaignId" value={campaignId} />

      <div className="flex flex-col gap-2">
        <label
          htmlFor="postTitle"
          className="block text-sm font-medium text-gray-700"
        >
          Post Title
        </label>
        <Input
          id="postTitle"
          name="postTitle"
          placeholder="Share the latest news and progress of your campaign..."
          className="h-12 resize-none border-gray-300 focus:ring-primary-focus focus:border-primary-focus"
          required
        />
        <label
          htmlFor="postContent"
          className="block text-sm font-medium text-gray-700"
        >
          Post Content
        </label>
        <Textarea
          id="postContent"
          name="postContent"
          placeholder="Share the latest news and progress of your campaign..."
          className="h-36 resize-none border-gray-300 focus:ring-primary-focus focus:border-primary-focus"
          required
        />
        <p className="mt-1 text-xs text-gray-500">
          This update will be visible to donors and followers of the campaign.
        </p>
      </div>

      <Button
        type="submit"
        className="cursor-pointer w-fit ml-auto bg-primary hover:bg-primary-dark text-white font-semibold py-2 px-4 rounded-md transition-colors duration-150"
      >
        Submit Update
      </Button>
    </form>
  );
}