import { Box, Stack, Title, Text, Container, SimpleGrid, Card, ThemeIcon } from '@mantine/core';
import { IconChartLine, IconCalculator, IconDeviceMobile, IconLock, IconBolt, IconTarget } from '@tabler/icons-react';
import SiteHeader from '@/components/layout/SiteHeader';
import SiteFooter from '@/components/layout/SiteFooter';
import ScrollReveal from '@/components/animations/ScrollReveal';

export default function FeaturesPage() {
  return (
    <Box bg="#F5F3EE" mih="100vh" style={{ display: 'flex', flexDirection: 'column' }}>
      <Box bg="#1B3A28" pb="xl">
        <SiteHeader />
        <Container size="lg" pt="120px" pb="60px">
          <ScrollReveal>
            <Stack align="center" gap="md">
              <Title order={1} c="white" ff="var(--font-serif)" fz={{ base: 40, md: 56 }}>
                Features
              </Title>
              <Text c="white" opacity={0.8} size="xl" ta="center" maw={600}>
                Everything you need to take control of your debt and achieve financial freedom faster.
              </Text>
            </Stack>
          </ScrollReveal>
        </Container>
      </Box>
  <Box style={{ flex: 1 }}>
        <Container size="lg" py="80px">
          <SimpleGrid cols={{ base: 1, sm: 2, md: 3 }} spacing="xl">
            {[
              {
                icon: IconCalculator,
                title: 'Snowball vs Avalanche',
                description: 'Compare different payoff strategies to see which saves you the most money or gets you out of debt the fastest.',
              },
              {
                icon: IconChartLine,
                title: 'Visual Timeline',
                description: 'See exactly when you will be debt-free with our beautiful, easy-to-understand interactive charts.',
              },
              {
                icon: IconTarget,
                title: 'Goal Tracking',
                description: 'Set custom payoff goals and watch your progress as you crush your debts one by one.',
              },
              {
                icon: IconBolt,
                title: 'Extra Payments Impact',
                description: 'Instantly calculate how much time and interest you save by adding extra to your monthly payments.',
              },
              {
                icon: IconDeviceMobile,
                title: 'Cross-Device Sync',
                description: 'Access your debt payoff plan anywhere. Your data safely syncs across all your devices in real-time.',
              },
              {
                icon: IconLock,
                title: 'Bank-Grade Security',
                description: 'Your financial data is encrypted and secure. We never connect directly to your bank accounts.',
              },
            ].map((feature, index) => (
              <ScrollReveal key={index} delay={index * 0.1}>
                <Card padding="xl" radius="md" bg="white" shadow="sm" withBorder style={{ height: '100%' }}>
                  <ThemeIcon size={50} radius="md" color="#1B3A28" variant="light" mb="md">
                    <feature.icon size={26} stroke={1.5} />
                  </ThemeIcon>
                  <Text fz="lg" fw={600} mb="xs" ff="var(--font-sans)">
                    {feature.title}
                  </Text>
                  <Text fz="sm" c="dimmed" lh={1.6}>
                    {feature.description}
                  </Text>
                </Card>
              </ScrollReveal>
            ))}
          </SimpleGrid>
        </Container>
      </Box>
      <SiteFooter />
    </Box>
  );
}
