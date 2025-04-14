// Reminder types
const REMINDER_TYPES = {
  birthday: {
    name: 'Birthday',
    icon: 'cake',
    color: '#ec407a' // pink
  },
  water: {
    name: 'Water',
    icon: 'water_drop',
    color: '#29b6f6' // light blue
  },
  pomodoro: {
    name: 'Pomodoro',
    icon: 'timer',
    color: '#ef5350' // red
  },
  socialization: {
    name: 'Social',
    icon: 'people',
    color: '#66bb6a' // green
  },
  custom: {
    name: 'Custom',
    icon: 'notifications',
    color: '#7e57c2' // purple
  }
};

// Reminder frequencies
const REMINDER_FREQUENCIES = [
  { value: 'once', label: 'Once' },
  { value: 'daily', label: 'Daily' },
  { value: 'weekly', label: 'Weekly' },
  { value: 'monthly', label: 'Monthly' },
  { value: 'yearly', label: 'Yearly' }
];

// Weekdays
const WEEKDAYS = [
  { value: 1, label: 'Monday' },
  { value: 2, label: 'Tuesday' },
  { value: 3, label: 'Wednesday' },
  { value: 4, label: 'Thursday' },
  { value: 5, label: 'Friday' },
  { value: 6, label: 'Saturday' },
  { value: 7, label: 'Sunday' }
];

// Sample reminders
let reminders = [
  {
    id: '1',
    title: 'Drink Water',
    description: 'Stay hydrated throughout the day',
    type: 'water',
    frequency: 'daily',
    times: ['09:00', '11:00', '13:00', '15:00', '17:00'],
    isEnabled: true,
    interval: 120 // minutes between reminders
  },
  {
    id: '2',
    title: 'Focus Time',
    description: 'Deep work session',
    type: 'pomodoro',
    frequency: 'weekly',
    times: ['10:00'],
    weekdays: [1, 2, 3, 4, 5], // Monday to Friday
    isEnabled: true,
    duration: 25, // focus duration in minutes
    breakDuration: 5 // break duration in minutes
  },
  {
    id: '3',
    title: 'Mom\'s Birthday',
    description: 'Don\'t forget to call and send flowers',
    type: 'birthday',
    frequency: 'yearly',
    date: '2025-05-15',
    time: '09:00',
    isEnabled: true,
    phoneNumber: '+1234567890'
  },
  {
    id: '4',
    title: 'Team Meeting',
    description: 'Weekly sync with the development team',
    type: 'socialization',
    frequency: 'weekly',
    times: ['14:00'],
    weekdays: [2], // Tuesday
    isEnabled: true
  },
  {
    id: '5',
    title: 'Brother\'s Birthday',
    description: 'Get gaming gift card',
    type: 'birthday',
    frequency: 'yearly',
    date: '2025-08-20',
    time: '10:00',
    isEnabled: true,
    phoneNumber: '+0987654321'
  },
  {
    id: '6',
    title: 'Exercise',
    description: 'Morning workout routine',
    type: 'custom',
    frequency: 'daily',
    times: ['07:00'],
    isEnabled: true
  },
  {
    id: '7',
    title: 'Friend\'s Birthday',
    description: 'Plan surprise party',
    type: 'birthday',
    frequency: 'yearly',
    date: '2025-09-10',
    time: '11:00',
    isEnabled: true,
    phoneNumber: '+1122334455'
  }
];

// Get saved reminders from localStorage
function loadReminders() {
  const savedReminders = localStorage.getItem('reminders');
  if (savedReminders) {
    reminders = JSON.parse(savedReminders);
  }
  renderReminders();
}

// Save reminders to localStorage
function saveReminders() {
  const subscription = JSON.parse(localStorage.getItem('subscription') || '{"tier": "free"}');
  const birthdayReminders = reminders.filter(r => r.type === 'birthday');
  
  if (subscription.tier === 'free' && birthdayReminders.length > 3) {
    throw new Error('Free tier limited to 3 birthday reminders. Upgrade to Premium for unlimited!');
  }
  
  localStorage.setItem('reminders', JSON.stringify(reminders));
}

