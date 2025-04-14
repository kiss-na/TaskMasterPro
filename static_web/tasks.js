// Task priority levels and their colors
const PRIORITY_LEVELS = {
  high: {
    name: 'High',
    color: '#e53935' // red
  },
  medium: {
    name: 'Medium',
    color: '#fb8c00' // orange
  },
  low: {
    name: 'Low',
    color: '#43a047' // green
  }
};

// Default priority for new tasks
const DEFAULT_TASK_PRIORITY = 'low';

// Sample tasks
let tasks = [
  {
    id: '1',
    title: 'Complete project proposal',
    description: 'Finish the proposal document for the client meeting',
    isCompleted: false,
    dueDate: '2025-04-15',
    dueTime: '14:00',
    calendarType: 'gregorian',
    priority: 'high',
    color: '#e53935',
    hasReminder: true,
    reminderTime: '13:00',
    reminderFrequency: 'once',
    contactPhone: '',
    contactEmail: 'client@example.com',
    location: '',
    subtasks: [
      { id: '1-1', title: 'Create project outline', isCompleted: true },
      { id: '1-2', title: 'Gather requirements', isCompleted: false },
      { id: '1-3', title: 'Draft proposal document', isCompleted: false }
    ]
  },
  {
    id: '2',
    title: 'Buy groceries',
    description: 'Milk, eggs, bread, vegetables',
    isCompleted: false,
    dueDate: '2025-04-12',
    dueTime: '10:30',
    calendarType: 'gregorian',
    priority: 'medium',
    color: '#fb8c00',
    hasReminder: false,
    reminderTime: '',
    reminderFrequency: 'once',
    contactPhone: '',
    contactEmail: '',
    location: 'Supermarket'
  },
  {
    id: '3',
    title: 'Call mom',
    description: 'Ask about weekend plans',
    isCompleted: false,
    dueDate: '2025-04-13',
    dueTime: '18:30',
    calendarType: 'gregorian',
    priority: 'low',
    color: '#43a047',
    hasReminder: true,
    reminderTime: '18:00',
    reminderFrequency: 'weekly',
    contactPhone: '+1234567890',
    contactEmail: 'mom@familyemail.com',
    location: ''
  }
];

// Get saved tasks from localStorage
function loadTasks() {
  const savedTasks = localStorage.getItem('tasks');
  if (savedTasks) {
    tasks = JSON.parse(savedTasks);
  }
  renderTasks();
}

// Save tasks to localStorage
function saveTasks() {
  localStorage.setItem('tasks', JSON.stringify(tasks));
}

