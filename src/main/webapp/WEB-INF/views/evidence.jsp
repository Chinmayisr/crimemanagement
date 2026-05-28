<%@ page contentType="text/html;charset=UTF-8" isELIgnored="true" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1.0">
  <title>Evidence — Crime Management System</title>
  <link rel="stylesheet" href="/css/style.css">
</head>
<body>
<jsp:include page="partials/navbar.jsp"><jsp:param name="active" value="evidence"/></jsp:include>
<jsp:include page="partials/common.jsp"/>

<div class="page-container">
  <div class="page-header">
    <div class="page-title"><div class="icon-badge">🔬</div>Evidence Vault</div>
    <button class="btn btn-primary" onclick="openAddModal()">＋ Add Evidence</button>
  </div>

  <div class="filter-bar">
    <div class="search-wrap">
      <span class="search-icon">🔍</span>
      <input class="form-control" id="search-input" placeholder="Search by type…" oninput="onSearch(this.value)">
    </div>
    <select class="form-select" style="width:200px;" id="type-filter" onchange="onTypeFilter(this.value)">
      <option value="">All Types</option>
      <option value="Physical">Physical</option>
      <option value="Digital">Digital</option>
      <option value="Forensic">Forensic</option>
      <option value="Document">Document</option>
      <option value="Biological">Biological</option>
      <option value="Witness">Witness</option>
    </select>
    <button class="btn btn-secondary" onclick="loadEvidence()">↺ Refresh</button>
  </div>

  <div class="card">
    <div class="card-header"><span>All Evidence</span><span class="text-muted text-sm" id="count-label"></span></div>
    <div class="table-wrapper" id="table-body"></div>
  </div>
</div>

<!-- MODAL -->
<div class="modal-overlay" id="modal-evidence">
  <div class="modal-box">
    <div class="modal-header">
      <span id="modal-title">Add Evidence</span>
      <button class="btn-close-modal" onclick="closeModal('modal-evidence')">✕</button>
    </div>
    <div class="modal-body">
      <input type="hidden" id="f-id">
      <div class="form-grid-2">
        <div class="form-group">
          <label class="form-label">Evidence Type *</label>
          <select class="form-select" id="f-type">
            <option value="">Select type</option>
            <option value="Physical">Physical</option>
            <option value="Digital">Digital</option>
            <option value="Forensic">Forensic</option>
            <option value="Document">Document</option>
            <option value="Biological">Biological</option>
            <option value="Witness">Witness</option>
          </select>
        </div>
        <div class="form-group">
          <label class="form-label">Collected Date</label>
          <input class="form-control" id="f-date" type="date">
        </div>
        <div class="form-group" style="grid-column:1/-1;">
          <label class="form-label">Link to Case</label>
          <select class="form-select" id="f-case">
            <option value="">— No case —</option>
          </select>
        </div>
      </div>
      <div class="form-group">
        <label class="form-label">Description</label>
        <textarea class="form-control" id="f-desc" placeholder="Describe the evidence item…"></textarea>
      </div>
    </div>
    <div class="modal-footer">
      <button class="btn btn-secondary" onclick="closeModal('modal-evidence')">Cancel</button>
      <button class="btn btn-primary" onclick="saveEvidence()">💾 Save</button>
    </div>
  </div>
</div>

<!-- DETAIL PANEL -->
<div class="detail-panel" id="detail-panel">
  <div class="detail-panel-header"><span>Evidence Details</span><button class="btn-close-modal" onclick="closePanel('detail-panel')">✕</button></div>
  <div class="detail-panel-body" id="detail-content"></div>
</div>

<script src="/js/app.js"></script>
<script>
let allEvidence = [], allCases = [];

const TYPE_COLORS = {
  Physical: '#e74c3c', Digital: '#3498db', Forensic: '#9b59b6',
  Document: '#f39c12', Biological: '#1abc9c', Witness: '#e67e22'
};

async function loadEvidence() {
  allEvidence = await API.get('/evidence');
  renderTable(allEvidence);
}

async function loadRelations() {
  allCases = await API.get('/cases');
}

