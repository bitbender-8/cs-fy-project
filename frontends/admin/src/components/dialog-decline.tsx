import { Button } from "@/components/ui/button";
import {
  Dialog,
  DialogClose,
  DialogContent,
  DialogFooter,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "@/components/ui/dialog";
import { useState } from "react";

type DialogDeclineProps = {
  onDecline: () => void;
};

export function DialogDecline({ onDecline }: DialogDeclineProps) {
  const [dialogOpen, setDialogOpen] = useState(false);

  const handleCancel = () => {
    setDialogOpen(false);
  };
  return (
    <Dialog open={dialogOpen} onOpenChange={setDialogOpen}>
      <DialogTrigger asChild>
        <Button
          className="cursor-pointer hover:bg-red-800"
          variant="destructive"
        >
          Decline
        </Button>
      </DialogTrigger>
      <DialogContent className="sm:max-w-md">
        <DialogHeader>
          <DialogTitle>
            Are you sure you want to decline this request?
          </DialogTitle>
        </DialogHeader>
        <DialogFooter className="sm:justify-end">
          <DialogClose asChild>
            <Button
              className="cursor-pointer hover:bg-red-800"
              variant="destructive"
              onClick={() => onDecline()}
            >
              Decline
            </Button>
          </DialogClose>

          <Button variant="outline" onClick={handleCancel}>
            No
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}