// Generate task item HTML
function generateTaskHTML(task) {
  // Additional detail indicators
  const hasLocation = task.location && task.location.trim() !== '';
  const hasPhone = task.contactPhone && task.contactPhone.trim() !== '';
  const hasEmail = task.contactEmail && task.contactEmail.trim() !== '';

  let additionalInfo = '';
  if (hasLocation) {
    additionalInfo += `<span class="task-location" title="${task.location}"><i class="material-icons">place</i></span>`;
  }
  if (hasPhone) {
    additionalInfo += `<span class="task-contact" title="${task.contactPhone}"><i class="material-icons">phone</i></span>`;
  }
  if (hasEmail) {
    additionalInfo += `<span class="task-email" title="${task.contactEmail}"><i class="material-icons">email</i></span>`;
  }

  // Get category information if available
  let categoryIcon = '';
  if (window.TaskIntelligence && task.category) {
    const categoryData = window.TaskIntelligence.categories[task.category] || window.TaskIntelligence.categories.other;
    categoryIcon = `<span class="task-category-icon" title="${categoryData.name}"><i class="material-icons">${categoryData.icon}</i></span>`;
  }

  // Display tags if available
  let tagsHTML = '';
  if (task.tags && task.tags.length > 0) {
    tagsHTML = `
      <div class="task-tags">
        ${task.tags.slice(0, 3).map(tag => `<span class="task-tag">${tag}</span>`).join('')}
        ${task.tags.length > 3 ? `<span class="task-tag-more">+${task.tags.length - 3}</span>` : ''}
      </div>
    `;
  }

  // Generate subtasks HTML if available
  let subtasksHTML = '';
  if (task.subtasks && task.subtasks.length > 0) {
    const subtasksList = task.subtasks.map(subtask => `
      <div class="subtask-item ${subtask.isCompleted ? 'subtask-completed' : ''}" data-id="${subtask.id}">
        <div class="subtask-checkbox-container">
          <input type="checkbox" id="subtask-${subtask.id}" class="subtask-checkbox" ${subtask.isCompleted ? 'checked' : ''}>
          <label for="subtask-${subtask.id}" class="subtask-checkbox-label"></label>
        </div>
        <div class="subtask-title">${subtask.title}</div>
      </div>
    `).join('');

    subtasksHTML = `
      <div class="subtasks-container hidden">
        ${subtasksList}
        <button class="add-subtask-btn" data-parent-id="${task.id}">
          <i class="material-icons">add</i> Add subtask
        </button>
      </div>
    `;
  }

  return `
    <div class="task-item" data-id="${task.id}" data-category="${task.category || 'other'}" style="border-color: ${task.color}">
      <div class="task-checkbox-container">
        <input type="checkbox" id="task-${task.id}" class="task-checkbox" ${task.isCompleted ? 'checked' : ''}>
        <label for="task-${task.id}" class="task-checkbox-label"></label>
      </div>
      <div class="task-content ${task.isCompleted ? 'completed' : ''}">
        <div class="task-title">${task.title}</div>
        <div class="task-details hidden">
          <span class="task-due-date">${formatDate(task.dueDate, task.dueTime)}</span>
          <span class="task-priority" style="background-color: ${task.color}">${PRIORITY_LEVELS[task.priority].name}</span>
          ${task.hasReminder ? '<span class="task-reminder"><i class="material-icons">alarm</i></span>' : ''}
          ${additionalInfo}
        </div>
        ${task.calendarType && task.calendarType !== 'gregorian' ? 
          `<div class="task-calendar-type">${task.calendarType.charAt(0).toUpperCase() + task.calendarType.slice(1)} Calendar</div>` : ''}
        ${tagsHTML}
        ${subtasksHTML}
      </div>
      ${categoryIcon}
      <div class="task-actions">
        <button class="task-edit-btn"><i class="material-icons">edit</i></button>
        <button class="task-delete-btn"><i class="material-icons">delete</i></button>
      </div>
    </div>
  `;
}

// Format date for display
function formatDate(dateStr, timeStr) {
  const date = new Date(dateStr);
  const dateText = date.toLocaleDateString('en-US', { month: 'short', day: 'numeric' });

  if (timeStr) {
    // Convert 24h time to 12h format
    let [hours, minutes] = timeStr.split(':');
    const ampm = hours >= 12 ? 'PM' : 'AM';
    hours = hours % 12 || 12; // Convert 0 to 12
    const timeText = `${hours}:${minutes} ${ampm}`;
    return `${dateText}, ${timeText}`;
  }

  return dateText;
}

// Render all tasks
function renderTasks(activeTab = 'todo') {
  const taskList = document.getElementById('task-list');
  if (!taskList) return;

  // Only show class-related tasks
  let filteredTasks = tasks.filter(task => task.category === 'education');

  // Further filter based on active tab
  if (activeTab === 'todo') {
    filteredTasks = filteredTasks.filter(task => !task.isCompleted);
  } else if (activeTab === 'done') {
    filteredTasks = filteredTasks.filter(task => task.isCompleted);
  } else if (activeTab === 'metrics') {
    renderMetrics(filteredTasks);
    return;
  }
  if (activeTab === 'todo') {
    filteredTasks = tasks.filter(task => !task.isCompleted);
  } else if (activeTab === 'done') {
    filteredTasks = tasks.filter(task => task.isCompleted);
  } else if (activeTab === 'metrics') {
    renderMetrics();
    return;
  }

  // Sort tasks: incomplete first, then by priority, then by due date
  const sortedTasks = [...tasks].sort((a, b) => {
    // Completed tasks go to the bottom
    if (a.isCompleted !== b.isCompleted) {
      return a.isCompleted ? 1 : -1;
    }

    // Sort by priority
    const priorityOrder = { high: 0, medium: 1, low: 2 };
    if (a.priority !== b.priority) {
      return priorityOrder[a.priority] - priorityOrder[b.priority];
    }

    // Sort by due date
    return new Date(a.dueDate) - new Date(b.dueDate);
  });

  taskList.innerHTML = sortedTasks.length > 0 
    ? sortedTasks.map(generateTaskHTML).join('') 
    : '<div class="empty-state">No tasks. Click the + button to add one.</div>';

  // Add event listeners
  document.querySelectorAll('.task-checkbox').forEach(checkbox => {
    checkbox.addEventListener('change', handleTaskStatusChange);
  });

  document.querySelectorAll('.task-edit-btn').forEach(btn => {
    btn.addEventListener('click', handleTaskEdit);
  });

  document.querySelectorAll('.task-delete-btn').forEach(btn => {
    btn.addEventListener('click', handleTaskDelete);
  });

  // Add event listeners for subtasks
  document.querySelectorAll('.subtask-checkbox').forEach(checkbox => {
    checkbox.addEventListener('change', handleSubtaskStatusChange);
  });

  document.querySelectorAll('.add-subtask-btn').forEach(btn => {
    btn.addEventListener('click', handleAddSubtask);
  });

  // Add double-click event listener to task items for quick subtask creation
  document.querySelectorAll('.task-item').forEach(taskItem => {
    taskItem.addEventListener('dblclick', handleTaskDoubleClick);
  });
  document.querySelectorAll('.task-item').forEach(taskItem => {
    taskItem.addEventListener('click', handleTaskClick);
  });
}

