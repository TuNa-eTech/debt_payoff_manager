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
                Terms of Use
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
              <Title order={2} mb="md" ff="var(--font-serif)">1. Agreement to Terms</Title>
              <Text c="dimmed" lh={1.6} mb="sm">
                These Terms of Use ("Terms") constitute a legally binding agreement between you ("User," "you," or "your") and TuNa eTech ("Company," "we," "us," or "our"), governing your access to and use of the Debt Payoff Manager mobile application ("App") and related website ("Website"), collectively referred to as the "Service."
              </Text>
              <Text c="dimmed" lh={1.6} mb="sm">
                By downloading, installing, accessing, or using the Service, you acknowledge that you have read, understood, and agree to be bound by these Terms and our Privacy Policy. If you do not agree with any part of these Terms, you must immediately stop using the Service and uninstall the App.
              </Text>
              <Text c="dimmed" lh={1.6}>
                These Terms apply to all visitors, users, and others who access or use the Service, whether through a free or paid subscription.
              </Text>
            </Box>

            <Box>
              <Title order={2} mb="md" ff="var(--font-serif)">2. Eligibility</Title>
              <Text c="dimmed" lh={1.6}>
                You must be at least 18 years old (or the age of majority in your jurisdiction) to use the Service. By using the Service, you represent and warrant that you meet this eligibility requirement. If you are using the Service on behalf of an organization, you represent that you have authority to bind that organization to these Terms.
              </Text>
            </Box>

            <Box>
              <Title order={2} mb="md" ff="var(--font-serif)">3. License Grant</Title>
              <Text c="dimmed" lh={1.6} mb="sm">
                Subject to your compliance with these Terms, we grant you a limited, non-exclusive, non-transferable, revocable license to download, install, and use the App on a device that you own or control, solely for your personal, non-commercial purposes.
              </Text>
              <Text c="dimmed" lh={1.6}>
                You shall not: (a) copy, modify, or distribute the App; (b) reverse engineer, decompile, or disassemble the App; (c) make the App available over a network where it could be used by multiple devices at the same time; (d) rent, lease, lend, sell, or sublicense the App; or (e) use the App for any unlawful purpose or in violation of any applicable law.
              </Text>
            </Box>

            <Box>
              <Title order={2} mb="md" ff="var(--font-serif)">4. Description of the Service</Title>
              <Text c="dimmed" lh={1.6} mb="sm">
                Debt Payoff Manager is a personal finance planning tool that helps users organize, track, and accelerate their debt repayment. The App allows you to:
              </Text>
              <Text c="dimmed" lh={1.6} mb="sm">
                • Enter and manage multiple debts (balances, interest rates, minimum payments, due dates)
                <br />
                • Choose payoff strategies (Snowball, Avalanche, or Custom priority)
                <br />
                • View a projected payoff timeline with month-by-month breakdowns
                <br />
                • Log actual payments and track progress over time
                <br />
                • Set payment reminders and receive milestone notifications
                <br />
                • Export data as CSV or local JSON backup
              </Text>
              <Text c="dimmed" lh={1.6}>
                The Service operates on a local-first architecture. Your data is stored primarily on your device. Optional cloud backup is available for signed-in users.
              </Text>
            </Box>

            <Box>
              <Title order={2} mb="md" ff="var(--font-serif)">5. Free and Premium Features</Title>
              <Text c="dimmed" lh={1.6} mb="sm">
                The App offers a <strong>Free tier</strong> that includes core functionality: unlimited debt entry, Snowball/Avalanche strategies, a living payoff timeline, payment logging, monthly action views, CSV export, and local backup/restore.
              </Text>
              <Text c="dimmed" lh={1.6}>
                A <strong>Premium tier</strong> is available via paid subscription and unlocks additional features such as: what-if scenario planning, scenario comparison, partner sharing, PDF report generation, and other power features as described within the App. Free features remain fully functional regardless of subscription status.
              </Text>
            </Box>

            <Box>
              <Title order={2} mb="md" ff="var(--font-serif)">6. Subscriptions &amp; Auto-Renewal</Title>
              <Text c="dimmed" lh={1.6} mb="sm">
                Debt Payoff Manager offers the following <strong>auto-renewable subscription</strong> plans to unlock Premium features:
              </Text>
              <Text c="dimmed" lh={1.6} mb="sm">
                • <strong>Premium Monthly</strong> — A 1-month subscription period that automatically renews each month until cancelled.
                <br />
                • <strong>Premium Yearly</strong> — A 12-month subscription period that automatically renews each year until cancelled.
              </Text>
              <Text c="dimmed" lh={1.6} mb="sm">
                <strong>Pricing:</strong> Subscription prices are clearly displayed in the App at the time of purchase and may vary by region and currency. Prices are set in App Store Connect and may be subject to change. Any price changes will take effect at the start of the next subscription period following the date of the price change.
              </Text>
              <Text c="dimmed" lh={1.6} mb="sm">
                <strong>Payment:</strong> Payment will be charged to your Apple ID account at the confirmation of purchase. Your subscription begins immediately upon successful payment.
              </Text>
              <Text c="dimmed" lh={1.6} mb="sm">
                <strong>Auto-Renewal:</strong> Your subscription automatically renews unless auto-renew is turned off at least 24 hours before the end of the current billing period. Your Apple ID account will be charged for renewal within 24 hours prior to the end of the current period at the same price you originally subscribed at, unless the price has been changed with prior notice.
              </Text>
              <Text c="dimmed" lh={1.6} mb="sm">
                <strong>Managing &amp; Cancelling:</strong> You can manage your subscription or turn off auto-renewal at any time by going to your Apple ID Account Settings (Settings → [your name] → Subscriptions) after purchase. Cancellation takes effect at the end of the current billing period — you will continue to have access to Premium features until the end of your paid period. No partial refunds are provided for the unused portion of any subscription period.
              </Text>
              <Text c="dimmed" lh={1.6}>
                <strong>Free Trials:</strong> If a free trial is offered, any unused portion of the free trial period will be forfeited when you purchase a subscription. Free trial eligibility is determined by Apple and limited to one trial per Apple ID.
              </Text>
            </Box>

            <Box>
              <Title order={2} mb="md" ff="var(--font-serif)">7. User Accounts</Title>
              <Text c="dimmed" lh={1.6} mb="sm">
                Certain features of the Service (such as cloud backup) may require you to create an account or sign in using a supported authentication method (e.g., Google Sign-In or Sign in with Apple). When you create an account, you agree to:
              </Text>
              <Text c="dimmed" lh={1.6} mb="sm">
                • Provide accurate, complete, and current information
                <br />
                • Maintain the security of your account credentials
                <br />
                • Accept responsibility for all activities that occur under your account
                <br />
                • Notify us immediately of any unauthorized use of your account
              </Text>
              <Text c="dimmed" lh={1.6}>
                We reserve the right to suspend or terminate your account if we reasonably believe that information you provided is inaccurate or that you have violated these Terms.
              </Text>
            </Box>

            <Box>
              <Title order={2} mb="md" ff="var(--font-serif)">8. User Data &amp; Content</Title>
              <Text c="dimmed" lh={1.6} mb="sm">
                You retain ownership of all data you enter into the App, including debt details, payment records, and personal notes ("User Data"). We do not claim ownership over your User Data.
              </Text>
              <Text c="dimmed" lh={1.6} mb="sm">
                By using cloud backup features, you grant us a limited license to store, process, and transmit your User Data solely for the purpose of providing the Service to you. We will not sell, share, or use your User Data for advertising purposes.
              </Text>
              <Text c="dimmed" lh={1.6}>
                You are responsible for maintaining your own backups. While we take reasonable measures to protect your data, we are not liable for any loss or corruption of User Data.
              </Text>
            </Box>

            <Box>
              <Title order={2} mb="md" ff="var(--font-serif)">9. Privacy</Title>
              <Text c="dimmed" lh={1.6}>
                Your use of the Service is also governed by our Privacy Policy, which describes how we collect, use, and protect your personal information. By using the Service, you consent to the practices described in our Privacy Policy. The Privacy Policy is available at <a href="/privacy" style={{ color: '#1B3A28' }}>https://debt-payoff-manager-e6283.web.app/privacy</a>.
              </Text>
            </Box>

            <Box>
              <Title order={2} mb="md" ff="var(--font-serif)">10. Not Financial Advice</Title>
              <Text c="dimmed" lh={1.6} mb="sm">
                The Service is provided for <strong>educational and informational purposes only</strong>. We are not financial advisors, certified financial planners, accountants, or tax professionals. Nothing contained in the Service should be construed as financial, investment, legal, or tax advice.
              </Text>
              <Text c="dimmed" lh={1.6} mb="sm">
                All calculations, projections, timelines, and estimates provided by the App are based on the data you enter and standard amortization formulas. Actual results may differ due to factors such as variable interest rates, fees, payment timing, or other financial conditions not accounted for by the App.
              </Text>
              <Text c="dimmed" lh={1.6}>
                You should consult with a qualified financial professional before making any financial decisions based on information provided by the Service.
              </Text>
            </Box>

            <Box>
              <Title order={2} mb="md" ff="var(--font-serif)">11. Intellectual Property</Title>
              <Text c="dimmed" lh={1.6} mb="sm">
                The Service and its original content (excluding User Data), features, functionality, design, graphics, and trademarks are and will remain the exclusive property of TuNa eTech and its licensors.
              </Text>
              <Text c="dimmed" lh={1.6}>
                The Service is protected by copyright, trademark, trade secret, and other intellectual property laws. Our trademarks and trade dress may not be used in connection with any product or service without our prior written consent.
              </Text>
            </Box>

            <Box>
              <Title order={2} mb="md" ff="var(--font-serif)">12. Disclaimer of Warranties</Title>
              <Text c="dimmed" lh={1.6} mb="sm">
                THE SERVICE IS PROVIDED ON AN "AS IS" AND "AS AVAILABLE" BASIS, WITHOUT WARRANTIES OF ANY KIND, EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, AND NON-INFRINGEMENT.
              </Text>
              <Text c="dimmed" lh={1.6}>
                We do not warrant that the Service will be uninterrupted, timely, secure, error-free, or that defects will be corrected. We do not warrant the accuracy, reliability, or completeness of any information provided through the Service, including financial calculations or projections.
              </Text>
            </Box>

            <Box>
              <Title order={2} mb="md" ff="var(--font-serif)">13. Limitation of Liability</Title>
              <Text c="dimmed" lh={1.6} mb="sm">
                TO THE MAXIMUM EXTENT PERMITTED BY APPLICABLE LAW, IN NO EVENT SHALL TUNA ETECH, NOR ITS DIRECTORS, EMPLOYEES, PARTNERS, AGENTS, SUPPLIERS, OR AFFILIATES, BE LIABLE FOR ANY INDIRECT, INCIDENTAL, SPECIAL, CONSEQUENTIAL, OR PUNITIVE DAMAGES, INCLUDING WITHOUT LIMITATION, LOSS OF PROFITS, DATA, USE, GOODWILL, OR OTHER INTANGIBLE LOSSES, RESULTING FROM:
              </Text>
              <Text c="dimmed" lh={1.6} mb="sm">
                • Your access to or use of or inability to access or use the Service
                <br />
                • Any conduct or content of any third party on the Service
                <br />
                • Any content obtained from the Service
                <br />
                • Unauthorized access, use, or alteration of your transmissions or content
                <br />
                • Financial decisions made based on information provided by the Service
              </Text>
              <Text c="dimmed" lh={1.6}>
                Our total liability to you for any claims arising from or relating to these Terms or the Service shall not exceed the amount you have paid to us in the twelve (12) months preceding the claim.
              </Text>
            </Box>

            <Box>
              <Title order={2} mb="md" ff="var(--font-serif)">14. Indemnification</Title>
              <Text c="dimmed" lh={1.6}>
                You agree to defend, indemnify, and hold harmless TuNa eTech and its officers, directors, employees, and agents from and against any claims, liabilities, damages, losses, and expenses (including reasonable attorneys' fees) arising out of or related to: (a) your use of the Service; (b) your violation of these Terms; (c) your violation of any rights of another party; or (d) any financial decisions you make based on the Service.
              </Text>
            </Box>

            <Box>
              <Title order={2} mb="md" ff="var(--font-serif)">15. Termination</Title>
              <Text c="dimmed" lh={1.6} mb="sm">
                We may terminate or suspend your account and access to the Service immediately, without prior notice or liability, for any reason, including if you breach these Terms.
              </Text>
              <Text c="dimmed" lh={1.6}>
                Upon termination, your right to use the Service will immediately cease. If you wish to terminate your account, you may do so by deleting your data through the App's settings. Termination of your account does not automatically cancel any active subscriptions — you must separately cancel your subscription through your Apple ID Account Settings.
              </Text>
            </Box>

            <Box>
              <Title order={2} mb="md" ff="var(--font-serif)">16. Governing Law</Title>
              <Text c="dimmed" lh={1.6}>
                These Terms shall be governed and construed in accordance with the laws of Vietnam, without regard to its conflict of law provisions. Any legal action or proceeding arising under these Terms shall be brought exclusively in the courts located in Ho Chi Minh City, Vietnam, and you consent to personal jurisdiction and venue in such courts.
              </Text>
            </Box>

            <Box>
              <Title order={2} mb="md" ff="var(--font-serif)">17. Severability</Title>
              <Text c="dimmed" lh={1.6}>
                If any provision of these Terms is held to be unenforceable or invalid, such provision will be changed and interpreted to accomplish the objectives of such provision to the greatest extent possible under applicable law, and the remaining provisions will continue in full force and effect.
              </Text>
            </Box>

            <Box>
              <Title order={2} mb="md" ff="var(--font-serif)">18. Changes to Terms</Title>
              <Text c="dimmed" lh={1.6} mb="sm">
                We reserve the right, at our sole discretion, to modify or replace these Terms at any time. If a revision is material, we will provide at least 30 days' notice prior to any new terms taking effect, by posting the updated Terms on this page with a revised "Last updated" date.
              </Text>
              <Text c="dimmed" lh={1.6}>
                By continuing to access or use our Service after any revisions become effective, you agree to be bound by the revised Terms. If you do not agree to the new Terms, you are no longer authorized to use the Service.
              </Text>
            </Box>

            <Box>
              <Title order={2} mb="md" ff="var(--font-serif)">19. Apple-Specific Terms</Title>
              <Text c="dimmed" lh={1.6} mb="sm">
                These Terms are between you and TuNa eTech only, and not with Apple Inc. ("Apple"). TuNa eTech, not Apple, is solely responsible for the App and its content.
              </Text>
              <Text c="dimmed" lh={1.6} mb="sm">
                Your use of the App must comply with the App Store Terms of Service. Apple has no obligation to furnish any maintenance and support services with respect to the App.
              </Text>
              <Text c="dimmed" lh={1.6}>
                Apple and Apple's subsidiaries are third-party beneficiaries of these Terms, and upon your acceptance, Apple will have the right (and will be deemed to have accepted the right) to enforce these Terms against you as a third-party beneficiary thereof.
              </Text>
            </Box>

            <Box>
              <Title order={2} mb="md" ff="var(--font-serif)">20. Contact Us</Title>
              <Text c="dimmed" lh={1.6} mb="sm">
                If you have any questions, concerns, or feedback about these Terms of Use, please contact us at:
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
