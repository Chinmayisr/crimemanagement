<%@ page contentType="text/html;charset=UTF-8" isELIgnored="true" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1.0">
  <title>Cases — Crime Management System</title>
  <link rel="stylesheet" href="/css/style.css">
</head>
<body>
<jsp:include page="partials/navbar.jsp"><jsp:param name="active" value="cases"/></jsp:include>
<jsp:include page="partials/common.jsp"/>

<div class="page-container">
  <div class="page-header">
    <div class="page-title"><div class="icon-badge">📁</div>Case Files</div>
    <button class="btn btn-primary" onclick="openAddModal()">＋ New Case</button>
  </div>

  <!-- Status Quick Filters -->
  <div style="display:flex;gap:0.5rem;flex-wrap:wrap;margin-bottom:1.25rem;">
    <button class="btn btn-secondary btn-sm" onclick="filterStatus('')">All</button>
    <button class="btn btn-sm" style="background:rgba(231,76,60,0.2);color:#e74c3c;" onclick="filterStatus('OPEN')">Open</button>
    <button class="btn btn-sm" style="background:rgba(26,188,156,0.2);color:#1abc9c;" onclick="filterStatus('CLOSED')">Closed</button>
    <button class="btn btn-sm" style="background:rgba(243,156,18,0.2);color:#f39c12;" onclick="filterStatus('PENDING')">Pending</button>
    <button class="btn btn-sm" style="background:rgba(41,128,185,0.2);color:#3498db;" onclick="filterStatus('UNDER_INVESTIGATION')">Under Investigation</button>
  </div>

  <div class="filter-bar">
    <div class="search-wrap">
      <span class="search-icon">🔍</span>
      <input class="form-control" id="search-input" placeholder="Search by case ID or officer…" oninput="onSearch(this.value)">
    </div>
    <button class="btn btn-secondary" onclick="loadCases()">↺ Refresh</button>
  </div>

  <div class="card">
    <div class="card-header"><span>All Cases</span><span class="text-muted text-sm" id="count-label"></span></div>
    <div class="table-wrapper" id="table-body"></div>
  </div>
</div>

<!-- MODAL -->
<div class="modal-overlay" id="modal-case">
  <div class="modal-box">
    <div class="modal-header">
      <span id="modal-title">New Case</span>
      <button class="btn-close-modal" onclick="closeModal('modal-case')">✕</button>
    </div>
    <div class="modal-body">
      <input type="hidden" id="f-id">
      <div class="form-grid-2">
        <div class="form-group">
          <label class="form-label">Case Status</label>
          <select class="form-select" id="f-status">
            <option value="OPEN">Open</option>
            <option value="PENDING">Pending</option>
            <option value="UNDER_INVESTIGATION">Under Investigation</option>
            <option value="CLOSED">Closed</option>
          </select>
        </div>
        <div class="form-group">
          <label class="form-label">Assigned Officer</label>
          <select class="form-select" id="f-officer">
            <option value="">— Unassigned —</option>
          </select>
        </div>
        <div class="form-group">
          <label class="form-label">Filing Date</label>
          <input class="form-control" id="f-filing" type="date">
        </div>
        <div class="form-group">
          <label class="form-label">Closing Date</label>
          <input class="form-control" id="f-closing" type="date">
        </div>
      </div>
      <div class="form-group">
        <label class="form-label">Linked Criminals</label>
        <div id="criminals-checklist" style="max-height:150px;overflow-y:auto;background:var(--navy-3);border:1px solid var(--border-2);border-radius:6px;padding:0.5rem 0.75rem;"></div>
      </div>
    </div>
    <div class="modal-footer">
      <button class="btn btn-secondary" onclick="closeModal('modal-case')">Cancel</button>
      <button class="btn btn-primary" onclick="saveCase()">💾 Save</button>
    </div>
  </div>
</div>

<!-- DETAIL PANEL -->
<div class="detail-panel" id="detail-panel">
  <div class="detail-panel-header"><span>Case Details</span><button class="btn-close-modal" onclick="closePanel('detail-panel')">✕</button></div>
  <div class="detail-panel-body" id="detail-content"></div>
</div>

<script src="/js/app.js"></script>
<script>
let allCases = [], allOfficers = [], allCriminals = [];
let currentFilter = '';

async function loadCases() {
  allCases = await API.get('/cases');
  renderTable(currentFilter ? allCases.filter(c=>c.caseStatus===currentFilter) : allCases);
}

async function loadRelations() {
  [allOfficers, allCriminals] = await Promise.all([API.get('/officers'), API.get('/criminals')]);
}

function renderTable(data) {
  document.getElementById('count-label').textContent=`${data.length} case${data.length!=1?'s':''}`;
  if(!data.length){document.getElementById('table-body').innerHTML=`<div class="empty-state"><div class="empty-icon">📁</div><p>No cases found</p></div>`;return;}
  document.getElementById('table-body').innerHTML=`
    <table>
      <thead><tr><th>#</th><th>Status</th><th>Officer</th><th>Filed</th><th>Closed</th><th>Crimes</th><th>Evidence</th><th>Actions</th></tr></thead>
      <tbody>${data.map(c=>`
        <tr>
          <td class="text-muted">${c.caseId}</td>
          <td>${statusBadge(c.caseStatus)}</td>
          <td>${c.officer?c.officer.name:'<span class="text-muted">Unassigned</span>'}</td>
          <td>${fmtDate(c.filingDate)}</td>
          <td>${c.closingDate?fmtDate(c.closingDate):'<span class="text-muted">—</span>'}</td>
          <td>${(c.crimes||[]).length}</td>
          <td>${(c.evidences||[]).length}</td>
          <td><div class="action-btns">
            <button class="btn btn-secondary btn-sm btn-icon" onclick="viewDetail(${c.caseId})">👁</button>
            <button class="btn btn-warning btn-sm btn-icon" onclick="editCase(${c.caseId})">✏️</button>
            <button class="btn btn-danger btn-sm btn-icon" onclick="deleteCase(${c.caseId})">🗑</button>
          </div></td>
        </tr>`).join('')}
      </tbody>
    </table>`;
}

