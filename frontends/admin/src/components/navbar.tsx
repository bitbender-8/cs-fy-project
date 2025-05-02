import { Avatar, AvatarFallback } from "./ui/avatar";
import { SidebarTrigger } from "./ui/sidebar";
import ProfileDropdownMenu from "./profile-dropdown-menu";
import NotificationsDropdownMenu from "./notifications-dropdown-menu";
import prisma from "@/lib/prisma";
import { auth0 } from "@/lib/auth0";

export default async function Navbar() {
  const session = await auth0.getSession();
  const auth0UserId = session?.user.sub;

  const supervisor = await prisma.supervisor.findUnique({
    where: {
      auth0UserId: auth0UserId,
    },
  });

  return (
    <div className="flex items-center justify-between py-2">
      <SidebarTrigger className="cursor-pointer" />
      <nav className="flex space-x-3 items-center px-4">
        <NotificationsDropdownMenu />
        <Avatar className="w-10 h-10">
          <AvatarFallback className="bg-primary text-white">
            {supervisor?.firstName[0] + " " + supervisor?.lastName[0]}
          </AvatarFallback>
        </Avatar>
        <div>
          <p className="font-bold">
            {supervisor?.firstName + " " + supervisor?.lastName}
          </p>
          <p className="text-[12px] text-[#565656]">Admin</p>
        </div>

        <ProfileDropdownMenu />
      </nav>
    </div>
  );
}
