import {
  Action,
  ActionPanel,
  Color,
  Icon,
  List,
  showToast,
  Toast,
  Clipboard,
  open,
} from "@raycast/api";
import { useEffect, useState } from "react";
import { scanDevProcesses, killProcess, getDisplayName, abbreviatePath } from "./scanner";
import type { DevProcess } from "./types";

export default function Command() {
  const [processes, setProcesses] = useState<DevProcess[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  const refresh = async () => {
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

  const handleCopyURL = async (process: DevProcess) => {
    const url = `http://localhost:${process.port}`;
    await Clipboard.copy(url);
    await showToast({
      style: Toast.Style.Success,
      title: "URL Copied",
      message: url,
    });
  };

  const handleOpenInBrowser = async (process: DevProcess) => {
    await open(`http://localhost:${process.port}`);
  };

  const handleOpenFolder = async (process: DevProcess) => {
    if (process.workingDirectory) {
      await open(process.workingDirectory);
    }
  };

  const handleOpenTerminal = async (process: DevProcess) => {
    if (process.workingDirectory) {
      // Use AppleScript to open Terminal at the directory
      const script = `tell application "Terminal" to do script "cd '${process.workingDirectory}'"`;
      await open(`osascript -e '${script}'`);
    }
  };

  const handleOpenVSCode = async (process: DevProcess) => {
    if (process.workingDirectory) {
      await open(process.workingDirectory, "com.microsoft.VSCode");
    }
  };

  return (
    <List isLoading={isLoading} searchBarPlaceholder="Search dev servers...">
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
            icon={{ source: Icon.Circle, tintColor: Color.Green }}
            title={getDisplayName(process)}
            subtitle={process.workingDirectory ? abbreviatePath(process.workingDirectory) : undefined}
            accessories={[
              ...(process.gitBranch
                ? [{ tag: { value: process.gitBranch, color: Color.Orange }, icon: Icon.Branch }]
                : []),
              { text: `:${process.port}`, icon: Icon.Network },
            ]}
            actions={
              <ActionPanel>
                <ActionPanel.Section>
                  <Action
                    title="Open in Browser"
                    icon={Icon.Globe}
                    onAction={() => handleOpenInBrowser(process)}
                  />
                  <Action
                    title="Copy URL"
                    icon={Icon.Clipboard}
                    shortcut={{ modifiers: ["cmd"], key: "c" }}
                    onAction={() => handleCopyURL(process)}
                  />
                </ActionPanel.Section>

                <ActionPanel.Section>
                  <Action
                    title="Open in Finder"
                    icon={Icon.Finder}
                    shortcut={{ modifiers: ["cmd"], key: "o" }}
                    onAction={() => handleOpenFolder(process)}
                  />
                  <Action
                    title="Open in Terminal"
                    icon={Icon.Terminal}
                    shortcut={{ modifiers: ["cmd"], key: "t" }}
                    onAction={() => handleOpenTerminal(process)}
                  />
                  <Action
                    title="Open in VS Code"
                    icon={Icon.Code}
                    shortcut={{ modifiers: ["cmd"], key: "." }}
                    onAction={() => handleOpenVSCode(process)}
                  />
                </ActionPanel.Section>

                <ActionPanel.Section>
                  <Action
                    title="Kill Process"
                    icon={Icon.XMarkCircle}
                    style={Action.Style.Destructive}
                    shortcut={{ modifiers: ["cmd"], key: "k" }}
                    onAction={() => handleKill(process)}
                  />
                </ActionPanel.Section>

                <ActionPanel.Section>
                  <Action
                    title="Refresh"
                    icon={Icon.ArrowClockwise}
                    shortcut={{ modifiers: ["cmd"], key: "r" }}
                    onAction={refresh}
                  />
                </ActionPanel.Section>
              </ActionPanel>
            }
          />
        ))
      )}
    </List>
  );
}