function filterStatus(s) { currentFilter=s; renderTable(s?allCases.filter(c=>c.caseStatus===s):allCases); }
const onSearch = debounce(v => { renderTable(v?allCases.filter(c=>String(c.caseId).includes(v)||(c.officer?.name||'').toLowerCase().includes(v.toLowerCase())):allCases); });

async function openAddModal() {
  await loadRelations();
  document.getElementById('modal-title').textContent='New Case';
  ['f-id','f-filing','f-closing'].forEach(id=>document.getElementById(id).value='');
  document.getElementById('f-status').value='OPEN';
  populateOfficerSelect(null);
  renderCheckList('criminals-checklist', allCriminals, [], 'criminalId', 'name');
  openModal('modal-case');
}

function populateOfficerSelect(selectedId) {
  const sel=document.getElementById('f-officer');
  sel.innerHTML='<option value="">— Unassigned —</option>';
  allOfficers.forEach(o=>{
    const opt=document.createElement('option');
    opt.value=o.officerId; opt.textContent=`${o.name} (${o.rank||'Officer'})`;
    if(o.officerId=selectedId) opt.selected=true;
    sel.appendChild(opt);
  });
}

async function editCase(id) {
  await loadRelations();
  const c=await API.get('/cases/'+id);
  document.getElementById('modal-title').textContent='Edit Case';
  document.getElementById('f-id').value=c.caseId;
  document.getElementById('f-status').value=c.caseStatus||'OPEN';
  document.getElementById('f-filing').value=c.filingDate||'';
  document.getElementById('f-closing').value=c.closingDate||'';
  populateOfficerSelect(c.officer?.officerId);
  const linkedCriminals=(c.criminals||[]).map(x=>x.criminalId);
  renderCheckList('criminals-checklist',allCriminals,linkedCriminals,'criminalId','name');
  openModal('modal-case');
}

async function saveCase() {
  const id=document.getElementById('f-id').value;
  const body={caseStatus:document.getElementById('f-status').value,filingDate:document.getElementById('f-filing').value||null,closingDate:document.getElementById('f-closing').value||null};
  const officerId=document.getElementById('f-officer').value;
  const criminalIds=getChecked('criminals-checklist');
  const params=buildParams({officerId:officerId||undefined,criminalIds:criminalIds.join(',')||undefined});
  try{if(id)await API.put('/cases/'+id,body,params);else await API.post('/cases',body,params);
    showToast(id?'Case updated':'Case created','success');closeModal('modal-case');loadCases();}
  catch(e){showToast('Error saving','error');}
}

async function deleteCase(id) {
  confirmDelete(`Delete Case #${id}? This will also delete linked evidence.`,async()=>{
    await API.delete('/cases/'+id);showToast('Case deleted','success');loadCases();});
}

async function viewDetail(id) {
  const c=await API.get('/cases/'+id);
  const crimes=c.crimes||[]; const evidences=c.evidences||[]; const criminals=c.criminals||[];
  document.getElementById('detail-content').innerHTML=`
    <div class="detail-row"><span class="detail-label">Case ID</span><span class="detail-value"><strong>#${c.caseId}</strong></span></div>
    <div class="detail-row"><span class="detail-label">Status</span><span class="detail-value">${statusBadge(c.caseStatus)}</span></div>
    <div class="detail-row"><span class="detail-label">Officer</span><span class="detail-value">${c.officer?`${c.officer.name} (${c.officer.rank})`:'Unassigned'}</span></div>
    <div class="detail-row"><span class="detail-label">Filed</span><span class="detail-value">${fmtDate(c.filingDate)}</span></div>
    <div class="detail-row"><span class="detail-label">Closed</span><span class="detail-value">${c.closingDate?fmtDate(c.closingDate):'Still active'}</span></div>
    <div class="detail-section">👤 Suspects (${criminals.length})</div>
    <div>${criminals.map(cr=>`<span class="relation-tag">👤 ${cr.name}</span>`).join('')||'<p class="text-muted text-sm">None</p>'}</div>
    <div class="detail-section">🔪 Crimes (${crimes.length})</div>
    <div>${crimes.map(cr=>`<span class="relation-tag">🔪 ${cr.crimeType}</span>`).join('')||'<p class="text-muted text-sm">None</p>'}</div>
    <div class="detail-section">🔬 Evidence (${evidences.length})</div>
    <div>${evidences.map(e=>`<span class="relation-tag">🔬 ${e.type}</span>`).join('')||'<p class="text-muted text-sm">None</p>'}</div>
    <div style="margin-top:2rem;display:flex;gap:0.75rem;">
      <button class="btn btn-warning btn-sm" onclick="editCase(${c.caseId});closePanel('detail-panel')">✏️ Edit</button>
      <button class="btn btn-danger btn-sm" onclick="deleteCase(${c.caseId});closePanel('detail-panel')">🗑 Delete</button>
    </div>`;
  openPanel('detail-panel');
}

loadCases();
</script>
</body>
</html>
