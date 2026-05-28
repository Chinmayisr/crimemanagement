<%@ page contentType="text/html;charset=UTF-8" isELIgnored="true" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Criminals — Crime Management System</title>
  <link rel="stylesheet" href="/css/style.css">
</head>
<body>
<jsp:include page="partials/navbar.jsp"><jsp:param name="active" value="criminals"/></jsp:include>
<jsp:include page="partials/common.jsp"/>

<div class="page-container">
  <div class="page-header">
    <div class="page-title">
      <div class="icon-badge">👤</div>
      Criminal Records
    </div>
    <button class="btn btn-primary" onclick="openAddModal()">＋ Add Criminal</button>
  </div>

  <!-- Filter Bar -->
  <div class="filter-bar">
    <div class="search-wrap">
      <span class="search-icon">🔍</span>
      <input class="form-control" id="search-input" placeholder="Search by name…" oninput="onSearch(this.value)">
    </div>
    <select class="form-select" style="width:160px;" id="gender-filter" onchange="onGenderFilter(this.value)">
      <option value="">All Genders</option>
      <option value="Male">Male</option>
      <option value="Female">Female</option>
      <option value="Other">Other</option>
    </select>
    <button class="btn btn-secondary" onclick="loadCriminals()">↺ Refresh</button>
  </div>

  <!-- Table Card -->
  <div class="card">
    <div class="card-header">
      <span>All Criminals</span>
      <span class="text-muted text-sm" id="count-label"></span>
    </div>
    <div class="table-wrapper">
      <div id="table-body"></div>
    </div>
  </div>
</div>

<!-- ADD / EDIT MODAL -->
<div class="modal-overlay" id="modal-criminal">
  <div class="modal-box">
    <div class="modal-header">
      <span id="modal-title">Add Criminal</span>
      <button class="btn-close-modal" onclick="closeModal('modal-criminal')">✕</button>
    </div>
    <div class="modal-body">
      <input type="hidden" id="f-id">
      <div class="form-grid-2">
        <div class="form-group">
          <label class="form-label">Full Name *</label>
          <input class="form-control" id="f-name" placeholder="Enter full name">
        </div>
        <div class="form-group">
          <label class="form-label">Age</label>
          <input class="form-control" id="f-age" type="number" min="1" placeholder="Age">
        </div>
        <div class="form-group">
          <label class="form-label">Gender</label>
          <select class="form-select" id="f-gender">
            <option value="">Select</option>
            <option value="Male">Male</option>
            <option value="Female">Female</option>
            <option value="Other">Other</option>
          </select>
        </div>
        <div class="form-group">
          <label class="form-label">Address</label>
          <input class="form-control" id="f-address" placeholder="Address">
        </div>
      </div>
      <div class="form-group">
        <label class="form-label">Crime History</label>
        <textarea class="form-control" id="f-history" placeholder="Prior convictions, notable incidents…"></textarea>
      </div>
      <!-- Relationships -->
      <div style="display:grid;grid-template-columns:1fr 1fr;gap:1rem;margin-top:0.5rem;">
        <div class="form-group">
          <label class="form-label">Link to Crimes</label>
          <div id="crimes-checklist" style="max-height:150px;overflow-y:auto;background:var(--navy-3);border:1px solid var(--border-2);border-radius:6px;padding:0.5rem 0.75rem;"></div>
        </div>
        <div class="form-group">
          <label class="form-label">Link to Cases</label>
          <div id="cases-checklist" style="max-height:150px;overflow-y:auto;background:var(--navy-3);border:1px solid var(--border-2);border-radius:6px;padding:0.5rem 0.75rem;"></div>
        </div>
      </div>
    </div>
    <div class="modal-footer">
      <button class="btn btn-secondary" onclick="closeModal('modal-criminal')">Cancel</button>
      <button class="btn btn-primary" onclick="saveCriminal()">💾 Save</button>
    </div>
  </div>
</div>

<!-- DETAIL PANEL -->
<div class="detail-panel" id="detail-panel">
  <div class="detail-panel-header">
    <span>Criminal Details</span>
    <button class="btn-close-modal" onclick="closePanel('detail-panel')">✕</button>
  </div>
  <div class="detail-panel-body" id="detail-content"></div>
</div>

<script src="/js/app.js"></script>
<script>
let allCriminals = [];
let allCrimes = [];
let allCases = [];

async function loadCriminals() {
  const res = await API.get('/criminals');
  allCriminals = res;
  renderTable(res);
}

async function loadRelations() {
  const [crimes, cases] = await Promise.all([API.get('/crimes'), API.get('/cases')]);
  allCrimes = crimes;
  allCases = cases;
}

function renderTable(data) {
  document.getElementById('count-label').textContent = `${data.length} record${data.length != 1 ? 's' : ''}`;
  if (!data.length) {
    document.getElementById('table-body').innerHTML = `<div class="empty-state"><div class="empty-icon">👤</div><p>No criminals found</p></div>`;
    return;
  }
  document.getElementById('table-body').innerHTML = `
    <table>
      <thead><tr>
        <th>#</th><th>Name</th><th>Age</th><th>Gender</th><th>Address</th><th>Actions</th>
      </tr></thead>
      <tbody>
        ${data.map(c => `
          <tr>
            <td class="text-muted">${c.criminalId}</td>
            <td><strong>${c.name}</strong></td>
            <td>${c.age || '—'}</td>
            <td>${c.gender ? genderBadge(c.gender) : '—'}</td>
            <td class="text-muted" style="max-width:180px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;">${c.address || '—'}</td>
            <td>
              <div class="action-btns">
                <button class="btn btn-secondary btn-sm btn-icon" title="View" onclick="viewDetail(${c.criminalId})">👁</button>
                <button class="btn btn-warning btn-sm btn-icon" title="Edit" onclick="editCriminal(${c.criminalId})">✏️</button>
                <button class="btn btn-danger btn-sm btn-icon" title="Delete" onclick="deleteCriminal(${c.criminalId},'${c.name}')">🗑</button>
              </div>
            </td>
          </tr>`).join('')}
      </tbody>
    </table>`;
}

