/* ═══════════════════════════════════════════════════════════════
   CRIME MANAGEMENT SYSTEM — Core JavaScript
═══════════════════════════════════════════════════════════════ */

const API = {
  BASE: '/api',
  get:    (url)       => fetch(API.BASE + url).then(r => r.json()),
  post:   (url, data, params='') => fetch(API.BASE + url + params, { method:'POST',   headers:{'Content-Type':'application/json'}, body: JSON.stringify(data) }).then(r => r.json()),
  put:    (url, data, params='') => fetch(API.BASE + url + params, { method:'PUT',    headers:{'Content-Type':'application/json'}, body: JSON.stringify(data) }).then(r => r.json()),
  delete: (url)       => fetch(API.BASE + url, { method:'DELETE' }).then(r => r.json()),
};

// ── Toast ─────────────────────────────────────────────────────
function showToast(message, type = 'success') {
  const icons = { success: '✅', error: '❌', warning: '⚠️', info: 'ℹ️' };
  const container = document.getElementById('toast-container') || (() => {
    const div = document.createElement('div');
    div.id = 'toast-container';
    div.className = 'toast-container';
    document.body.appendChild(div);
    return div;
  })();

  const toast = document.createElement('div');
  toast.className = `toast ${type}`;
  toast.innerHTML = `<span>${icons[type]}</span><span>${message}</span>`;
  container.appendChild(toast);

  setTimeout(() => {
    toast.style.opacity = '0';
    toast.style.transform = 'translateX(40px)';
    toast.style.transition = 'all 0.3s ease';
    setTimeout(() => toast.remove(), 300);
  }, 3500);
}

// ── Modal helpers ─────────────────────────────────────────────
function openModal(id) {
  const m = document.getElementById(id);
  if (m) m.classList.add('active');
}

function closeModal(id) {
  const m = document.getElementById(id);
  if (m) { m.classList.remove('active'); }
}

// Close on overlay click
document.addEventListener('click', e => {
  if (e.target.classList.contains('modal-overlay')) {
    e.target.classList.remove('active');
  }
});

// Escape key closes modals
document.addEventListener('keydown', e => {
  if (e.key === 'Escape') {
    document.querySelectorAll('.modal-overlay.active').forEach(m => m.classList.remove('active'));
    document.querySelectorAll('.detail-panel.open').forEach(p => p.classList.remove('open'));
  }
});

// ── Confirm Dialog ────────────────────────────────────────────
function confirmDelete(message, onConfirm) {
  const overlay = document.getElementById('confirm-overlay');
  const msgEl = document.getElementById('confirm-message');
  if (msgEl) msgEl.textContent = message;
  if (overlay) overlay.classList.add('active');

  window._pendingConfirm = onConfirm;
}

document.addEventListener('DOMContentLoaded', () => {
  const yesBtn = document.getElementById('confirm-yes');
  const noBtn  = document.getElementById('confirm-no');

  if (yesBtn) yesBtn.addEventListener('click', () => {
    if (window._pendingConfirm) window._pendingConfirm();
    document.getElementById('confirm-overlay').classList.remove('active');
    window._pendingConfirm = null;
  });

  if (noBtn) noBtn.addEventListener('click', () => {
    document.getElementById('confirm-overlay').classList.remove('active');
    window._pendingConfirm = null;
  });
});

// ── Detail Panel ──────────────────────────────────────────────
function openPanel(id) {
  document.getElementById(id)?.classList.add('open');
}
function closePanel(id) {
  document.getElementById(id)?.classList.remove('open');
}

// ── Search debounce ───────────────────────────────────────────
function debounce(fn, delay = 300) {
  let t;
  return (...args) => { clearTimeout(t); t = setTimeout(() => fn(...args), delay); };
}

// ── Format date ───────────────────────────────────────────────
function fmtDate(d) {
  if (!d) return '—';
  return new Date(d).toLocaleDateString('en-IN', { day:'2-digit', month:'short', year:'numeric' });
}

// ── Status badge HTML ─────────────────────────────────────────
function statusBadge(status) {
  const map = {
    'OPEN':               'badge-open',
    'CLOSED':             'badge-closed',
    'PENDING':            'badge-pending',
    'UNDER_INVESTIGATION':'badge-investigation'
  };
  const label = (status || '').replace('_', ' ');
  return `<span class="badge ${map[status] || ''}">${label}</span>`;
}

function genderBadge(g) {
  const map = { Male: 'badge-male', Female: 'badge-female', Other: 'badge-other' };
  return `<span class="badge ${map[g] || ''}">${g || '—'}</span>`;
}

// ── Build query string from params object ─────────────────────
function buildParams(obj) {
  const p = Object.entries(obj).filter(([,v]) => v != null && v !== '').map(([k,v]) => `${k}=${encodeURIComponent(v)}`);
  return p.length ? '?' + p.join('&') : '';
}

// ── Multi-select checkbox list helper ─────────────────────────
function renderCheckList(containerId, items, selectedIds = [], idKey, labelKey) {
  const el = document.getElementById(containerId);
  if (!el) return;
  if (!items.length) { el.innerHTML = '<p class="text-muted text-sm">No items available</p>'; return; }
  el.innerHTML = items.map(item => `
    <label style="display:flex;align-items:center;gap:0.5rem;padding:0.4rem 0;cursor:pointer;font-size:0.88rem;">
      <input type="checkbox" value="${item[idKey]}" ${selectedIds.includes(item[idKey]) ? 'checked' : ''}
             style="accent-color:var(--crimson);">
      ${item[labelKey]}
    </label>`).join('');
}

function getChecked(containerId) {
  return [...document.querySelectorAll(`#${containerId} input[type=checkbox]:checked`)].map(c => +c.value);
}
