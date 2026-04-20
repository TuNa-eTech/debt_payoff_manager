import { Box, Text, Title } from '@mantine/core';

export default function SectionHeading({
  eyebrow,
  title,
  description,
  inverted = false,
  titleMaxWidth,
  descriptionMaxWidth,
}) {
  return (
    <Box maw={titleMaxWidth}>
      <Text className={inverted ? 'eyebrow eyebrow-light' : 'eyebrow'}>{eyebrow}</Text>
      <Title order={2} c={inverted ? 'white' : undefined}>
        {title}
      </Title>
      {description ? (
        <Text
          mt="md"
          c={inverted ? 'rgba(255, 255, 255, 0.72)' : 'dimmed'}
          maw={descriptionMaxWidth ?? titleMaxWidth}
        >
          {description}
        </Text>
      ) : null}
    </Box>
  );
}
