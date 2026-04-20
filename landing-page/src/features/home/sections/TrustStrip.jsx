import { Box, Flex, Stack, Text } from '@mantine/core';
import { IconDeviceFloppy, IconUnlink, IconEyeOff, IconDownload } from '@tabler/icons-react';
import ScrollReveal from '@/components/animations/ScrollReveal';

export default function TrustStrip() {
  const items = [
    {
      icon: IconDeviceFloppy,
      title: '100% Local-First',
      subtitle: 'All data stays on your device',
    },
    {
      icon: IconUnlink,
      title: 'No Bank Linking',
      subtitle: 'No OAuth, no permissions',
    },
    {
      icon: IconEyeOff,
      title: 'No Ads or Tracking',
      subtitle: 'Zero telemetry, always',
    },
    {
      icon: IconDownload,
      title: 'CSV Export & Backup',
      subtitle: 'CSV & encrypted ZIP backup',
    },
  ];

  return (
    <Box
      style={{
        backgroundColor: '#FFFFFF',
        borderBottom: '1px solid #D6DDD0',
        padding: '36px 16px',
      }}
      px={{ md: '120px' }}
    >
      <Flex
        direction={{ base: 'column', md: 'row' }}
        justify="center"
        align="center"
        gap={{ base: 'xl', md: 0 }}
      >
        {items.map((item, index) => (
          <ScrollReveal key={index} delay={index * 0.1} direction="up" distance={20} style={{ flex: 1, display: 'flex', justifyContent: 'center' }}>
            <Flex style={{ width: '100%' }} align="center" justify="center">
              <Stack align="center" gap={4} py={20} style={{ flex: 1 }}>
                <item.icon size={22} color="#2D5E3A" />
                <Text fw={600} size="15px" c="#1B3A28" ff="var(--font-sans)">
                  {item.title}
                </Text>
                <Text size="12px" c="#7A9A80" ff="var(--font-sans)">
                  {item.subtitle}
                </Text>
              </Stack>
              {index < items.length - 1 && (
                <Box
                  visibleFrom="md"
                  style={{
                    width: '1px',
                    height: '30px',
                    backgroundColor: '#D6DDD0',
                  }}
                />
              )}
            </Flex>
          </ScrollReveal>
        ))}
      </Flex>
    </Box>
  );
}
