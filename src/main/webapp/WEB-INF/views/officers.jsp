<%@ page contentType="text/html;charset=UTF-8" isELIgnored="true" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1.0">
  <title>Police Officers — Crime Management System</title>
  <link rel="stylesheet" href="/css/style.css">
</head>
<body>
<jsp:include page="partials/navbar.jsp"><jsp:param name="active" value="officers"/></jsp:include>
<jsp:include page="partials/common.jsp"/>

<div class="page-container">
  <div class="page-header">
    <div class="page-title"><div class="icon-badge">👮</div>Police Officers</div>
    <button class="btn btn-primary" onclick="openAddModal()">＋ Add Officer</button>
  </div>

  <div class="filter-bar">
    <div class="search-wrap">
      <span class="search-icon">🔍</span>
      <input class="form-control" id="search-input" placeholder="Search by name…" oninput="onSearch(this.value)">
    </div>
    <select class="form-select" style="width:180px;" id="rank-filter" onchange="onRankFilter(this.value)">
      <option value="">All Ranks</option>
      <option>Constable</option><option>Sub-Inspector</option><option>Inspector</option>
      <option>Deputy SP</option><option>Superintendent</option>
    </select>
    <button class="btn btn-secondary" onclick="loadOfficers()">↺ Refresh</button>
  </div>

  <div class="card">
    <div class="card-header"><span>All Officers</span><span class="text-muted text-sm" id="count-label"></span></div>
    <div class="table-wrapper" id="table-body"></div>
  </div>
</div>

<!-- MODAL -->
<div class="modal-overlay" id="modal-officer">
  <div class="modal-box">
    <div class="modal-header">
      <span id="modal-title">Add Officer</span>
      <button class="btn-close-modal" onclick="closeModal('modal-officer')">✕</button>
    </div>
    <div class="modal-body">
      <input type="hidden" id="f-id">
      <div class="form-grid-2">
        <div class="form-group"><label class="form-label">Full Name *</label><input class="form-control" id="f-name" placeholder="Officer name"></div>
        <div class="form-group">
          <label class="form-label">Rank</label>
          <select class="form-select" id="f-rank">
            <option value="">Select rank</option>
            <option>Constable</option><option>Sub-Inspector</option><option>Inspector</option><option>Deputy SP</option><option>Superintendent</option>
          </select>
        </div>
        <div class="form-group"><label class="form-label">Badge Number</label><input class="form-control" id="f-badge" placeholder="e.g. HYD-001"></div>
        <div class="form-group"><label class="form-label">Contact Number</label><input class="form-control" id="f-contact" placeholder="Phone"></div>
      </div>
    </div>
    <div class="modal-footer">
      <button class="btn btn-secondary" onclick="closeModal('modal-officer')">Cancel</button>
      <button class="btn btn-primary" onclick="saveOfficer()">💾 Save</button>
    </div>
  </div>
</div>

<!-- DETAIL PANEL -->
<div class="detail-panel" id="detail-panel">
  <div class="detail-panel-header"><span>Officer Details</span><button class="btn-close-modal" onclick="closePanel('detail-panel')">✕</button></div>
  <div class="detail-panel-body" id="detail-content"></div>
</div>

<script src="/js/app.js"></script>
<script>
let allOfficers = [];

async function loadOfficers() {
  allOfficers = await API.get('/officers');
  renderTable(allOfficers);
}

function renderTable(data) {
  document.getElementById('count-label').textContent=`${data.length} record${data.length!=1?'s':''}`;
  if(!data.length){document.getElementById('table-body').innerHTML=`<div class="empty-state"><div class="empty-icon">👮</div><p>No officers found</p></div>`;return;}
  document.getElementById('table-body').innerHTML=`
    <table>
      <thead><tr><th>#</th><th>Name</th><th>Rank</th><th>Badge</th><th>Contact</th><th>Cases</th><th>Actions</th></tr></thead>
      <tbody>${data.map(o=>`
        <tr>
          <td class="text-muted">${o.officerId}</td>
          <td><strong>${o.name}</strong></td>
          <td><span class="badge" style="background:rgba(41,128,185,0.15);color:#5dade2;">${o.rank||'—'}</span></td>
          <td class="text-muted">${o.badgeNumber||'—'}</td>
          <td class="text-muted">${o.contactNumber||'—'}</td>
          <td>${(o.cases||[]).length}</td>
          <td><div class="action-btns">
            <button class="btn btn-secondary btn-sm btn-icon" onclick="viewDetail(${o.officerId})">👁</button>
            <button class="btn btn-warning btn-sm btn-icon" onclick="editOfficer(${o.officerId})">✏️</button>
            <button class="btn btn-danger btn-sm btn-icon" onclick="deleteOfficer(${o.officerId},'${o.name}')">🗑</button>
          </div></td>
        </tr>`).join('')}
      </tbody>
    </table>`;
}

