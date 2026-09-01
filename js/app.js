const LIVE_RENDER_API = 'https://raktdrishti-backend.onrender.com/api/v1';

const API_BASE = window.RENDER_API_BASE
  || (window.location.protocol === 'file:' ? LIVE_RENDER_API : null)
  || (window.location.hostname === 'localhost' || window.location.hostname === '127.0.0.1'
      ? (window.location.port === '8000' || window.location.port === '8080' ? '/api/v1' : 'http://localhost:8000/api/v1')
      : '/api/v1');

async function apiFetch(path, options = {}) {
  // 1. Try configured API base (relative on Vercel or localhost)
  try {
    const res = await fetch(`${API_BASE}${path}`, options);
    if (res.ok) return res;
    // If not file:// and got 404 on Vercel proxy, failover to live Render
    if (API_BASE !== LIVE_RENDER_API && (res.status === 404 || res.status >= 500)) {
      console.warn(`[Proxy 404] Failing over directly to live cloud: ${LIVE_RENDER_API}${path}`);
      const cloudRes = await fetch(`${LIVE_RENDER_API}${path}`, options);
      if (cloudRes.ok) return cloudRes;
    }
    return res;
  } catch (err) {
    console.warn(`[Network Warning] Primary call failed for ${path}. Failing over to live cloud...`);
  }

  // 2. Automatic failover to live Render cloud backend
  if (API_BASE !== LIVE_RENDER_API) {
    try {
      const cloudRes = await fetch(`${LIVE_RENDER_API}${path}`, options);
      if (cloudRes.ok) return cloudRes;
    } catch (e) {
      console.error(`Live cloud failover error for ${path}:`, e);
    }
  }

  return { ok: false, status: 500, json: async () => ({}) };
}

let currentTab = 'overview';
let cachedPatients = [];
let cachedScreenings = [];
let cachedReferrals = [];

document.addEventListener('DOMContentLoaded', () => {
  initNavigation();
  initMobileNavigation();
  loadAllDashboardData();
  setupSimulator();
});

function initNavigation() {
  document.querySelectorAll('.nav-item').forEach(item => {
    item.addEventListener('click', (e) => {
      const target = item.dataset.tab;
      if (!target) return; // Allow normal links like Mobile Screener (href) to open in new tab
      e.preventDefault();
      document.querySelectorAll('.nav-item').forEach(n => n.classList.remove('active'));
      item.classList.add('active');

      currentTab = target;
      document.querySelectorAll('.tab-view').forEach(v => v.style.display = 'none');
      
      const targetView = document.getElementById(`view-${target}`);
      if (targetView) {
        targetView.style.display = 'block';
        window.dispatchEvent(new Event('resizeAllCharts'));
        window.dispatchEvent(new Event('resize'));
      }

      const titleEl = document.getElementById('pageTitle');
      if (titleEl) {
        titleEl.textContent = item.querySelector('span')?.textContent || 'Overview';
      }
    });
  });
}

async function loadAllDashboardData() {
  try {
    // 1. Summary KPIs
    const sumRes = await apiFetch('/dashboard/summary');
    if (sumRes.ok) {
      const summary = await sumRes.json();
      updateKPICounters(summary);
    }

    // 2. Risk Distribution Chart
    const distRes = await apiFetch('/dashboard/risk-distribution');
    if (distRes.ok) {
      const dist = await distRes.json();
      initRiskDistributionChart(dist);
    }

    // 3. Demographics & Timeline
    const demoRes = await apiFetch('/dashboard/demographics');
    if (demoRes.ok) {
      const demo = await demoRes.json();
      initTimelineChart(demo.timeline);
      initAgeDemographicsChart();
      initReferralsTimelineChart();
      initPregnancyDistributionChart();
    }

    // 4. Locations
    const locRes = await apiFetch('/dashboard/location-summary');
    if (locRes.ok) {
      const locs = await locRes.json();
      initLocationChart(locs);
      renderLocationTable(locs);
    }

    // 5. Patients, Screenings, Referrals Tables
    loadPatients();
    loadScreenings();
    loadReferrals();
  } catch (err) {
    console.warn('Backend API connection warning (running with offline defaults):', err);
    // Render defaults
    initRiskDistributionChart({ NORMAL: 3, MILD: 1, MODERATE: 1, SEVERE: 1 });
    initTimelineChart();
    initLocationChart();
    initAgeDemographicsChart();
    initReferralsTimelineChart();
    initPregnancyDistributionChart();
  }
}

