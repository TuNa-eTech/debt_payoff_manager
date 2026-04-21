import { Box, Stack, Title, Text, Container } from '@mantine/core';
import SiteHeader from '@/components/layout/SiteHeader';
import SiteFooter from '@/components/layout/SiteFooter';
import ScrollReveal from '@/components/animations/ScrollReveal';

export default function PrivacyPolicyPage() {
  return (
    <Box bg="#F5F3EE" mih="100vh" style={{ display: 'flex', flexDirection: 'column' }}>
      <Box bg="#1B3A28" pb="xl">
        <SiteHeader />
        <Container size="lg" pt="120px" pb="60px">
          <ScrollReveal>
            <Stack align="center" gap="md">
              <Title order={1} c="white" ff="var(--font-serif)" fz={{ base: 40, md: 56 }}>
                Privacy Policy
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
              <Title order={2} mb="md" ff="var(--font-serif)">1. Introduction</Title>
              <Text c="dimmed" lh={1.6}>
                At Debt Payoff Manager, we take your privacy seriously. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our mobile application and website. Please read this privacy policy carefully. If you do not agree with the terms of this privacy policy, please do not access the application.
              </Text>
            </Box>

            <Box>
              <Title order={2} mb="md" ff="var(--font-serif)">2. Information We Collect</Title>
              <Text c="dimmed" lh={1.6} mb="sm">
                We may collect information about you in a variety of ways. The information we may collect includes:
              </Text>
              <Text c="dimmed" lh={1.6}>
                • <strong>Personal Data:</strong> Personally identifiable information, such as your name and email address, that you voluntarily give to us when you register with the Application.
                <br />
                • <strong>Financial Data:</strong> Information related to your debts (balances, interest rates, minimum payments) that you manually enter into the app. We do NOT connect to your bank accounts or collect sensitive financial credentials.
                <br />
                • <strong>Derivative Data:</strong> Information our servers automatically collect when you access the Application, such as your native actions that are integral to the Application.
              </Text>
            </Box>

            <Box>
              <Title order={2} mb="md" ff="var(--font-serif)">3. Use of Your Information</Title>
              <Text c="dimmed" lh={1.6}>
                Having accurate information about you permits us to provide you with a smooth, efficient, and customized experience. Specifically, we may use information collected about you via the Application to:
                <br />• Create and manage your account.
                <br />• Calculate your debt payoff timeline and strategies.
                <br />• Sync your data across multiple devices.
                <br />• Email you regarding your account or order.
                <br />• Respond to product and customer service requests.
              </Text>
            </Box>

            <Box>
              <Title order={2} mb="md" ff="var(--font-serif)">4. Security of Your Information</Title>
              <Text c="dimmed" lh={1.6}>
                We use administrative, technical, and physical security measures to help protect your personal information. While we have taken reasonable steps to secure the personal information you provide to us, please be aware that despite our efforts, no security measures are perfect or impenetrable, and no method of data transmission can be guaranteed against any interception or other type of misuse.
              </Text>
            </Box>

            <Box>
              <Title order={2} mb="md" ff="var(--font-serif)">5. Contact Us</Title>
              <Text c="dimmed" lh={1.6}>
                If you have questions or comments about this Privacy Policy, please contact us at: support@debtpayoffmanager.com
              </Text>
            </Box>
          </Stack>
        </Container>
      </Box>
      <SiteFooter />
    </Box>
  );
}
