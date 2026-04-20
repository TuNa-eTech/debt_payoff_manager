import { Box } from '@mantine/core';

export default function MarketingLayout({ children }) {
  return (
    <Box className="page-shell">
      <Box className="hero-backdrop" />
      {children}
    </Box>
  );
}
