<%@ page contentType="text/html;charset=UTF-8" isELIgnored="true" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<nav class="navbar">
  <a class="navbar-brand" href="/">
    <div class="brand-icon">🔒</div>
    CRIME <span class="highlight">MGMT</span>
  </a>
  <div class="navbar-nav">
    <a class="nav-link ${param.active == 'home'      ? 'active' : ''}" href="/">🏠 Dashboard</a>
    <a class="nav-link ${param.active == 'criminals' ? 'active' : ''}" href="/criminals">👤 Criminals</a>
    <a class="nav-link ${param.active == 'crimes'    ? 'active' : ''}" href="/crimes">🔪 Crimes</a>
    <a class="nav-link ${param.active == 'victims'   ? 'active' : ''}" href="/victims">🩺 Victims</a>
    <a class="nav-link ${param.active == 'officers'  ? 'active' : ''}" href="/officers">👮 Officers</a>
    <a class="nav-link ${param.active == 'cases'     ? 'active' : ''}" href="/cases">📁 Cases</a>
    <a class="nav-link ${param.active == 'evidence'  ? 'active' : ''}" href="/evidence">🔬 Evidence</a>
  </div>
</nav>
