import { Action, ActionPanel, Color, Icon, List, showToast, Toast } from "@raycast/api";
import { useEffect, useState } from "react";
import { scanDevProcesses, killProcess, getDisplayName, abbreviatePath } from "./scanner";
import type { DevProcess } from "./types";

export default function Command() {
  const [processes, setProcesses] = useState<DevProcess[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  const refresh = () => {
    setIsLoading(true);
    const scanned = scanDevProcesses();
    setProcesses(scanned);
    setIsLoading(false);
  };

  useEffect(() => {
    refresh();
  }, []);

  const handleKill = async (process: DevProcess) => {
    const success = killProcess(process.pid);
    if (success) {
      await showToast({
        style: Toast.Style.Success,
        title: "Process Killed",
        message: `Stopped ${getDisplayName(process)} on port ${process.port}`,
      });
      refresh();
    } else {
      await showToast({
        style: Toast.Style.Failure,
        title: "Failed to Kill Process",
        message: `Could not stop process ${process.pid}`,
      });
    }
  };

  return (
    <List isLoading={isLoading} searchBarPlaceholder="Search servers to kill...">
      {processes.length === 0 && !isLoading ? (
        <List.EmptyView
          icon={Icon.Moon}
          title="No Dev Servers Running"
          description="Nothing to kill!"
        />
      ) : (
        processes.map((process) => (
          <List.Item
            key={process.pid}
            icon={{ source: Icon.XMarkCircle, tintColor: Color.Red }}
            title={getDisplayName(process)}
            subtitle={`:${process.port}`}
            accessories={[
              ...(process.gitBranch
                ? [{ tag: { value: process.gitBranch, color: Color.Orange } }]
                : []),
              {
                text: process.workingDirectory
                  ? abbreviatePath(process.workingDirectory)
                  : undefined,
              },
            ]}
            actions={
              <ActionPanel>
                <Action
                  title="Kill Process"
                  icon={Icon.XMarkCircle}
                  style={Action.Style.Destructive}
                  onAction={() => handleKill(process)}
                />
              </ActionPanel>
            }
          />
        ))
      )}
    </List>
  );
}