const onSearch = debounce(async v => {
  if (!v.trim()) return renderTable(allCriminals);
  const res = await API.get('/criminals?name=' + encodeURIComponent(v));
  renderTable(res);
});

function onGenderFilter(v) {
  renderTable(v ? allCriminals.filter(c => c.gender === v) : allCriminals);
}

async function openAddModal() {
  await loadRelations();
  document.getElementById('modal-title').textContent = 'Add Criminal';
  ['f-id','f-name','f-age','f-address','f-history'].forEach(id => document.getElementById(id).value = '');
  document.getElementById('f-gender').value = '';
  renderCheckList('crimes-checklist', allCrimes, [], 'crimeId', 'crimeType');
  renderCheckList('cases-checklist', allCases.map(c => ({...c, label:`Case #${c.caseId} (${c.caseStatus})`})), [], 'caseId', 'label');
  openModal('modal-criminal');
}

async function editCriminal(id) {
  await loadRelations();
  const c = await API.get('/criminals/' + id);
  document.getElementById('modal-title').textContent = 'Edit Criminal';
  document.getElementById('f-id').value = c.criminalId;
  document.getElementById('f-name').value = c.name || '';
  document.getElementById('f-age').value = c.age || '';
  document.getElementById('f-gender').value = c.gender || '';
  document.getElementById('f-address').value = c.address || '';
  document.getElementById('f-history').value = c.crimeHistory || '';
  const linkedCrimes = (c.crimes || []).map(x => x.crimeId);
  const linkedCases  = (c.cases  || []).map(x => x.caseId);
  renderCheckList('crimes-checklist', allCrimes, linkedCrimes, 'crimeId', 'crimeType');
  renderCheckList('cases-checklist', allCases.map(x => ({...x, label:`Case #${x.caseId} (${x.caseStatus})`})), linkedCases, 'caseId', 'label');
  openModal('modal-criminal');
}

async function saveCriminal() {
  const id = document.getElementById('f-id').value;
  const body = {
    name: document.getElementById('f-name').value.trim(),
    age: +document.getElementById('f-age').value || null,
    gender: document.getElementById('f-gender').value,
    address: document.getElementById('f-address').value.trim(),
    crimeHistory: document.getElementById('f-history').value.trim()
  };
  if (!body.name) { showToast('Name is required', 'error'); return; }
  const crimeIds = getChecked('crimes-checklist');
  const caseIds  = getChecked('cases-checklist');
  const params   = buildParams({crimeIds: crimeIds.join(',') || undefined, caseIds: caseIds.join(',') || undefined});

  try {
    if (id) {
      await API.put('/criminals/' + id, body, params);
      showToast('Criminal updated successfully', 'success');
    } else {
      await API.post('/criminals', body, params);
      showToast('Criminal added successfully', 'success');
    }
    closeModal('modal-criminal');
    loadCriminals();
  } catch (e) { showToast('Error saving record', 'error'); }
}

async function deleteCriminal(id, name) {
  confirmDelete(`Delete criminal "${name}"?`, async () => {
    await API.delete('/criminals/' + id);
    showToast('Criminal deleted', 'success');
    loadCriminals();
  });
}

async function viewDetail(id) {
  const c = await API.get('/criminals/' + id);
  const el = document.getElementById('detail-content');
  const crimes = c.crimes || [];
  const cases  = c.cases  || [];
  el.innerHTML = `
    <div class="detail-row"><span class="detail-label">ID</span><span class="detail-value">#${c.criminalId}</span></div>
    <div class="detail-row"><span class="detail-label">Name</span><span class="detail-value"><strong>${c.name}</strong></span></div>
    <div class="detail-row"><span class="detail-label">Age</span><span class="detail-value">${c.age || '—'}</span></div>
    <div class="detail-row"><span class="detail-label">Gender</span><span class="detail-value">${c.gender ? genderBadge(c.gender) : '—'}</span></div>
    <div class="detail-row"><span class="detail-label">Address</span><span class="detail-value">${c.address || '—'}</span></div>
    <div class="detail-row"><span class="detail-label">Crime History</span><span class="detail-value text-muted">${c.crimeHistory || '—'}</span></div>
    <div class="detail-section">🔪 Linked Crimes (${crimes.length})</div>
    <div>${crimes.length ? crimes.map(cr=>`<span class="relation-tag">🔪 ${cr.crimeType} (${fmtDate(cr.date)})</span>`).join('') : '<p class="text-muted text-sm">None linked</p>'}</div>
    <div class="detail-section">📁 Linked Cases (${cases.length})</div>
    <div>${cases.length ? cases.map(cs=>`<span class="relation-tag">📁 Case #${cs.caseId} ${statusBadge(cs.caseStatus)}</span>`).join('') : '<p class="text-muted text-sm">None linked</p>'}</div>
    <div style="margin-top:2rem;display:flex;gap:0.75rem;">
      <button class="btn btn-warning btn-sm" onclick="editCriminal(${c.criminalId});closePanel('detail-panel')">✏️ Edit</button>
      <button class="btn btn-danger btn-sm" onclick="deleteCriminal(${c.criminalId},'${c.name}');closePanel('detail-panel')">🗑 Delete</button>
    </div>`;
  openPanel('detail-panel');
}

loadCriminals();
</script>
</body>
</html>
