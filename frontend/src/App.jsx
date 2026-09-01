import React, { useState, useEffect } from 'react';
import {
  Activity, Users, Stethoscope, ShieldAlert, FileText,
  BarChart3, Camera, Smartphone, RefreshCw, Menu, X,
  Download, Sparkles
} from 'lucide-react';
import CommandCenter from './components/CommandCenter';
import MobileScreener from './components/MobileScreener';
import LiveCameraModal from './components/LiveCameraModal';
import { api } from './services/api';

const DEFAULT_PATIENTS = [
  { id: 'p-1', patient_code: 'RD-2026-0042', name: 'Ananya Rao', age: 24, gender: 'female', pregnancy_status: 'pregnant', village: 'Demo Village' },
  { id: 'p-2', patient_code: 'RD-2026-0089', name: 'Pooja Devi', age: 28, gender: 'female', pregnancy_status: 'lactating', village: 'Kashi PHC' },
  { id: 'p-3', patient_code: 'RD-2026-0104', name: 'Meena Kumari', age: 19, gender: 'female', pregnancy_status: 'pregnant', village: 'Shivpur Sector 2' },
  { id: 'p-4', patient_code: 'RD-2026-0155', name: 'Sunita Sharma', age: 34, gender: 'female', pregnancy_status: 'non_pregnant', village: 'Ramnagar' },
  { id: 'p-5', patient_code: 'RD-2026-0201', name: 'Ramesh Patel', age: 45, gender: 'male', pregnancy_status: 'non_pregnant', village: 'Demo Village' }
];

const DEFAULT_SCREENINGS = [
  { id: 's-1', patient_id: 'p-1', screening_date: new Date().toISOString(), final_risk_category: 'MODERATE', risk_score: 0.72, confidence: 0.88, conjunctiva_quality: 92, nail_quality: 91, palm_quality: 90, model_version: 'v1.0.0-tflite' },
  { id: 's-2', patient_id: 'p-2', screening_date: new Date().toISOString(), final_risk_category: 'SEVERE', risk_score: 0.91, confidence: 0.92, conjunctiva_quality: 95, nail_quality: 93, palm_quality: 91, model_version: 'v1.0.0-tflite' },
  { id: 's-3', patient_id: 'p-3', screening_date: new Date().toISOString(), final_risk_category: 'NORMAL', risk_score: 0.18, confidence: 0.94, conjunctiva_quality: 94, nail_quality: 96, palm_quality: 92, model_version: 'v1.0.0-tflite' }
];

const DEFAULT_REFERRALS = [
  { id: 'ref-1', facility_name: 'CHC Shivpur', urgency: 'Immediate', status: 'Pending', clinical_notes: 'Severe mucosal pallor flagged' },
  { id: 'ref-2', facility_name: 'PHC Kashi', urgency: 'High', status: 'Lab Test Completed', lab_confirmed_hb: 8.4, clinical_notes: 'Prescribed therapeutic IFA' }
];

const DEFAULT_LOCATIONS = [
  { village_name: 'Demo Village', district: 'Varanasi', total_screenings: 6, severe_count: 1, moderate_count: 2, normal_count: 3, high_risk_rate: 0.5 },
  { village_name: 'Shivpur Sector 2', district: 'Varanasi', total_screenings: 4, severe_count: 1, moderate_count: 1, normal_count: 2, high_risk_rate: 0.5 }
];

