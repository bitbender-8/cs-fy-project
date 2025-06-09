"use client";

import { useState, useTransition } from "react";
import { Button } from "./ui/button";
import { Input } from "./ui/input";
import { Label } from "./ui/label";
import { useRouter } from "next/navigation"; // For page refresh or revalidation

interface Supervisor {
  id: string;
  phoneNo: string | null;
  firstName: string | null;
  middleName: string | null;
  lastName: string | null;
  dateOfBirth: Date | null;
  email: string; // Assuming email is always present
}

interface ProfileFormProps {
  supervisor: Supervisor;
  updateAction: (formData: FormData) => Promise<{ success: boolean; error?: string; supervisor?: Supervisor }>;
}

export default function ProfileForm({ supervisor, updateAction }: ProfileFormProps) {
  const [isEditing, setIsEditing] = useState(false);
  const [isPending, startTransition] = useTransition();
  const router = useRouter();

  const [formData, setFormData] = useState({
    firstName: supervisor.firstName || "",
    middleName: supervisor.middleName || "",
    lastName: supervisor.lastName || "",
    phoneNo: supervisor.phoneNo || "",
    // dateOfBirth: supervisor.dateOfBirth ? supervisor.dateOfBirth.toISOString().split("T")[0] : "", // Handle date carefully
  });

  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const { name, value } = e.target;
    setFormData((prev) => ({ ...prev, [name]: value }));
  };

  const handleSubmit = async (event: React.FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    const form = new FormData(event.currentTarget);

    startTransition(async () => {
      const result = await updateAction(form);
      if (result.success) {
        setIsEditing(false);
        // Optionally, show a success message (e.g., using a toast library)
        alert("Profile updated successfully!");
        router.refresh(); // Refresh server components
      } else {
        // Optionally, show an error message
        alert(`Error: ${result.error || "Failed to update profile."}`);
      }
    });
  };

  const handleCancel = () => {
    setFormData({
      firstName: supervisor.firstName || "",
      middleName: supervisor.middleName || "",
      lastName: supervisor.lastName || "",
      phoneNo: supervisor.phoneNo || "",
      // dateOfBirth: supervisor.dateOfBirth ? supervisor.dateOfBirth.toISOString().split("T")[0] : "",
    });
    setIsEditing(false);
  };

  return (
    <form onSubmit={handleSubmit}>
      <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mb-6">
        <div>
          <Label htmlFor="firstName">First Name</Label>
          <Input
            id="firstName"
            name="firstName"
            value={formData.firstName}
            onChange={handleInputChange}
            readOnly={!isEditing}
            required
          />
        </div>
        <div>
          <Label htmlFor="middleName">Middle Name</Label>
          <Input
            id="middleName"
            name="middleName"
            value={formData.middleName}
            onChange={handleInputChange}
            readOnly={!isEditing}
          />
        </div>
        <div>
          <Label htmlFor="lastName">Last Name</Label>
          <Input
            id="lastName"
            name="lastName"
            value={formData.lastName}
            onChange={handleInputChange}
            readOnly={!isEditing}
            required
          />
        </div>
        <div>
          <Label htmlFor="email">Email</Label>
          <Input
            id="email"
            type="email"
            defaultValue={supervisor.email || ""}
            readOnly
            disabled
          />
        </div>
        <div>
          <Label htmlFor="phoneNo">Phone Number</Label>
          <Input
            id="phoneNo"
            name="phoneNo"
            value={formData.phoneNo}
            onChange={handleInputChange}
            readOnly={!isEditing}
          />
        </div>
        <div>
          <Label htmlFor="dateOfBirth">Date of Birth</Label>
          <Input
            id="dateOfBirth"
            name="dateOfBirth"
            type="date"
            defaultValue={
              supervisor.dateOfBirth
                ? supervisor.dateOfBirth.toISOString().split("T")[0]
                : ""
            }
            readOnly
            disabled
          />
        </div>
      </div>

      <div className="flex justify-end space-x-2">
        {isEditing ? (
          <>
            <Button type="button" variant="outline" onClick={handleCancel} disabled={isPending}>
              Cancel
            </Button>
            <Button type="submit" disabled={isPending}>
              {isPending ? "Submitting..." : "Submit"}
            </Button>
          </>
        ) : (
          <Button type="button" onClick={() => setIsEditing(true)}>
            Edit Profile
          </Button>
        )}
      </div>
    </form>
  );
}