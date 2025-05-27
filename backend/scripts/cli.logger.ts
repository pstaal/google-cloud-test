import { colors } from './cli.colors';

export function logError(message: string): void {
  console.log(`${colors.fg.red}Error ${colors.reset}${message}`);
}

export function logWarning(message: string): void {
  console.log(`${colors.fg.red}Warn ${colors.reset}${message}`);
}

export function logInfo(message: string): void {
  console.log(`${colors.fg.blue}Info ${colors.reset}${message}`);
}

export function logSuccess(message: string): void {
  console.log(`${colors.fg.green}Success ${colors.reset}${message}`);
}

let prevTime: number;
export function logSuccessEntity(
  entity: string,
  count: number | { length: number },
): void {
  const newTime = performance.now();
  const total = typeof count === 'number' ? count : count.length;
  console.log(
    `${colors.bright}✨  Successfully seeded entity ${
      colors.fg.cyan
    }${entity} ${total}x ${colors.fg.gray}${
      prevTime ? `(+${Math.round(newTime - prevTime)}ms)` : ''
    }${colors.reset}`,
  );
  prevTime = newTime;
}

export function logFinished(message: string): void {
  console.log(`\n${colors.bright}✅  ${message}${colors.reset}`);
}
