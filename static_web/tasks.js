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

// Sample tasks
let tasks = [
  {
    id: '1',
    title: 'Complete project proposal',
    description: 'Finish the proposal document for the client meeting',
    isCompleted: false,
    dueDate: '2025-04-15',
    priority: 'high',
    color: '#e53935',
    hasReminder: true
  },
  {
    id: '2',
    title: 'Buy groceries',
    description: 'Milk, eggs, bread, vegetables',
    isCompleted: false,
    dueDate: '2025-04-12',
    priority: 'medium',
    color: '#fb8c00',
    hasReminder: false
  },
  {
    id: '3',
    title: 'Call mom',
    description: 'Ask about weekend plans',
    isCompleted: false,
    dueDate: '2025-04-13',
    priority: 'low',
    color: '#43a047',
    hasReminder: true
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
  return `
    <div class="task-item" data-id="${task.id}" style="border-left: 4px solid ${task.color}">
      <div class="task-checkbox-container">
        <input type="checkbox" id="task-${task.id}" class="task-checkbox" ${task.isCompleted ? 'checked' : ''}>
        <label for="task-${task.id}" class="task-checkbox-label"></label>
      </div>
      <div class="task-content ${task.isCompleted ? 'completed' : ''}">
        <div class="task-title">${task.title}</div>
        <div class="task-details">
          <span class="task-due-date">${formatDate(task.dueDate)}</span>
          <span class="task-priority" style="background-color: ${task.color}">${PRIORITY_LEVELS[task.priority].name}</span>
          ${task.hasReminder ? '<span class="task-reminder"><i class="material-icons">alarm</i></span>' : ''}
        </div>
      </div>
      <div class="task-actions">
        <button class="task-edit-btn"><i class="material-icons">edit</i></button>
        <button class="task-delete-btn"><i class="material-icons">delete</i></button>
      </div>
    </div>
  `;
}

// Format date for display
function formatDate(dateStr) {
  const date = new Date(dateStr);
  return date.toLocaleDateString('en-US', { month: 'short', day: 'numeric' });
}

// Render all tasks
function renderTasks() {
  const taskList = document.getElementById('task-list');
  if (!taskList) return;
  
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
              <label for="task-title">Title</label>
              <input type="text" id="task-title" required value="${isEditing ? task.title : ''}">
            </div>
            <div class="form-group">
              <label for="task-description">Description (optional)</label>
              <textarea id="task-description">${isEditing ? task.description : ''}</textarea>
            </div>
            <div class="form-group">
              <label for="task-due-date">Due Date</label>
              <input type="date" id="task-due-date" required value="${isEditing ? task.dueDate : getTodayDate()}">
            </div>
            <div class="form-group">
              <label>Priority</label>
              <div class="priority-options">
                <label class="priority-option">
                  <input type="radio" name="priority" value="high" ${isEditing && task.priority === 'high' ? 'checked' : ''}>
                  <span class="priority-label" style="background-color: ${PRIORITY_LEVELS.high.color}">High</span>
                </label>
                <label class="priority-option">
                  <input type="radio" name="priority" value="medium" 
                    ${(!isEditing || task.priority === 'medium') ? 'checked' : ''}>
                  <span class="priority-label" style="background-color: ${PRIORITY_LEVELS.medium.color}">Medium</span>
                </label>
                <label class="priority-option">
                  <input type="radio" name="priority" value="low" ${isEditing && task.priority === 'low' ? 'checked' : ''}>
                  <span class="priority-label" style="background-color: ${PRIORITY_LEVELS.low.color}">Low</span>
                </label>
              </div>
            </div>
            <div class="form-group">
              <label class="checkbox-container">
                <input type="checkbox" id="task-reminder" ${isEditing && task.hasReminder ? 'checked' : ''}>
                <span class="checkbox-label">Set reminder</span>
              </label>
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
  
  // Add event listeners
  document.querySelector('.modal-close-btn').addEventListener('click', closeTaskForm);
  document.querySelector('.btn-cancel').addEventListener('click', closeTaskForm);
  document.getElementById('task-form').addEventListener('submit', saveTaskForm);
  
  // Show modal with animation
  setTimeout(() => {
    document.getElementById('task-modal').classList.add('active');
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
  const priority = form.querySelector('input[name="priority"]:checked').value;
  const hasReminder = form.querySelector('#task-reminder').checked;
  
  if (!title) {
    alert('Please enter a task title');
    return;
  }
  
  if (taskId) {
    // Update existing task
    const task = tasks.find(t => t.id === taskId);
    if (task) {
      task.title = title;
      task.description = description;
      task.dueDate = dueDate;
      task.priority = priority;
      task.color = PRIORITY_LEVELS[priority].color;
      task.hasReminder = hasReminder;
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
      priority,
      color: PRIORITY_LEVELS[priority].color,
      hasReminder
    };
    tasks.push(newTask);
    showSnackbar('Task added');
  }
  
  saveTasks();
  renderTasks();
  closeTaskForm();
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