function checkLocationBasedAlerts(position) {
  const giftShops = [
    { name: "Gift Gallery", lat: 40.7128, lng: -74.0060 },
    { name: "Present Paradise", lat: 34.0522, lng: -118.2437 }
  ];
  
  const birthdays = reminders.filter(r => 
    r.type === 'birthday' && 
    isUpcoming(r.date, 7) // within next 7 days
  );
  
  giftShops.forEach(shop => {
    const distance = calculateDistance(
      position.coords.latitude,
      position.coords.longitude,
      shop.lat,
      shop.lng
    );
    
    if (distance < 0.5) { // within 0.5 km
      birthdays.forEach(birthday => {
        showNotification(
          `Birthday Alert: ${birthday.name}`,
          `You're near ${shop.name}! Perfect time to buy a gift.`,
          () => { window.location.href = `tel:${birthday.phoneNumber}`; }
        );
      });
    }
  });
}

function calculateDistance(lat1, lon1, lat2, lon2) {
  // Haversine formula implementation
  const R = 6371; // Earth's radius in km
  const dLat = (lat2 - lat1) * Math.PI / 180;
  const dLon = (lon2 - lon1) * Math.PI / 180;
  const a = 
    Math.sin(dLat/2) * Math.sin(dLat/2) +
    Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) * 
    Math.sin(dLon/2) * Math.sin(dLon/2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
  return R * c;
}

// Generate reminder item HTML
function generateReminderHTML(reminder) {
  const reminderType = REMINDER_TYPES[reminder.type];
  
  // Format frequency display
  let frequencyDisplay = '';
  switch (reminder.frequency) {
    case 'once':
      frequencyDisplay = 'Once';
      break;
    case 'daily':
      frequencyDisplay = 'Daily';
      break;
    case 'weekly':
      if (reminder.weekdays && reminder.weekdays.length > 0) {
        if (reminder.weekdays.length === 7) {
          frequencyDisplay = 'Every day';
        } else if (reminder.weekdays.length === 5 && 
                  reminder.weekdays.includes(1) && 
                  reminder.weekdays.includes(2) && 
                  reminder.weekdays.includes(3) && 
                  reminder.weekdays.includes(4) && 
                  reminder.weekdays.includes(5)) {
          frequencyDisplay = 'Weekdays';
        } else if (reminder.weekdays.length === 2 && 
                  reminder.weekdays.includes(6) && 
                  reminder.weekdays.includes(7)) {
          frequencyDisplay = 'Weekends';
        } else {
          const dayNames = reminder.weekdays.map(day => {
            return WEEKDAYS.find(wd => wd.value === day)?.label.substr(0, 3);
          }).join(', ');
          frequencyDisplay = `Weekly (${dayNames})`;
        }
      } else {
        frequencyDisplay = 'Weekly';
      }
      break;
    case 'monthly':
      frequencyDisplay = 'Monthly';
      break;
    case 'yearly':
      frequencyDisplay = 'Yearly';
      break;
    default:
      frequencyDisplay = reminder.frequency;
  }
  
  // Format times display
  let timesDisplay = '';
  if (reminder.times && reminder.times.length > 0) {
    if (reminder.times.length === 1) {
      timesDisplay = formatTime(reminder.times[0]);
    } else {
      timesDisplay = `${reminder.times.length} times per day`;
    }
  } else if (reminder.time) {
    timesDisplay = formatTime(reminder.time);
  }
  
  // Add type-specific details
  let specialDetails = '';
  if (reminder.type === 'water') {
    specialDetails = `<div class="reminder-detail">Every ${reminder.interval} minutes</div>`;
  } else if (reminder.type === 'pomodoro') {
    specialDetails = `<div class="reminder-detail">${reminder.duration}min work / ${reminder.breakDuration}min break</div>`;
  } else if (reminder.type === 'birthday' && reminder.date) {
    specialDetails = `<div class="reminder-detail">Date: ${formatDate(reminder.date)}</div>`;
  }
  
  return `
    <div class="reminder-item" data-id="${reminder.id}">
      <div class="reminder-icon" style="background-color: ${reminderType.color}">
        <i class="material-icons">${reminderType.icon}</i>
      </div>
      <div class="reminder-content">
        <div class="reminder-header">
          <h3 class="reminder-title">${reminder.title}</h3>
          <label class="switch">
            <input type="checkbox" class="reminder-toggle" ${reminder.isEnabled ? 'checked' : ''}>
            <span class="slider round"></span>
          </label>
        </div>
        <div class="reminder-description">${reminder.description}</div>
        <div class="reminder-details">
          <div class="reminder-detail">
            <i class="material-icons">repeat</i> ${frequencyDisplay}
          </div>
          <div class="reminder-detail">
            <i class="material-icons">access_time</i> ${timesDisplay}
          </div>
          ${specialDetails}
        </div>
      </div>
      <div class="reminder-actions">
        <button class="reminder-edit-btn"><i class="material-icons">edit</i></button>
        <button class="reminder-delete-btn"><i class="material-icons">delete</i></button>
      </div>
    </div>
  `;
}

