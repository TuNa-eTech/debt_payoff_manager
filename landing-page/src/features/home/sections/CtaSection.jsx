import { Box, Stack, Text, Title, Button } from '@mantine/core';
import { IconBrandAppleFilled } from '@tabler/icons-react';
import ScrollReveal from '@/components/animations/ScrollReveal';

export default function CtaSection() {
  return (
    <Box
      component="section"
      id="cta"
      style={{
        position: 'relative',
        height: '500px',
        width: '100%',
        overflow: 'hidden',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
      }}
    >
      {/* Background Image */}
      <Box
        style={{
          position: 'absolute',
          top: 0,
          left: 0,
          right: 0,
          bottom: 0,
          backgroundImage: 'url("https://images.unsplash.com/photo-1767948156141-42785b949ed6?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w4NDM0ODN8MHwxfHJhbmRvbXx8fHx8fHx8fDE3NzY2OTM0NTZ8&ixlib=rb-4.1.0&q=80&w=1080")',
          backgroundSize: 'cover',
          backgroundPosition: 'center',
          zIndex: 1,
        }}
      />

      {/* Overlay */}
      <Box
        style={{
          position: 'absolute',
          top: 0,
          left: 0,
          right: 0,
          bottom: 0,
          background: 'linear-gradient(0deg, #1B3A28BB 0%, #1B3A28DD 100%)',
          zIndex: 2,
        }}
      />

      {/* Content */}
      <ScrollReveal delay={0.2} direction="up" distance={30}>
      <Stack
        align="center"
        justify="center"
        gap={32}
        style={{
          position: 'relative',
          zIndex: 3,
          padding: '0 20px',
        }}
      >
        <Title
          order={2}
          ta="center"
          ff="var(--font-serif)"
          c="#FFFFFF"
          fw={600}
          style={{ fontSize: '52px', lineHeight: 1.1, maxWidth: '650px' }}
        >
          Your debt-free date is<br />closer than you think.
        </Title>

        <Text
          ta="center"
          c="#FFFFFFAA"
          ff="var(--font-sans)"
          size="18px"
        >
          Start planning in under 2 minutes.
        </Text>

        <Button
          size="xl"
          radius="xl"
          c="#1B3A28"
          bg="#FFFFFF"
          leftSection={<IconBrandAppleFilled size={20} />}
          style={{
            fontFamily: 'var(--font-sans)',
            fontWeight: 600,
            padding: '0 40px',
            height: '56px',
          }}
        >
          Download on the App Store
        </Button>
      </Stack>
      </ScrollReveal>
    </Box>
  );
}
