<%@ page contentType="text/html;charset=UTF-8" isELIgnored="true" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1.0">
  <title>Victims — Crime Management System</title>
  <link rel="stylesheet" href="/css/style.css">
</head>
<body>
<jsp:include page="partials/navbar.jsp"><jsp:param name="active" value="victims"/></jsp:include>
<jsp:include page="partials/common.jsp"/>

<div class="page-container">
  <div class="page-header">
    <div class="page-title"><div class="icon-badge">🩺</div>Victim Records</div>
    <button class="btn btn-primary" onclick="openAddModal()">＋ Add Victim</button>
  </div>

  <div class="filter-bar">
    <div class="search-wrap">
      <span class="search-icon">🔍</span>
      <input class="form-control" id="search-input" placeholder="Search by name…" oninput="onSearch(this.value)">
    </div>
    <select class="form-select" style="width:160px;" id="gender-filter" onchange="onGenderFilter(this.value)">
      <option value="">All Genders</option><option value="Male">Male</option><option value="Female">Female</option><option value="Other">Other</option>
    </select>
    <button class="btn btn-secondary" onclick="loadVictims()">↺ Refresh</button>
  </div>

  <div class="card">
    <div class="card-header"><span>All Victims</span><span class="text-muted text-sm" id="count-label"></span></div>
    <div class="table-wrapper" id="table-body"></div>
  </div>
</div>

<!-- MODAL -->
<div class="modal-overlay" id="modal-victim">
  <div class="modal-box">
    <div class="modal-header">
      <span id="modal-title">Add Victim</span>
      <button class="btn-close-modal" onclick="closeModal('modal-victim')">✕</button>
    </div>
    <div class="modal-body">
      <input type="hidden" id="f-id">
      <div class="form-grid-2">
        <div class="form-group"><label class="form-label">Full Name *</label><input class="form-control" id="f-name" placeholder="Name"></div>
        <div class="form-group"><label class="form-label">Age</label><input class="form-control" id="f-age" type="number" min="1" placeholder="Age"></div>
        <div class="form-group">
          <label class="form-label">Gender</label>
          <select class="form-select" id="f-gender">
            <option value="">Select</option><option value="Male">Male</option><option value="Female">Female</option><option value="Other">Other</option>
          </select>
        </div>
        <div class="form-group"><label class="form-label">Contact Info</label><input class="form-control" id="f-contact" placeholder="Phone / Email"></div>
      </div>
    </div>
    <div class="modal-footer">
      <button class="btn btn-secondary" onclick="closeModal('modal-victim')">Cancel</button>
      <button class="btn btn-primary" onclick="saveVictim()">💾 Save</button>
    </div>
  </div>
</div>

<!-- DETAIL PANEL -->
<div class="detail-panel" id="detail-panel">
  <div class="detail-panel-header"><span>Victim Details</span><button class="btn-close-modal" onclick="closePanel('detail-panel')">✕</button></div>
  <div class="detail-panel-body" id="detail-content"></div>
</div>

<script src="/js/app.js"></script>
<script>
let allVictims = [];

async function loadVictims() {
  allVictims = await API.get('/victims');
  renderTable(allVictims);
}

function renderTable(data) {
  document.getElementById('count-label').textContent = `${data.length} record${data.length!=1?'s':''}`;
  if (!data.length) { document.getElementById('table-body').innerHTML = `<div class="empty-state"><div class="empty-icon">🩺</div><p>No victims found</p></div>`; return; }
  document.getElementById('table-body').innerHTML = `
    <table>
      <thead><tr><th>#</th><th>Name</th><th>Age</th><th>Gender</th><th>Contact</th><th>Crimes Involved</th><th>Actions</th></tr></thead>
      <tbody>${data.map(v=>`
        <tr>
          <td class="text-muted">${v.victimId}</td>
          <td><strong>${v.name}</strong></td>
          <td>${v.age||'—'}</td>
          <td>${v.gender?genderBadge(v.gender):'—'}</td>
          <td class="text-muted">${v.contactInfo||'—'}</td>
          <td>${(v.crimes||[]).length}</td>
          <td><div class="action-btns">
            <button class="btn btn-secondary btn-sm btn-icon" onclick="viewDetail(${v.victimId})">👁</button>
            <button class="btn btn-warning btn-sm btn-icon" onclick="editVictim(${v.victimId})">✏️</button>
            <button class="btn btn-danger btn-sm btn-icon" onclick="deleteVictim(${v.victimId},'${v.name}')">🗑</button>
          </div></td>
        </tr>`).join('')}
      </tbody>
    </table>`;
}

