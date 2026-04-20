import { Box, Stack, Title, Text, Container } from '@mantine/core';
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
                Support
              </Title>
            </Stack>
          </ScrollReveal>
        </Container>
      </Box>
      <Box style={{ flex: 1 }}>
        <Container size="lg" py="60px">
          <Text>Content coming soon...</Text>
        </Container>
      </Box>
      <SiteFooter />
    </Box>
  );
}
