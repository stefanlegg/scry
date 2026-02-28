import { Action, ActionPanel, Color, Icon, List, open } from "@raycast/api";
import { useEffect, useState } from "react";
import { scanDevProcesses, getDisplayName, abbreviatePath } from "./scanner";
import type { DevProcess } from "./types";

export default function Command() {
  const [processes, setProcesses] = useState<DevProcess[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    const scanned = scanDevProcesses();
    setProcesses(scanned);
    setIsLoading(false);
  }, []);

  const handleOpen = async (process: DevProcess) => {
    await open(`http://localhost:${process.port}`);
  };

  return (
    <List isLoading={isLoading} searchBarPlaceholder="Search servers to open...">
      {processes.length === 0 && !isLoading ? (
        <List.EmptyView
          icon={Icon.Moon}
          title="No Dev Servers Running"
          description="Start a dev server on ports 3000-9999"
        />
      ) : (
        processes.map((process) => (
          <List.Item
            key={process.pid}
            icon={{ source: Icon.Globe, tintColor: Color.Blue }}
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
                  title="Open in Browser"
                  icon={Icon.Globe}
                  onAction={() => handleOpen(process)}
                />
              </ActionPanel>
            }
          />
        ))
      )}
    </List>
  );
}