// Format time for display
function formatTime(timeStr) {
  if (!timeStr) return '';
  
  try {
    const [hours, minutes] = timeStr.split(':');
    const h = parseInt(hours);
    const m = minutes.padStart(2, '0');
    
    return `${h > 12 ? h - 12 : h}:${m} ${h >= 12 ? 'PM' : 'AM'}`;
  } catch (e) {
    return timeStr;
  }
}

// Format date for display
function formatDate(dateStr) {
  if (!dateStr) return '';
  
  try {
    const date = new Date(dateStr);
    return date.toLocaleDateString('en-US', { month: 'short', day: 'numeric' });
  } catch (e) {
    return dateStr;
  }
}

// Render all reminders
function renderReminders(categoryFilter = 'all') {
  const remindersList = document.getElementById('reminders-list');
  if (!remindersList) return;
  
  // Load reminders if not already loaded
  if (!reminders || reminders.length === 0) {
    loadReminders();
  }
  
  // Filter reminders by category
  let filteredReminders = reminders;
  if (categoryFilter !== 'all') {
    const subscription = JSON.parse(localStorage.getItem('subscription') || '{"tier": "free"}');
    
    // Apply category filters
    filteredReminders = reminders.filter(reminder => {
      switch(categoryFilter) {
        case 'health':
          return reminder.type === 'water' || reminder.type === 'pomodoro';
        case 'birthday':
          // Check subscription limit for birthday reminders
          if (subscription.tier === 'free' && categoryFilter === 'birthday') {
            return reminder.type === 'birthday' && 
                   reminders.filter(r => r.type === 'birthday').indexOf(reminder) < 3;
          }
          return reminder.type === 'birthday';
        case 'social':
          return reminder.type === 'socialization';
        case 'other':
          return !['water', 'pomodoro', 'birthday', 'socialization'].includes(reminder.type);
        default:
          return true;
      }
    });
    filteredReminders = reminders.filter(reminder => {
      switch(categoryFilter) {
        case 'health':
          return reminder.type === 'water' || reminder.type === 'pomodoro';
        case 'birthday':
          return reminder.type === 'birthday';
        case 'social':
          return reminder.type === 'socialization';
        case 'other':
          return !['water', 'pomodoro', 'birthday', 'socialization'].includes(reminder.type);
        default:
          return true;
      }
    });
  }
  
  // Sort reminders: enabled first, then by type
  const sortedReminders = [...filteredReminders].sort((a, b) => {
    // Enabled reminders go to the top
    if (a.isEnabled !== b.isEnabled) {
      return a.isEnabled ? -1 : 1;
    }
    
    // Sort by type
    if (a.type !== b.type) {
      return a.type.localeCompare(b.type);
    }
    
    // Sort by title
    return a.title.localeCompare(b.title);
  });
  
  remindersList.innerHTML = sortedReminders.length > 0 
    ? sortedReminders.map(generateReminderHTML).join('') 
    : '<div class="empty-state">No reminders found. Click the + button to add one.</div>';
  
  // Add event listeners
  document.querySelectorAll('.reminder-toggle').forEach(toggle => {
    toggle.addEventListener('change', handleReminderToggle);
  });
  
  document.querySelectorAll('.reminder-edit-btn').forEach(btn => {
    btn.addEventListener('click', handleReminderEdit);
  });
  
  document.querySelectorAll('.reminder-delete-btn').forEach(btn => {
    btn.addEventListener('click', handleReminderDelete);
  });
}

