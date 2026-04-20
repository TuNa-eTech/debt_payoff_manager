import { Box, Group, Text, Flex } from '@mantine/core';
import { Link } from 'react-router-dom';

export default function SiteFooter() {
  return (
    <Box
      component="footer"
      bg="#1B3A28"
      px={{ base: 'md', md: '120px' }}
      py="48px"
      style={{ width: '100%' }}
    >
      <Flex
        direction={{ base: 'column', md: 'row' }}
        justify="space-between"
        align="center"
        gap="xl"
      >
        <Text ff="var(--font-serif)" size="16px" fw={600} c="white">
          Debt Payoff X
        </Text>

        <Group gap={32}>
          <Link to="/support" style={{ color: 'rgba(255, 255, 255, 0.66)', fontSize: '14px', textDecoration: 'none', fontFamily: 'var(--font-sans)' }}>
            Support
          </Link>
          <Link to="/privacy-policy" style={{ color: 'rgba(255, 255, 255, 0.66)', fontSize: '14px', textDecoration: 'none', fontFamily: 'var(--font-sans)' }}>
            Privacy Policy
          </Link>
          <Link to="/terms-of-service" style={{ color: 'rgba(255, 255, 255, 0.66)', fontSize: '14px', textDecoration: 'none', fontFamily: 'var(--font-sans)' }}>
            Terms of Service
          </Link>
        </Group>

        <Text c="rgba(255, 255, 255, 0.4)" size="14px">
          © 2026
        </Text>
      </Flex>
    </Box>
  );
}
