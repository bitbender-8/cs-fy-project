import {
  Search,
  Settings,
  LayoutDashboard,
  LogOutIcon,
  BellIcon,
  BadgeDollarSign,
} from "lucide-react";

import Image from "next/image";

import {
  Sidebar,
  SidebarContent,
  SidebarGroup,
  SidebarGroupContent,
  SidebarHeader,
  SidebarMenu,
  SidebarMenuButton,
  SidebarMenuItem,
} from "@/components/ui/sidebar";

const itemsTop = [
  {
    title: "Dashboard",
    url: "/",
    icon: LayoutDashboard,
  },
  {
    title: "Browse Campaigns",
    url: "/browse-campaigns",
    icon: Search,
  },
  {
    title: "Notifications",
    url: "/notifications",
    icon: BellIcon,
  },
  {
    title: "Donations",
    url: "/donations",
    icon: BadgeDollarSign,
  },
];

const itemsBottom = [
  {
    title: "Settings",
    url: "/settings",
    icon: Settings,
  },
  {
    title: "Logout",
    url: "/auth/logout",
    icon: LogOutIcon,
  },
];

export function AppSidebar() {
  return (
    <Sidebar collapsible="icon">
      <SidebarHeader>
        <Image
          src="/tesfafund-main-logo.png"
          alt="TesfaFund Logo"
          width={120}
          height={120}
          className=""
        />
      </SidebarHeader>
      <SidebarContent>
        <SidebarGroup className="h-full">
          <SidebarGroupContent className="h-full">
            <SidebarMenu className="h-full justify-between">
              <div>
                {itemsTop.map((item) => (
                  <SidebarMenuItem key={item.title}>
                    <SidebarMenuButton asChild>
                      <a href={item.url}>
                        <item.icon />
                        <span>{item.title}</span>
                      </a>
                    </SidebarMenuButton>
                  </SidebarMenuItem>
                ))}
              </div>

              <div className="pb-8">
                <hr className="border-t border-gray-200 my-4" />
                {itemsBottom.map((item) => (
                  <SidebarMenuItem key={item.title}>
                    <SidebarMenuButton asChild>
                      <a href={item.url}>
                        <item.icon />
                        <span>{item.title}</span>
                      </a>
                    </SidebarMenuButton>
                  </SidebarMenuItem>
                ))}
              </div>
            </SidebarMenu>
          </SidebarGroupContent>
        </SidebarGroup>
      </SidebarContent>
    </Sidebar>
  );
}
