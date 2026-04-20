import { Paper, Text, ThemeIcon, Title } from '@mantine/core';

export default function FeatureCard({ icon: Icon, title, description }) {
  return (
    <Paper className="feature-card" p="xl" radius="xl">
      <ThemeIcon size={52} radius="xl" color="mint" variant="light">
        <Icon size={24} stroke={1.8} />
      </ThemeIcon>

      <Title order={3} mt="lg" mb="xs">
        {title}
      </Title>

      <Text c="dimmed">{description}</Text>
    </Paper>
  );
}