// Handle task status change
function handleTaskStatusChange(e) {
  const taskId = e.target.closest('.task-item').dataset.id;
  const task = tasks.find(t => t.id === taskId);
  if (task) {
    task.isCompleted = e.target.checked;
    e.target.closest('.task-item').querySelector('.task-content')
      .classList.toggle('completed', task.isCompleted);
    saveTasks();
    setTimeout(renderTasks, 300); // Re-render after animation
  }
}

// Handle task edit
function handleTaskEdit(e) {
  const taskId = e.target.closest('.task-item').dataset.id;
  const task = tasks.find(t => t.id === taskId);
  if (task) {
    showTaskForm(task);
  }
}

// Handle task delete
function handleTaskDelete(e) {
  const taskId = e.target.closest('.task-item').dataset.id;
  const taskIndex = tasks.findIndex(t => t.id === taskId);
  if (taskIndex > -1) {
    const taskTitle = tasks[taskIndex].title;
    if (confirm(`Delete task "${taskTitle}"?`)) {
      tasks.splice(taskIndex, 1);
      saveTasks();
      renderTasks();
      showSnackbar('Task deleted');
    }
  }
}

// Show task form
function showTaskForm(task = null) {
  const isEditing = !!task;
  const formTitle = isEditing ? 'Edit Task' : 'New Task';

  // Calendar types from the calendar module
  const calendarTypeOptions = `
    <option value="gregorian" ${isEditing && task?.calendarType === 'gregorian' ? 'selected' : ''}>Gregorian</option>
    <option value="nepali" ${isEditing && task?.calendarType === 'nepali' ? 'selected' : ''}>Nepali</option>
    <option value="chinese" ${isEditing && task?.calendarType === 'chinese' ? 'selected' : ''}>Chinese</option>
    <option value="islamic" ${isEditing && task?.calendarType === 'islamic' ? 'selected' : ''}>Islamic</option>
  `;

  // Reminder frequency options
  const reminderFrequencyOptions = `
    <option value="once" ${isEditing && task?.reminderFrequency === 'once' ? 'selected' : ''}>Once</option>
    <option value="daily" ${isEditing && task?.reminderFrequency === 'daily' ? 'selected' : ''}>Daily</option>
    <option value="weekly" ${isEditing && task?.reminderFrequency === 'weekly' ? 'selected' : ''}>Weekly</option>
    <option value="monthly" ${isEditing && task?.reminderFrequency === 'monthly' ? 'selected' : ''}>Monthly</option>
    <option value="yearly" ${isEditing && task?.reminderFrequency === 'yearly' ? 'selected' : ''}>Yearly</option>
    <option value="custom" ${isEditing && task?.reminderFrequency === 'custom' ? 'selected' : ''}>Custom</option>
  `;

  const modalHTML = `
    <div class="modal-overlay" id="task-modal">
      <div class="modal-content">
        <div class="modal-header">
          <h2>${formTitle}</h2>
          <button class="modal-close-btn"><i class="material-icons">close</i></button>
        </div>
        <div class="modal-body">
          <form id="task-form">
            <div class="form-group">
              <input type="text" id="task-title" placeholder="Title" required value="${isEditing ? task.title : ''}">
            </div>
            <div class="form-group">
              <textarea id="task-description" placeholder="Description (optional)">${isEditing ? task.description : ''}</textarea>
            </div>

            <!-- Due Date and Time Section -->
            <div class="form-group">
              <select id="task-calendar-type">
                ${calendarTypeOptions}
              </select>
            </div>

            <div class="form-row">
              <div class="form-group form-group-half">
                <input type="date" id="task-due-date" required value="${isEditing ? task.dueDate : getTodayDate()}">
              </div>
              <div class="form-group form-group-half">
                <input type="time" id="task-due-time" placeholder="Due time" value="${isEditing && task.dueTime ? task.dueTime : ''}">
              </div>
            </div>

            <div class="form-group">
              <div class="priority-options">
                <label class="priority-option">
                  <input type="radio" name="priority" value="high" ${isEditing && task.priority === 'high' ? 'checked' : ''}>
                  <span class="priority-label" style="background-color: ${PRIORITY_LEVELS.high.color}">High</span>
                </label>
                <label class="priority-option">
                  <input type="radio" name="priority" value="medium" ${isEditing && task.priority === 'medium' ? 'checked' : ''}>
                  <span class="priority-label" style="background-color: ${PRIORITY_LEVELS.medium.color}">Medium</span>
                </label>
                <label class="priority-option">
                  <input type="radio" name="priority" value="low" ${(!isEditing || task.priority === 'low') ? 'checked' : ''}>
                  <span class="priority-label" style="background-color: ${PRIORITY_LEVELS.low.color}">Low</span>
                </label>
              </div>
            </div>

            <!-- Additional Options (Collapsible) -->
            <div class="collapsible-section">
              <div class="collapsible-header">
                <label>Additional Options</label>
                <i class="material-icons collapsible-icon">expand_more</i>
              </div>
              <div class="collapsible-content">
                <!-- Reminder Option -->
                <div class="form-group">
                  <label class="checkbox-container">
                    <input type="checkbox" id="task-reminder" ${isEditing && task.hasReminder ? 'checked' : ''}>
                    <span class="checkbox-label">Set reminder</span>
                  </label>
                </div>
                <div id="reminder-details" style="display: ${isEditing && task.hasReminder ? 'block' : 'none'}">
                  <div class="form-row">
                    <div class="form-group form-group-half">
                      <input type="time" id="task-reminder-time" placeholder="Reminder time" value="${isEditing && task.reminderTime ? task.reminderTime : ''}">
                    </div>
                    <div class="form-group form-group-half">
                      <select id="task-reminder-frequency">
                        ${reminderFrequencyOptions}
                      </select>
                    </div>
                  </div>
                </div>

                <!-- Contact Fields -->
                <div class="form-group">
                  <div class="input-with-button">
                    <input type="tel" id="task-contact-phone" placeholder="Phone number" value="${isEditing && task.contactPhone ? task.contactPhone : ''}">
                    <button type="button" class="input-button" id="contact-picker-btn">
                      <i class="material-icons">contact_phone</i>
                    </button>
                  </div>
                </div>

                <div class="form-group">
                  <div class="input-with-button">
                    <input type="email" id="task-contact-email" placeholder="Email address" value="${isEditing && task.contactEmail ? task.contactEmail : ''}">
                    <button type="button" class="input-button" id="email-picker-btn">
                      <i class="material-icons">email</i>
                    </button>
                  </div>
                </div>

                <!-- Location Field -->
                <div class="form-group">
                  <div class="input-with-button">
                    <input type="text" id="task-location" placeholder="Location" value="${isEditing && task.location ? task.location : ''}">
                    <button type="button" class="input-button" id="location-picker-btn">
                      <i class="material-icons">place</i>
                    </button>
                  </div>
                </div>
              </div>
            </div>

            <div class="form-actions">
              ${isEditing ? '<input type="hidden" id="task-id" value="' + task.id + '">' : ''}
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

  // Store task data for intelligence system
  const form = document.getElementById('task-form');
  if (form && task) {
    form._taskData = task;
  }

  // Add event listeners
  document.querySelector('.modal-close-btn').addEventListener('click', closeTaskForm);
  document.querySelector('.btn-cancel').addEventListener('click', closeTaskForm);
  document.getElementById('task-form').addEventListener('submit', saveTaskForm);

  // Dispatch event for task intelligence system
  document.dispatchEvent(new CustomEvent('taskFormShown', {
    detail: {
      form: document.getElementById('task-form'),
      isEditing: isEditing
    }
  }));

  // Collapsible sections
  document.querySelectorAll('.collapsible-header').forEach(header => {
    header.addEventListener('click', (e) => {
      // Don't toggle if clicking the checkbox itself
      if (e.target.type === 'checkbox') return;

      const content = header.nextElementSibling;
      const icon = header.querySelector('.collapsible-icon');
      const isVisible = content.style.display !== 'none';

      content.style.display = isVisible ? 'none' : 'block';
      icon.textContent = isVisible ? 'expand_more' : 'expand_less';
    });
  });

  // Special handling for reminder checkbox
  const reminderCheckbox = document.getElementById('task-reminder');
  reminderCheckbox.addEventListener('change', function() {
    const reminderDetails = document.getElementById('reminder-details');
    reminderDetails.style.display = this.checked ? 'block' : 'none';
  });

  // Contact picker buttons
  document.getElementById('contact-picker-btn').addEventListener('click', function() {
    // In a real implementation, this would open the device contacts
    // For now, we'll show a simulated contact picker
    showContactPicker();
  });

  document.getElementById('email-picker-btn').addEventListener('click', function() {
    // In a real implementation, this would open the Google contacts
    // For now, we'll show a simulated contact picker
    showContactPicker();
  });

  // Location picker button
  document.getElementById('location-picker-btn').addEventListener('click', function() {
    // In a real implementation, this would open the Google Maps integration
    // For now, we'll show a simulated location picker
    showLocationPicker();
  });

  // Show modal with animation
  setTimeout(() => {
    document.getElementById('task-modal').classList.add('active');
  }, 10);
}

// Simulated contact picker
function showContactPicker() {
  const contacts = [
    { name: 'John Smith', phone: '+15551234567', email: 'john.smith@example.com' },
    { name: 'Jane Doe', phone: '+15559876543', email: 'jane.doe@example.com' },
    { name: 'Alice Johnson', phone: '+15552223333', email: 'alice@example.com' },
    { name: 'Bob Brown', phone: '+15554445555', email: 'bob.brown@gmail.com' }
  ];

  // Determine if this is being called for phone or email
  const sourceButtonId = document.activeElement.id;
  const forEmail = sourceButtonId === 'email-picker-btn';
  const title = forEmail ? 'Select Email Contact' : 'Select Phone Contact';

  const pickerHTML = `
    <div class="modal-overlay" id="contact-picker-modal">
      <div class="modal-content picker-content">
        <div class="modal-header">
          <h2>${title}</h2>
          <button class="modal-close-btn"><i class="material-icons">close</i></button>
        </div>
        <div class="modal-body">
          <div class="picker-tabs">
            <button class="picker-tab ${!forEmail ? 'active' : ''}" data-type="phone">Phone</button>
            <button class="picker-tab ${forEmail ? 'active' : ''}" data-type="email">Email</button>
          </div>
          <div class="picker-search">
            <input type="text" placeholder="Search contacts..." class="picker-search-input">
          </div>
          <div class="picker-list">
            ${contacts.map(contact => `
              <div class="picker-item" data-phone="${contact.phone}" data-email="${contact.email}">
                <i class="material-icons picker-item-icon">person</i>
                <div class="picker-item-details">
                  <div class="picker-item-title">${contact.name}</div>
                  <div class="picker-item-subtitle">${forEmail ? contact.email : contact.phone}</div>
                </div>
              </div>
            `).join('')}
          </div>
          <div class="picker-google-connect">
            <button class="google-connect-btn">
              <img src="https://developers.google.com/identity/images/g-logo.png" alt="Google" width="18" height="18">
              Connect Google Contacts
            </button>
          </div>
        </div>
      </div>
    </div>
  `;

  // Add picker to body
  const pickerContainer = document.createElement('div');
  pickerContainer.innerHTML = pickerHTML;
  document.body.appendChild(pickerContainer);

  // Add event listeners
  document.querySelector('#contact-picker-modal .modal-close-btn').addEventListener('click', function() {
    document.getElementById('contact-picker-modal').remove();
  });

  document.querySelectorAll('#contact-picker-modal .picker-item').forEach(item => {
    item.addEventListener('click', function() {
      const phoneNumber = this.dataset.phone;
      const email = this.dataset.email;

      if (forEmail) {
        document.getElementById('task-contact-email').value = email;
      } else {
        document.getElementById('task-contact-phone').value = phoneNumber;
      }

      document.getElementById('contact-picker-modal').remove();
    });
  });

  // Tab switching
  document.querySelectorAll('.picker-tab').forEach(tab => {
    tab.addEventListener('click', function() {
      const type = this.dataset.type;
      document.querySelectorAll('.picker-tab').forEach(t => t.classList.remove('active'));
      this.classList.add('active');

      // Update the contact list to show emails or phones
      document.querySelectorAll('.picker-item').forEach(item => {
        const subtitle = item.querySelector('.picker-item-subtitle');
        subtitle.textContent = type === 'email' ? item.dataset.email : item.dataset.phone;
      });
    });
  });

  // Google connect button (simulated)
  document.querySelector('.google-connect-btn').addEventListener('click', function() {
    showSnackbar('Google Contacts integration would be implemented here');
  });

  // Show the search functionality (simulated)
  document.querySelector('.picker-search-input').addEventListener('input', function(e) {
    const searchTerm = e.target.value.toLowerCase();
    const isEmailTab = document.querySelector('.picker-tab[data-type="email"]').classList.contains('active');

    document.querySelectorAll('.picker-item').forEach(item => {
      const name = item.querySelector('.picker-item-title').textContent.toLowerCase();
      const contactValue = isEmailTab ? item.dataset.email.toLowerCase() : item.dataset.phone.toLowerCase();
      const match = name.includes(searchTerm) || contactValue.includes(searchTerm);
      item.style.display = match ? 'flex' : 'none';
    });
  });
}

// Simulated location picker
function showLocationPicker() {
  const locations = [
    { name: 'Office', address: '123 Business Ave, Suite 200' },
    { name: 'Home', address: '456 Residential St' },
    { name: 'Gym', address: 'FitLife Center, 789 Health Blvd' },
    { name: 'Supermarket', address: 'GreenMart, 321 Shopping Ln' }
  ];

  const pickerHTML = `
    <div class="modal-overlay" id="location-picker-modal">
      <div class="modal-content picker-content">
        <div class="modal-header">
          <h2>Select Location</h2>
          <button class="modal-close-btn"><i class="material-icons">close</i></button>
        </div>
        <div class="modal-body">
          <div class="picker-search">
            <input type="text" placeholder="Search locations..." class="picker-search-input">
          </div>
          <div class="picker-map">
            <div class="map-placeholder">
              <i class="material-icons">map</i>
              <div>Map View (Simulated)</div>
            </div>
          </div>
          <div class="picker-list">
            ${locations.map(location => `
              <div class="picker-item" data-value="${location.name}">
                <i class="material-icons picker-item-icon">place</i>
                <div class="picker-item-details">
                  <div class="picker-item-title">${location.name}</div>
                  <div class="picker-item-subtitle">${location.address}</div>
                </div>
              </div>
            `).join('')}
          </div>
        </div>
      </div>
    </div>
  `;

  // Add picker to body
  const pickerContainer = document.createElement('div');
  pickerContainer.innerHTML = pickerHTML;
  document.body.appendChild(pickerContainer);

  // Add event listeners
  document.querySelector('#location-picker-modal .modal-close-btn').addEventListener('click', function() {
    document.getElementById('location-picker-modal').remove();
  });

  document.querySelectorAll('#location-picker-modal .picker-item').forEach(item => {
    item.addEventListener('click', function() {
      const location = this.dataset.value;
      document.getElementById('task-location').value = location;
      document.getElementById('location-picker-modal').remove();
    });
  });

  // Show the search functionality (simulated)
  document.querySelector('.picker-search-input').addEventListener('input', function(e) {
    const searchTerm = e.target.value.toLowerCase();
    document.querySelectorAll('.picker-item').forEach(item => {
      const name = item.querySelector('.picker-item-title').textContent.toLowerCase();
      const address = item.querySelector('.picker-item-subtitle').textContent.toLowerCase();
      const match = name.includes(searchTerm) || address.includes(searchTerm);
      item.style.display = match ? 'flex' : 'none';
    });
  });
}

// Get today's date formatted for date input
function getTodayDate() {
  const today = new Date();
  const yyyy = today.getFullYear();
  const mm = String(today.getMonth() + 1).padStart(2, '0');
  const dd = String(today.getDate()).padStart(2, '0');
  return `${yyyy}-${mm}-${dd}`;
}

// Close task form
function closeTaskForm() {
  const modal = document.getElementById('task-modal');
  modal.classList.remove('active');
  setTimeout(() => {
    modal.parentElement.remove();
  }, 300);
}

// Save task form
function saveTaskForm(e) {
  e.preventDefault();

  const form = document.getElementById('task-form');
  const taskId = form.querySelector('#task-id')?.value;
  const title = form.querySelector('#task-title').value.trim();
  const description = form.querySelector('#task-description').value.trim();
  const dueDate = form.querySelector('#task-due-date').value;
  const dueTime = form.querySelector('#task-due-time').value;
  const calendarType = form.querySelector('#task-calendar-type').value;
  const priority = form.querySelector('input[name="priority"]:checked')?.value || DEFAULT_TASK_PRIORITY;
  const hasReminder = form.querySelector('#task-reminder').checked;

  // Additional fields
  const reminderTime = form.querySelector('#task-reminder-time')?.value || '';
  const reminderFrequency = form.querySelector('#task-reminder-frequency')?.value || 'once';
  const contactPhone = form.querySelector('#task-contact-phone')?.value || '';
  const contactEmail = form.querySelector('#task-contact-email')?.value || '';
  const location = form.querySelector('#task-location')?.value || '';

  // Intelligence fields - may not exist if TaskIntelligence is not loaded
  const category = form.querySelector('#task-category')?.value || 'other';
  const tagsInput = form.querySelector('#task-tags')?.value || '';
  const tags = tagsInput ? tagsInput.split(',').filter(tag => tag.trim()) : [];

  if (!title) {
    alert('Please enter a task title');
    return;
  }

  let updatedTask;

  if (taskId) {
    // Update existing task
    const task = tasks.find(t => t.id === taskId);
    if (task) {
      task.title = title;
      task.description = description;
      task.dueDate = dueDate;
      task.dueTime = dueTime;
      task.calendarType = calendarType;
      task.priority = priority;
      task.color = PRIORITY_LEVELS[priority].color;
      task.hasReminder = hasReminder;

      // Update additional fields
      if (hasReminder) {
        task.reminderTime = reminderTime;
        task.reminderFrequency = reminderFrequency;
      } else {
        task.reminderTime = '';
        task.reminderFrequency = 'once';
      }

      task.contactPhone = contactPhone;
      task.contactEmail = contactEmail;
      task.location = location;

      // Intelligence fields
      task.category = category;
      task.tags = tags;

      updatedTask = task;
      showSnackbar('Task updated');
    }
  } else {
    // Create new task
    const newTask = {
      id: Date.now().toString(),
      title,
      description,
      isCompleted: false,
      dueDate,
      dueTime,
      calendarType,
      priority,
      color: PRIORITY_LEVELS[priority].color,
      hasReminder,
      reminderTime: hasReminder ? reminderTime : '',
      reminderFrequency: hasReminder ? reminderFrequency : 'once',
      contactPhone,
      contactEmail,
      location,
      category,
      tags
    };
    tasks.push(newTask);
    updatedTask = newTask;
    showSnackbar('Task added');
  }

  saveTasks();
  renderTasks();
  closeTaskForm();

  // Dispatch event for task intelligence system
  if (updatedTask) {
    document.dispatchEvent(new CustomEvent('taskSaved', {
      detail: {
        task: updatedTask,
        isNew: !taskId
      }
    }));
  }
}

// Handle subtask status change
function handleSubtaskStatusChange(e) {
  const subtaskId = e.target.closest('.subtask-item').dataset.id;
  const taskId = subtaskId.split('-')[0]; // Get parent task ID from subtask ID

  const task = tasks.find(t => t.id === taskId);
  if (task && task.subtasks) {
    const subtask = task.subtasks.find(st => st.id === subtaskId);
    if (subtask) {
      subtask.isCompleted = e.target.checked;
      e.target.closest('.subtask-item').classList.toggle('subtask-completed', subtask.isCompleted);
      saveTasks();
    }
  }
}

// Handle add subtask button click
function handleAddSubtask(e) {
  e.stopPropagation(); // Prevent event from bubbling up

  const taskId = e.target.closest('.add-subtask-btn').dataset.parentId;
  const task = tasks.find(t => t.id === taskId);

  if (task) {
    showSubtaskForm(task);
  }
}

// Handle double-click on task to quickly add subtasks
function handleTaskDoubleClick(e) {
  // Skip if clicking on buttons, checkboxes, or subtasks
  if (e.target.closest('.task-actions') || 
      e.target.closest('.task-checkbox-container') ||
      e.target.closest('.subtasks-container')) {
    return;
  }

  const taskId = e.currentTarget.dataset.id;
  const task = tasks.find(t => t.id === taskId);

  if (task) {
    showSubtaskForm(task);
  }
}

// Show form to add a new subtask
function showSubtaskForm(parentTask) {
  const modalHTML = `
    <div class="modal-overlay" id="subtask-modal">
      <div class="modal-content">
        <div class="modal-header">
          <h2>Add Subtask</h2>
          <button class="modal-close-btn"><i class="material-icons">close</i></button>
        </div>
        <div class="modal-body">
          <form id="subtask-form">
            <div class="form-group">
              <label>Parent Task: ${parentTask.title}</label>
            </div>
            <div class="form-group">
              <input type="text" id="subtask-title" placeholder="Subtask Title" required>
            </div>
            <div class="form-actions">
              <input type="hidden" id="parent-task-id" value="${parentTask.id}">
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

  // Add event listeners
  document.querySelector('#subtask-modal .modal-close-btn').addEventListener('click', closeSubtaskForm);
  document.querySelector('#subtask-modal .btn-cancel').addEventListener('click', closeSubtaskForm);
  document.getElementById('subtask-form').addEventListener('submit', saveSubtaskForm);

  // Show modal with animation
  setTimeout(() => {
    document.getElementById('subtask-modal').classList.add('active');
    document.getElementById('subtask-title').focus();
  }, 10);
}