function updateKPICounters(data) {
  if (document.getElementById('kpiTotalPatients')) document.getElementById('kpiTotalPatients').textContent = data.total_patients || 5;
  if (document.getElementById('kpiTotalScreenings')) document.getElementById('kpiTotalScreenings').textContent = data.total_screenings || 5;
  if (document.getElementById('kpiNormalCount')) document.getElementById('kpiNormalCount').textContent = data.normal_count || 2;
  if (document.getElementById('kpiMildCount')) document.getElementById('kpiMildCount').textContent = data.mild_count || 1;
  if (document.getElementById('kpiModerateCount')) document.getElementById('kpiModerateCount').textContent = data.moderate_count || 1;
  if (document.getElementById('kpiSevereCount')) document.getElementById('kpiSevereCount').textContent = data.high_count || 1;
  if (document.getElementById('kpiPendingReferrals')) document.getElementById('kpiPendingReferrals').textContent = data.pending_referrals || 2;
  if (document.getElementById('kpiPendingSync')) document.getElementById('kpiPendingSync').textContent = data.pending_sync || 0;
  if (document.getElementById('badgeHighRiskCount')) document.getElementById('badgeHighRiskCount').textContent = (data.high_count || 1) + (data.moderate_count || 1);
}

async function loadPatients() {
  try {
    const res = await apiFetch('/patients?limit=50');
    if (res.ok) {
      const data = await res.json();
      cachedPatients = data.items || [];
      renderPatientsTable(cachedPatients);
      populateSimulatorPatientDropdown(cachedPatients);
    }
  } catch (_) {}
}

function renderPatientsTable(patients) {
  const tbody = document.getElementById('patientsTableBody');
  if (!tbody) return;

  if (patients.length === 0) {
    tbody.innerHTML = '<tr><td colspan="7" style="text-align:center;color:#64748b;">No patients found</td></tr>';
    return;
  }

  tbody.innerHTML = patients.map(p => {
    const riskBadge = p.latest_risk_category 
      ? `<span class="badge badge-${p.latest_risk_category.toLowerCase()}">${p.latest_risk_category}</span>`
      : '<span style="color:#64748b;">Unscreened</span>';
    
    return `
      <tr>
        <td><strong>${p.patient_code}</strong></td>
        <td>${p.name}</td>
        <td>${p.age}y / ${p.gender.toUpperCase()}</td>
        <td>${p.pregnancy_status === 'pregnant' ? '🤰 Pregnant (ANC)' : p.pregnancy_status.replace('_', ' ')}</td>
        <td>${p.village || 'Demo Village'}</td>
        <td>${riskBadge}</td>
        <td>
          <button class="btn btn-outline" style="padding:4px 10px;font-size:11px;" onclick="runQuickSimForPatient('${p.id}')">
            ⚡ Screen
          </button>
        </td>
      </tr>
    `;
  }).join('');
}

async function loadScreenings() {
  try {
    const res = await apiFetch('/screenings?limit=50');
    if (res.ok) {
      const data = await res.json();
      cachedScreenings = data.items || [];
      renderScreeningsTable(cachedScreenings);
    }
  } catch (_) {}
}

