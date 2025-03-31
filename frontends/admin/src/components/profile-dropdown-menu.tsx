import {
    ChevronDown,
    LogOutIcon,
    User,
  } from "lucide-react"
   
  import {
    DropdownMenu,
    DropdownMenuContent,
    DropdownMenuGroup,
    DropdownMenuItem,
    DropdownMenuTrigger,
  } from "@/components/ui/dropdown-menu"
   

export default function ProfileDropdownMenu() {
    return (
        <DropdownMenu modal={false}>
          <DropdownMenuTrigger asChild className="cursor-pointer">
            <ChevronDown width={18} height={18} color="#565656"/>
          </DropdownMenuTrigger>
          <DropdownMenuContent className="w-52 mt-3" align="end">
            <DropdownMenuGroup>
              <DropdownMenuItem>
                <User />
                <span>Manage Account</span>
              </DropdownMenuItem>
              <DropdownMenuItem>
                <LogOutIcon />
                <span>Logout</span>
              </DropdownMenuItem>
            </DropdownMenuGroup>
          </DropdownMenuContent>
        </DropdownMenu>
      )
}