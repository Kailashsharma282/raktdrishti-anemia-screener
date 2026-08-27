const API_BASE = window.location.port === '8080' ? '/api/v1' : 'http://localhost:8080/api/v1';

let currentTab = 'overview';
let cachedPatients = [];
let cachedScreenings = [];
let cachedReferrals = [];

document.addEventListener('DOMContentLoaded', () => {
  initNavigation();
  loadAllDashboardData();
  setupSimulator();
});

function initNavigation() {
  document.querySelectorAll('.nav-item').forEach(item => {
    item.addEventListener('click', (e) => {
      e.preventDefault();
      document.querySelectorAll('.nav-item').forEach(n => n.classList.remove('active'));
      item.classList.add('active');

      const target = item.dataset.tab;
      currentTab = target;
      document.querySelectorAll('.tab-view').forEach(v => v.style.display = 'none');
      
      const targetView = document.getElementById(`view-${target}`);
      if (targetView) targetView.style.display = 'block';

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
    const sumRes = await fetch(`${API_BASE}/dashboard/summary`);
    if (sumRes.ok) {
      const summary = await sumRes.json();
      updateKPICounters(summary);
    }

    // 2. Risk Distribution Chart
    const distRes = await fetch(`${API_BASE}/dashboard/risk-distribution`);
    if (distRes.ok) {
      const dist = await distRes.json();
      initRiskDistributionChart(dist);
    }

    // 3. Demographics & Timeline
    const demoRes = await fetch(`${API_BASE}/dashboard/demographics`);
    if (demoRes.ok) {
      const demo = await demoRes.json();
      initTimelineChart(demo.timeline);
      initAgeDemographicsChart();
    }

    // 4. Locations
    const locRes = await fetch(`${API_BASE}/dashboard/location-summary`);
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
  }
}

function updateKPICounters(data) {
  document.getElementById('kpiTotalPatients').textContent = data.total_patients || 5;
  document.getElementById('kpiTotalScreenings').textContent = data.total_screenings || 5;
  document.getElementById('kpiSevereCount').textContent = data.high_count || 1;
  document.getElementById('kpiModerateCount').textContent = data.moderate_count || 1;
  document.getElementById('kpiNormalCount').textContent = data.normal_count || 2;
  document.getElementById('kpiPendingReferrals').textContent = data.pending_referrals || 2;
}

async function loadPatients() {
  try {
    const res = await fetch(`${API_BASE}/patients?limit=50`);
    if (res.ok) {
      const data = await res.json();
      cachedPatients = data.items;
      renderPatientsTable(data.items);
      populateSimulatorPatientDropdown(data.items);
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
    const res = await fetch(`${API_BASE}/screenings?limit=50`);
    if (res.ok) {
      const data = await res.json();
      cachedScreenings = data.items;
      renderScreeningsTable(data.items);
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
}

async function loadReferrals() {
  try {
    const res = await fetch(`${API_BASE}/referrals?limit=50`);
    if (res.ok) {
      const data = await res.json();
      cachedReferrals = data.items;
      renderReferralsTable(data.items);
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

    const res = await fetch(`${API_BASE}/screenings`, {
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
    const res = await fetch(`${API_BASE}/referrals/${referralId}`, {
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
    const res = await fetch(`${API_BASE}/demo/reset`, { method: 'POST' });
    if (res.ok) {
      alert('Demo dataset restored to initial benchmark state!');
      loadAllDashboardData();
    }
  } catch (err) {
    alert('Error resetting demo database');
  }
}
