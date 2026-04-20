import { Box, Flex, Stack, Text, Image, Container, SimpleGrid, Paper } from '@mantine/core';
import ScrollReveal from '@/components/animations/ScrollReveal';

export default function MonthlyActionSection() {
  return (
    <Box
      component="section"
      id="monthly-action"
      style={{
        backgroundColor: 'var(--color-primary)',
        padding: '120px 0',
      }}
    >
      <Container size="xl">
        <Flex
          direction={{ base: 'column', lg: 'row' }}
          align="center"
          justify="space-between"
          gap={{ base: 60, lg: 80 }}
        >
          {/* Left Text */}
          <ScrollReveal delay={0} direction="right" distance={40}>
          <Stack gap={24} style={{ flex: 1, maxWidth: '500px' }}>
            <Text c="#7A9A80" size="11px" fw={600} ff="var(--font-sans)" style={{ letterSpacing: '3px' }}>
              MONTHLY ACTION
            </Text>
            <Text ff="var(--font-serif)" size="48px" fw={600} c="#FFFFFF" lh={1.1}>
              Know exactly<br />what to pay<br />this month.
            </Text>
            <Text size="17px" c="#FFFFFFAA" ff="var(--font-sans)" style={{ lineHeight: 1.6 }}>
              No more confusion at the start of each month. Open the app, see the exact amount for each debt. Follow the plan. Stay on track.
            </Text>

            <Flex gap={40} mt="16px">
              <Stack gap={4}>
                <Text ff="var(--font-serif)" size="32px" fw={600} c="#FFFFFF">2 min</Text>
                <Text size="13px" c="#7A9A80" ff="var(--font-sans)">Monthly review time</Text>
              </Stack>
              <Stack gap={4}>
                <Text ff="var(--font-serif)" size="32px" fw={600} c="#FFFFFF">₫0</Text>
                <Text size="13px" c="#7A9A80" ff="var(--font-sans)">Hidden fees</Text>
              </Stack>
            </Flex>
          </Stack>
          </ScrollReveal>

          {/* Right Device */}
          <ScrollReveal delay={0.2} direction="left" distance={40}>
          <Box
            style={{
              flex: 1,
              display: 'flex',
              justifyContent: 'flex-end',
              maxWidth: '500px',
            }}
          >
            <Box
              style={{
                borderRadius: '32px',
                overflow: 'hidden',
                boxShadow: '0 24px 60px rgba(0,0,0,0.4)',
                width: '100%',
                maxWidth: '390px',
                backgroundColor: '#fff',
                border: '8px solid white',
              }}
            >
              <Image src="/assets/device_monthly_mockup_1776696521663.png" alt="Monthly Action Dashboard" w="100%" />
            </Box>
          </Box>
          </ScrollReveal>
        </Flex>
      </Container>
    </Box>
  );
}
