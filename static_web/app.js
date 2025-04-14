// Current active tab
let currentTab = 'tasks';

// Initialize the app
document.addEventListener('DOMContentLoaded', function() {
  // Set up tab navigation
  setupTabs();
  
  // Initialize the FAB (Floating Action Button)
  initFAB();
  
  // Render initial content
  renderActiveTab();
});

// Show snackbar message
function showSnackbar(message) {
  const snackbar = document.getElementById('snackbar');
  snackbar.textContent = message;
  snackbar.classList.add('show');
  
  setTimeout(() => {
    snackbar.classList.remove('show');
  }, 3000);
}

// Set up tab navigation
function setupTabs() {
  const navItems = document.querySelectorAll('.nav-item');
  
  navItems.forEach(item => {
    item.addEventListener('click', function() {
      // Get the tab name from data attribute
      const tabName = this.dataset.tab;
      if (tabName === currentTab) return;
      
      // Update active tab
      currentTab = tabName;
      
      // Update active nav item
      navItems.forEach(navItem => {
        navItem.classList.toggle('active', navItem.dataset.tab === currentTab);
      });
      
      // Render the active tab content
      renderActiveTab();
    });
  });
}

// Initialize the FAB
function initFAB() {
  const fab = document.getElementById('fab');
  
  fab.addEventListener('click', function() {
    // Handle click based on current tab
    switch (currentTab) {
      case 'tasks':
        if (typeof showTaskForm === 'function') {
          showTaskForm();
        } else {
          showSnackbar('Add new task feature coming soon');
        }
        break;
      case 'calendar':
        showSnackbar('Calendar event creation coming soon');
        break;
      case 'notes':
        if (typeof showNoteForm === 'function') {
          showNoteForm();
        } else {
          showSnackbar('Add new note feature coming soon');
        }
        break;
      case 'reminders':
        if (typeof showReminderForm === 'function') {
          showReminderForm();
        } else {
          showSnackbar('Add new reminder feature coming soon');
        }
        break;
      case 'settings':
        showSnackbar('Settings feature coming soon');
        break;
    }
  });
}

// Render the active tab content
function renderActiveTab() {
  // Create tab content containers if they don't exist
  const mainContent = document.getElementById('main-content');
  const existingTabs = mainContent.querySelectorAll('.tab-content');
  
  if (existingTabs.length === 0) {
    // Create tab content containers if none exist
    const tabs = ['tasks', 'calendar', 'notes', 'reminders', 'settings'];
    tabs.forEach(tab => {
      const tabContent = document.createElement('div');
      tabContent.className = 'tab-content';
      tabContent.dataset.tab = tab;
      mainContent.appendChild(tabContent);
    });
  }
  
  // Hide all tab content
  document.querySelectorAll('.tab-content').forEach(tab => {
    tab.classList.remove('active');
  });
  
  // Show active tab content
  const activeTab = document.querySelector(`.tab-content[data-tab="${currentTab}"]`);
  if (activeTab) {
    activeTab.classList.add('active');
    
    // Generate content based on active tab
    switch (currentTab) {
      case 'tasks':
        if (typeof renderTasks === 'function' && activeTab.innerHTML === '') {
          renderTasks();
        } else if (activeTab.innerHTML === '') {
          activeTab.innerHTML = getPlaceholderContent('Tasks', 'Manage your tasks with priorities and reminders', 'task_alt', '#4285f4');
        }
        break;
      case 'calendar':
        if (typeof renderCalendar === 'function') {
          renderCalendar();
        } else if (activeTab.innerHTML === '') {
          activeTab.innerHTML = getPlaceholderContent('Calendar', 'View your tasks in different calendar formats', 'calendar_today', '#0f9d58');
        }
        break;
      case 'notes':
        if (typeof renderNotes === 'function' && activeTab.innerHTML === '') {
          renderNotes();
        } else if (activeTab.innerHTML === '') {
          activeTab.innerHTML = getPlaceholderContent('Notes', 'Create and manage your notes', 'note', '#f4b400');
        }
        break;
      case 'reminders':
        if (typeof renderReminders === 'function' && activeTab.innerHTML === '') {
          renderReminders();
        } else if (activeTab.innerHTML === '') {
          activeTab.innerHTML = getPlaceholderContent('Reminders', 'Set up different types of reminders', 'alarm', '#db4437');
        }
        break;
      case 'settings':
        if (activeTab.innerHTML === '') {
          activeTab.innerHTML = getSettingsContent();
        }
        break;
    }
  }
}

// Generate placeholder content
function getPlaceholderContent(title, description, icon, color) {
  return `
    <div class="tab-placeholder">
      <div class="placeholder-icon" style="color: ${color}">
        <i class="material-icons" style="font-size: 72px;">${icon}</i>
      </div>
      <h2 class="placeholder-title">${title}</h2>
      <p class="placeholder-description">${description}</p>
    </div>
  `;
}

// Generate settings content
function getSettingsContent() {
  return `
    <div class="settings-container">
      <h2 class="tab-section-title">Settings</h2>
      
      <div class="settings-section">
        <h3>Appearance</h3>
        <div class="settings-option">
          <div class="settings-label">
            <div class="settings-name">Theme</div>
            <div class="settings-description">Choose between light and dark mode</div>
          </div>
          <select id="theme-selector">
            <option value="light">Light</option>
            <option value="dark">Dark (Coming Soon)</option>
          </select>
        </div>
      </div>
      
      <div class="settings-section">
        <h3>Calendar</h3>
        <div class="settings-option">
          <div class="settings-label">
            <div class="settings-name">Default Calendar</div>
            <div class="settings-description">Set your preferred calendar type</div>
          </div>
          <select id="default-calendar">
            <option value="gregorian">Gregorian</option>
            <option value="nepali">Nepali</option>
            <option value="chinese">Chinese</option>
            <option value="islamic">Islamic</option>
          </select>
        </div>
      </div>
      
      <div class="settings-section">
        <h3>Notifications</h3>
        <div class="settings-option">
          <div class="settings-label">
            <div class="settings-name">Enable Notifications</div>
            <div class="settings-description">Get notified about upcoming tasks and reminders</div>
          </div>
          <label class="switch">
            <input type="checkbox" id="notifications-toggle" checked>
            <span class="slider round"></span>
          </label>
        </div>
        <div class="settings-option">
          <div class="settings-label">
            <div class="settings-name">Notification Sound</div>
            <div class="settings-description">Choose notification sound</div>
          </div>
          <select id="notification-sound">
            <option value="default">Default</option>
            <option value="bell">Bell</option>
            <option value="chime">Chime</option>
          </select>
        </div>
      </div>
      
      <div class="settings-section">
        <h3>About</h3>
        <div class="settings-option">
          <div class="settings-label">
            <div class="settings-name">Version</div>
            <div class="settings-description">Current version of the app</div>
          </div>
          <div>1.0.0</div>
        </div>
      </div>
    </div>
  `;
}