export default function App() {
  const [currentView, setCurrentView] = useState('command-center');
  const [isSidebarOpen, setIsSidebarOpen] = useState(false);
  const [isCameraModalOpen, setIsCameraModalOpen] = useState(false);
  const [isLoading, setIsLoading] = useState(true);

  const [summary, setSummary] = useState({
    total_patients: 10,
    total_screenings: 12,
    total_referrals: 4,
    high_risk_percentage: 42,
    screenings_today: 3,
    risk_counts: { NORMAL: 5, MILD: 2, MODERATE: 3, SEVERE: 2 }
  });
  const [patients, setPatients] = useState(DEFAULT_PATIENTS);
  const [screenings, setScreenings] = useState(DEFAULT_SCREENINGS);
  const [referrals, setReferrals] = useState(DEFAULT_REFERRALS);
  const [locations, setLocations] = useState(DEFAULT_LOCATIONS);

  useEffect(() => {
    loadAllData();
  }, []);

  const loadAllData = async () => {
    setIsLoading(true);
    try {
      const [sum, pts, scrs, refs, locs] = await Promise.allSettled([
        api.getSummary(),
        api.getPatients(),
        api.getScreenings(),
        api.getReferrals(),
        api.getLocations()
      ]);

      if (sum.status === 'fulfilled' && sum.value && typeof sum.value === 'object' && !sum.value.detail) {
        setSummary(prev => ({ ...prev, ...sum.value }));
      }
      if (pts.status === 'fulfilled' && Array.isArray(pts.value)) {
        setPatients(pts.value);
      }
      if (scrs.status === 'fulfilled' && Array.isArray(scrs.value)) {
        setScreenings(scrs.value);
      }
      if (refs.status === 'fulfilled' && Array.isArray(refs.value)) {
        setReferrals(refs.value);
      }
      if (locs.status === 'fulfilled' && Array.isArray(locs.value)) {
        setLocations(locs.value);
      }
    } catch (e) {
      console.error('Error loading dashboard data:', e);
    } finally {
      setIsLoading(false);
    }
  };

  const handleResetDemoData = async () => {
    if (!window.confirm('Reset database cohort to standard hackathon benchmark dataset?')) return;
    try {
      await api.resetDemoData();
      alert('✓ Demo cohort restored to initial benchmark state!');
      loadAllData();
    } catch (e) {
      alert('Error resetting demo database');
    }
  };

  return (
    <div className="app-layout">
      {/* Mobile Sidebar Backdrop */}
      <div
        className={`sidebar-backdrop ${isSidebarOpen ? 'active' : ''}`}
        onClick={() => setIsSidebarOpen(false)}
      />

      {/* Main Sidebar */}
      <aside className={`app-sidebar ${isSidebarOpen ? 'open' : ''}`}>
        <div className="sidebar-header">
          <div className="brand-icon-box">
            <Activity size={22} />
          </div>
          <div className="brand-info">
            <h2>RaktDrishti</h2>
            <span>AI Optical Screener</span>
          </div>
        </div>

        <nav className="sidebar-nav">
          <div className="nav-category-title">Command Views</div>

          <button
            className={`nav-link-btn ${currentView === 'command-center' ? 'active' : ''}`}
            onClick={() => {
              setCurrentView('command-center');
              setIsSidebarOpen(false);
            }}
          >
            <Activity size={18} />
            <span>Command Center</span>
          </button>

          <button
            className={`nav-link-btn ${currentView === 'screener' ? 'active' : ''}`}
            onClick={() => {
              setCurrentView('screener');
              setIsSidebarOpen(false);
            }}
          >
            <Smartphone size={18} />
            <span>Field Screener (PWA)</span>
            <span className="nav-badge" style={{ background: '#ef4444', color: 'white' }}>LIVE</span>
          </button>

          <div className="nav-category-title" style={{ marginTop: '14px' }}>Fast Actions</div>

          <button
            className="nav-link-btn"
            onClick={() => {
              setIsCameraModalOpen(true);
              setIsSidebarOpen(false);
            }}
          >
            <Camera size={18} color="#ef4444" />
            <span>Live Camera Test</span>
          </button>

          <button
            className="nav-link-btn"
            onClick={() => window.open('/assets/calibration/raktdrishti_calibration_card.pdf', '_blank')}
          >
            <Download size={18} color="#38bdf8" />
            <span>Calibration Card PDF</span>
          </button>
        </nav>

        <div className="sidebar-footer">
          <button
            className="btn-ui btn-outline"
            style={{ width: '100%', justifyContent: 'center', fontSize: '12px' }}
            onClick={handleResetDemoData}
          >
            <RefreshCw size={13} />
            <span>Reset Demo Cohort</span>
          </button>
        </div>
      </aside>

      {/* Main Content Viewport */}
      <div className="app-main">
        {/* Top Header */}
        <header className="app-header">
          <div className="header-left">
            <button
              className="mobile-menu-toggle"
              onClick={() => setIsSidebarOpen(!isSidebarOpen)}
              aria-label="Toggle menu"
            >
              <Menu size={20} />
            </button>
            <div className="page-title-box">
              <h1>
                {currentView === 'command-center' ? 'Epidemiological Command Center' : 'ASHA Mobile Field Screener'}
              </h1>
              <p>
                <span style={{ color: '#10b981' }}>●</span> FastAPI & PostgreSQL Online • Omnikon Hackathon 2026
              </p>
            </div>
          </div>

          <div className="header-actions">
            <button
              className="btn-ui btn-primary"
              onClick={() => setIsCameraModalOpen(true)}
            >
              <Camera size={16} />
              <span>Live Camera Screening</span>
            </button>

            <button
              className="btn-ui btn-secondary"
              onClick={() => setCurrentView(currentView === 'command-center' ? 'screener' : 'command-center')}
            >
              <Smartphone size={16} />
              <span>{currentView === 'command-center' ? 'Mobile PWA View' : 'Command Center'}</span>
            </button>
          </div>
        </header>

        {/* Page Content */}
        <main className="app-content">
          {currentView === 'command-center' ? (
            <CommandCenter
              summary={summary}
              patients={patients}
              screenings={screenings}
              referrals={referrals}
              locations={locations}
              onRefresh={loadAllData}
              onOpenLiveCamera={() => setIsCameraModalOpen(true)}
            />
          ) : (
            <MobileScreener
              onBackToDashboard={() => setCurrentView('command-center')}
            />
          )}
        </main>
      </div>

      {/* Mobile Bottom Bar */}
      <nav className="mobile-bottom-bar">
        <button
          className={`bottom-nav-item ${currentView === 'command-center' ? 'active' : ''}`}
          onClick={() => setCurrentView('command-center')}
        >
          <Activity size={18} />
          <span>Dashboard</span>
        </button>

        <button
          className="bottom-nav-item"
          onClick={() => setIsCameraModalOpen(true)}
          style={{ color: '#ef4444' }}
        >
          <Camera size={22} />
          <span>Camera</span>
        </button>

        <button
          className={`bottom-nav-item ${currentView === 'screener' ? 'active' : ''}`}
          onClick={() => setCurrentView('screener')}
        >
          <Smartphone size={18} />
          <span>Screener</span>
        </button>
      </nav>

      {/* Live Hardware Camera Modal */}
      <LiveCameraModal
        isOpen={isCameraModalOpen}
        onClose={() => setIsCameraModalOpen(false)}
        onScreeningComplete={loadAllData}
        patients={patients}
      />
    </div>
  );
}
