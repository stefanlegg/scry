export interface DevProcess {
  pid: number;
  name: string;
  port: number;
  workingDirectory?: string;
  gitBranch?: string;
  command?: string;
}

export interface PinnedProject {
  path: string;
  displayName: string;
  isWatched: boolean;
  runningProcess?: DevProcess;
}
