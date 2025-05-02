import Image from "next/image";

import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuGroup,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import prisma from "@/lib/prisma";

export default async function NotificationsDropdownMenu() {
  const notifications = await prisma.notification.findMany();

  return (
    <DropdownMenu modal={false}>
      <DropdownMenuTrigger asChild className="cursor-pointer">
        <div className="relative w-10">
          <Image
            aria-hidden
            src="/icons/notification-icon.svg"
            alt="Notification Icon"
            width={25}
            height={25}
            className="mx-auto"
          />

          <div className="absolute -top-[5px] right-[5px] flex text-white bg-red-500 rounded-full w-4 h-4">
            <p className="text-[12px] m-auto">{notifications.length}</p>
          </div>
        </div>
      </DropdownMenuTrigger>
      <DropdownMenuContent className="w-52 mt-3">
        <DropdownMenuGroup>
          {notifications.map((item) => (
            <DropdownMenuItem key={item.id}>
              <p className="text-[14px]">{item.body}</p>
            </DropdownMenuItem>
          ))}
        </DropdownMenuGroup>
      </DropdownMenuContent>
    </DropdownMenu>
  );
}