// Handle reminder toggle
function handleReminderToggle(e) {
  const reminderId = e.target.closest('.reminder-item').dataset.id;
  const reminder = reminders.find(r => r.id === reminderId);
  if (reminder) {
    reminder.isEnabled = e.target.checked;
    saveReminders();
    showSnackbar(`Reminder ${reminder.isEnabled ? 'enabled' : 'disabled'}`);
  }
}

// Handle reminder edit
function handleReminderEdit(e) {
  const reminderId = e.target.closest('.reminder-item').dataset.id;
  const reminder = reminders.find(r => r.id === reminderId);
  if (reminder) {
    showReminderForm(reminder);
  }
}

// Handle reminder delete
function handleReminderDelete(e) {
  const reminderId = e.target.closest('.reminder-item').dataset.id;
  const reminderIndex = reminders.findIndex(r => r.id === reminderId);
  if (reminderIndex > -1) {
    const reminderTitle = reminders[reminderIndex].title;
    if (confirm(`Delete reminder "${reminderTitle}"?`)) {
      reminders.splice(reminderIndex, 1);
      saveReminders();
      renderReminders(document.getElementById('reminder-type-filter').value);
      showSnackbar('Reminder deleted');
    }
  }
}

// Show reminder form
function showReminderForm(reminder = null) {
  const isEditing = !!reminder;
  const formTitle = isEditing ? 'Edit Reminder' : 'New Reminder';
  
  // Generate reminder type options
  let typeOptionsHTML = '';
  Object.entries(REMINDER_TYPES).forEach(([key, type]) => {
    const isSelected = isEditing && reminder.type === key;
    typeOptionsHTML += `
      <option value="${key}" ${isSelected ? 'selected' : ''}>${type.name}</option>
    `;
  });
  
  // Generate frequency options
  let frequencyOptionsHTML = '';
  REMINDER_FREQUENCIES.forEach(freq => {
    const isSelected = isEditing && reminder.frequency === freq.value;
    frequencyOptionsHTML += `
      <option value="${freq.value}" ${isSelected ? 'selected' : ''}>${freq.label}</option>
    `;
  });
  
  // Generate weekday checkboxes for weekly frequency
  let weekdaysHTML = '';
  WEEKDAYS.forEach(day => {
    const isChecked = isEditing && reminder.weekdays && reminder.weekdays.includes(day.value);
    weekdaysHTML += `
      <label class="checkbox-container weekday-checkbox">
        <input type="checkbox" name="weekday" value="${day.value}" ${isChecked ? 'checked' : ''}>
        <span class="checkbox-label">${day.label.substr(0, 3)}</span>
      </label>
    `;
  });
  
  // Time input value
  const timeValue = isEditing && reminder.time ? reminder.time : '';
  
  // Date input for birthday type
  const dateValue = isEditing && reminder.date ? reminder.date : getTodayDate();
  
  // Reminder-specific fields based on type
  const reminderTypeFields = `
    <!-- Birthday fields -->
    <div class="form-group reminder-type-field" data-type="birthday">
      <label for="reminder-date">Date</label>
      <input type="date" id="reminder-date" value="${dateValue}">
    </div>
    
    <!-- Water reminder fields -->
    <div class="form-group reminder-type-field" data-type="water">
      <label for="reminder-interval">Remind every (minutes)</label>
      <input type="number" id="reminder-interval" min="15" max="240" value="${isEditing && reminder.interval ? reminder.interval : 60}">
    </div>
    
    <!-- Pomodoro fields -->
    <div class="form-group reminder-type-field" data-type="pomodoro">
      <label for="reminder-duration">Work duration (minutes)</label>
      <input type="number" id="reminder-duration" min="5" max="60" value="${isEditing && reminder.duration ? reminder.duration : 25}">
    </div>
    <div class="form-group reminder-type-field" data-type="pomodoro">
      <label for="reminder-break-duration">Break duration (minutes)</label>
      <input type="number" id="reminder-break-duration" min="1" max="30" value="${isEditing && reminder.breakDuration ? reminder.breakDuration : 5}">
    </div>
  `;
  
  const modalHTML = `
    <div class="modal-overlay" id="reminder-modal">
      <div class="modal-content">
        <div class="modal-header">
          <h2>${formTitle}</h2>
          <button class="modal-close-btn"><i class="material-icons">close</i></button>
        </div>
        <div class="modal-body">
          <form id="reminder-form">
            <div class="form-group">
              <label for="reminder-title">Title</label>
              <input type="text" id="reminder-title" required value="${isEditing ? reminder.title : ''}">
            </div>
            <div class="form-group">
              <label for="reminder-description">Description (optional)</label>
              <textarea id="reminder-description">${isEditing ? reminder.description : ''}</textarea>
            </div>
            <div class="form-group">
              <label for="reminder-type">Type</label>
              <select id="reminder-type">
                ${typeOptionsHTML}
              </select>
            </div>
            <div class="form-group">
              <label for="reminder-frequency">Frequency</label>
              <select id="reminder-frequency">
                ${frequencyOptionsHTML}
              </select>
            </div>
            <div class="form-group frequency-field" data-frequency="weekly">
              <label>Days of Week</label>
              <div class="weekdays-container">
                ${weekdaysHTML}
              </div>
            </div>
            <div class="form-group">
              <label for="reminder-time">Time</label>
              <input type="time" id="reminder-time" value="${timeValue || '09:00'}">
            </div>
            
            ${reminderTypeFields}
            
            <div class="form-group">
              <label class="checkbox-container">
                <input type="checkbox" id="reminder-enabled" ${isEditing ? (reminder.isEnabled ? 'checked' : '') : 'checked'}>
                <span class="checkbox-label">Enabled</span>
              </label>
            </div>
            <div class="form-actions">
              ${isEditing ? '<input type="hidden" id="reminder-id" value="' + reminder.id + '">' : ''}
              <button type="button" class="btn-cancel">Cancel</button>
              <button type="submit" class="btn-save">Save</button>
            </div>
          </form>
        </div>
      </div>
    </div>
  `;
  
  // Add modal to body
  const modalContainer = document.createElement('div');
  modalContainer.innerHTML = modalHTML;
  document.body.appendChild(modalContainer);
  
  // Set up conditional field visibility
  const typeSelect = document.getElementById('reminder-type');
  const frequencySelect = document.getElementById('reminder-frequency');
  
  function updateTypeFields() {
    const selectedType = typeSelect.value;
    document.querySelectorAll('.reminder-type-field').forEach(field => {
      field.style.display = field.dataset.type === selectedType ? 'block' : 'none';
    });
  }
  
  function updateFrequencyFields() {
    const selectedFrequency = frequencySelect.value;
    document.querySelectorAll('.frequency-field').forEach(field => {
      field.style.display = field.dataset.frequency === selectedFrequency ? 'block' : 'none';
    });
  }
  
  typeSelect.addEventListener('change', updateTypeFields);
  frequencySelect.addEventListener('change', updateFrequencyFields);
  
  // Initialize field visibility
  updateTypeFields();
  updateFrequencyFields();
  
  // Add event listeners
  document.querySelector('.modal-close-btn').addEventListener('click', closeReminderForm);
  document.querySelector('.btn-cancel').addEventListener('click', closeReminderForm);
  document.getElementById('reminder-form').addEventListener('submit', saveReminderForm);
  
  // Show modal with animation
  setTimeout(() => {
    document.getElementById('reminder-modal').classList.add('active');
  }, 10);
}

