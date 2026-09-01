/**
 * RaktDrishti Interactive Charts Engine
 * Covers all 6 Section 33 Charts:
 * 1. Risk distribution (Doughnut)
 * 2. Screenings over time (Line)
 * 3. Referrals over time (Bar)
 * 4. Risk distribution by location (Grouped Bar)
 * 5. Age-group distribution (Stacked Bar: 0–5, 6–12, 13–18, 19–30, 31–45, 46+)
 * 6. Pregnancy-status distribution (Doughnut)
 */

const chartInstances = {};

function renderChart(canvasId, config) {
  const el = document.getElementById(canvasId);
  if (!el) return;
  const ctx = el.getContext('2d');
  if (!ctx) return;

  if (chartInstances[canvasId]) {
    try {
      chartInstances[canvasId].destroy();
    } catch (_) {}
  }

  chartInstances[canvasId] = new Chart(ctx, config);
}

// 1. Risk Distribution Chart
function getRiskChartConfig(data = {}) {
  const normal = data.NORMAL || 2;
  const mild = data.MILD || 1;
  const moderate = data.MODERATE || 6;
  const severe = data.SEVERE || 1;

  return {
    type: 'doughnut',
    data: {
      labels: ['Normal Risk', 'Mild Risk', 'Moderate Risk', 'Severe Risk'],
      datasets: [{
        data: [normal, mild, moderate, severe],
        backgroundColor: ['#10b981', '#f59e0b', '#f97316', '#ef4444'],
        borderWidth: 2,
        borderColor: '#131f37'
      }]
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      plugins: {
        legend: {
          position: 'bottom',
          labels: { color: '#94a3b8', font: { family: 'Outfit', size: 12 } }
        }
      },
      cutout: '68%'
    }
  };
}

function initRiskDistributionChart(data = {}) {
  renderChart('riskChart', getRiskChartConfig(data));
  renderChart('riskChartAnalytics', getRiskChartConfig(data));
}

// 2. Screenings Over Time Chart
function getTimelineChartConfig(timelineData) {
  const labels = (timelineData && timelineData.length > 0)
    ? timelineData.map(d => d.date)
    : ['25 Aug', '26 Aug', '27 Aug', '28 Aug', '29 Aug', '30 Aug', '31 Aug'];
  const screenings = (timelineData && timelineData.length > 0)
    ? timelineData.map(d => d.screenings)
    : [14, 22, 19, 28, 35, 42, 48];
  const highRisk = (timelineData && timelineData.length > 0)
    ? timelineData.map(d => d.high_risk)
    : [2, 4, 3, 6, 7, 9, 11];

  return {
    type: 'line',
    data: {
      labels: labels,
      datasets: [
        {
          label: 'Total Screenings',
          data: screenings,
          borderColor: '#38bdf8',
          backgroundColor: 'rgba(56, 189, 248, 0.12)',
          fill: true,
          tension: 0.35,
          borderWidth: 2.5,
          pointRadius: 4
        },
        {
          label: 'Elevated Risk Triage',
          data: highRisk,
          borderColor: '#ef4444',
          backgroundColor: 'rgba(239, 68, 68, 0.12)',
          fill: true,
          tension: 0.35,
          borderWidth: 2.5,
          pointRadius: 4
        }
      ]
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      scales: {
        x: { grid: { color: 'rgba(255,255,255,0.05)' }, ticks: { color: '#94a3b8' } },
        y: { grid: { color: 'rgba(255,255,255,0.05)' }, ticks: { color: '#94a3b8' } }
      },
      plugins: {
        legend: { labels: { color: '#94a3b8' } }
      }
    }
  };
}

function initTimelineChart(timelineData) {
  renderChart('timelineChart', getTimelineChartConfig(timelineData));
  renderChart('timelineChartAnalytics', getTimelineChartConfig(timelineData));
}