// Close subtask form
function closeSubtaskForm() {
  const modal = document.getElementById('subtask-modal');
  if (modal) {
    modal.classList.remove('active');
    setTimeout(() => modal.remove(), 300);
  }
}

// Save subtask form
function saveSubtaskForm(e) {
  e.preventDefault();

  const parentTaskId = document.getElementById('parent-task-id').value;
  const subtaskTitle = document.getElementById('subtask-title').value.trim();

  if (!subtaskTitle) return;

  const parentTask = tasks.find(t => t.id === parentTaskId);
  if (parentTask) {
    // Initialize subtasks array if it doesn't exist
    if (!parentTask.subtasks) {
      parentTask.subtasks = [];
    }

    // Generate a new subtask ID by combining parent ID with a unique ID
    const subtaskId = `${parentTaskId}-${Date.now().toString().slice(-4)}`;

    // Add the new subtask
    parentTask.subtasks.push({
      id: subtaskId,
      title: subtaskTitle,
      isCompleted: false
    });

    saveTasks();
    renderTasks();
    closeSubtaskForm();
    showSnackbar('Subtask added');
  }
}

// Handle task click to expand/collapse details
function handleTaskClick(e) {
  if (!e.target.closest('.task-actions') && 
      !e.target.closest('.task-checkbox-container')) {
    const details = e.target.closest('.task-item').querySelector('.task-details');
    const subtasks = e.target.closest('.task-item').querySelector('.subtasks-container');
    if (details) details.classList.toggle('hidden');
    if (subtasks) subtasks.classList.toggle('hidden');
  }
}

