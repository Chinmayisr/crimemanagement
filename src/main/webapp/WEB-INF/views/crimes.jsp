<%@ page contentType="text/html;charset=UTF-8" isELIgnored="true" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Crimes — Crime Management System</title>
  <link rel="stylesheet" href="/css/style.css">
</head>
<body>
<jsp:include page="partials/navbar.jsp"><jsp:param name="active" value="crimes"/></jsp:include>
<jsp:include page="partials/common.jsp"/>

<div class="page-container">
  <div class="page-header">
    <div class="page-title"><div class="icon-badge">🔪</div>Crime Records</div>
    <button class="btn btn-primary" onclick="openAddModal()">＋ Add Crime</button>
  </div>

  <div class="filter-bar">
    <div class="search-wrap">
      <span class="search-icon">🔍</span>
      <input class="form-control" id="search-input" placeholder="Search by type…" oninput="onSearch(this.value)">
    </div>
    <input class="form-control" id="loc-filter" style="width:200px;" placeholder="Filter by location…" oninput="onLocFilter(this.value)">
    <input class="form-control" id="date-start" type="date" style="width:160px;">
    <input class="form-control" id="date-end"   type="date" style="width:160px;">
    <button class="btn btn-secondary" onclick="filterByDate()">📅 Filter</button>
    <button class="btn btn-secondary" onclick="loadCrimes()">↺ Reset</button>
  </div>

  <div class="card">
    <div class="card-header">
      <span>All Crime Records</span>
      <span class="text-muted text-sm" id="count-label"></span>
    </div>
    <div class="table-wrapper" id="table-body"></div>
  </div>
</div>

<!-- MODAL -->
<div class="modal-overlay" id="modal-crime">
  <div class="modal-box">
    <div class="modal-header">
      <span id="modal-title">Add Crime</span>
      <button class="btn-close-modal" onclick="closeModal('modal-crime')">✕</button>
    </div>
    <div class="modal-body">
      <input type="hidden" id="f-id">
      <div class="form-grid-2">
        <div class="form-group">
          <label class="form-label">Crime Type *</label>
          <input class="form-control" id="f-type" placeholder="e.g. Robbery, Assault">
        </div>
        <div class="form-group">
          <label class="form-label">Date</label>
          <input class="form-control" id="f-date" type="date">
        </div>
        <div class="form-group">
          <label class="form-label">Location</label>
          <input class="form-control" id="f-location" placeholder="Location">
        </div>
        <div class="form-group">
          <label class="form-label">Link to Case</label>
          <select class="form-select" id="f-case-id">
            <option value="">— No case —</option>
          </select>
        </div>
      </div>
      <div class="form-group">
        <label class="form-label">Description</label>
        <textarea class="form-control" id="f-desc" placeholder="Describe the incident…"></textarea>
      </div>
      <div class="form-group">
        <label class="form-label">Involved Victims</label>
        <div id="victims-checklist" style="max-height:140px;overflow-y:auto;background:var(--navy-3);border:1px solid var(--border-2);border-radius:6px;padding:0.5rem 0.75rem;"></div>
      </div>
    </div>
    <div class="modal-footer">
      <button class="btn btn-secondary" onclick="closeModal('modal-crime')">Cancel</button>
      <button class="btn btn-primary" onclick="saveCrime()">💾 Save</button>
    </div>
  </div>
</div>

<!-- DETAIL PANEL -->
<div class="detail-panel" id="detail-panel">
  <div class="detail-panel-header">
    <span>Crime Details</span>
    <button class="btn-close-modal" onclick="closePanel('detail-panel')">✕</button>
  </div>
  <div class="detail-panel-body" id="detail-content"></div>
</div>

<script src="/js/app.js"></script>
<script>
let allCrimes = [], allVictims = [], allCases = [];

async function loadCrimes() {
  allCrimes = await API.get('/crimes');
  renderTable(allCrimes);
}

async function loadRelations() {
  [allVictims, allCases] = await Promise.all([API.get('/victims'), API.get('/cases')]);
}

function renderTable(data) {
  document.getElementById('count-label').textContent = `${data.length} record${data.length!=1?'s':''}`;
  if (!data.length) {
    document.getElementById('table-body').innerHTML = `<div class="empty-state"><div class="empty-icon">🔪</div><p>No crimes found</p></div>`;
    return;
  }
  document.getElementById('table-body').innerHTML = `
    <table>
      <thead><tr><th>#</th><th>Type</th><th>Date</th><th>Location</th><th>Criminals</th><th>Victims</th><th>Case</th><th>Actions</th></tr></thead>
      <tbody>
        ${data.map(c => `
          <tr>
            <td class="text-muted">${c.crimeId}</td>
            <td><strong>${c.crimeType}</strong></td>
            <td>${fmtDate(c.date)}</td>
            <td class="text-muted">${c.location || '—'}</td>
            <td>${(c.criminals||[]).length}</td>
            <td>${(c.victims||[]).length}</td>
            <td>${c.crimeCase ? `<span class="badge badge-open">Case #${c.crimeCase.caseId}</span>` : '—'}</td>
            <td><div class="action-btns">
              <button class="btn btn-secondary btn-sm btn-icon" onclick="viewDetail(${c.crimeId})">👁</button>
              <button class="btn btn-warning btn-sm btn-icon" onclick="editCrime(${c.crimeId})">✏️</button>
              <button class="btn btn-danger btn-sm btn-icon" onclick="deleteCrime(${c.crimeId},'${c.crimeType}')">🗑</button>
            </div></td>
          </tr>`).join('')}
      </tbody>
    </table>`;
}

