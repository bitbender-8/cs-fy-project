import { Avatar, AvatarFallback, AvatarImage } from "./ui/avatar";
import { SidebarTrigger } from "./ui/sidebar";
import ProfileDropdownMenu from "./profile-dropdown-menu";
import NotificationsDropdownMenu from "./notifications-dropdown-menu";

export default function Navbar() {
  return (
    <div className="flex items-center justify-between py-2">
      <SidebarTrigger className="cursor-pointer" />
      <nav className="flex space-x-3 items-center px-4">
        <NotificationsDropdownMenu />
        <Avatar className="w-10 h-10">
          <AvatarImage src="https://github.com/shadcn.png" alt="@shadcn" />
          <AvatarFallback className="bg-primary">CN</AvatarFallback>
        </Avatar>
        <div>
          <p className="font-bold">Chala Daba</p>
          <p className="text-[12px] text-[#565656]">Admin</p>
        </div>

        <ProfileDropdownMenu />
      </nav>
    </div>
  );
}