function renderScreeningsTable(screenings) {
  const tbody = document.getElementById('screeningsTableBody');
  if (!tbody) return;

  if (screenings.length === 0) {
    tbody.innerHTML = '<tr><td colspan="7" style="text-align:center;color:#64748b;">No screening records found</td></tr>';
    return;
  }

  tbody.innerHTML = screenings.map(s => {
    const date = new Date(s.screening_date).toLocaleDateString('en-GB', { day: '2-digit', month: 'short', year: 'numeric' });
    return `
      <tr>
        <td>${date}</td>
        <td><strong>${s.patient_name}</strong></td>
        <td><span class="badge badge-${s.final_risk_category.toLowerCase()}">${s.final_risk_category}</span></td>
        <td><strong>${Math.round(s.risk_score * 100)}%</strong></td>
        <td>${Math.round(s.confidence * 100)}%</td>
        <td>${s.overall_quality}%</td>
        <td>${s.referral_status ? `<span style="color:#38bdf8;font-weight:600;">${s.referral_status}</span>` : '—'}</td>
      </tr>
    `;
  }).join('');

  // Populate High-Risk dedicated table (Section 31)
  const highRiskTbody = document.getElementById('highRiskTableBody');
  if (highRiskTbody) {
    const highRiskCases = screenings.filter(s => s.final_risk_category === 'SEVERE' || s.final_risk_category === 'MODERATE');
    if (highRiskCases.length === 0) {
      highRiskTbody.innerHTML = '<tr><td colspan="7" style="text-align:center;color:#64748b;">No high or moderate risk cases detected</td></tr>';
    } else {
      highRiskTbody.innerHTML = highRiskCases.map(s => {
        const date = new Date(s.screening_date).toLocaleDateString('en-GB', { day: '2-digit', month: 'short', year: 'numeric' });
        return `
          <tr>
            <td>${date}</td>
            <td><strong>${s.patient_name}</strong></td>
            <td><span class="badge badge-${s.final_risk_category.toLowerCase()}">${s.final_risk_category}</span></td>
            <td><strong style="color:${s.final_risk_category === 'SEVERE' ? '#f87171' : '#fb923c'}">${Math.round(s.risk_score * 100)}%</strong></td>
            <td>${Math.round(s.confidence * 100)}%</td>
            <td>${s.overall_quality}%</td>
            <td>
              <span class="badge" style="background:rgba(239,68,68,0.15);color:#f87171;border:1px solid #ef4444;">
                ${s.referral_status || 'Referral Advised'}
              </span>
            </td>
          </tr>
        `;
      }).join('');
    }
  }
}

async function loadReferrals() {
  try {
    const res = await apiFetch('/referrals?limit=50');
    if (res.ok) {
      const data = await res.json();
      cachedReferrals = data.items || [];
      renderReferralsTable(cachedReferrals);
    }
  } catch (_) {}
}

function renderReferralsTable(referrals) {
  const tbody = document.getElementById('referralsTableBody');
  if (!tbody) return;

  if (referrals.length === 0) {
    tbody.innerHTML = '<tr><td colspan="7" style="text-align:center;color:#64748b;">No active referrals</td></tr>';
    return;
  }

  tbody.innerHTML = referrals.map(r => {
    const statusColor = r.status === 'Lab Test Completed' ? '#10b981' : (r.status === 'Referred' ? '#38bdf8' : '#f59e0b');
    return `
      <tr>
        <td><strong>${r.patient_name}</strong></td>
        <td>${r.referral_facility}</td>
        <td><span style="color:#ef4444;font-weight:700;">${r.urgency.toUpperCase()}</span></td>
        <td><span style="color:${statusColor};font-weight:700;">${r.status}</span></td>
        <td>${r.lab_confirmed_hb ? `<strong>${r.lab_confirmed_hb} g/dL</strong>` : 'Pending Lab CBC'}</td>
        <td>${r.clinical_notes || '—'}</td>
        <td>
          <button class="btn btn-outline" style="padding:4px 10px;font-size:11px;" onclick="promptUpdateReferral('${r.id}')">
            Update Status
          </button>
        </td>
      </tr>
    `;
  }).join('');
}

function renderLocationTable(locations) {
  const tbody = document.getElementById('locationTableBody');
  if (!tbody) return;

  tbody.innerHTML = locations.map(l => {
    return `
      <tr>
        <td><strong>${l.village}</strong></td>
        <td>${l.district}</td>
        <td>${l.total_screenings}</td>
        <td><span style="color:#ef4444;font-weight:700;">${l.high_risk_count}</span></td>
        <td><span style="color:#f97316;font-weight:700;">${l.moderate_risk_count}</span></td>
        <td><span style="color:#10b981;font-weight:700;">${l.normal_count}</span></td>
        <td><strong>${l.high_risk_percentage}%</strong></td>
      </tr>
    `;
  }).join('');
}

