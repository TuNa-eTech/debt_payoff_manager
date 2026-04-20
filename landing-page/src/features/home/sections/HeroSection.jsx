import { Box, Stack, Text, Title, Group, Button, Flex } from '@mantine/core';
import { IconShield, IconApple } from '@tabler/icons-react';
import SiteHeader from '@/components/layout/SiteHeader';
import ScrollReveal from '@/components/animations/ScrollReveal';

export default function HeroSection() {
  return (
    <Box
      component="section"
      style={{
        position: 'relative',
        height: '860px',
        width: '100%',
        overflow: 'hidden',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
      }}
    >
      <SiteHeader />

      {/* Hero Background Image */}
      <Box
        style={{
          position: 'absolute',
          top: 0,
          left: 0,
          right: 0,
          bottom: 0,
          backgroundImage: 'url("https://images.unsplash.com/photo-1761831087685-1ee17becb6d1?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w4NDM0ODN8MHwxfHJhbmRvbXx8fHx8fHx8fDE3NzY2OTMyNDl8&ixlib=rb-4.1.0&q=80&w=1080")',
          backgroundSize: 'cover',
          backgroundPosition: 'center',
          zIndex: 1,
        }}
      />

      {/* Hero Overlay */}
      <Box
        style={{
          position: 'absolute',
          top: 0,
          left: 0,
          right: 0,
          bottom: 0,
          background: 'linear-gradient(175deg, rgba(0,0,0,0.66) 0%, rgba(27,58,40,0.8) 50%, rgba(13,35,24,0.96) 100%)',
          zIndex: 2,
        }}
      />

      {/* Hero Content */}
      <ScrollReveal delay={0.2} direction="up" distance={30}>
        <Stack
          align="center"
          justify="center"
          gap={28}
          px={{ base: 'md', md: '180px' }}
          style={{
            position: 'relative',
            zIndex: 3,
            maxWidth: '1440px',
            width: '100%',
          }}
        >
          {/* Eyebrow */}
          <Group
            gap={8}
            style={{
              padding: '8px 20px',
              borderRadius: '100px',
              backgroundColor: 'rgba(255, 255, 255, 0.094)',
            }}
          >
            <IconShield size={14} color="rgba(255, 255, 255, 0.8)" />
            <Text
              c="rgba(255, 255, 255, 0.8)"
              size="12px"
              fw={600}
              style={{ letterSpacing: '2px' }}
            >
              LOCAL-FIRST DEBT FREEDOM
            </Text>
          </Group>

          {/* Headline */}
          <Title
            order={1}
            ta="center"
            ff="var(--font-serif)"
            c="white"
            fw={700}
            fz={{ base: 48, md: 72, lg: 96 }}
            style={{ lineHeight: 0.96, maxWidth: '900px' }}
          >
            Finally feel<br />in control.
          </Title>

          {/* Subtitle */}
          <Text
            ta="center"
            c="rgba(255, 255, 255, 0.73)"
            fz={{ base: 16, md: 21 }}
            style={{ maxWidth: '640px', lineHeight: 1.55 }}
          >
            Build a real payoff plan with snowball or avalanche — no bank linking, no tracking, no stress.
          </Text>

          {/* CTA Row */}
          <Stack gap={16} mt="md" align="center">
            <Button
              size="xl"
              radius="xl"
              c="white"
              bg="#2D5E3A"
              leftSection={<IconApple size={20} color="#FFFFFF" />}
              style={{
                fontFamily: 'var(--font-sans)',
                fontWeight: 600,
                padding: '16px 36px',
                height: 'auto',
              }}
            >
              Download on the App Store
            </Button>
            <Text c="rgba(255, 255, 255, 0.5)" size="14px">
              Free · No ads
            </Text>
          </Stack>

          {/* statsRow */}
          <Flex
            gap={20}
            mt="xl"
            direction={{ base: 'column', md: 'row' }}
            align="center"
          >
            {/* Card 1 */}
            <Stack
              gap={6}
              w={280}
              style={{
                backgroundColor: 'rgba(255, 255, 255, 0.08)',
                borderRadius: '16px',
                border: '1px solid rgba(255, 255, 255, 0.15)',
                padding: '24px 28px',
              }}
            >
              <Group gap={8} align="center">
                <Box w={8} h={8} style={{ borderRadius: '100px', backgroundColor: '#4ADE80' }} />
                <Text size="13px" fw={500} c="rgba(255, 255, 255, 0.63)">Debt-free date</Text>
              </Group>
              <Text ff="var(--font-serif)" size="32px" fw={700} c="white">Aug 2028</Text>
              <Text size="13px" c="#4ADE80">↓ 4 months faster with Snowball</Text>
            </Stack>

            {/* Card 2 */}
            <Stack
              gap={6}
              w={280}
              style={{
                backgroundColor: 'rgba(255, 255, 255, 0.08)',
                borderRadius: '16px',
                border: '1px solid rgba(255, 255, 255, 0.15)',
                padding: '24px 28px',
              }}
            >
              <Group gap={8} align="center">
                <Box w={8} h={8} style={{ borderRadius: '100px', backgroundColor: '#60A5FA' }} />
                <Text size="13px" fw={500} c="rgba(255, 255, 255, 0.63)">Interest saved</Text>
              </Group>
              <Text ff="var(--font-serif)" size="32px" fw={700} c="white">₫12.4M</Text>
              <Text size="13px" c="rgba(255, 255, 255, 0.38)">vs. minimum payments only</Text>
            </Stack>

            {/* Card 3 */}
            <Stack
              gap={6}
              w={280}
              style={{
                backgroundColor: 'rgba(255, 255, 255, 0.08)',
                borderRadius: '16px',
                border: '1px solid rgba(255, 255, 255, 0.15)',
                padding: '24px 28px',
              }}
            >
              <Group gap={8} align="center">
                <Box w={8} h={8} style={{ borderRadius: '100px', backgroundColor: '#FBBF24' }} />
                <Text size="13px" fw={500} c="rgba(255, 255, 255, 0.63)">Monthly plan</Text>
              </Group>
              <Text ff="var(--font-serif)" size="32px" fw={700} c="white">₫5.0M</Text>
              <Text size="13px" c="rgba(255, 255, 255, 0.38)">across 3 active debts</Text>
            </Stack>
          </Flex>

          {/* progWrap */}
          <Stack
            gap={8}
            mt="lg"
            style={{
              width: '100%',
              maxWidth: '860px',
            }}
          >
            <Flex justify="space-between">
              <Text size="12px" c="rgba(255, 255, 255, 0.31)">Total payoff progress</Text>
              <Text size="12px" fw={500} c="rgba(255, 255, 255, 0.5)">37% paid</Text>
            </Flex>
            <Box style={{ width: '100%', height: '4px', backgroundColor: 'rgba(255, 255, 255, 0.08)', borderRadius: '100px' }}>
              <Box style={{ width: '37%', height: '4px', background: 'linear-gradient(90deg, #4ADE80 0%, #2D5E3A 100%)', borderRadius: '100px' }} />
            </Box>
          </Stack>
        </Stack>
      </ScrollReveal>
    </Box>
  );
}
