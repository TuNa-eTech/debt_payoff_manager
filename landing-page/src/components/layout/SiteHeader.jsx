import { Box, Group, Text, Anchor, Button } from '@mantine/core';
import { Link } from 'react-router-dom';

export default function SiteHeader() {
  return (
    <Box
      component="nav"
      px={{ base: 'md', md: '120px' }}
      style={{
        position: 'absolute',
        top: 0,
        left: 0,
        right: 0,
        zIndex: 10,
        height: '64px',
      }}
    >
      <Group justify="space-between" h="100%">
        <Text ff="var(--font-serif)" size="20px" fw={600} c="white">
          Debt Payoff X
        </Text>
        <Group gap={32} visibleFrom="sm">
          <Link to="/features" style={{ color: 'rgba(255, 255, 255, 0.8)', fontSize: '14px', textDecoration: 'none', fontFamily: 'var(--font-sans)' }}>
            Features
          </Link>
          <Link to="/" style={{ color: 'rgba(255, 255, 255, 0.8)', fontSize: '14px', textDecoration: 'none', fontFamily: 'var(--font-sans)' }}>
            How it Works
          </Link>
          <Button
            component={Link}
            to="/#download"
            radius="xl"
            bg="rgba(255, 255, 255, 0.133)"
            c="white"
            style={{
              padding: '10px 24px',
              fontFamily: 'var(--font-sans)',
              fontWeight: 500,
              height: 'auto',
            }}
          >
            Download
          </Button>
        </Group>
      </Group>
    </Box>
  );
}
