import Image from "next/image";

import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuGroup,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";

const items = [
  {
    id: 1,
    message: "New user registered",
  },
  {
    id: 2,
    message: "New donation received",
  },
  {
    id: 5,
    message: "New message from John",
  },
];

export default function NotificationsDropdownMenu() {
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
            <p className="text-[12px] m-auto">6</p>
          </div>
        </div>
      </DropdownMenuTrigger>
      <DropdownMenuContent className="w-52 mt-3">
        <DropdownMenuGroup>
          {items.map((item) => (
            <DropdownMenuItem key={item.id}>
              <p className="text-[14px]">{item.message}</p>
            </DropdownMenuItem>
          ))}
        </DropdownMenuGroup>
      </DropdownMenuContent>
    </DropdownMenu>
  );
}