const onSearch = debounce(v=>{renderTable(v.trim()?allOfficers.filter(o=>o.name.toLowerCase().includes(v.toLowerCase())):allOfficers);});
function onRankFilter(v){renderTable(v?allOfficers.filter(o=>o.rank===v):allOfficers);}

function openAddModal(){
  document.getElementById('modal-title').textContent='Add Officer';
  ['f-id','f-name','f-badge','f-contact'].forEach(id=>document.getElementById(id).value='');
  document.getElementById('f-rank').value='';
  openModal('modal-officer');
}

async function editOfficer(id){
  const o=await API.get('/officers/'+id);
  document.getElementById('modal-title').textContent='Edit Officer';
  document.getElementById('f-id').value=o.officerId;
  document.getElementById('f-name').value=o.name||'';
  document.getElementById('f-rank').value=o.rank||'';
  document.getElementById('f-badge').value=o.badgeNumber||'';
  document.getElementById('f-contact').value=o.contactNumber||'';
  openModal('modal-officer');
}

async function saveOfficer(){
  const id=document.getElementById('f-id').value;
  const body={name:document.getElementById('f-name').value.trim(),rank:document.getElementById('f-rank').value,badgeNumber:document.getElementById('f-badge').value.trim(),contactNumber:document.getElementById('f-contact').value.trim()};
  if(!body.name){showToast('Name is required','error');return;}
  try{if(id)await API.put('/officers/'+id,body);else await API.post('/officers',body);
    showToast(id?'Officer updated':'Officer added','success');closeModal('modal-officer');loadOfficers();}
  catch(e){showToast('Error saving','error');}
}

async function deleteOfficer(id,name){
  confirmDelete(`Delete officer "${name}"?`,async()=>{await API.delete('/officers/'+id);showToast('Deleted','success');loadOfficers();});
}

async function viewDetail(id){
  const o=await API.get('/officers/'+id);
  const cases=o.cases||[];
  document.getElementById('detail-content').innerHTML=`
    <div class="detail-row"><span class="detail-label">ID</span><span class="detail-value">#${o.officerId}</span></div>
    <div class="detail-row"><span class="detail-label">Name</span><span class="detail-value"><strong>${o.name}</strong></span></div>
    <div class="detail-row"><span class="detail-label">Rank</span><span class="detail-value">${o.rank||'—'}</span></div>
    <div class="detail-row"><span class="detail-label">Badge</span><span class="detail-value">${o.badgeNumber||'—'}</span></div>
    <div class="detail-row"><span class="detail-label">Contact</span><span class="detail-value">${o.contactNumber||'—'}</span></div>
    <div class="detail-section">📁 Assigned Cases (${cases.length})</div>
    <div>${cases.map(c=>`<span class="relation-tag">📁 Case #${c.caseId} ${statusBadge(c.caseStatus)}</span>`).join('')||'<p class="text-muted text-sm">None assigned</p>'}</div>
    <div style="margin-top:2rem;display:flex;gap:0.75rem;">
      <button class="btn btn-warning btn-sm" onclick="editOfficer(${o.officerId});closePanel('detail-panel')">✏️ Edit</button>
      <button class="btn btn-danger btn-sm" onclick="deleteOfficer(${o.officerId},'${o.name}');closePanel('detail-panel')">🗑 Delete</button>
    </div>`;
  openPanel('detail-panel');
}

loadOfficers();
</script>
</body>
</html>
