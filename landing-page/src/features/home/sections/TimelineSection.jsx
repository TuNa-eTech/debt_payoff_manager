import { Box, Flex, Stack, Text, Image, Group, ThemeIcon } from '@mantine/core';
import { IconCircleCheckFilled } from '@tabler/icons-react';
import ScrollReveal from '@/components/animations/ScrollReveal';

export default function TimelineSection() {
  const bulletPoints = [
    'Updates with every payment you log',
    'Shows month-by-month payment breakdown',
    'Switch strategy anytime, see impact instantly',
  ];

  return (
    <Box
      component="section"
      id="timeline"
      style={{ backgroundColor: '#F5F3EE', padding: '120px 0', overflow: 'hidden' }}
    >
      <Flex direction={{ base: 'column', lg: 'row' }} align="center" justify="center" gap={{ base: 60, lg: 40 }}>
        {/* Left Ghost 2 */}
        <ScrollReveal delay={0} direction="right" distance={40}>
        <Box w={{ base: '100%', lg: '400px' }} style={{ position: 'relative', display: 'flex', justifyContent: 'center' }}>
          <Text
            ff="var(--font-serif)"
            fw={900}
            c="#7A9A8020"
            ta="center"
            style={{ fontSize: '130px', letterSpacing: '-3px', lineHeight: 0.85, position: 'absolute', top: '-60px', zIndex: 1 }}
          >
            DEBT<br />FREE
          </Text>
        </Box>
        </ScrollReveal>

        {/* Center Device 2 */}
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
            border: '8px solid white',
          }}
        >
          <Image src="/assets/device_timeline_mockup_1776696583197.png" alt="Timeline Dashboard" w="100%" />
        </Box>
        </ScrollReveal>

        {/* Right Content */}
        <ScrollReveal delay={0.4} direction="left" distance={40}>
        <Stack justify="center" w={{ base: '100%', lg: '400px' }} style={{ zIndex: 2, padding: '0 24px' }}>
          <Text c="#7A9A80" size="11px" fw={600} ff="var(--font-sans)" style={{ letterSpacing: '3px' }}>
            TIMELINE
          </Text>
          <Text ff="var(--font-serif)" size="36px" fw={600} c="#1B3A28" lh={1.15} mt="8px">
            Your living<br />payoff timeline.
          </Text>
          <Text size="16px" c="#7A9A80" ff="var(--font-sans)" style={{ lineHeight: 1.6 }} mt="xs" mb="lg">
            Your debt-free date isn't static. It updates every time you log a payment, adjust a balance, or change your extra payment amount.
          </Text>

          <Stack gap={12} mt="8px">
            {bulletPoints.map((point, i) => (
              <Group key={i} gap="12px" align="center" wrap="nowrap">
                <IconCircleCheckFilled size={18} color="#2D5E3A" style={{ flexShrink: 0 }} />
                <Text size="15px" c="#1B3A28" ff="var(--font-sans)" style={{ lineHeight: 1.4 }}>
                  {point}
                </Text>
              </Group>
            ))}
            </Stack>
        </Stack>
        </ScrollReveal>
      </Flex>
    </Box>
  );
}
