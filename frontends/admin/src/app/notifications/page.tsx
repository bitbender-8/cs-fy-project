import { DataTableNotificationList } from "@/components/data-tables/data-table-notification-list";
import { notificationTableColumns } from "@/components/table-columns/notification-table-columns";
import prisma from "@/lib/prisma";

export default async function NotificationsPage() {
  const notifications = await prisma.notification.findMany({
    select: {
      id: true,
      subject: true,
      body: true,
      isRead: true,
      createdAt: true,
      recipientId: true,
      supervisorId: true,
    },
    orderBy: {
      createdAt: "desc",
    },
    where: {
      recipientId: null, // Assuming you want to fetch notifications for supervisors only
    },
  });

  return (
    <div>
      <div className="flex justify-between items-center">
        <h1 className="text-primary">Browse Notifications</h1>
      </div>

      <DataTableNotificationList
        columns={notificationTableColumns}
        data={notifications}
      />
    </div>
  );
}