const onSearch = debounce(async v => {
  if (!v.trim()) return renderTable(allCrimes);
  renderTable(allCrimes.filter(c => c.crimeType.toLowerCase().includes(v.toLowerCase())));
});

const onLocFilter = debounce(async v => {
  if (!v.trim()) return renderTable(allCrimes);
  renderTable(allCrimes.filter(c => (c.location||'').toLowerCase().includes(v.toLowerCase())));
});

async function filterByDate() {
  const s = document.getElementById('date-start').value;
  const e = document.getElementById('date-end').value;
  if (!s || !e) { showToast('Select both dates', 'warning'); return; }
  const res = await API.get(`/crimes?startDate=${s}&endDate=${e}`);
  renderTable(res);
}

async function openAddModal() {
  await loadRelations();
  document.getElementById('modal-title').textContent = 'Add Crime';
  ['f-id','f-type','f-location','f-desc'].forEach(id => document.getElementById(id).value='');
  document.getElementById('f-date').value = '';
  populateCaseSelect(null);
  renderCheckList('victims-checklist', allVictims, [], 'victimId', 'name');
  openModal('modal-crime');
}

function populateCaseSelect(selectedId) {
  const sel = document.getElementById('f-case-id');
  sel.innerHTML = '<option value="">— No case —</option>';
  allCases.forEach(c => {
    const opt = document.createElement('option');
    opt.value = c.caseId;
    opt.textContent = `Case #${c.caseId} — ${c.caseStatus}`;
    if (c.caseId = selectedId) opt.selected = true;
    sel.appendChild(opt);
  });
}

async function editCrime(id) {
  await loadRelations();
  const c = await API.get('/crimes/' + id);
  document.getElementById('modal-title').textContent = 'Edit Crime';
  document.getElementById('f-id').value = c.crimeId;
  document.getElementById('f-type').value = c.crimeType || '';
  document.getElementById('f-date').value = c.date || '';
  document.getElementById('f-location').value = c.location || '';
  document.getElementById('f-desc').value = c.description || '';
  populateCaseSelect(c.crimeCase?.caseId);
  const linkedVictims = (c.victims||[]).map(v => v.victimId);
  renderCheckList('victims-checklist', allVictims, linkedVictims, 'victimId', 'name');
  openModal('modal-crime');
}

async function saveCrime() {
  const id = document.getElementById('f-id').value;
  const body = {
    crimeType: document.getElementById('f-type').value.trim(),
    date: document.getElementById('f-date').value || null,
    location: document.getElementById('f-location').value.trim(),
    description: document.getElementById('f-desc').value.trim()
  };
  if (!body.crimeType) { showToast('Crime type is required', 'error'); return; }
  const victimIds = getChecked('victims-checklist');
  const caseId = document.getElementById('f-case-id').value;
  const params = buildParams({victimIds: victimIds.join(',')||undefined, caseId: caseId||undefined});
  try {
    if (id) await API.put('/crimes/'+id, body, params);
    else    await API.post('/crimes', body, params);
    showToast(id ? 'Crime updated' : 'Crime added', 'success');
    closeModal('modal-crime');
    loadCrimes();
  } catch(e) { showToast('Error saving', 'error'); }
}

async function deleteCrime(id, type) {
  confirmDelete(`Delete crime "${type}"?`, async () => {
    await API.delete('/crimes/'+id);
    showToast('Crime deleted', 'success');
    loadCrimes();
  });
}

async function viewDetail(id) {
  const c = await API.get('/crimes/'+id);
  const criminals = c.criminals || [];
  const victims   = c.victims   || [];
  document.getElementById('detail-content').innerHTML = `
    <div class="detail-row"><span class="detail-label">ID</span><span class="detail-value">#${c.crimeId}</span></div>
    <div class="detail-row"><span class="detail-label">Type</span><span class="detail-value"><strong>${c.crimeType}</strong></span></div>
    <div class="detail-row"><span class="detail-label">Date</span><span class="detail-value">${fmtDate(c.date)}</span></div>
    <div class="detail-row"><span class="detail-label">Location</span><span class="detail-value">${c.location||'—'}</span></div>
    <div class="detail-row"><span class="detail-label">Case</span><span class="detail-value">${c.crimeCase?`Case #${c.crimeCase.caseId}`:'Not assigned'}</span></div>
    <div class="detail-row"><span class="detail-label">Description</span><span class="detail-value text-muted">${c.description||'—'}</span></div>
    <div class="detail-section">👤 Criminals (${criminals.length})</div>
    <div>${criminals.map(cr=>`<span class="relation-tag">👤 ${cr.name}</span>`).join('')||'<p class="text-muted text-sm">None</p>'}</div>
    <div class="detail-section">🩺 Victims (${victims.length})</div>
    <div>${victims.map(v=>`<span class="relation-tag">🩺 ${v.name}</span>`).join('')||'<p class="text-muted text-sm">None</p>'}</div>
    <div style="margin-top:2rem;display:flex;gap:0.75rem;">
      <button class="btn btn-warning btn-sm" onclick="editCrime(${c.crimeId});closePanel('detail-panel')">✏️ Edit</button>
      <button class="btn btn-danger btn-sm" onclick="deleteCrime(${c.crimeId},'${c.crimeType}');closePanel('detail-panel')">🗑 Delete</button>
    </div>`;
  openPanel('detail-panel');
}

loadCrimes();
</script>
</body>
</html>
