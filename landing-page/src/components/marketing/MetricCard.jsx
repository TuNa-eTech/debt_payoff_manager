import { Paper, Text } from '@mantine/core';

export default function MetricCard({ value, label }) {
  return (
    <Paper className="metric-card" p="lg" radius="xl">
      <Text className="metric-value">{value}</Text>
      <Text size="sm" c="dimmed">
        {label}
      </Text>
    </Paper>
  );
}
