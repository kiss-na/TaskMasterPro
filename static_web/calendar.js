// Calendar types
const CALENDAR_TYPES = {
  gregorian: {
    name: 'Gregorian',
    monthNames: [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ],
    dayNames: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'],
    firstDayOfWeek: 0 // 0 = Sunday
  },
  nepali: {
    name: 'Nepali',
    monthNames: [
      'Baishakh', 'Jestha', 'Ashadh', 'Shrawan', 'Bhadra', 'Ashwin',
      'Kartik', 'Mangsir', 'Poush', 'Magh', 'Falgun', 'Chaitra'
    ],
    dayNames: ['Aai', 'Som', 'Man', 'Bud', 'Bih', 'Shu', 'Sha'],
    firstDayOfWeek: 0
  },
  chinese: {
    name: 'Chinese',
    monthNames: [
      '正月', '二月', '三月', '四月', '五月', '六月',
      '七月', '八月', '九月', '十月', '十一月', '十二月'
    ],
    dayNames: ['周日', '周一', '周二', '周三', '周四', '周五', '周六'],
    firstDayOfWeek: 1 // 1 = Monday
  },
  islamic: {
    name: 'Islamic',
    monthNames: [
      'Muharram', 'Safar', 'Rabi al-Awwal', 'Rabi al-Thani', 'Jumada al-Awwal', 'Jumada al-Thani',
      'Rajab', 'Shaban', 'Ramadan', 'Shawwal', 'Dhu al-Qadah', 'Dhu al-Hijjah'
    ],
    dayNames: ['Ahd', 'Ith', 'Thu', 'Arb', 'Kha', 'Jum', 'Sab'],
    firstDayOfWeek: 6 // 6 = Saturday
  }
};

// Current calendar state
let calendarState = {
  type: 'gregorian',
  currentDate: new Date(),
  selectedDate: new Date(),
  events: [] // Will store task events
};