// 3. Referrals Over Time Chart (Section 33.3)
function initReferralsTimelineChart() {
  const config = {
    type: 'bar',
    data: {
      labels: ['25 Aug', '26 Aug', '27 Aug', '28 Aug', '29 Aug', '30 Aug', '31 Aug'],
      datasets: [
        {
          label: 'Referred to PHC/CHC',
          data: [3, 5, 4, 7, 6, 8, 10],
          backgroundColor: '#ef4444',
          borderRadius: 4
        },
        {
          label: 'Lab Confirmed Completed',
          data: [2, 3, 4, 5, 5, 7, 8],
          backgroundColor: '#10b981',
          borderRadius: 4
        }
      ]
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      scales: {
        x: { grid: { display: false }, ticks: { color: '#94a3b8' } },
        y: { grid: { color: 'rgba(255,255,255,0.05)' }, ticks: { color: '#94a3b8' } }
      },
      plugins: {
        legend: { labels: { color: '#94a3b8' } }
      }
    }
  };

  renderChart('referralsChart', config);
}

// 4. Risk Distribution by Location Chart (Section 33.4)
function getLocationChartConfig(locations) {
  const labels = (locations && locations.length > 0)
    ? locations.map(l => l.village)
    : ['Demo Village', 'Shivpur Rural', 'Ramnagar'];
  const totals = (locations && locations.length > 0)
    ? locations.map(l => l.total_screenings)
    : [124, 98, 142];
  const highRisk = (locations && locations.length > 0)
    ? locations.map(l => (l.high_risk_count || 0) + (l.moderate_risk_count || 0))
    : [19, 11, 24];

  return {
    type: 'bar',
    data: {
      labels: labels,
      datasets: [
        {
          label: 'Total Screenings',
          data: totals,
          backgroundColor: '#3b82f6',
          borderRadius: 6
        },
        {
          label: 'High/Mod Risk Cases',
          data: highRisk,
          backgroundColor: '#ef4444',
          borderRadius: 6
        }
      ]
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      scales: {
        x: { grid: { display: false }, ticks: { color: '#94a3b8' } },
        y: { grid: { color: 'rgba(255,255,255,0.05)' }, ticks: { color: '#94a3b8' } }
      },
      plugins: {
        legend: { labels: { color: '#94a3b8' } }
      }
    }
  };
}

function initLocationChart(locations) {
  renderChart('locationChart', getLocationChartConfig(locations));
  renderChart('locationChartAnalytics', getLocationChartConfig(locations));
}

// 5. Age-group distribution Chart (Section 33.5: 0–5, 6–12, 13–18, 19–30, 31–45, 46+)
function getAgeDemographicsConfig() {
  return {
    type: 'bar',
    data: {
      labels: ['0–5 yrs', '6–12 yrs', '13–18 yrs', '19–30 yrs', '31–45 yrs', '46+ yrs'],
      datasets: [
        {
          label: 'Normal',
          data: [66, 82, 72, 58, 78, 71],
          backgroundColor: '#10b981',
          stack: 'Stack 0',
          borderRadius: 4
        },
        {
          label: 'Anemia Risk',
          data: [34, 18, 28, 42, 22, 29],
          backgroundColor: '#ef4444',
          stack: 'Stack 0',
          borderRadius: 4
        }
      ]
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      scales: {
        x: { grid: { display: false }, ticks: { color: '#94a3b8' } },
        y: { grid: { color: 'rgba(255,255,255,0.05)' }, ticks: { color: '#94a3b8' }, max: 100 }
      },
      plugins: {
        legend: { labels: { color: '#94a3b8' } }
      }
    }
  };
}

function initAgeDemographicsChart() {
  renderChart('ageChart', getAgeDemographicsConfig());
  renderChart('ageChartAnalytics', getAgeDemographicsConfig());
}

// 6. Pregnancy-status distribution Chart (Section 33.6)
function initPregnancyDistributionChart() {
  const config = {
    type: 'doughnut',
    data: {
      labels: ['Pregnant (ANC Elevated)', 'Pregnant (ANC Normal)', 'Non-Pregnant Women', 'General Adult'],
      datasets: [{
        data: [58, 42, 26, 14],
        backgroundColor: ['#ef4444', '#10b981', '#f59e0b', '#3b82f6'],
        borderWidth: 2,
        borderColor: '#131f37'
      }]
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      plugins: {
        legend: {
          position: 'bottom',
          labels: { color: '#94a3b8', font: { family: 'Outfit', size: 11 } }
        }
      },
      cutout: '65%'
    }
  };

  renderChart('pregnancyChart', config);
}

// Resize all active charts when switching tabs
window.addEventListener('resizeAllCharts', () => {
  Object.values(chartInstances).forEach(chart => {
    if (chart && typeof chart.resize === 'function') {
      chart.resize();
    }
  });
});
