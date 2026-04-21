import { Box, Stack, Title, Text, Container, SimpleGrid, Card, ThemeIcon, Accordion, Button } from '@mantine/core';
import { IconMail, IconHelp, IconMessageCircle, IconBug } from '@tabler/icons-react';
import SiteHeader from '@/components/layout/SiteHeader';
import SiteFooter from '@/components/layout/SiteFooter';
import ScrollReveal from '@/components/animations/ScrollReveal';

export default function SupportPage() {
  return (
    <Box bg="#F5F3EE" mih="100vh" style={{ display: 'flex', flexDirection: 'column' }}>
      <Box bg="#1B3A28" pb="xl">
        <SiteHeader />
        <Container size="lg" pt="120px" pb="60px">
          <ScrollReveal>
            <Stack align="center" gap="md">
              <Title order={1} c="white" ff="var(--font-serif)" fz={{ base: 40, md: 56 }}>
                Support Center
              </Title>
              <Text c="white" opacity={0.8} size="xl" ta="center" maw={600}>
                How can we help you today?
              </Text>
            </Stack>
          </ScrollReveal>
        </Container>
      </Box>
      <Box style={{ flex: 1 }}>
        <Container size="lg" py="80px">
          <SimpleGrid cols={{ base: 1, sm: 2 }} spacing="xl" mb="80px">
            <Card padding="xl" radius="md" bg="white" shadow="sm" withBorder>
              <ThemeIcon size={50} radius="md" color="#1B3A28" variant="light" mb="md">
                <IconMail size={26} stroke={1.5} />
              </ThemeIcon>
              <Title order={3} mb="sm" ff="var(--font-sans)">Email Support</Title>
              <Text c="dimmed" mb="lg">
                Have a specific question? Send us an email and our team will get back to you within 24 hours.
              </Text>
              <Button component="a" href="mailto:support@debtpayoffmanager.com" variant="light" color="#1B3A28">
                Contact Support
              </Button>
            </Card>

            <Card padding="xl" radius="md" bg="white" shadow="sm" withBorder>
              <ThemeIcon size={50} radius="md" color="#1B3A28" variant="light" mb="md">
                <IconBug size={26} stroke={1.5} />
              </ThemeIcon>
              <Title order={3} mb="sm" ff="var(--font-sans)">Report a Bug</Title>
              <Text c="dimmed" mb="lg">
                Found something that isn't working right? Let us know so we can fix it in our next update.
              </Text>
              <Button component="a" href="mailto:bugs@debtpayoffmanager.com" variant="light" color="#1B3A28">
                Report Issue
              </Button>
            </Card>
          </SimpleGrid>

          <Box maw={800} mx="auto">
            <Title order={2} ta="center" mb="xl" ff="var(--font-serif)">Frequently Asked Questions</Title>
            <Accordion variant="separated" radius="md">
              <Accordion.Item value="safe">
                <Accordion.Control>Is my financial data safe?</Accordion.Control>
                <Accordion.Panel>
                  <Text c="dimmed">Yes. We use industry-standard encryption to protect your data. Furthermore, we never connect directly to your bank accounts or ask for your banking credentials. All data you enter is purely for calculation purposes.</Text>
                </Accordion.Panel>
              </Accordion.Item>

              <Accordion.Item value="strategy">
                <Accordion.Control>Should I use Snowball or Avalanche?</Accordion.Control>
                <Accordion.Panel>
                  <Text c="dimmed">The Avalanche method (paying highest interest first) is mathematically optimal and saves the most money. The Snowball method (paying smallest balance first) provides quick psychological wins. Our app lets you compare both to see what works best for you.</Text>
                </Accordion.Panel>
              </Accordion.Item>

              <Accordion.Item value="sync">
                <Accordion.Control>Does the app sync across my devices?</Accordion.Control>
                <Accordion.Panel>
                  <Text c="dimmed">Yes! If you create an account, your data will securely sync across all your iOS and Android devices in real-time.</Text>
                </Accordion.Panel>
              </Accordion.Item>
              
              <Accordion.Item value="export">
                <Accordion.Control>Can I export my data?</Accordion.Control>
                <Accordion.Panel>
                  <Text c="dimmed">We are currently working on an export feature (CSV/PDF) which will be available in an upcoming release.</Text>
                </Accordion.Panel>
              </Accordion.Item>
            </Accordion>
          </Box>
        </Container>
      </Box>
      <SiteFooter />
    </Box>
  );
}