// Initialize tasks
document.addEventListener('DOMContentLoaded', function() {
  const tasksTab = document.querySelector('.tab-content[data-tab="tasks"]');
  if (tasksTab) {
    tasksTab.innerHTML = `
      <div class="task-header">
        <h2 class="tab-section-title">My Tasks</h2>
        <div class="task-filter">
          <label for="task-filter" class="visually-hidden">Filter</label>
          <select id="task-filter">
            <option value="all">All Tasks</option>
            <option value="today">Due Today</option>
            <option value="upcoming">Upcoming</option>
            <option value="completed">Completed</option>
          </select>
        </div>
      </div>
      <div id="task-list" class="task-list"></div>
    `;

    loadTasks();
  }
});
function renderMetrics() {
  const taskList = document.getElementById('task-list');
  if (!taskList) return;

  const totalTasks = tasks.length;
  const completedTasks = tasks.filter(task => task.isCompleted).length;
  const completionRate = totalTasks ? ((completedTasks / totalTasks) * 100).toFixed(1) : 0;
  
  taskList.innerHTML = `
    <div class="task-metrics">
      <div class="metric-card">
        <div class="metric-title">Total Tasks</div>
        <div class="metric-value">${totalTasks}</div>
      </div>
      <div class="metric-card">
        <div class="metric-title">Completed Tasks</div>
        <div class="metric-value">${completedTasks}</div>
      </div>
      <div class="metric-card">
        <div class="metric-title">Completion Rate</div>
        <div class="metric-value">${completionRate}%</div>
      </div>
    </div>
  `;
}

// Add event listeners for task tabs
document.addEventListener('DOMContentLoaded', function() {
  const taskTabs = document.querySelectorAll('.task-tab');
  taskTabs.forEach(tab => {
    tab.addEventListener('click', function() {
      taskTabs.forEach(t => t.classList.remove('active'));
      this.classList.add('active');
      renderTasks(this.dataset.tab);
    });
  });
});