const onSearch = debounce(v => { renderTable(v.trim() ? allVictims.filter(x=>x.name.toLowerCase().includes(v.toLowerCase())) : allVictims); });
function onGenderFilter(v) { renderTable(v ? allVictims.filter(x=>x.gender===v) : allVictims); }

function openAddModal() {
  document.getElementById('modal-title').textContent='Add Victim';
  ['f-id','f-name','f-age','f-contact'].forEach(id=>document.getElementById(id).value='');
  document.getElementById('f-gender').value='';
  openModal('modal-victim');
}

async function editVictim(id) {
  const v = await API.get('/victims/'+id);
  document.getElementById('modal-title').textContent='Edit Victim';
  document.getElementById('f-id').value=v.victimId;
  document.getElementById('f-name').value=v.name||'';
  document.getElementById('f-age').value=v.age||'';
  document.getElementById('f-gender').value=v.gender||'';
  document.getElementById('f-contact').value=v.contactInfo||'';
  openModal('modal-victim');
}

async function saveVictim() {
  const id=document.getElementById('f-id').value;
  const body={name:document.getElementById('f-name').value.trim(),age:+document.getElementById('f-age').value||null,gender:document.getElementById('f-gender').value,contactInfo:document.getElementById('f-contact').value.trim()};
  if(!body.name){showToast('Name is required','error');return;}
  try {
    if(id) await API.put('/victims/'+id,body); else await API.post('/victims',body);
    showToast(id?'Victim updated':'Victim added','success');
    closeModal('modal-victim'); loadVictims();
  } catch(e){showToast('Error saving','error');}
}

async function deleteVictim(id,name) {
  confirmDelete(`Delete victim "${name}"?`, async()=>{await API.delete('/victims/'+id);showToast('Deleted','success');loadVictims();});
}

async function viewDetail(id) {
  const v=await API.get('/victims/'+id);
  const crimes=v.crimes||[];
  document.getElementById('detail-content').innerHTML=`
    <div class="detail-row"><span class="detail-label">ID</span><span class="detail-value">#${v.victimId}</span></div>
    <div class="detail-row"><span class="detail-label">Name</span><span class="detail-value"><strong>${v.name}</strong></span></div>
    <div class="detail-row"><span class="detail-label">Age</span><span class="detail-value">${v.age||'—'}</span></div>
    <div class="detail-row"><span class="detail-label">Gender</span><span class="detail-value">${v.gender?genderBadge(v.gender):'—'}</span></div>
    <div class="detail-row"><span class="detail-label">Contact</span><span class="detail-value">${v.contactInfo||'—'}</span></div>
    <div class="detail-section">🔪 Crimes Involved (${crimes.length})</div>
    <div>${crimes.map(c=>`<span class="relation-tag">🔪 ${c.crimeType} — ${fmtDate(c.date)}</span>`).join('')||'<p class="text-muted text-sm">None</p>'}</div>
    <div style="margin-top:2rem;display:flex;gap:0.75rem;">
      <button class="btn btn-warning btn-sm" onclick="editVictim(${v.victimId});closePanel('detail-panel')">✏️ Edit</button>
      <button class="btn btn-danger btn-sm" onclick="deleteVictim(${v.victimId},'${v.name}');closePanel('detail-panel')">🗑 Delete</button>
    </div>`;
  openPanel('detail-panel');
}

loadVictims();
</script>
</body>
</html>
