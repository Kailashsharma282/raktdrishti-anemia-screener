/**
 * RaktDrishti Interactive Charts Engine
 */

let riskChartInstance = null;
let timelineChartInstance = null;
let locationChartInstance = null;
let ageChartInstance = null;

function initRiskDistributionChart(data) {
  const ctx = document.getElementById('riskChart')?.getContext('2d');
  if (!ctx) return;

  if (riskChartInstance) riskChartInstance.destroy();

  riskChartInstance = new Chart(ctx, {
    type: 'doughnut',
    data: {
      labels: ['Normal Risk', 'Mild Risk', 'Moderate Risk', 'Severe Risk'],
      datasets: [{
        data: [data.NORMAL || 3, data.MILD || 1, data.MODERATE || 1, data.SEVERE || 1],
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
      cutout: '70%'
    }
  });
}

function initTimelineChart(timelineData) {
  const ctx = document.getElementById('timelineChart')?.getContext('2d');
  if (!ctx) return;

  if (timelineChartInstance) timelineChartInstance.destroy();

  const labels = timelineData ? timelineData.map(d => d.date) : ['23 Aug', '24 Aug', '25 Aug', '26 Aug', '27 Aug'];
  const screenings = timelineData ? timelineData.map(d => d.screenings) : [12, 18, 24, 31, 38];
  const highRisk = timelineData ? timelineData.map(d => d.high_risk) : [2, 4, 5, 7, 9];

  timelineChartInstance = new Chart(ctx, {
    type: 'line',
    data: {
      labels: labels,
      datasets: [
        {
          label: 'Total Screenings',
          data: screenings,
          borderColor: '#38bdf8',
          backgroundColor: 'rgba(56, 189, 248, 0.1)',
          fill: true,
          tension: 0.35,
          borderWidth: 2,
          pointRadius: 4
        },
        {
          label: 'Elevated Risk Triage',
          data: highRisk,
          borderColor: '#ef4444',
          backgroundColor: 'rgba(239, 68, 68, 0.1)',
          fill: true,
          tension: 0.35,
          borderWidth: 2,
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
  });
}

function initLocationChart(locations) {
  const ctx = document.getElementById('locationChart')?.getContext('2d');
  if (!ctx) return;

  if (locationChartInstance) locationChartInstance.destroy();

  const labels = locations ? locations.map(l => l.village) : ['Demo Village', 'Shivpur Rural', 'Ramnagar'];
  const totals = locations ? locations.map(l => l.total_screenings) : [124, 98, 142];
  const highRisk = locations ? locations.map(l => l.high_risk_count + l.moderate_risk_count) : [19, 11, 24];

  locationChartInstance = new Chart(ctx, {
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
  });
}

function initAgeDemographicsChart() {
  const ctx = document.getElementById('ageChart')?.getContext('2d');
  if (!ctx) return;

  if (ageChartInstance) ageChartInstance.destroy();

  ageChartInstance = new Chart(ctx, {
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
  });
}