// Generate calendar HTML
function generateCalendarHTML() {
  const calType = CALENDAR_TYPES[calendarState.type];
  const year = calendarState.currentDate.getFullYear();
  const month = calendarState.currentDate.getMonth();

  // Get first day of the month
  const firstDay = new Date(year, month, 1);
  // Get last day of the month
  const lastDay = new Date(year, month + 1, 0);

  // Get the day of the week of the first day (0-6)
  let firstDayOfWeek = firstDay.getDay();
  // Adjust for the first day of the week based on calendar type
  firstDayOfWeek = (firstDayOfWeek - calType.firstDayOfWeek + 7) % 7;

  // Number of days in the month
  const daysInMonth = lastDay.getDate();

  // Create day header cells
  let dayHeadersHTML = '';
  for (let i = 0; i < 7; i++) {
    const dayIndex = (calType.firstDayOfWeek + i) % 7;
    dayHeadersHTML += `<div class="calendar-day-header">${calType.dayNames[dayIndex]}</div>`;
  }

  // Create calendar cells
  let daysHTML = '';
  
  // If Nepali calendar is selected, show Hamro Patro widget
  if (calendarState.type === 'nepali') {
    return `
      <div class="calendar-container">
        <div class="calendar-header">
          <div class="calendar-type-selector">
            <select id="calendar-type">
              <option value="gregorian">Gregorian</option>
              <option value="nepali" selected>Nepali</option>
            </select>
          </div>
        </div>
        <div class="nepali-calendar-widget">
          <iframe src="https://www.hamropatro.com/widgets/calender-small.php" 
                  frameborder="0" 
                  scrolling="no" 
                  marginwidth="0" 
                  marginheight="0" 
                  style="border:none; overflow:hidden; width:100%; height:290px;" 
                  allowtransparency="true">
          </iframe>
        </div>
        <div class="calendar-events">
          <h3 class="events-header">Events for ${formatDate(calendarState.selectedDate)}</h3>
          <div class="events-list" id="events-list">
            ${generateEventsHTML(calendarState.selectedDate)}
          </div>
          
          <h3 class="events-header">Upcoming Events</h3>
          <div class="events-list" id="upcoming-events">
            ${sortEventsByDate(getUpcomingEvents())
              .map(event => `
                <div class="event-item" style="border-left: 4px solid ${event.color}">
                  <div class="event-time">${formatDate(event.date, event.time)}</div>
                  <div class="event-title">${event.title}</div>
                </div>
              `).join('')}
          </div>
        </div>
      </div>
    `;
  }

  // For other calendar types, add empty cells for days before the first day of the month
  for (let i = 0; i < firstDayOfWeek; i++) {
    daysHTML += '<div class="calendar-day empty"></div>';
  }

  // Add days of the month
  const today = new Date();
  const selectedDateStr = calendarState.selectedDate.toDateString();

  for (let day = 1; day <= daysInMonth; day++) {
    const date = new Date(year, month, day);
    const dateStr = date.toDateString();

    const isToday = today.getFullYear() === year && 
                    today.getMonth() === month && 
                    today.getDate() === day;

    const isSelected = selectedDateStr === dateStr;

    // Check if there are events on this day
    const hasEvents = calendarState.events.some(event => {
      const eventDate = new Date(event.date);
      return eventDate.getFullYear() === year && 
             eventDate.getMonth() === month && 
             eventDate.getDate() === day;
    });

    // Count events for this day (for event dots)
    const dayEvents = calendarState.events.filter(event => {
      const eventDate = new Date(event.date);
      return eventDate.getFullYear() === year && 
             eventDate.getMonth() === month && 
             eventDate.getDate() === day;
    });

    let eventDotsHTML = '';
    if (dayEvents.length > 0) {
      const maxDots = 3; // Max dots to show
      const dots = Math.min(dayEvents.length, maxDots);
      for (let i = 0; i < dots; i++) {
        eventDotsHTML += '<span class="event-dot"></span>';
      }
      if (dayEvents.length > maxDots) {
        eventDotsHTML += `<span class="event-more">+${dayEvents.length - maxDots}</span>`;
      }
    }

    daysHTML += `
      <div class="calendar-day ${isToday ? 'today' : ''} ${isSelected ? 'selected' : ''} ${hasEvents ? 'has-events' : ''}" 
           data-date="${year}-${(month + 1).toString().padStart(2, '0')}-${day.toString().padStart(2, '0')}">
        <span class="day-number">${day}</span>
        <div class="event-indicators">${eventDotsHTML}</div>
      </div>
    `;
  }

  // Sort events by date
function sortEventsByDate(events) {
  return events.sort((a, b) => {
    const dateA = new Date(a.date + (a.time ? 'T' + a.time : ''));
    const dateB = new Date(b.date + (b.time ? 'T' + b.time : ''));
    return dateA - dateB;
  });
}

// Get upcoming events
function getUpcomingEvents() {
  const today = new Date();
  today.setHours(0, 0, 0, 0);
  
  return calendarState.events
    .filter(event => {
      const eventDate = new Date(event.date);
      eventDate.setHours(0, 0, 0, 0);
      return eventDate >= today;
    });
}

// Build the calendar
  return `
    <div class="calendar-container">
      <div class="calendar-header">
        <div class="calendar-actions">
          <button class="add-event-btn" onclick="showEventForm()">
            <i class="material-icons">add</i> Add Event
          </button>
        </div>
        <div class="calendar-nav">
          <button class="prev-month-btn"><i class="material-icons">chevron_left</i></button>
          <div class="current-month-year">
            <span class="current-month">${calType.monthNames[month]}</span>
            <span class="current-year">${year}</span>
          </div>
          <button class="next-month-btn"><i class="material-icons">chevron_right</i></button>
        </div>
        <div class="calendar-type-selector">
          <select id="calendar-type">
            <option value="gregorian" ${calendarState.type === 'gregorian' ? 'selected' : ''}>Gregorian</option>
            <option value="nepali" ${calendarState.type === 'nepali' ? 'selected' : ''}>Nepali</option>
            <option value="chinese" ${calendarState.type === 'chinese' ? 'selected' : ''}>Chinese</option>
            <option value="islamic" ${calendarState.type === 'islamic' ? 'selected' : ''}>Islamic</option>
          </select>
        </div>
      </div>
      <div class="calendar-grid">
        ${dayHeadersHTML}
        ${daysHTML}
      </div>
      <div class="calendar-events">
        <h3 class="events-header">Events for ${formatDate(calendarState.selectedDate)}</h3>
        <div class="events-list" id="events-list">
          ${generateEventsHTML(calendarState.selectedDate)}
        </div>
        
        <h3 class="events-header">Upcoming Events</h3>
        <div class="events-list" id="upcoming-events">
          ${sortEventsByDate(getUpcomingEvents())
            .map(event => `
              <div class="event-item" style="border-left: 4px solid ${event.color}">
                <div class="event-time">${formatDate(event.date, event.time)}</div>
                <div class="event-title">${event.title}</div>
              </div>
            `).join('')}
        </div>
      </div>
    </div>
  `;
}

