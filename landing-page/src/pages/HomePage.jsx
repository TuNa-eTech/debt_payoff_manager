import MarketingLayout from '@/components/layout/MarketingLayout';
import SiteFooter from '@/components/layout/SiteFooter';
import SiteHeader from '@/components/layout/SiteHeader';
import HeroSection from '@/features/home/sections/HeroSection';
import TrustStrip from '@/features/home/sections/TrustStrip';
import CompareSection from '@/features/home/sections/CompareSection';
import MonthlyActionSection from '@/features/home/sections/MonthlyActionSection';
import TimelineSection from '@/features/home/sections/TimelineSection';
import DataControlSection from '@/features/home/sections/DataControlSection';
import CtaSection from '@/features/home/sections/CtaSection';

export default function HomePage() {
  return (
    <MarketingLayout>
      <HeroSection />
      <TrustStrip />
      <CompareSection />
      <MonthlyActionSection />
      <TimelineSection />
      <DataControlSection />
      <CtaSection />
      <SiteFooter />
    </MarketingLayout>
  );
}