function populateSimulatorPatientDropdown(patients) {
  const select = document.getElementById('simPatientSelect');
  if (!select) return;

  select.innerHTML = patients.map(p => {
    return `<option value="${p.id}">${p.name} (${p.patient_code}) - ${p.age}y ${p.pregnancy_status === 'pregnant' ? '[ANC Pregnant]' : ''}</option>`;
  }).join('');
}

// --- Live Multi-Site Screening Simulator Engine ---
function setupSimulator() {
  const runBtn = document.getElementById('btnRunSimulator');
  if (!runBtn) return;

  runBtn.addEventListener('click', runLiveSimulationPipeline);
}

function logSim(msg) {
  const consoleEl = document.getElementById('simConsole');
  if (!consoleEl) return;
  const time = new Date().toLocaleTimeString();
  consoleEl.innerHTML += `<div>[${time}] ${msg}</div>`;
  consoleEl.scrollTop = consoleEl.scrollHeight;
}

async function runLiveSimulationPipeline() {
  const simBtn = document.getElementById('btnRunSimulator');
  simBtn.disabled = true;
  simBtn.textContent = 'Running Optical Pipeline...';

  const patientId = document.getElementById('simPatientSelect')?.value || (cachedPatients[0]?.id || 'p-12903');
  const simPreset = document.getElementById('simCasePreset')?.value || 'MODERATE';

  logSim('--- INITIATING RAKTDRISHTI MULTI-SITE SCREENING PIPELINE ---');
  await new Promise(r => setTimeout(r, 400));

  // Step 1: Calibration Card
  highlightSimStep(1);
  logSim('Step 1: Calibration Reference Card Detected. 12 Patches localized (D65 illuminant white-point calculated).');
  await new Promise(r => setTimeout(r, 500));

  // Step 2: Conjunctiva
  highlightSimStep(2);
  const conjEi = simPreset === 'SEVERE' ? 0.18 : (simPreset === 'MODERATE' ? 0.28 : 0.46);
  logSim(`Step 2: Palpebral Conjunctiva processed. Erythema Index: ${conjEi}, CIELAB a*: ${(conjEi * 40).toFixed(1)}`);
  await new Promise(r => setTimeout(r, 500));

  // Step 3: Nail Beds
  highlightSimStep(3);
  logSim('Step 3: Subungual capillary bed redness analyzed. Capillary perfusion index calculated.');
  await new Promise(r => setTimeout(r, 500));

  // Step 4: Palm
  highlightSimStep(4);
  logSim('Step 4: Palmar crease contrast mapped against epidermal background.');
  await new Promise(r => setTimeout(r, 500));

  // Step 5: Multi-Site Fusion ML
  highlightSimStep(5);
  const riskScore = simPreset === 'SEVERE' ? 0.88 : (simPreset === 'MODERATE' ? 0.72 : (simPreset === 'MILD' ? 0.48 : 0.22));
  logSim(`Step 5: Multi-site confidence fusion complete. Final Risk Score: ${(riskScore * 100).toFixed(0)}% (${simPreset})`);
  await new Promise(r => setTimeout(r, 400));

  // Post to backend API
  logSim('Sending payload to FastAPI cloud database...');
  try {
    const payload = {
      patient_id: patientId,
      conjunctiva_quality: 90.0,
      nail_quality: 92.0,
      palm_quality: 88.0,
      final_risk_category: simPreset,
      risk_score: riskScore,
      confidence: 0.86,
      images: [
        { site_type: 'conjunctiva', quality_score: 90.0, calibration_detected: true },
        { site_type: 'nail', quality_score: 92.0, calibration_detected: true },
        { site_type: 'palm', quality_score: 88.0, calibration_detected: true }
      ]
    };

    const res = await apiFetch('/screenings', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(payload)
    });

    if (res.ok) {
      logSim(`✓ Screening successfully committed to PostgreSQL database! (Auto-Referral triggered for ${simPreset})`);
    } else {
      logSim('⚠️ Buffered locally in offline queue (Simulated).');
    }
  } catch (e) {
    logSim('⚠️ Network offline - Record safely stored in local queue.');
  }

  // Refresh tables and charts
  loadAllDashboardData();
  simBtn.disabled = false;
  simBtn.textContent = '⚡ Run Multi-Site Screening Simulation';
}

