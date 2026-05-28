<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Dashboard — Crime Management System</title>
  <link rel="stylesheet" href="/css/style.css">
</head>
<body>
<jsp:include page="partials/navbar.jsp"><jsp:param name="active" value="home"/></jsp:include>
<jsp:include page="partials/common.jsp"/>

<div class="page-container">

  <!-- Hero -->
  <div class="hero">
    <div class="hero-title">Crime Records <span>Management</span> System</div>
    <p class="hero-sub">Centralized intelligence platform for managing criminal records, case files, evidence, and law enforcement operations.</p>
    <div style="margin-top:1.25rem; display:flex; gap:0.75rem; flex-wrap:wrap;">
      <a href="/cases?status=OPEN" class="btn btn-primary">📂 View Open Cases</a>
      <a href="/criminals" class="btn btn-secondary">👤 Browse Criminals</a>
    </div>
  </div>

  <!-- Stat Cards -->
  <div class="stats-grid" id="stats-grid">
    <div class="stat-card" style="--accent-color:#e74c3c;">
      <div class="stat-icon" style="background:rgba(231,76,60,0.15);color:#e74c3c;">👤</div>
      <div class="stat-info"><div class="stat-value" id="s-criminals">—</div><div class="stat-label">Criminals</div></div>
    </div>
    <div class="stat-card" style="--accent-color:#e67e22;">
      <div class="stat-icon" style="background:rgba(230,126,34,0.15);color:#e67e22;">🔪</div>
      <div class="stat-info"><div class="stat-value" id="s-crimes">—</div><div class="stat-label">Crimes</div></div>
    </div>
    <div class="stat-card" style="--accent-color:#9b59b6;">
      <div class="stat-icon" style="background:rgba(155,89,182,0.15);color:#9b59b6;">🩺</div>
      <div class="stat-info"><div class="stat-value" id="s-victims">—</div><div class="stat-label">Victims</div></div>
    </div>
    <div class="stat-card" style="--accent-color:#2980b9;">
      <div class="stat-icon" style="background:rgba(41,128,185,0.15);color:#2980b9;">👮</div>
      <div class="stat-info"><div class="stat-value" id="s-officers">—</div><div class="stat-label">Officers</div></div>
    </div>
    <div class="stat-card" style="--accent-color:#1abc9c;">
      <div class="stat-icon" style="background:rgba(26,188,156,0.15);color:#1abc9c;">📁</div>
      <div class="stat-info"><div class="stat-value" id="s-cases">—</div><div class="stat-label">Cases</div></div>
    </div>
    <div class="stat-card" style="--accent-color:#f39c12;">
      <div class="stat-icon" style="background:rgba(243,156,18,0.15);color:#f39c12;">🔬</div>
      <div class="stat-info"><div class="stat-value" id="s-evidence">—</div><div class="stat-label">Evidence</div></div>
    </div>
  </div>

  <!-- Case Status Row -->
  <div style="display:grid;grid-template-columns:repeat(auto-fit,minmax(200px,1fr));gap:1rem;margin-bottom:2rem;">
    <div class="card" style="border-top:3px solid #e74c3c;">
      <div class="card-body" style="display:flex;align-items:center;justify-content:space-between;">
        <span class="text-muted" style="font-size:0.85rem;text-transform:uppercase;letter-spacing:0.5px;">Open Cases</span>
        <span class="stat-value" id="s-open" style="font-family:'Rajdhani',sans-serif;font-size:1.8rem;font-weight:700;color:#e74c3c;">—</span>
      </div>
    </div>
    <div class="card" style="border-top:3px solid #1abc9c;">
      <div class="card-body" style="display:flex;align-items:center;justify-content:space-between;">
        <span class="text-muted" style="font-size:0.85rem;text-transform:uppercase;letter-spacing:0.5px;">Closed Cases</span>
        <span class="stat-value" id="s-closed" style="font-family:'Rajdhani',sans-serif;font-size:1.8rem;font-weight:700;color:#1abc9c;">—</span>
      </div>
    </div>
    <div class="card" style="border-top:3px solid #f39c12;">
      <div class="card-body" style="display:flex;align-items:center;justify-content:space-between;">
        <span class="text-muted" style="font-size:0.85rem;text-transform:uppercase;letter-spacing:0.5px;">Pending Cases</span>
        <span class="stat-value" id="s-pending" style="font-family:'Rajdhani',sans-serif;font-size:1.8rem;font-weight:700;color:#f39c12;">—</span>
      </div>
    </div>
    <div class="card" style="border-top:3px solid #3498db;">
      <div class="card-body" style="display:flex;align-items:center;justify-content:space-between;">
        <span class="text-muted" style="font-size:0.85rem;text-transform:uppercase;letter-spacing:0.5px;">Under Investigation</span>
        <span class="stat-value" id="s-investigation" style="font-family:'Rajdhani',sans-serif;font-size:1.8rem;font-weight:700;color:#3498db;">—</span>
      </div>
    </div>
  </div>

  <!-- Quick Navigation -->
  <div class="card" style="margin-bottom:2rem;">
    <div class="card-header">⚡ Quick Access</div>
    <div class="card-body">
      <div class="quick-nav">
        <a href="/criminals" class="quick-nav-item">
          <div class="nav-icon">👤</div>
          <div style="font-weight:600;margin-bottom:0.25rem;">Criminals</div>
          <div class="nav-label">Manage records</div>
        </a>
        <a href="/crimes" class="quick-nav-item">
          <div class="nav-icon">🔪</div>
          <div style="font-weight:600;margin-bottom:0.25rem;">Crimes</div>
          <div class="nav-label">Browse incidents</div>
        </a>
        <a href="/victims" class="quick-nav-item">
          <div class="nav-icon">🩺</div>
          <div style="font-weight:600;margin-bottom:0.25rem;">Victims</div>
          <div class="nav-label">Support records</div>
        </a>
        <a href="/officers" class="quick-nav-item">
          <div class="nav-icon">👮</div>
          <div style="font-weight:600;margin-bottom:0.25rem;">Officers</div>
          <div class="nav-label">Personnel roster</div>
        </a>
        <a href="/cases" class="quick-nav-item">
          <div class="nav-icon">📁</div>
          <div style="font-weight:600;margin-bottom:0.25rem;">Cases</div>
          <div class="nav-label">Case management</div>
        </a>
        <a href="/evidence" class="quick-nav-item">
          <div class="nav-icon">🔬</div>
          <div style="font-weight:600;margin-bottom:0.25rem;">Evidence</div>
          <div class="nav-label">Evidence vault</div>
        </a>
      </div>
    </div>
  </div>

</div>

<script src="/js/app.js"></script>
<script>
  // Load dashboard stats
  API.get('/dashboard/stats').then(data => {
    document.getElementById('s-criminals').textContent   = data.totalCriminals;
    document.getElementById('s-crimes').textContent      = data.totalCrimes;
    document.getElementById('s-victims').textContent     = data.totalVictims;
    document.getElementById('s-officers').textContent    = data.totalOfficers;
    document.getElementById('s-cases').textContent       = data.totalCases;
    document.getElementById('s-evidence').textContent    = data.totalEvidence;
    document.getElementById('s-open').textContent        = data.openCases;
    document.getElementById('s-closed').textContent      = data.closedCases;
    document.getElementById('s-pending').textContent     = data.pendingCases;
    document.getElementById('s-investigation').textContent = data.underInvestigation;
  }).catch(() => showToast('Could not load dashboard stats', 'error'));
</script>
</body>
</html>
