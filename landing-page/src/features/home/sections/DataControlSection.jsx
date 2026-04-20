import { Box, Stack, Text, SimpleGrid, Paper, ThemeIcon, Container } from '@mantine/core';
import { IconInfinity, IconPencil, IconDownload } from '@tabler/icons-react';
import ScrollReveal from '@/components/animations/ScrollReveal';

export default function DataControlSection() {
  const cards = [
    {
      icon: IconInfinity,
      title: 'Unlimited debts',
      description: 'Credit cards, student loans, car payments, personal loans — track them all in one place without limits.',
    },
    {
      icon: IconPencil,
      title: 'Manual logging',
      description: 'You log each payment yourself. No automated pulls, no bank permissions. Your plan stays aligned with reality.',
    },
    {
      icon: IconDownload,
      title: 'Export & backup',
      description: 'One tap to CSV. One tap to ZIP backup. Restore anytime. Your financial data never leaves your device unless you choose.',
    },
  ];

  return (
    <Box
      component="section"
      style={{ backgroundColor: '#F5F3EE', padding: '100px 0 120px 0' }}
    >
      <Container size="lg">
        <Stack gap={64}>
          <ScrollReveal delay={0} direction="up" distance={30}>
          <Stack gap={16} align="center">
            <Text c="#7A9A80" size="11px" fw={600} ff="var(--font-sans)" style={{ letterSpacing: '3px' }}>
              YOUR DATA, YOUR RULES
            </Text>
            <Text ff="var(--font-serif)" size="48px" fw={600} c="#1B3A28" ta="center">
              Total control, always.
            </Text>
          </Stack>
          </ScrollReveal>

          <SimpleGrid cols={{ base: 1, md: 3 }} spacing={24}>
            {cards.map((card, idx) => (
              <ScrollReveal key={idx} delay={idx * 0.15} direction="up" distance={30}>
              <Paper
                radius="16px"
                style={{
                  backgroundColor: '#FFFFFF',
                  border: '1px solid #D6DDD0',
                  display: 'flex',
                  flexDirection: 'column',
                  gap: '16px',
                  padding: '36px 32px',
                }}
              >
                <Box
                  style={{
                    width: '52px',
                    height: '52px',
                    backgroundColor: '#2D5E3A15',
                    borderRadius: '14px',
                    display: 'flex',
                    justifyContent: 'center',
                    alignItems: 'center',
                  }}
                >
                  <card.icon size={26} color="#2D5E3A" />
                </Box>
                <Text fw={600} size="20px" ff="var(--font-serif)" c="#1B3A28">
                  {card.title}
                </Text>
                <Text size="15px" ff="var(--font-sans)" c="#7A9A80" style={{ lineHeight: 1.6 }}>
                  {card.description}
                </Text>
              </Paper>
              </ScrollReveal>
            ))}
          </SimpleGrid>
        </Stack>
      </Container>
    </Box>
  );
}