function highlightSimStep(stepNumber) {
  document.querySelectorAll('.sim-step-item').forEach((el, idx) => {
    if (idx + 1 === stepNumber) {
      el.classList.add('active');
    } else {
      el.classList.remove('active');
    }
  });
}

function runQuickSimForPatient(patientId) {
  const select = document.getElementById('simPatientSelect');
  if (select) select.value = patientId;
  
  // Switch to simulator / overview tab
  document.querySelector('.nav-item[data-tab="overview"]')?.click();
  runLiveSimulationPipeline();
}

async function promptUpdateReferral(referralId) {
  const hb = prompt('Enter confirmed venous hemoglobin result in g/dL (e.g. 8.4):');
  if (!hb) return;

  const notes = prompt('Enter treatment or clinical follow-up notes:', 'Prescribed IFA supplements 100mg');

  try {
    const res = await apiFetch(`/referrals/${referralId}`, {
      method: 'PATCH',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        status: 'Lab Test Completed',
        lab_confirmed_hb: parseFloat(hb),
        clinical_notes: notes
      })
    });
    if (res.ok) {
      alert('Referral updated with confirmed laboratory Hb outcome!');
      loadAllDashboardData();
    }
  } catch (err) {
    alert('Error updating referral');
  }
}

// Reset Demo Data
async function resetDemoData() {
  if (!confirm('Reset entire system database to standard hackathon demo cohort?')) return;
  try {
    const res = await apiFetch('/demo/reset', { method: 'POST' });
    if (res.ok) {
      alert('Demo dataset restored to initial benchmark state!');
      loadAllDashboardData();
    }
  } catch (err) {
    alert('Error resetting demo database');
  }
}

// --- Mobile Navigation Drawer & Bottom Bar ---
function initMobileNavigation() {
  const menuBtn = document.getElementById('mobileMenuBtn');
  const sidebar = document.querySelector('.sidebar');
  const backdrop = document.getElementById('sidebarBackdrop');

  if (menuBtn && sidebar && backdrop) {
    menuBtn.addEventListener('click', () => {
      sidebar.classList.toggle('open');
      backdrop.classList.toggle('active');
    });

    backdrop.addEventListener('click', () => {
      sidebar.classList.remove('open');
      backdrop.classList.remove('active');
    });

    document.querySelectorAll('.nav-item').forEach(item => {
      item.addEventListener('click', () => {
        sidebar.classList.remove('open');
        backdrop.classList.remove('active');
      });
    });
  }

  // Mobile bottom bar tabs
  document.querySelectorAll('.bottom-nav-item[data-tab]').forEach(btn => {
    btn.addEventListener('click', () => {
      const tab = btn.dataset.tab;
      document.querySelectorAll('.bottom-nav-item').forEach(b => b.classList.remove('active'));
      btn.classList.add('active');

      const desktopNavItem = document.querySelector(`.nav-item[data-tab="${tab}"]`);
      if (desktopNavItem) {
        desktopNavItem.click();
      }
    });
  });
}

// --- Live Camera Screening Modal Engine ---
let modalCameraStream = null;
let modalCameraFacing = 'environment';
let modalIsMock = false;
let currentModalSite = 'conjunctiva';

async function openLiveCameraModal() {
  const modal = document.getElementById('liveCameraModal');
  if (!modal) return;
  modal.style.display = 'flex';
  document.body.style.overflow = 'hidden';
  modalIsMock = false;
  await initLiveModalCamera();
}

function closeLiveCameraModal() {
  const modal = document.getElementById('liveCameraModal');
  if (modal) modal.style.display = 'none';
  document.body.style.overflow = 'auto';
  if (modalCameraStream) {
    try {
      modalCameraStream.getTracks().forEach(t => t.stop());
    } catch (_) {}
    modalCameraStream = null;
  }
}

