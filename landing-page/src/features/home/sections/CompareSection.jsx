import { Box, Flex, Text, Stack, Image } from '@mantine/core';
import ScrollReveal from '@/components/animations/ScrollReveal';

export default function CompareSection() {
  return (
    <Box
      component="section"
      id="compare"
      style={{ backgroundColor: '#F5F3EE', padding: '120px 0', overflow: 'hidden' }}
    >
      <Flex direction={{ base: 'column', lg: 'row' }} align="center" justify="center" gap={{ base: 60, lg: 40 }}>
        {/* Left Column */}
        <ScrollReveal delay={0} direction="right" distance={40}>
          <Stack align="center" justify="center" w={{ base: '100%', lg: '400px' }} style={{ position: 'relative' }}>
            <Text
              ff="var(--font-serif)"
              fw={900}
              c="#7A9A8025"
              style={{ fontSize: '72px', letterSpacing: '-1px', position: 'absolute', zIndex: 1, top: '-40px' }}
            >
              SNOWBALL
            </Text>
            <Stack style={{ zIndex: 2, padding: '20px 24px' }} gap="12px">
              <Text c="#7A9A80" size="11px" fw={600} ff="var(--font-sans)" style={{ letterSpacing: '3px' }}>
                STRATEGY
              </Text>
              <Text ff="var(--font-serif)" size="36px" fw={600} c="#1B3A28" lh={1.15}>
                Compare snowball<br/>vs avalanche
              </Text>
              <Text size="16px" c="#7A9A80" ff="var(--font-sans)" style={{ lineHeight: 1.6, maxWidth: '380px' }}>
                See the exact difference in interest paid and payoff timeline. Choose motivation-first or savings-first — with your real numbers.
              </Text>
            </Stack>
          </Stack>
        </ScrollReveal>

        {/* Center Device */}
        <ScrollReveal delay={0.2} direction="up" distance={40}>
          <Box
            style={{
              borderRadius: '40px',
              overflow: 'hidden',
              boxShadow: '0 2px 4px rgba(0,0,0,0.03), 0 12px 32px rgba(0,0,0,0.06)',
              width: '100%',
              maxWidth: '390px',
              flexShrink: 0,
              zIndex: 3,
              backgroundColor: '#fff',
              border: '8px solid white', // simulate the frame outline
            }}
          >
            <Image src="/assets/device_compare_mockup_1776696492708.png" alt="Compare Strategies Dashboard" w="100%" />
          </Box>
        </ScrollReveal>

        {/* Right Column */}
        <ScrollReveal delay={0.4} direction="left" distance={40}>
          <Stack align="center" justify="center" w={{ base: '100%', lg: '400px' }} style={{ position: 'relative' }}>
            <Text
              ff="var(--font-serif)"
              fw={900}
              c="#7A9A8022"
              style={{ fontSize: '72px', letterSpacing: '-1px', position: 'absolute', zIndex: 1, top: '-40px' }}
            >
              AVALANCHE
            </Text>
            <Stack style={{ zIndex: 2, padding: '20px 24px' }} gap="12px">
              <Text c="#7A9A80" size="11px" fw={600} ff="var(--font-sans)" style={{ letterSpacing: '3px' }}>
                AVALANCHE
              </Text>
              <Text ff="var(--font-serif)" size="28px" fw={600} c="#1B3A28" lh={1.2}>
                Save more<br/>interest over time.
              </Text>
              <Text size="15px" c="#7A9A80" ff="var(--font-sans)" style={{ lineHeight: 1.6, maxWidth: '360px' }}>
                Attack the highest APR debt first. Mathematically optimal — perfect for maximizing savings when rates vary widely.
              </Text>
            </Stack>
          </Stack>
        </ScrollReveal>
      </Flex>
    </Box>
  );
}
