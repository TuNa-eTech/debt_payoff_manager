import { Box, Stack, Title, Text, Container } from '@mantine/core';
import SiteHeader from '@/components/layout/SiteHeader';
import SiteFooter from '@/components/layout/SiteFooter';
import ScrollReveal from '@/components/animations/ScrollReveal';

export default function TermsOfServicePage() {
  return (
    <Box bg="#F5F3EE" mih="100vh" style={{ display: 'flex', flexDirection: 'column' }}>
      <Box bg="#1B3A28" pb="xl">
        <SiteHeader />
        <Container size="lg" pt="120px" pb="60px">
          <ScrollReveal>
            <Stack align="center" gap="md">
              <Title order={1} c="white" ff="var(--font-serif)" fz={{ base: 40, md: 56 }}>
                Terms of Service
              </Title>
              <Text c="white" opacity={0.8} size="xl" ta="center" maw={600}>
                Last updated: April 2026
              </Text>
            </Stack>
          </ScrollReveal>
        </Container>
      </Box>
      <Box style={{ flex: 1 }}>
        <Container size="md" py="80px">
          <Stack gap="xl">
            <Box>
              <Title order={2} mb="md" ff="var(--font-serif)">1. Agreement to Terms</Title>
              <Text c="dimmed" lh={1.6}>
                By accessing or using Debt Payoff Manager, you agree to be bound by these Terms of Service. If you disagree with any part of the terms, then you do not have permission to access the Service.
              </Text>
            </Box>

            <Box>
              <Title order={2} mb="md" ff="var(--font-serif)">2. Not Financial Advice</Title>
              <Text c="dimmed" lh={1.6}>
                The Service is provided for educational and informational purposes only. We are not financial advisors, and nothing contained in the Service should be construed as financial, investment, or tax advice. You should consult with a professional financial advisor before making any financial decisions. We do not guarantee the accuracy of any calculations or timeline projections.
              </Text>
            </Box>

            <Box>
              <Title order={2} mb="md" ff="var(--font-serif)">3. User Accounts</Title>
              <Text c="dimmed" lh={1.6}>
                When you create an account with us, you guarantee that the information you provide us is accurate, complete, and current at all times. Inaccurate, incomplete, or obsolete information may result in the immediate termination of your account on the Service.
              </Text>
              <Text c="dimmed" lh={1.6} mt="sm">
                You are responsible for maintaining the confidentiality of your account and password, including but not limited to the restriction of access to your computer and/or account.
              </Text>
            </Box>

            <Box>
              <Title order={2} mb="md" ff="var(--font-serif)">4. Intellectual Property</Title>
              <Text c="dimmed" lh={1.6}>
                The Service and its original content, features, and functionality are and will remain the exclusive property of Debt Payoff Manager and its licensors. The Service is protected by copyright, trademark, and other laws of both the United States and foreign countries.
              </Text>
            </Box>

            <Box>
              <Title order={2} mb="md" ff="var(--font-serif)">5. Limitation of Liability</Title>
              <Text c="dimmed" lh={1.6}>
                In no event shall Debt Payoff Manager, nor its directors, employees, partners, agents, suppliers, or affiliates, be liable for any indirect, incidental, special, consequential or punitive damages, including without limitation, loss of profits, data, use, goodwill, or other intangible losses, resulting from your access to or use of or inability to access or use the Service.
              </Text>
            </Box>

            <Box>
              <Title order={2} mb="md" ff="var(--font-serif)">6. Changes</Title>
              <Text c="dimmed" lh={1.6}>
                We reserve the right, at our sole discretion, to modify or replace these Terms at any time. What constitutes a material change will be determined at our sole discretion. By continuing to access or use our Service after any revisions become effective, you agree to be bound by the revised terms.
              </Text>
            </Box>
          </Stack>
        </Container>
      </Box>
      <SiteFooter />
    </Box>
  );
}
