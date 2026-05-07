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
                Last updated: May 2026
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
              <Text c="dimmed" lh={1.6} mb="sm">
                This Privacy Policy ("Policy") describes how TuNa eTech ("Company," "we," "us," or "our") collects, uses, discloses, and protects your personal information when you use the Debt Payoff Manager mobile application ("App") and related website ("Website"), collectively referred to as the "Service."
              </Text>
              <Text c="dimmed" lh={1.6} mb="sm">
                By downloading, installing, accessing, or using the Service, you agree to the collection and use of information in accordance with this Policy. If you do not agree with the terms of this Policy, please do not access the Service.
              </Text>
              <Text c="dimmed" lh={1.6}>
                This Policy applies to all users of the Service, including free and Premium subscribers.
              </Text>
            </Box>

            <Box>
              <Title order={2} mb="md" ff="var(--font-serif)">2. Information We Collect</Title>
              <Text c="dimmed" lh={1.6} mb="sm">
                We may collect the following types of information:
              </Text>
              <Text c="dimmed" lh={1.6} mb="sm">
                <strong>a) Personal Data:</strong> When you create an account (via Google Sign-In or Sign in with Apple), we collect your name, email address, and profile photo as provided by the authentication provider. This information is used solely to identify your account and enable cloud backup features.
              </Text>
              <Text c="dimmed" lh={1.6} mb="sm">
                <strong>b) Financial Data:</strong> Information related to your debts that you manually enter into the App, including: debt names, balances, interest rates, minimum payments, due dates, payment history, and personal notes. <strong>We do NOT connect to your bank accounts, credit bureaus, or any financial institution.</strong> We do not collect bank account numbers, credit card numbers, or any sensitive financial credentials.
              </Text>
              <Text c="dimmed" lh={1.6} mb="sm">
                <strong>c) Subscription Data:</strong> When you subscribe to Premium, Apple processes the payment. We receive a purchase receipt token from Apple to verify your subscription status. We do not receive or store your credit card information, Apple ID password, or payment details.
              </Text>
              <Text c="dimmed" lh={1.6} mb="sm">
                <strong>d) Device Data:</strong> We may automatically collect certain technical information, including: device type, operating system version, app version, and anonymous usage analytics to improve the Service. This data is not linked to your personal identity.
              </Text>
              <Text c="dimmed" lh={1.6}>
                <strong>e) Crash Reports:</strong> If the App crashes, anonymous diagnostic data may be sent to help us identify and fix bugs. This data does not contain any personal or financial information.
              </Text>
            </Box>

            <Box>
              <Title order={2} mb="md" ff="var(--font-serif)">3. How We Use Your Information</Title>
              <Text c="dimmed" lh={1.6} mb="sm">
                We use the information we collect for the following purposes:
              </Text>
              <Text c="dimmed" lh={1.6}>
                • To provide, maintain, and improve the Service
                <br />
                • To create and manage your user account
                <br />
                • To calculate your debt payoff timeline, strategies, and projections
                <br />
                • To sync your data across devices (when cloud backup is enabled)
                <br />
                • To verify and manage your Premium subscription status
                <br />
                • To send payment reminders and milestone notifications (with your permission)
                <br />
                • To respond to your support requests and customer service inquiries
                <br />
                • To monitor aggregate usage patterns and improve the App's features
                <br />
                • To detect, prevent, and address technical issues and security vulnerabilities
              </Text>
            </Box>

            <Box>
              <Title order={2} mb="md" ff="var(--font-serif)">4. Local-First Architecture</Title>
              <Text c="dimmed" lh={1.6} mb="sm">
                Debt Payoff Manager is built on a <strong>local-first architecture</strong>. This means:
              </Text>
              <Text c="dimmed" lh={1.6} mb="sm">
                • All your financial data (debts, payments, milestones) is stored primarily on your device
                <br />
                • The App works fully offline — no internet connection is required for core functionality
                <br />
                • You can export your data at any time as CSV or local JSON backup
                <br />
                • You can delete all local data through the App's settings at any time
              </Text>
              <Text c="dimmed" lh={1.6}>
                Cloud backup is an <strong>optional feature</strong> that requires you to sign in. Even with cloud backup enabled, your data is always accessible locally.
              </Text>
            </Box>

            <Box>
              <Title order={2} mb="md" ff="var(--font-serif)">5. Cloud Backup &amp; Data Storage</Title>
              <Text c="dimmed" lh={1.6} mb="sm">
                If you enable cloud backup by signing in, your data is stored in Google Cloud Firestore, a secure cloud database operated by Google. Your cloud data is:
              </Text>
              <Text c="dimmed" lh={1.6} mb="sm">
                • Protected by Firebase Security Rules that restrict access to your account only
                <br />
                • Encrypted in transit using TLS and at rest using Google's default encryption
                <br />
                • Never shared with other users unless you explicitly enable partner sharing features
                <br />
                • Deletable at any time by clearing your data through the App
              </Text>
              <Text c="dimmed" lh={1.6}>
                We do not access, review, or analyze your individual cloud data. Access to the database is governed by strict security rules that prevent unauthorized access.
              </Text>
            </Box>

            <Box>
              <Title order={2} mb="md" ff="var(--font-serif)">6. Third-Party Services</Title>
              <Text c="dimmed" lh={1.6} mb="sm">
                The Service uses the following third-party services, each with their own privacy policies:
              </Text>
              <Text c="dimmed" lh={1.6} mb="sm">
                • <strong>Firebase Authentication</strong> (Google) — For user sign-in via Google Sign-In and Sign in with Apple. <a href="https://firebase.google.com/support/privacy" style={{ color: '#1B3A28' }}>Firebase Privacy Policy</a>
                <br />
                • <strong>Cloud Firestore</strong> (Google) — For optional cloud data storage and sync
                <br />
                • <strong>Firebase Cloud Functions</strong> (Google) — For server-side subscription verification
                <br />
                • <strong>Apple App Store</strong> — For subscription purchases, payment processing, and receipt validation. <a href="https://www.apple.com/legal/privacy/" style={{ color: '#1B3A28' }}>Apple Privacy Policy</a>
              </Text>
              <Text c="dimmed" lh={1.6}>
                We do not sell, trade, or rent your personal information to any third parties. We do not use your data for advertising purposes.
              </Text>
            </Box>

            <Box>
              <Title order={2} mb="md" ff="var(--font-serif)">7. Data Retention</Title>
              <Text c="dimmed" lh={1.6} mb="sm">
                <strong>Local data:</strong> Your local data persists on your device until you delete it through the App's "Clear all data" function, uninstall the App, or reset your device.
              </Text>
              <Text c="dimmed" lh={1.6} mb="sm">
                <strong>Cloud data:</strong> If you use cloud backup, your data is retained in our cloud database as long as your account is active. You can delete your cloud data at any time through the App.
              </Text>
              <Text c="dimmed" lh={1.6}>
                <strong>Account deletion:</strong> If you request account deletion, we will delete all associated personal data and cloud-stored financial data within 30 days, except where retention is required by law.
              </Text>
            </Box>

            <Box>
              <Title order={2} mb="md" ff="var(--font-serif)">8. Security</Title>
              <Text c="dimmed" lh={1.6} mb="sm">
                We take the security of your information seriously and implement industry-standard measures to protect it, including:
              </Text>
              <Text c="dimmed" lh={1.6} mb="sm">
                • Encryption of data in transit (TLS/SSL) and at rest
                <br />
                • Firebase Security Rules that enforce per-user data isolation
                <br />
                • Secure authentication via industry-standard OAuth 2.0 providers
                <br />
                • Regular security reviews of our codebase and infrastructure
              </Text>
              <Text c="dimmed" lh={1.6}>
                However, no method of transmission over the Internet or electronic storage is 100% secure. While we strive to protect your personal information, we cannot guarantee its absolute security.
              </Text>
            </Box>

            <Box>
              <Title order={2} mb="md" ff="var(--font-serif)">9. Children's Privacy</Title>
              <Text c="dimmed" lh={1.6}>
                The Service is not intended for use by children under the age of 18. We do not knowingly collect personal information from children under 18. If we become aware that we have collected personal data from a child under 18, we will take steps to delete that information promptly. If you are a parent or guardian and believe your child has provided us with personal information, please contact us.
              </Text>
            </Box>

            <Box>
              <Title order={2} mb="md" ff="var(--font-serif)">10. Your Rights</Title>
              <Text c="dimmed" lh={1.6} mb="sm">
                Depending on your jurisdiction, you may have the following rights regarding your personal data:
              </Text>
              <Text c="dimmed" lh={1.6} mb="sm">
                • <strong>Access:</strong> You can access all your data within the App at any time, and export it as CSV or JSON backup.
                <br />
                • <strong>Correction:</strong> You can edit or correct any data you have entered into the App.
                <br />
                • <strong>Deletion:</strong> You can delete all local data through the App's settings. For cloud data deletion, use the same function or contact us directly.
                <br />
                • <strong>Portability:</strong> You can export your data in standard formats (CSV, JSON) at any time using the App's built-in export features.
                <br />
                • <strong>Opt-out:</strong> You can opt out of cloud backup at any time by not signing in or by signing out.
              </Text>
              <Text c="dimmed" lh={1.6}>
                To exercise any of these rights, you can use the relevant features within the App or contact us at support@debtpayoffmanager.com.
              </Text>
            </Box>

            <Box>
              <Title order={2} mb="md" ff="var(--font-serif)">11. Changes to This Policy</Title>
              <Text c="dimmed" lh={1.6} mb="sm">
                We may update this Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page and updating the "Last updated" date at the top.
              </Text>
              <Text c="dimmed" lh={1.6}>
                You are advised to review this Privacy Policy periodically for any changes. Changes are effective when they are posted on this page. Your continued use of the Service after any changes constitutes acceptance of the updated Policy.
              </Text>
            </Box>

            <Box>
              <Title order={2} mb="md" ff="var(--font-serif)">12. Contact Us</Title>
              <Text c="dimmed" lh={1.6} mb="sm">
                If you have any questions, concerns, or requests regarding this Privacy Policy or our data practices, please contact us at:
              </Text>
              <Text c="dimmed" lh={1.6}>
                <strong>TuNa eTech</strong>
                <br />
                Email: support@debtpayoffmanager.com
                <br />
                Website: https://debt-payoff-manager-e6283.web.app
              </Text>
            </Box>
          </Stack>
        </Container>
      </Box>
      <SiteFooter />
    </Box>
  );
}
