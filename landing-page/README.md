# Landing Page

Project landing page riêng cho `Debt Payoff Manager`, dựng bằng:

- React
- Vite
- Mantine
- Yarn

## Structure

```text
landing-page/
├── src/
│   ├── app/
│   │   ├── providers/
│   │   └── App.jsx
│   ├── components/
│   │   ├── common/
│   │   ├── layout/
│   │   └── marketing/
│   ├── constants/
│   ├── features/
│   │   └── home/
│   │       ├── data/
│   │       └── sections/
│   ├── pages/
│   ├── styles/
│   └── theme/
├── jsconfig.json
├── package.json
└── vite.config.js
```

## Convention

- `app/`: entry-level wiring, providers, root app
- `pages/`: page composition layer
- `features/`: feature-specific sections, data, logic
- `components/`: reusable UI blocks
- `constants/`: site config, ids, navigation constants
- `theme/`: Mantine theme and design tokens
- `styles/`: global CSS only, tránh nhét toàn bộ UI vào đây

## Chạy local

```bash
cd landing-page
yarn
yarn dev
```

## Build production

```bash
yarn build
yarn preview
```

## Firebase

Firebase app init nằm ở `src/lib/firebase/`:

- `config.js`: config của project Firebase web
- `client.js`: init `initializeApp()` và bật Analytics an toàn bằng `isSupported()`

Firebase Hosting config nằm ở:

- `firebase.json`
- `.firebaserc`

Script deploy:

```bash
yarn hosting:serve
yarn deploy:hosting
```

Lưu ý: `deploy:hosting` sẽ chạy `yarn build` trước qua `predeploy` trong `firebase.json`.

## Vì sao chọn Mantine

Mantine phù hợp cho bản landing đầu tiên vì:

- có sẵn component và theme system
- responsive layout rất nhanh
- ít setup hơn Tailwind + component kit
- dễ đổi branding và typography sau này
