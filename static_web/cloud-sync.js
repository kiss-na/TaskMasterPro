/**
 * Cloud Sync Service for Task Manager
 * Handles synchronization of tasks, notes, and reminders to the cloud
 */

// Cloud Sync Configuration
const CloudSync = {
  // Authentication state
  auth: {
    isAuthenticated: false,
    user: null,
    lastSyncTime: null
  },
  
  // Initialize the cloud sync service
  init: function() {
    // Check if the user is already authenticated
    this.checkAuthentication();
    
    // Set up sync status indicators
    this.setupSyncUI();
    
    // Set up event listeners
    this.setupEventListeners();
    
    console.log('Cloud Sync service initialized');
  },
  
  // Check if the user is already authenticated
  checkAuthentication: function() {
    // Check for stored auth data
    const userData = localStorage.getItem('cloudSyncUser');
    
    if (userData) {
      try {
        const parsedData = JSON.parse(userData);
        
        // Validate token expiration
        if (parsedData && parsedData.expiresAt > Date.now()) {
          this.auth.isAuthenticated = true;
          this.auth.user = parsedData;
          this.updateSyncStatus('connected');
          
          console.log('User is already authenticated:', parsedData.email);
          
          // Schedule auto-sync
          this.scheduleAutoSync();
          
          // Update last sync display time
          if (parsedData.lastSyncTime) {
            this.auth.lastSyncTime = parsedData.lastSyncTime;
            this.updateLastSyncTime();
          }
        } else {
          // Token expired, clear authentication
          this.signOut(false);
        }
      } catch (error) {
        console.error('Error parsing auth data:', error);
        this.signOut(false);
      }
    }
  },
  
  // Set up sync status indicators
  setupSyncUI: function() {
    // Create sync status indicators if they don't exist
    if (!document.querySelector('.sync-status')) {
      const header = document.querySelector('.app-header');
      if (header) {
        const syncStatusHTML = `
          <div class="sync-status">
            <span class="sync-status-icon" title="Not connected to cloud">
              <i class="material-icons">cloud_off</i>
            </span>
            <div class="sync-dropdown">
              <div class="sync-dropdown-header">
                <span class="sync-status-text">Cloud Sync</span>
                <span class="sync-last-time"></span>
              </div>
              <div class="sync-dropdown-content">
                <div class="sync-user-info"></div>
                <button class="sync-action-btn" id="sync-now-btn">Sync Now</button>
                <button class="sync-action-btn" id="sync-settings-btn">Settings</button>
                <button class="sync-action-btn" id="sync-sign-in-btn">Sign In</button>
                <button class="sync-action-btn" id="sync-sign-out-btn">Sign Out</button>
              </div>
            </div>
          </div>
        `;
        
        // Insert the sync status indicator
        const div = document.createElement('div');
        div.innerHTML = syncStatusHTML;
        header.appendChild(div.firstElementChild);
        
        // Update sync status based on current auth state
        this.updateSyncStatus(this.auth.isAuthenticated ? 'connected' : 'disconnected');
      }
    }
  },
  
  // Set up event listeners for sync-related actions
  setupEventListeners: function() {
    // Toggle sync dropdown
    document.addEventListener('click', (e) => {
      if (e.target.closest('.sync-status-icon')) {
        document.querySelector('.sync-dropdown').classList.toggle('active');
      } else if (!e.target.closest('.sync-dropdown')) {
        document.querySelector('.sync-dropdown')?.classList.remove('active');
      }
    });
    
    // Sync now button
    document.getElementById('sync-now-btn')?.addEventListener('click', () => {
      if (this.auth.isAuthenticated) {
        this.syncData();
      } else {
        this.showSignInModal();
      }
    });
    
    // Settings button
    document.getElementById('sync-settings-btn')?.addEventListener('click', () => {
      this.showSyncSettings();
    });
    
    // Sign in button
    document.getElementById('sync-sign-in-btn')?.addEventListener('click', () => {
      this.showSignInModal();
    });
    
    // Sign out button
    document.getElementById('sync-sign-out-btn')?.addEventListener('click', () => {
      this.signOut();
    });
  },
  
  // Update the sync status indicator
  updateSyncStatus: function(status) {
    const statusIcon = document.querySelector('.sync-status-icon');
    const signInBtn = document.getElementById('sync-sign-in-btn');
    const signOutBtn = document.getElementById('sync-sign-out-btn');
    const syncNowBtn = document.getElementById('sync-now-btn');
    const userInfo = document.querySelector('.sync-user-info');
    
    if (!statusIcon) return;
    
    switch (status) {
      case 'connected':
        statusIcon.innerHTML = '<i class="material-icons">cloud_done</i>';
        statusIcon.title = 'Connected to cloud';
        statusIcon.classList.remove('syncing', 'error');
        
        if (signInBtn) signInBtn.style.display = 'none';
        if (signOutBtn) signOutBtn.style.display = 'block';
        if (syncNowBtn) syncNowBtn.disabled = false;
        
        // Display user info
        if (userInfo && this.auth.user) {
          userInfo.innerHTML = `
            <div class="user-avatar">${this.auth.user.email.charAt(0).toUpperCase()}</div>
            <div class="user-details">
              <div class="user-email">${this.auth.user.email}</div>
            </div>
          `;
          userInfo.style.display = 'flex';
        }
        break;
        
      case 'syncing':
        statusIcon.innerHTML = '<i class="material-icons rotating">sync</i>';
        statusIcon.title = 'Syncing...';
        statusIcon.classList.add('syncing');
        statusIcon.classList.remove('error');
        if (syncNowBtn) syncNowBtn.disabled = true;
        break;
        
      case 'error':
        statusIcon.innerHTML = '<i class="material-icons">cloud_off</i>';
        statusIcon.title = 'Sync error';
        statusIcon.classList.add('error');
        statusIcon.classList.remove('syncing');
        if (syncNowBtn) syncNowBtn.disabled = false;
        break;
        
      case 'disconnected':
      default:
        statusIcon.innerHTML = '<i class="material-icons">cloud_off</i>';
        statusIcon.title = 'Not connected to cloud';
        statusIcon.classList.remove('syncing', 'error');
        
        if (signInBtn) signInBtn.style.display = 'block';
        if (signOutBtn) signOutBtn.style.display = 'none';
        if (syncNowBtn) syncNowBtn.disabled = true;
        
        // Hide user info
        if (userInfo) {
          userInfo.style.display = 'none';
          userInfo.innerHTML = '';
        }
        break;
    }
  },
  
  // Update last sync time display
  updateLastSyncTime: function() {
    const lastSyncElement = document.querySelector('.sync-last-time');
    if (!lastSyncElement || !this.auth.lastSyncTime) return;
    
    const lastSync = new Date(this.auth.lastSyncTime);
    const now = new Date();
    
    let timeText;
    const secondsAgo = Math.floor((now - lastSync) / 1000);
    
    if (secondsAgo < 60) {
      timeText = 'Synced just now';
    } else if (secondsAgo < 3600) {
      const minutes = Math.floor(secondsAgo / 60);
      timeText = `Synced ${minutes} minute${minutes > 1 ? 's' : ''} ago`;
    } else if (secondsAgo < 86400) {
      const hours = Math.floor(secondsAgo / 3600);
      timeText = `Synced ${hours} hour${hours > 1 ? 's' : ''} ago`;
    } else {
      timeText = `Synced on ${lastSync.toLocaleDateString()}`;
    }
    
    lastSyncElement.textContent = timeText;
  },
  
  // Schedule automatic sync
  scheduleAutoSync: function() {
    // Clear any existing sync timer
    if (this.syncTimer) {
      clearInterval(this.syncTimer);
    }
    
    // Set up auto-sync every 5 minutes for authenticated users
    if (this.auth.isAuthenticated) {
      this.syncTimer = setInterval(() => {
        this.syncData();
      }, 5 * 60 * 1000); // 5 minutes
    }
  },
  
  // Sync data with the cloud
  syncData: async function() {
    if (!this.auth.isAuthenticated) {
      console.log('Cannot sync: User not authenticated');
      return;
    }
    
    // Update status to syncing
    this.updateSyncStatus('syncing');
    
    try {
      // Get all local data
      const tasks = localStorage.getItem('tasks') ? JSON.parse(localStorage.getItem('tasks')) : [];
      const notes = localStorage.getItem('notes') ? JSON.parse(localStorage.getItem('notes')) : [];
      const reminders = localStorage.getItem('reminders') ? JSON.parse(localStorage.getItem('reminders')) : [];
      
      // Simulated server communication (in a real app, this would be an API call)
      await new Promise(resolve => setTimeout(resolve, 1500)); // Simulate network delay
      
      // In a real implementation, we would merge server data with local data here
      
      // Update last sync time
      this.auth.lastSyncTime = Date.now();
      
      // Store the updated last sync time
      const userData = JSON.parse(localStorage.getItem('cloudSyncUser'));
      userData.lastSyncTime = this.auth.lastSyncTime;
      localStorage.setItem('cloudSyncUser', JSON.stringify(userData));
      
      // Update the last sync display
      this.updateLastSyncTime();
      
      // Update status to connected
      this.updateSyncStatus('connected');
      
      // Show success message
      showSnackbar('Data synced to cloud');
      
      console.log('Sync completed successfully');
    } catch (error) {
      console.error('Sync error:', error);
      
      // Update status to error
      this.updateSyncStatus('error');
      
      // Show error message
      showSnackbar('Sync failed, please try again');
    }
  },
  
  // Show the sign-in modal
  showSignInModal: function() {
    // Create the sign-in modal
    const modalHTML = `
      <div class="modal-overlay" id="sync-sign-in-modal">
        <div class="modal-content">
          <div class="modal-header">
            <h2>Sign In to Cloud Sync</h2>
            <button class="modal-close-btn"><i class="material-icons">close</i></button>
          </div>
          <div class="modal-body">
            <form id="sync-sign-in-form">
              <div class="form-group">
                <input type="email" id="sync-email" placeholder="Email address" required>
              </div>
              <div class="form-group">
                <input type="password" id="sync-password" placeholder="Password" required>
              </div>
              <div class="form-actions">
                <button type="button" class="btn-cancel">Cancel</button>
                <button type="submit" class="btn-save">Sign In</button>
              </div>
            </form>
            <div class="sign-in-divider"><span>or</span></div>
            <div class="sign-in-providers">
              <button class="provider-btn provider-google">
                <img src="https://developers.google.com/identity/images/g-logo.png" alt="Google" width="18" height="18">
                Sign in with Google
              </button>
            </div>
          </div>
        </div>
      </div>
    `;
    
    // Add modal to body
    const modalContainer = document.createElement('div');
    modalContainer.innerHTML = modalHTML;
    document.body.appendChild(modalContainer);
    
    // Add event listeners
    document.querySelector('#sync-sign-in-modal .modal-close-btn').addEventListener('click', () => {
      this.closeSignInModal();
    });
    
    document.querySelector('#sync-sign-in-modal .btn-cancel').addEventListener('click', () => {
      this.closeSignInModal();
    });
    
    document.getElementById('sync-sign-in-form').addEventListener('submit', (e) => {
      e.preventDefault();
      this.handleSignIn();
    });
    
    document.querySelector('.provider-google').addEventListener('click', () => {
      this.handleProviderSignIn('google');
    });
    
    // Show modal with animation
    setTimeout(() => {
      document.getElementById('sync-sign-in-modal').classList.add('active');
    }, 10);
  },
  
  // Close the sign-in modal
  closeSignInModal: function() {
    const modal = document.getElementById('sync-sign-in-modal');
    modal.classList.remove('active');
    setTimeout(() => {
      modal.parentElement.remove();
    }, 300);
  },
  
  // Handle sign-in form submission
  handleSignIn: function() {
    const email = document.getElementById('sync-email').value.trim();
    const password = document.getElementById('sync-password').value;
    
    if (!email || !password) {
      showSnackbar('Please enter your email and password');
      return;
    }
    
    // Simulate authentication process
    this.updateSyncStatus('syncing');
    
    // In a real app, this would be an API call to verify credentials
    setTimeout(() => {
      // Simulated successful authentication
      this.auth.isAuthenticated = true;
      this.auth.user = {
        email: email,
        displayName: email.split('@')[0],
        expiresAt: Date.now() + (7 * 24 * 60 * 60 * 1000) // 7 days from now
      };
      
      // Store auth data
      localStorage.setItem('cloudSyncUser', JSON.stringify(this.auth.user));
      
      // Update UI
      this.updateSyncStatus('connected');
      
      // Close the modal
      this.closeSignInModal();
      
      // Show success message
      showSnackbar('Signed in successfully');
      
      // Schedule auto-sync
      this.scheduleAutoSync();
      
      // Sync data immediately
      this.syncData();
    }, 1500);
  },
  
  // Handle provider sign-in (Google, etc.)
  handleProviderSignIn: function(provider) {
    // Simulate provider authentication
    this.updateSyncStatus('syncing');
    
    // In a real app, this would open OAuth flow
    setTimeout(() => {
      // Simulated successful authentication
      const providerNames = {
        google: 'Google',
        microsoft: 'Microsoft',
        apple: 'Apple'
      };
      
      const email = `user${Math.floor(Math.random() * 10000)}@example.com`;
      
      this.auth.isAuthenticated = true;
      this.auth.user = {
        email: email,
        displayName: email.split('@')[0],
        provider: provider,
        providerName: providerNames[provider] || 'Provider',
        expiresAt: Date.now() + (30 * 24 * 60 * 60 * 1000) // 30 days from now
      };
      
      // Store auth data
      localStorage.setItem('cloudSyncUser', JSON.stringify(this.auth.user));
      
      // Update UI
      this.updateSyncStatus('connected');
      
      // Close the modal
      this.closeSignInModal();
      
      // Show success message
      showSnackbar(`Signed in with ${providerNames[provider] || 'provider'}`);
      
      // Schedule auto-sync
      this.scheduleAutoSync();
      
      // Sync data immediately
      this.syncData();
    }, 1500);
  },
  
  // Sign out
  signOut: function(showMessage = true) {
    // Clear auth data
    this.auth.isAuthenticated = false;
    this.auth.user = null;
    this.auth.lastSyncTime = null;
    
    // Remove stored auth data
    localStorage.removeItem('cloudSyncUser');
    
    // Cancel auto-sync
    if (this.syncTimer) {
      clearInterval(this.syncTimer);
      this.syncTimer = null;
    }
    
    // Update UI
    this.updateSyncStatus('disconnected');
    
    // Show message (unless silent)
    if (showMessage) {
      showSnackbar('Signed out of cloud sync');
    }
  },
  
  // Show sync settings
  showSyncSettings: function() {
    // Create the settings modal
    const modalHTML = `
      <div class="modal-overlay" id="sync-settings-modal">
        <div class="modal-content">
          <div class="modal-header">
            <h2>Sync Settings</h2>
            <button class="modal-close-btn"><i class="material-icons">close</i></button>
          </div>
          <div class="modal-body">
            <div class="settings-section">
              <h3>Auto-Sync</h3>
              <div class="settings-option">
                <label class="switch">
                  <input type="checkbox" id="auto-sync-toggle" ${this.autoSyncEnabled ? 'checked' : ''}>
                  <span class="switch-slider"></span>
                </label>
                <div class="settings-label">
                  <div>Enable automatic synchronization</div>
                  <div class="settings-description">Automatically sync your data every 5 minutes</div>
                </div>
              </div>
            </div>
            
            <div class="settings-section">
              <h3>Data to Sync</h3>
              <div class="settings-option">
                <label class="switch">
                  <input type="checkbox" id="sync-tasks-toggle" checked>
                  <span class="switch-slider"></span>
                </label>
                <div class="settings-label">Tasks</div>
              </div>
              <div class="settings-option">
                <label class="switch">
                  <input type="checkbox" id="sync-notes-toggle" checked>
                  <span class="switch-slider"></span>
                </label>
                <div class="settings-label">Notes</div>
              </div>
              <div class="settings-option">
                <label class="switch">
                  <input type="checkbox" id="sync-reminders-toggle" checked>
                  <span class="switch-slider"></span>
                </label>
                <div class="settings-label">Reminders</div>
              </div>
            </div>
            
            <div class="settings-section">
              <h3>Conflict Resolution</h3>
              <div class="settings-option">
                <select id="conflict-resolution">
                  <option value="server">Server wins (use server data on conflict)</option>
                  <option value="client" selected>Client wins (use local data on conflict)</option>
                  <option value="merge">Merge (combine data from both sources)</option>
                </select>
              </div>
            </div>
            
            <div class="settings-actions">
              <button type="button" class="btn-cancel">Cancel</button>
              <button type="button" class="btn-save" id="save-sync-settings">Save Settings</button>
            </div>
          </div>
        </div>
      </div>
    `;
    
    // Add modal to body
    const modalContainer = document.createElement('div');
    modalContainer.innerHTML = modalHTML;
    document.body.appendChild(modalContainer);
    
    // Add event listeners
    document.querySelector('#sync-settings-modal .modal-close-btn').addEventListener('click', () => {
      this.closeSyncSettings();
    });
    
    document.querySelector('#sync-settings-modal .btn-cancel').addEventListener('click', () => {
      this.closeSyncSettings();
    });
    
    document.getElementById('save-sync-settings').addEventListener('click', () => {
      this.saveSyncSettings();
    });
    
    // Show modal with animation
    setTimeout(() => {
      document.getElementById('sync-settings-modal').classList.add('active');
    }, 10);
  },
  
  // Close sync settings modal
  closeSyncSettings: function() {
    const modal = document.getElementById('sync-settings-modal');
    modal.classList.remove('active');
    setTimeout(() => {
      modal.parentElement.remove();
    }, 300);
  },
  
  // Save sync settings
  saveSyncSettings: function() {
    // Get settings from form
    const autoSync = document.getElementById('auto-sync-toggle').checked;
    const syncTasks = document.getElementById('sync-tasks-toggle').checked;
    const syncNotes = document.getElementById('sync-notes-toggle').checked;
    const syncReminders = document.getElementById('sync-reminders-toggle').checked;
    const conflictResolution = document.getElementById('conflict-resolution').value;
    
    // Save settings (in a real app, this would be stored)
    this.autoSyncEnabled = autoSync;
    this.syncSettings = {
      tasks: syncTasks,
      notes: syncNotes,
      reminders: syncReminders,
      conflictResolution: conflictResolution
    };
    
    // Update auto-sync schedule
    this.scheduleAutoSync();
    
    // Close the modal
    this.closeSyncSettings();
    
    // Show success message
    showSnackbar('Sync settings saved');
  }
};

// Initialize when the page is loaded
document.addEventListener('DOMContentLoaded', function() {
  CloudSync.init();
});