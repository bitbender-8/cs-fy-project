"use client"; // Add this directive at the top

import Image from "next/image";
import { useEffect, useState, startTransition } from "react"; // Import hooks

import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuGroup,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
// Remove direct prisma import from client component
// import prisma from "@/lib/prisma";
import { getUnreadNotificationsAction, markNotificationsAsReadAction } from "@/lib/actions"; // Adjust path if your actions file is elsewhere

interface Notification {
  id: string;
  body: string | null;
}

export default function NotificationsDropdownMenu() {
  const [notifications, setNotifications] = useState<Notification[]>([]);
  const [isOpen, setIsOpen] = useState(false);
  const [isLoading, setIsLoading] = useState(true);

  const fetchNotifications = async () => {
    setIsLoading(true);
    const result = await getUnreadNotificationsAction();
    if (result.success && result.data) {
      setNotifications(result.data);
    } else {
      console.error("Failed to fetch notifications:", result.message);
    }
    setIsLoading(false);
  };

  useEffect(() => {
    fetchNotifications();
  }, []);

  const handleOpenChange = (open: boolean) => {
    setIsOpen(open);
    if (!open && notifications.length > 0) {
      // Dropdown is closing and there are notifications to mark as read
      const unreadNotificationIds = notifications.map((n) => n.id);

      startTransition(async () => {
        const result = await markNotificationsAsReadAction(unreadNotificationIds);
        if (result.success) {
          // Optimistically update UI or re-fetch
          // For immediate feedback, we can clear the notifications or filter them
          // This assumes all displayed notifications were marked as read
          setNotifications([]); // Clears the list, badge will show 0
          // Or, to be more accurate if some might not have been updated (e.g. already read by another process):
          // fetchNotifications(); // Re-fetch to get the true current state
        } else {
          console.error("Failed to mark notifications as read:", result.message);
          // Optionally, inform the user of the failure
        }
      });
    } else if (open && notifications.length === 0 && !isLoading) {
        // If opening and list is empty, try to fetch again in case new ones arrived
        fetchNotifications();
    }
  };

  return (
    <DropdownMenu modal={false} open={isOpen} onOpenChange={handleOpenChange}>
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
          {notifications.length > 0 && (
            <div className="absolute -top-[5px] right-[5px] flex text-white bg-red-500 rounded-full w-4 h-4">
              <p className="text-[12px] m-auto">{notifications.length}</p>
            </div>
          )}
        </div>
      </DropdownMenuTrigger>
      <DropdownMenuContent className="w-52 mt-3">
        <DropdownMenuGroup>
          {isLoading ? (
            <DropdownMenuItem disabled>
              <p className="text-[14px] text-gray-500">Loading...</p>
            </DropdownMenuItem>
          ) : notifications.length > 0 ? (
            notifications.map((item) => (
              <DropdownMenuItem key={item.id} onSelect={(e) => e.preventDefault()}> {/* Prevent auto-close on item click if needed */}
                <p className="text-[14px]">{item.body}</p>
              </DropdownMenuItem>
            ))
          ) : (
            <DropdownMenuItem disabled>
              <p className="text-[14px] text-gray-500">No new notifications</p>
            </DropdownMenuItem>
          )}
        </DropdownMenuGroup>
      </DropdownMenuContent>
    </DropdownMenu>
  );
}