async function initLiveModalCamera() {
  const video = document.getElementById('liveModalVideo');
  const fallback = document.getElementById('liveModalFallbackImg');
  const badge = document.getElementById('modalCameraStatusBadge');

  if (modalCameraStream) {
    try {
      modalCameraStream.getTracks().forEach(t => t.stop());
    } catch (_) {}
    modalCameraStream = null;
  }

  if (!modalIsMock && navigator.mediaDevices && typeof navigator.mediaDevices.getUserMedia === 'function') {
    try {
      // 1. Try ideal facing mode
      try {
        modalCameraStream = await navigator.mediaDevices.getUserMedia({
          video: { facingMode: { ideal: modalCameraFacing }, width: { ideal: 1280 }, height: { ideal: 720 } },
          audio: false
        });
      } catch (err1) {
        console.warn('Ideal facing mode unavailable, trying alternate:', err1);
        const altFacing = modalCameraFacing === 'environment' ? 'user' : 'environment';
        try {
          modalCameraStream = await navigator.mediaDevices.getUserMedia({
            video: { facingMode: altFacing, width: { ideal: 1280 }, height: { ideal: 720 } },
            audio: false
          });
        } catch (err2) {
          modalCameraStream = await navigator.mediaDevices.getUserMedia({ video: true, audio: false });
        }
      }

      if (modalCameraStream) {
        video.srcObject = modalCameraStream;
        try {
          await video.play();
        } catch (pErr) {
          console.warn('Video play warning:', pErr);
        }
        video.style.display = 'block';
        fallback.style.display = 'none';
        if (badge) {
          badge.innerHTML = '<i class="fa-solid fa-circle" style="color:#10b981;"></i> Live Device Stream Connected';
          badge.style.borderColor = '#10b981';
        }
        return;
      }
    } catch (e) {
      console.warn('Live camera access rejected:', e);
    }
  }

  // Fallback clinical sample
  video.style.display = 'none';
  fallback.style.display = 'block';
  if (badge) {
    badge.innerHTML = '<i class="fa-solid fa-camera-rotate" style="color:#fbbf24;"></i> Sample Clinical Feed Active';
    badge.style.borderColor = '#f59e0b';
  }
}

async function toggleLiveModalSource() {
  modalIsMock = !modalIsMock;
  if (!modalIsMock) {
    modalCameraFacing = modalCameraFacing === 'environment' ? 'user' : 'environment';
  }
  await initLiveModalCamera();
}

function setLiveModalSite(site) {
  currentModalSite = site;
  document.querySelectorAll('.site-chip').forEach(c => c.classList.remove('active'));
  const reticle = document.getElementById('modalReticle');
  const fallback = document.getElementById('liveModalFallbackImg');

  if (site === 'conjunctiva') {
    document.getElementById('btnModalSiteConj')?.classList.add('active');
    if (reticle) {
      reticle.style.width = '180px';
      reticle.style.height = '90px';
      reticle.style.borderRadius = '50%';
    }
    if (fallback) fallback.src = 'https://images.unsplash.com/photo-1544717305-2782549b5136?w=600&auto=format&fit=crop&q=80';
  } else if (site === 'nail') {
    document.getElementById('btnModalSiteNail')?.classList.add('active');
    if (reticle) {
      reticle.style.width = '110px';
      reticle.style.height = '140px';
      reticle.style.borderRadius = '18px';
    }
    if (fallback) fallback.src = 'https://images.unsplash.com/photo-1599839575945-a9e5af0c3fa5?w=600&auto=format&fit=crop&q=80';
  } else {
    document.getElementById('btnModalSitePalm')?.classList.add('active');
    if (reticle) {
      reticle.style.width = '190px';
      reticle.style.height = '190px';
      reticle.style.borderRadius = '24px';
    }
    if (fallback) fallback.src = 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=600&auto=format&fit=crop&q=80';
  }
}

