import { cn } from "@/lib/utils";

export interface InputProps
  extends React.InputHTMLAttributes<HTMLInputElement> {
  startIcon?: React.ElementType;
  endIcon?: React.ElementType;
}

function Input({ className, type, startIcon, endIcon, ...props }: InputProps) {
  const StartIcon = startIcon;

  return (
    <div className="w-full relative">
      <input
        type={type}
        className={cn(
          "peer flex h-10 w-full rounded-md border border-input bg-background py-2 px-4 text-sm ring-offset-background file:border-0 file:bg-transparent file:text-sm file:font-medium placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring focus-visible:ring-offset-0 disabled:cursor-not-allowed disabled:opacity-50",
          startIcon ? "pl-8" : "",
          endIcon ? "pr-8" : "",
          className,
        )}
        {...props}
      />
      {StartIcon && (
        <StartIcon className=" absolute left-2.5 top-1/2 transform -translate-y-1/2 h-4 w-4 text-gray-500 peer-focus:text-gray-900" />
      )}
    </div>
  );
}

export { Input };