// Get today's date formatted for date input
function getTodayDate() {
  const today = new Date();
  const yyyy = today.getFullYear();
  const mm = String(today.getMonth() + 1).padStart(2, '0');
  const dd = String(today.getDate()).padStart(2, '0');
  return `${yyyy}-${mm}-${dd}`;
}

// Close reminder form
function closeReminderForm() {
  const modal = document.getElementById('reminder-modal');
  modal.classList.remove('active');
  setTimeout(() => {
    modal.parentElement.remove();
  }, 300);
}

// Save reminder form
function saveReminderForm(e) {
  e.preventDefault();
  
  const form = document.getElementById('reminder-form');
  const reminderId = form.querySelector('#reminder-id')?.value;
  const title = form.querySelector('#reminder-title').value.trim();
  const description = form.querySelector('#reminder-description').value.trim();
  const type = form.querySelector('#reminder-type').value;
  const frequency = form.querySelector('#reminder-frequency').value;
  const time = form.querySelector('#reminder-time').value;
  const isEnabled = form.querySelector('#reminder-enabled').checked;
  
  // Get weekdays for weekly frequency
  let weekdays = [];
  if (frequency === 'weekly') {
    const weekdayCheckboxes = form.querySelectorAll('input[name="weekday"]:checked');
    weekdays = Array.from(weekdayCheckboxes).map(cb => parseInt(cb.value));
  }
  
  // Get type-specific fields
  let typeSpecificData = {};
  
  if (type === 'birthday') {
    typeSpecificData.date = form.querySelector('#reminder-date').value;
  } else if (type === 'water') {
    typeSpecificData.interval = parseInt(form.querySelector('#reminder-interval').value);
  } else if (type === 'pomodoro') {
    typeSpecificData.duration = parseInt(form.querySelector('#reminder-duration').value);
    typeSpecificData.breakDuration = parseInt(form.querySelector('#reminder-break-duration').value);
  }
  
  if (reminderId) {
    // Update existing reminder
    const reminder = reminders.find(r => r.id === reminderId);
    if (reminder) {
      reminder.title = title;
      reminder.description = description;
      reminder.type = type;
      reminder.frequency = frequency;
      reminder.time = time;
      reminder.isEnabled = isEnabled;
      
      // Update type-specific fields
      if (type === 'birthday') {
        reminder.date = typeSpecificData.date;
      } else if (type === 'water') {
        reminder.interval = typeSpecificData.interval;
      } else if (type === 'pomodoro') {
        reminder.duration = typeSpecificData.duration;
        reminder.breakDuration = typeSpecificData.breakDuration;
      }
      
      // Update weekdays if weekly
      if (frequency === 'weekly') {
        reminder.weekdays = weekdays;
      } else {
        delete reminder.weekdays;
      }
      
      showSnackbar('Reminder updated');
    }
  } else {
    // Create new reminder
    const newReminder = {
      id: Date.now().toString(),
      title,
      description,
      type,
      frequency,
      time,
      isEnabled,
      ...typeSpecificData
    };
    
    // Add weekdays if weekly
    if (frequency === 'weekly') {
      newReminder.weekdays = weekdays;
    }
    
    reminders.push(newReminder);
    showSnackbar('Reminder added');
  }
  
  saveReminders();
  renderReminders(document.getElementById('reminder-type-filter').value);
  closeReminderForm();
}