// Format date for display
function formatDate(date) {
  const options = { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' };
  return date.toLocaleDateString('en-US', options);
}

// Generate events HTML for selected date
function generateEventsHTML(date) {
  const formattedDate = `${date.getFullYear()}-${(date.getMonth() + 1).toString().padStart(2, '0')}-${date.getDate().toString().padStart(2, '0')}`;

  const events = calendarState.events.filter(event => event.date === formattedDate);

  if (events.length === 0) {
    return '<div class="no-events">No events for this day</div>';
  }

  let eventsHTML = '';
  events.forEach(event => {
    eventsHTML += `
      <div class="event-item" style="border-left: 4px solid ${event.color}">
        <div class="event-time">${event.time || 'All day'}</div>
        <div class="event-title">${event.title}</div>
      </div>
    `;
  });

  return eventsHTML;
}

// Handle calendar navigation (prev/next month)
function handleCalendarNavigation(direction) {
  const currentDate = calendarState.currentDate;
  const newDate = new Date(currentDate);

  if (direction === 'prev') {
    newDate.setMonth(currentDate.getMonth() - 1);
  } else {
    newDate.setMonth(currentDate.getMonth() + 1);
  }

  calendarState.currentDate = newDate;
  renderCalendar();
}

// Handle calendar type change
function handleCalendarTypeChange(e) {
  calendarState.type = e.target.value;
  renderCalendar();
}

// Handle date selection
function handleDateSelection(e) {
  const target = e.target.closest('.calendar-day');
  if (!target || target.classList.contains('empty')) return;

  const dateStr = target.dataset.date;
  if (dateStr) {
    const [year, month, day] = dateStr.split('-');
    calendarState.selectedDate = new Date(year, month - 1, day);
    renderCalendar();
  }
}

// Render calendar
function renderCalendar() {
  const calendarTab = document.querySelector('.tab-content[data-tab="calendar"]');
  if (!calendarTab) return;

  calendarTab.innerHTML = generateCalendarHTML();

  // Add event listeners
  calendarTab.querySelector('.prev-month-btn').addEventListener('click', () => handleCalendarNavigation('prev'));
  calendarTab.querySelector('.next-month-btn').addEventListener('click', () => handleCalendarNavigation('next'));
  calendarTab.querySelector('#calendar-type').addEventListener('change', handleCalendarTypeChange);

  // Add event listeners to date cells
  const dateCells = calendarTab.querySelectorAll('.calendar-day:not(.empty)');
  dateCells.forEach(cell => {
    cell.addEventListener('click', handleDateSelection);
  });
}


// Load events from tasks
function loadEventsFromTasks() {
  // Get priority colors from task intelligence system
  const priorityColors = {
    high: '#e53935',    // red
    medium: '#fb8c00',  // orange
    low: '#43a047'      // green
  };

  try {
    // Try to load tasks from localStorage
    const savedTasks = localStorage.getItem('tasks');
    if (savedTasks) {
      const tasks = JSON.parse(savedTasks);

      // Convert tasks to events with priority colors
      calendarState.events = tasks.map(task => ({
        id: task.id,
        title: task.title,
        date: task.dueDate,
        color: priorityColors[task.priority] || '#757575',
        time: task.dueTime || ''
      }));
    } else {
      // Fallback sample events
      calendarState.events = [
        {
          id: '1',
          title: 'Complete project proposal',
          date: '2025-04-15',
          color: priorityColors.high,
          time: '2:00 PM'
        },
        {
          id: '2',
          title: 'Buy groceries',
          date: '2025-04-12',
          color: priorityColors.medium
        },
        {
          id: '3',
          title: 'Call mom',
          date: '2025-04-13',
          color: priorityColors.low,
          time: '6:30 PM'
        }
      ];
    }
  } catch (e) {
    console.error('Error loading tasks for calendar:', e);
    calendarState.events = [];
  }

  try {
    // Try to load tasks from localStorage
    const savedTasks = localStorage.getItem('tasks');
    if (savedTasks) {
      const tasks = JSON.parse(savedTasks);

      // Convert tasks to events
      const taskEvents = tasks.map(task => ({
        id: task.id,
        title: task.title,
        date: task.dueDate,
        color: task.color,
        time: '' // We don't have time in tasks yet
      }));

      // Merge with existing events
      calendarState.events = taskEvents;
    }
  } catch (e) {
    console.error('Error loading tasks for calendar:', e);
  }
}

// Initialize calendar
document.addEventListener('DOMContentLoaded', function() {
  loadEventsFromTasks();
  renderCalendar();
});

// Show event creation form
function showEventForm() {
  const modal = document.createElement('div');
  modal.id = 'event-form-modal';
  modal.className = 'modal-overlay';
  modal.innerHTML = `
    <div class="modal-content">
      <div class="modal-header">
        <h2>Add Event</h2>
        <button class="modal-close-btn">&times;</button>
      </div>
      <div class="modal-body">
        <form id="event-form">
          <div class="form-group">
            <label for="event-title">Title</label>
            <input type="text" id="event-title" required>
          </div>
          <div class="form-group">
            <label for="event-date">Date</label>
            <input type="date" id="event-date" required>
          </div>
          <div class="form-group">
            <label for="event-time">Time</label>
            <input type="time" id="event-time">
          </div>
          <div class="form-group">
            <label>Priority</label>
            <div class="priority-options">
              <label class="priority-option">
                <input type="radio" name="priority" value="high">
                <span class="priority-label" style="background-color: #e53935">High</span>
              </label>
              <label class="priority-option">
                <input type="radio" name="priority" value="medium" checked>
                <span class="priority-label" style="background-color: #fb8c00">Medium</span>
              </label>
              <label class="priority-option">
                <input type="radio" name="priority" value="low">
                <span class="priority-label" style="background-color: #43a047">Low</span>
              </label>
            </div>
          </div>
          <div class="form-actions">
            <button type="button" class="btn-cancel">Cancel</button>
            <button type="submit" class="btn-save">Save Event</button>
          </div>
        </form>
      </div>
    </div>
  `;

  document.body.appendChild(modal);
  
  // Activate modal immediately
  modal.classList.add('active');

  // Event handlers
  const form = modal.querySelector('#event-form');
  const closeBtn = modal.querySelector('.modal-close-btn');
  const cancelBtn = modal.querySelector('.btn-cancel');

  closeBtn.addEventListener('click', () => modal.remove());
  cancelBtn.addEventListener('click', () => modal.remove());
  modal.addEventListener('click', (e) => {
    if (e.target === modal) modal.remove();
  });

  form.addEventListener('submit', (e) => {
    e.preventDefault();
    
    const title = form.querySelector('#event-title').value;
    const date = form.querySelector('#event-date').value;
    const time = form.querySelector('#event-time').value;
    const priority = form.querySelector('input[name="priority"]:checked').value;

    // Get existing tasks/events
    let tasks = JSON.parse(localStorage.getItem('tasks') || '[]');
    
    // Create new event
    const newEvent = {
      id: Date.now().toString(),
      title: title,
      dueDate: date,
      dueTime: time,
      priority: priority,
      completed: false,
      isEvent: true
    };
    
    // Add to tasks array
    tasks.push(newEvent);
    
    // Save back to localStorage
    localStorage.setItem('tasks', JSON.stringify(tasks));
    
    // Refresh calendar
    loadEventsFromTasks();
    renderCalendar();
    
    // Close modal
    modal.remove();
  });
}