import '@fontsource/space-grotesk/400.css';
import '@fontsource/space-grotesk/500.css';
import '@fontsource/space-grotesk/700.css';
import '@mantine/core/styles.css';
import { MantineProvider } from '@mantine/core';
import { theme } from '@/theme';

export function AppProviders({ children }) {
  return <MantineProvider theme={theme}>{children}</MantineProvider>;
}
