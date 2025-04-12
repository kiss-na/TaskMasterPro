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
  // Add empty cells for days before the first day of the month
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
  
  // Build the calendar
  return `
    <div class="calendar-container">
      <div class="calendar-header">
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
  // This function would normally synchronize with tasks data
  // For this demo, we'll just use some sample events
  
  calendarState.events = [
    {
      id: '1',
      title: 'Complete project proposal',
      date: '2025-04-15',
      color: '#e53935',
      time: '2:00 PM'
    },
    {
      id: '2',
      title: 'Buy groceries',
      date: '2025-04-12',
      color: '#fb8c00'
    },
    {
      id: '3',
      title: 'Call mom',
      date: '2025-04-13',
      color: '#43a047',
      time: '6:30 PM'
    }
  ];
  
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
});