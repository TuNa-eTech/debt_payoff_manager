import { Box, Paper, Text, Title } from '@mantine/core';

export default function StepCard({ index, title, description }) {
  return (
    <Paper className="step-card" p="lg" radius="xl">
      <Box className="step-index">{index}</Box>
      <Box>
        <Title order={4}>{title}</Title>
        <Text c="dimmed" mt={6}>
          {description}
        </Text>
      </Box>
    </Paper>
  );
}