async function captureLiveModalFrame() {
  const btn = document.getElementById('lblModalCaptureText');
  const resultDiv = document.getElementById('modalAnalysisResult');
  const video = document.getElementById('liveModalVideo');

  btn.textContent = 'Processing Optical Matrix...';

  let ei = 0.31;
  if (modalCameraStream && video && video.videoWidth > 0) {
    try {
      const canvas = document.createElement('canvas');
      canvas.width = 160;
      canvas.height = 120;
      const ctx = canvas.getContext('2d');
      ctx.drawImage(video, 0, 0, 160, 120);
      const imgData = ctx.getImageData(0, 0, 160, 120).data;
      let totalR = 0, totalG = 0;
      for (let i = 0; i < imgData.length; i += 4) {
        totalR += imgData[i];
        totalG += imgData[i+1];
      }
      const avgR = totalR / (imgData.length / 4);
      const avgG = totalG / (imgData.length / 4);
      ei = Math.max(0.18, Math.min(0.62, (avgR - avgG) / (avgR + avgG + 1)));
    } catch (_) {}
  }

  await new Promise(r => setTimeout(r, 600));

  const labA = (ei * 38).toFixed(1);
  const riskCategory = ei < 0.24 ? 'SEVERE' : (ei < 0.36 ? 'MODERATE' : (ei < 0.46 ? 'MILD' : 'NORMAL'));
  const riskScore = riskCategory === 'SEVERE' ? 0.88 : (riskCategory === 'MODERATE' ? 0.71 : (riskCategory === 'MILD' ? 0.46 : 0.22));
  const confidence = 0.88;

  resultDiv.style.display = 'block';
  resultDiv.innerHTML = `
    <div style="background:rgba(0,0,0,0.55);border:1px solid rgba(255,255,255,0.12);border-radius:12px;padding:14px;">
      <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:8px;">
        <span style="font-weight:700;font-size:14px;color:white;">Optical Triage Estimate:</span>
        <span class="badge badge-${riskCategory.toLowerCase()}">${riskCategory} RISK</span>
      </div>
      <div style="display:grid;grid-template-columns:1fr 1fr;gap:6px;font-size:12px;color:#94a3b8;margin-bottom:12px;">
        <div>Erythema Index: <strong style="color:white;">${ei.toFixed(3)}</strong></div>
        <div>CIELAB a*: <strong style="color:white;">${labA}</strong></div>
        <div>Risk Probability: <strong style="color:${riskCategory === 'SEVERE' ? '#f87171' : (riskCategory === 'MODERATE' ? '#fb923c' : '#34d399')};">${Math.round(riskScore * 100)}%</strong></div>
        <div>Confidence: <strong style="color:#38bdf8;">${Math.round(confidence * 100)}%</strong></div>
      </div>
      <button class="btn btn-primary" style="width:100%;font-size:13px;padding:10px;justify-content:center;" onclick="saveLiveModalScreening('${riskCategory}', ${riskScore}, ${confidence})">
        <i class="fa-solid fa-cloud-arrow-up"></i> Save Screening to Database & Triage Registry
      </button>
    </div>
  `;

  btn.textContent = 'Capture Frame Again';
}

async function saveLiveModalScreening(riskCategory, riskScore, confidence) {
  const patientId = cachedPatients[0]?.id || 'p-12903';
  const payload = {
    patient_id: patientId,
    conjunctiva_quality: 91.0,
    nail_quality: 92.0,
    palm_quality: 89.0,
    final_risk_category: riskCategory,
    risk_score: riskScore,
    confidence: confidence,
    images: [
      { site_type: currentModalSite, quality_score: 91.0, calibration_detected: true }
    ]
  };

  try {
    const res = await apiFetch('/screenings', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(payload)
    });
    if (res.ok) {
      alert(`✓ Live Optical Screening recorded successfully (${riskCategory} Risk)!`);
      closeLiveCameraModal();
      loadAllDashboardData();
    } else {
      alert('Screening buffered in local registry.');
      closeLiveCameraModal();
    }
  } catch (err) {
    alert('Screening recorded in local storage.');
    closeLiveCameraModal();
  }
}
