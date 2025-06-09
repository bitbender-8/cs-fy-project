import { auth0 } from "@/lib/auth0";
import prisma from "@/lib/prisma";
import { Avatar, AvatarFallback } from "@/components/ui/avatar";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import ProfileForm from "@/components/profile-form";
import { updateSupervisorProfile } from "@/lib/actions";

export default async function ProfilePage() {
  const session = await auth0.getSession();
  const auth0UserId = session?.user.sub;

  if (!auth0UserId) {
    // Handle unauthenticated state, e.g., redirect to login
    return <p>Please log in to view your profile.</p>;
  }

  const supervisor = await prisma.supervisor.findUnique({
    where: {
      auth0UserId: auth0UserId,
    },
  });

  if (!supervisor) {
    return <p>Supervisor profile not found.</p>;
  }

  return (
    <div className="container mx-auto py-10">
      <Card className="max-w-2xl mx-auto">
        <CardHeader>
          <div className="flex items-center space-x-4">
            <Avatar className="w-20 h-20">
              <AvatarFallback className="text-2xl bg-primary text-white">
                {supervisor.firstName?.[0]}
                {supervisor.lastName?.[0]}
              </AvatarFallback>
            </Avatar>
            <div>
              <CardTitle className="text-2xl">
                {supervisor.firstName} {supervisor.middleName}{" "}
                {supervisor.lastName}
              </CardTitle>
              <CardDescription>Supervisor Profile</CardDescription>
            </div>
          </div>
        </CardHeader>
        <CardContent className="space-y-6">
          <ProfileForm
            supervisor={supervisor}
            updateAction={updateSupervisorProfile}
          />
        </CardContent>
      </Card>
    </div>
  );
}
