"use client"

/* eslint-disable @next/next/no-img-element -- tiny static icon */
import { PanelLeftClose, PanelLeftOpen } from "lucide-react"
import Link from "next/link"
import { Tooltip, TooltipContent, TooltipTrigger } from "@/components/ui/tooltip"
import { useSidebar } from "@/components/ui/sidebar"

/**
 * The top of the sidebar, as on ChatGPT: logo and name on the left, the close button on the
 * right. Collapsed, only the logo stays (square, never squeezed); hovering it turns it into the
 * open button. Which variant shows is pure CSS on the sidebar's data-collapsible attribute, so
 * the server and the browser always render the same markup.
 */
export function SidebarTop({ name, suffix, href = "/" }: { name: string; suffix?: string; href?: string }) {
  const { toggleSidebar } = useSidebar()
  return (
    <div className="flex h-10 items-center">
      {/* Expanded */}
      <Link href={href} className="flex h-9 min-w-0 flex-1 items-center gap-2 rounded-md px-1.5 hover:bg-sidebar-accent group-data-[collapsible=icon]:hidden">
        <img src="/icons/icon-192.png" alt="" className="size-6 shrink-0 rounded-md" />
        <span className="truncate font-semibold tracking-tight">
          {name} {suffix && <span className="font-normal text-muted-foreground">{suffix}</span>}
        </span>
      </Link>
      <Tooltip>
        <TooltipTrigger
          render={<button type="button" onClick={toggleSidebar} aria-label="Close sidebar" />}
          className="flex size-8 shrink-0 items-center justify-center rounded-md text-muted-foreground hover:bg-sidebar-accent hover:text-foreground group-data-[collapsible=icon]:hidden"
        >
          <PanelLeftClose className="size-[18px]" strokeWidth={1.75} />
        </TooltipTrigger>
        <TooltipContent side="right">Close sidebar ⌘B</TooltipContent>
      </Tooltip>

      {/* Collapsed: the logo, which becomes the open button on hover */}
      <Tooltip>
        <TooltipTrigger
          render={<button type="button" onClick={toggleSidebar} aria-label="Open sidebar" />}
          className="group/logo relative hidden size-8 shrink-0 items-center justify-center rounded-md hover:bg-sidebar-accent group-data-[collapsible=icon]:flex"
        >
          <img src="/icons/icon-192.png" alt="" className="size-6 shrink-0 rounded-md group-hover/logo:opacity-0 group-focus-visible/logo:opacity-0" />
          <PanelLeftOpen
            className="absolute size-[18px] text-foreground opacity-0 group-hover/logo:opacity-100 group-focus-visible/logo:opacity-100"
            strokeWidth={1.75}
          />
        </TooltipTrigger>
        <TooltipContent side="right">Open sidebar ⌘B</TooltipContent>
      </Tooltip>
    </div>
  )
}