function renderTable(data) {
  document.getElementById('count-label').textContent=`${data.length} item${data.length!=1?'s':''}`;
  if(!data.length){document.getElementById('table-body').innerHTML=`<div class="empty-state"><div class="empty-icon">🔬</div><p>No evidence found</p></div>`;return;}
  document.getElementById('table-body').innerHTML=`
    <table>
      <thead><tr><th>#</th><th>Type</th><th>Description</th><th>Collected</th><th>Case</th><th>Actions</th></tr></thead>
      <tbody>${data.map(e=>{
        const col=TYPE_COLORS[e.type]||'#aaa';
        return `<tr>
          <td class="text-muted">${e.evidenceId}</td>
          <td><span class="badge" style="background:${col}22;color:${col};border:1px solid ${col}44;">${e.type}</span></td>
          <td style="max-width:220px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;" title="${e.description||''}">${e.description||'—'}</td>
          <td>${fmtDate(e.collectedDate)}</td>
          <td>${e.crimeCase?`<span class="badge badge-open">Case #${e.crimeCase.caseId}</span>`:'<span class="text-muted">—</span>'}</td>
          <td><div class="action-btns">
            <button class="btn btn-secondary btn-sm btn-icon" onclick="viewDetail(${e.evidenceId})">👁</button>
            <button class="btn btn-warning btn-sm btn-icon" onclick="editEvidence(${e.evidenceId})">✏️</button>
            <button class="btn btn-danger btn-sm btn-icon" onclick="deleteEvidence(${e.evidenceId},'${e.type}')">🗑</button>
          </div></td>
        </tr>`;}).join('')}
      </tbody>
    </table>`;
}

const onSearch = debounce(v=>{renderTable(v?allEvidence.filter(e=>(e.type||'').toLowerCase().includes(v.toLowerCase())):allEvidence);});
function onTypeFilter(v){renderTable(v?allEvidence.filter(e=>e.type===v):allEvidence);}

async function openAddModal() {
  await loadRelations();
  document.getElementById('modal-title').textContent='Add Evidence';
  ['f-id','f-date','f-desc'].forEach(id=>document.getElementById(id).value='');
  document.getElementById('f-type').value='';
  populateCaseSelect(null);
  openModal('modal-evidence');
}

function populateCaseSelect(selectedId) {
  const sel=document.getElementById('f-case');
  sel.innerHTML='<option value="">— No case —</option>';
  allCases.forEach(c=>{
    const opt=document.createElement('option');
    opt.value=c.caseId; opt.textContent=`Case #${c.caseId} (${c.caseStatus})`;
    if(c.caseId==selectedId)opt.selected=true;
    sel.appendChild(opt);
  });
}

async function editEvidence(id) {
  await loadRelations();
  const e=await API.get('/evidence/'+id);
  document.getElementById('modal-title').textContent='Edit Evidence';
  document.getElementById('f-id').value=e.evidenceId;
  document.getElementById('f-type').value=e.type||'';
  document.getElementById('f-date').value=e.collectedDate||'';
  document.getElementById('f-desc').value=e.description||'';
  populateCaseSelect(e.crimeCase?.caseId);
  openModal('modal-evidence');
}

async function saveEvidence() {
  const id=document.getElementById('f-id').value;
  const body={type:document.getElementById('f-type').value.trim(),description:document.getElementById('f-desc').value.trim(),collectedDate:document.getElementById('f-date').value||null};
  if(!body.type){showToast('Evidence type is required','error');return;}
  const caseId=document.getElementById('f-case').value;
  const params=buildParams({caseId:caseId||undefined});
  try{if(id)await API.put('/evidence/'+id,body,params);else await API.post('/evidence',body,params);
    showToast(id?'Evidence updated':'Evidence added','success');closeModal('modal-evidence');loadEvidence();}
  catch(e){showToast('Error saving','error');}
}

async function deleteEvidence(id,type) {
  confirmDelete(`Delete evidence item (${type})?`,async()=>{await API.delete('/evidence/'+id);showToast('Deleted','success');loadEvidence();});
}

async function viewDetail(id) {
  const e=await API.get('/evidence/'+id);
  const col=TYPE_COLORS[e.type]||'#aaa';
  document.getElementById('detail-content').innerHTML=`
    <div class="detail-row"><span class="detail-label">ID</span><span class="detail-value">#${e.evidenceId}</span></div>
    <div class="detail-row"><span class="detail-label">Type</span><span class="detail-value"><span class="badge" style="background:${col}22;color:${col};">${e.type}</span></span></div>
    <div class="detail-row"><span class="detail-label">Collected</span><span class="detail-value">${fmtDate(e.collectedDate)}</span></div>
    <div class="detail-row"><span class="detail-label">Linked Case</span><span class="detail-value">${e.crimeCase?`Case #${e.crimeCase.caseId} (${e.crimeCase.caseStatus})`:'Not linked'}</span></div>
    <div class="detail-section">📝 Description</div>
    <p style="font-size:0.88rem;color:var(--text-muted);line-height:1.7;">${e.description||'No description provided.'}</p>
    <div style="margin-top:2rem;display:flex;gap:0.75rem;">
      <button class="btn btn-warning btn-sm" onclick="editEvidence(${e.evidenceId});closePanel('detail-panel')">✏️ Edit</button>
      <button class="btn btn-danger btn-sm" onclick="deleteEvidence(${e.evidenceId},'${e.type}');closePanel('detail-panel')">🗑 Delete</button>
    </div>`;
  openPanel('detail-panel');
}

loadEvidence();
</script>
</body>
</html>
