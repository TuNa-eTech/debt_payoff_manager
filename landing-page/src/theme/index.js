import { createTheme } from '@mantine/core';

export const theme = createTheme({
  primaryColor: 'mint',
  defaultRadius: 'xl',
  fontFamily: '"Space Grotesk", sans-serif',
  headings: {
    fontFamily: '"Space Grotesk", sans-serif',
    fontWeight: '700',
  },
  colors: {
    mint: [
      '#effff7',
      '#daf7ea',
      '#b4eed0',
      '#8ce4b5',
      '#68d99e',
      '#54d390',
      '#48cf88',
      '#36b573',
      '#289d63',
      '#128750',
    ],
    ember: [
      '#fff4ec',
      '#ffe4d1',
      '#ffc7a0',
      '#ffa86b',
      '#ff8f42',
      '#ff7f24',
      '#ff7612',
      '#e36505',
      '#cb5900',
      '#b04a00',
    ],
  },
  shadows: {
    md: '0 18px 45px rgba(18, 52, 41, 0.12)',
    xl: '0 30px 80px rgba(18, 52, 41, 0.18)',
  },
});
