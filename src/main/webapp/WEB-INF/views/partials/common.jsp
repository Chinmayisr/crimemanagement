<%@ page contentType="text/html;charset=UTF-8" isELIgnored="true" %>
<!-- Confirm Dialog -->
<div class="modal-overlay" id="confirm-overlay">
  <div class="confirm-dialog">
    <div class="confirm-icon">⚠️</div>
    <h3>Confirm Delete</h3>
    <p id="confirm-message">Are you sure you want to delete this record? This action cannot be undone.</p>
    <div class="btns">
      <button class="btn btn-secondary" id="confirm-no">Cancel</button>
      <button class="btn btn-danger" id="confirm-yes">Delete</button>
    </div>
  </div>
</div>

<!-- Toast Container -->
<div class="toast-container" id="toast-container"></div>