// Filter reminders by type
function filterRemindersByType(e) {
  renderReminders(e.target.value);
}

// Initialize reminders
document.addEventListener('DOMContentLoaded', function() {
  const remindersTab = document.querySelector('.tab-content[data-tab="reminders"]');
  if (remindersTab) {
    loadReminders();
    
    // Set up category tab click handlers
    document.querySelectorAll('.category-tab').forEach(tab => {
      tab.addEventListener('click', function() {
        // Remove active class from all tabs
        document.querySelectorAll('.category-tab').forEach(t => t.classList.remove('active'));
        // Add active class to clicked tab
        this.classList.add('active');
        // Filter reminders by category
        renderReminders(this.dataset.category);
      });
    });
    
    remindersTab.innerHTML = `
      <div class="reminders-header">
        <h2 class="tab-section-title">My Reminders</h2>
      </div>
      <div class="reminder-categories">
        <button class="category-tab active" data-category="all">All</button>
        <button class="category-tab" data-category="health">Health</button>
        <button class="category-tab" data-category="birthday">Birthday</button>
        <button class="category-tab" data-category="social">Social</button>
        <button class="category-tab" data-category="other">Other</button>
      </div>
      <div id="reminders-list" class="reminders-list"></div>
    `;
    
    document.getElementById('reminder-type-filter').addEventListener('change', filterRemindersByType);
    loadReminders();
  }
});