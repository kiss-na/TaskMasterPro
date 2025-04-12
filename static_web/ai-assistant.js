/**
 * AI Assistant for Task Manager
 * Allows users to interact with the app using natural language
 * Supports text and voice input
 */

class AIAssistant {
  constructor() {
    this.container = null;
    this.inputField = null;
    this.responseElement = null;
    this.suggestionsElement = null;
    this.isRecording = false;
    this.speechRecognition = null;
    this.loadingIndicator = null;
    this.toggleButton = null;
    this.expanded = false;
    this.suggestedCommands = [
      "Add a task to buy groceries tomorrow",
      "Schedule a meeting with John on Friday",
      "Show all my high priority tasks",
      "Create a note about project ideas",
      "Remind me to call mom on Saturday"
    ];
    
    this.initSpeechRecognition();
  }
  
  initSpeechRecognition() {
    if ('webkitSpeechRecognition' in window || 'SpeechRecognition' in window) {
      // Create speech recognition instance
      const SpeechRecognition = window.SpeechRecognition || window.webkitSpeechRecognition;
      this.speechRecognition = new SpeechRecognition();
      this.speechRecognition.continuous = false;
      this.speechRecognition.interimResults = false;
      this.speechRecognition.lang = 'en-US';
      
      // Configure speech recognition events
      this.speechRecognition.onresult = (event) => {
        const transcript = event.results[0][0].transcript;
        this.inputField.value = transcript;
        this.stopRecording();
        this.processCommand(transcript);
      };
      
      this.speechRecognition.onerror = (event) => {
        console.error("Speech recognition error", event.error);
        this.stopRecording();
        this.showResponse("Sorry, I couldn't hear you. Please try again or type your request.");
      };
      
      this.speechRecognition.onend = () => {
        this.stopRecording();
      };
    }
  }
  
  initialize() {
    // Create and insert AI assistant HTML
    this.createHTML();
    
    // Add event listeners
    this.addEventListeners();
    
    // Initially show suggestions
    this.showSuggestions();
  }
  
  createHTML() {
    // Create the container
    this.container = document.createElement('div');
    this.container.className = 'ai-assistant-container';
    
    // Create the header
    const header = document.createElement('div');
    header.className = 'ai-assistant-header';
    
    const title = document.createElement('div');
    title.className = 'ai-assistant-title';
    title.innerHTML = '<i class="material-icons">smart_toy</i> AI Assistant';
    
    this.toggleButton = document.createElement('button');
    this.toggleButton.className = 'ai-assistant-toggle';
    this.toggleButton.innerHTML = '<i class="material-icons">expand_more</i>';
    
    header.appendChild(title);
    header.appendChild(this.toggleButton);
    
    // Create the content area
    const content = document.createElement('div');
    content.className = 'ai-assistant-content';
    
    // Create input container
    const inputContainer = document.createElement('div');
    inputContainer.className = 'ai-assistant-input-container';
    
    this.inputField = document.createElement('input');
    this.inputField.type = 'text';
    this.inputField.className = 'ai-assistant-input';
    this.inputField.placeholder = 'Ask me anything or give me a command...';
    
    const micButton = document.createElement('button');
    micButton.className = 'ai-assistant-btn';
    micButton.id = 'ai-mic-btn';
    micButton.innerHTML = '<i class="material-icons">mic</i>';
    
    const sendButton = document.createElement('button');
    sendButton.className = 'ai-assistant-btn primary';
    sendButton.id = 'ai-send-btn';
    sendButton.innerHTML = '<i class="material-icons">send</i>';
    
    inputContainer.appendChild(this.inputField);
    inputContainer.appendChild(micButton);
    inputContainer.appendChild(sendButton);
    
    // Create response area
    this.responseElement = document.createElement('div');
    this.responseElement.className = 'ai-assistant-response';
    this.responseElement.style.display = 'none';
    
    // Create loading indicator
    this.loadingIndicator = document.createElement('div');
    this.loadingIndicator.className = 'ai-loading';
    this.loadingIndicator.style.display = 'none';
    
    // Create suggestions
    this.suggestionsElement = document.createElement('div');
    this.suggestionsElement.className = 'ai-assistant-actions';
    
    // Add everything to content
    content.appendChild(inputContainer);
    content.appendChild(this.loadingIndicator);
    content.appendChild(this.responseElement);
    content.appendChild(this.suggestionsElement);
    
    // Add everything to container
    this.container.appendChild(header);
    this.container.appendChild(content);
    
    // Insert the container into the DOM
    const appHeader = document.querySelector('.app-header');
    appHeader.parentNode.insertBefore(this.container, appHeader.nextSibling);
  }
  
  addEventListeners() {
    // Toggle expand/collapse
    this.toggleButton.addEventListener('click', () => this.toggleExpand());
    
    // Send button click
    document.getElementById('ai-send-btn').addEventListener('click', () => {
      const command = this.inputField.value.trim();
      if (command) {
        this.processCommand(command);
      }
    });
    
    // Mic button click
    document.getElementById('ai-mic-btn').addEventListener('click', () => {
      if (this.isRecording) {
        this.stopRecording();
      } else {
        this.startRecording();
      }
    });
    
    // Input field enter key
    this.inputField.addEventListener('keypress', (e) => {
      if (e.key === 'Enter') {
        const command = this.inputField.value.trim();
        if (command) {
          this.processCommand(command);
        }
      }
    });
  }
  
  toggleExpand() {
    this.expanded = !this.expanded;
    this.container.classList.toggle('expanded', this.expanded);
    this.toggleButton.innerHTML = this.expanded ? 
      '<i class="material-icons">expand_less</i>' : 
      '<i class="material-icons">expand_more</i>';
  }
  
  startRecording() {
    if (!this.speechRecognition) {
      this.showResponse("Speech recognition is not supported in your browser.");
      return;
    }
    
    try {
      this.speechRecognition.start();
      this.isRecording = true;
      document.getElementById('ai-mic-btn').classList.add('recording');
      document.getElementById('ai-mic-btn').innerHTML = '<i class="material-icons">mic</i>';
      this.showResponse("Listening...");
    } catch (error) {
      console.error("Error starting speech recognition:", error);
      this.showResponse("Couldn't start listening. Please try again.");
    }
  }
  
  stopRecording() {
    if (this.isRecording && this.speechRecognition) {
      this.speechRecognition.stop();
    }
    this.isRecording = false;
    document.getElementById('ai-mic-btn').classList.remove('recording');
    document.getElementById('ai-mic-btn').innerHTML = '<i class="material-icons">mic</i>';
  }
  
  showLoading() {
    this.loadingIndicator.style.display = 'block';
    this.responseElement.style.display = 'none';
    this.suggestionsElement.style.display = 'none';
  }
  
  hideLoading() {
    this.loadingIndicator.style.display = 'none';
  }
  
  showResponse(message) {
    this.responseElement.innerHTML = message;
    this.responseElement.style.display = 'block';
    this.hideLoading();
  }
  
  showSuggestions() {
    this.suggestionsElement.innerHTML = '';
    this.suggestionsElement.style.display = 'flex';
    
    this.suggestedCommands.forEach(command => {
      const chip = document.createElement('div');
      chip.className = 'ai-suggestion-chip';
      chip.textContent = command;
      chip.addEventListener('click', () => {
        this.inputField.value = command;
        this.processCommand(command);
      });
      this.suggestionsElement.appendChild(chip);
    });
  }
  
  async processCommand(command) {
    // Ensure the assistant is expanded when processing a command
    if (!this.expanded) {
      this.toggleExpand();
    }
    
    this.showLoading();
    
    try {
      // Parse the command to understand the user's intent
      const intent = await this.parseIntent(command);
      
      // Execute the command based on the intent
      const result = await this.executeCommand(intent);
      
      // Show the result
      this.showResponse(result);
      
      // Clear the input field
      this.inputField.value = '';
      
      // Show suggestions after a delay
      setTimeout(() => {
        this.showSuggestions();
      }, 3000);
      
    } catch (error) {
      console.error("Error processing command:", error);
      this.showResponse("I'm sorry, I couldn't process your request. Please try again.");
    }
  }
  
  async parseIntent(command) {
    // Use the AI Service for better natural language understanding
    if (window.aiService) {
      try {
        return await window.aiService.processCommand(command);
      } catch (error) {
        console.error("Error using AI service:", error);
        // Fall back to basic NLP on error
      }
    }
    
    // Fallback in case AI service is not available
    console.log("Using fallback NLP (AI service unavailable)");
    return {
      action: 'create',
      entityType: 'task',
      details: {
        title: command
      },
      originalCommand: command
    };
  }
  
  async executeCommand(intent) {
    console.log("Executing command with intent:", intent);
    
    // Based on the intent, execute the appropriate action
    switch (intent.action) {
      case 'create':
        return this.createEntity(intent);
      case 'update':
        return this.updateEntity(intent);
      case 'delete':
        return this.deleteEntity(intent);
      case 'search':
        return this.searchEntities(intent);
      default:
        return "I'm not sure what you want me to do. Please try rephrasing your request.";
    }
  }
  
  async createEntity(intent) {
    switch (intent.entityType) {
      case 'task':
        return this.createTask(intent);
      case 'note':
        return this.createNote(intent);
      case 'reminder':
        return this.createReminder(intent);
      case 'event':
        return this.createEvent(intent);
      default:
        return "I'm not sure what you want me to create. Please try again.";
    }
  }
  
  createTask(intent) {
    try {
      // Get tasks from storage
      let tasks = JSON.parse(localStorage.getItem('tasks') || '[]');
      
      // Create a new task object
      const newTask = {
        id: Date.now().toString(),
        title: intent.details.title || "New Task",
        completed: false,
        date: intent.details.date || "",
        time: "",
        priority: intent.details.priority || "medium",
        location: "",
        contact: "",
        email: "",
        reminder: false
      };
      
      // Add the new task
      tasks.push(newTask);
      
      // Save to localStorage
      localStorage.setItem('tasks', JSON.stringify(tasks));
      
      // Refresh the tasks display if we're on the tasks tab
      if (currentTab === 'tasks') {
        renderTasks();
      }
      
      return `Created a new task: "${newTask.title}"${newTask.date ? ' on ' + formatDate(newTask.date, '') : ''}.`;
    } catch (error) {
      console.error("Error creating task:", error);
      return "I couldn't create the task. Please try again.";
    }
  }
  
  createNote(intent) {
    try {
      // Get notes from storage
      let notes = JSON.parse(localStorage.getItem('notes') || '[]');
      
      // Create a new note object
      const newNote = {
        id: Date.now().toString(),
        title: intent.details.title?.split(' ').slice(0, 5).join(' ') || "New Note",
        content: intent.details.title || "",
        color: "#ffffff",
        archived: false,
        createdAt: new Date().toISOString()
      };
      
      // Add the new note
      notes.push(newNote);
      
      // Save to localStorage
      localStorage.setItem('notes', JSON.stringify(notes));
      
      // Refresh the notes display if we're on the notes tab
      if (currentTab === 'notes') {
        renderNotes();
      }
      
      return `Created a new note: "${newNote.title}"`;
    } catch (error) {
      console.error("Error creating note:", error);
      return "I couldn't create the note. Please try again.";
    }
  }
  
  createReminder(intent) {
    try {
      // Get reminders from storage
      let reminders = JSON.parse(localStorage.getItem('reminders') || '[]');
      
      // Create a new reminder object
      const newReminder = {
        id: Date.now().toString(),
        title: intent.details.title || "New Reminder",
        completed: false,
        date: intent.details.date || getTodayDate(),
        time: "12:00",
        type: "task",
        frequency: "once",
        priority: intent.details.priority || "medium"
      };
      
      // Add the new reminder
      reminders.push(newReminder);
      
      // Save to localStorage
      localStorage.setItem('reminders', JSON.stringify(reminders));
      
      // Refresh the reminders display if we're on the reminders tab
      if (currentTab === 'reminders') {
        renderReminders();
      }
      
      return `Created a new reminder: "${newReminder.title}" on ${formatDate(newReminder.date)}.`;
    } catch (error) {
      console.error("Error creating reminder:", error);
      return "I couldn't create the reminder. Please try again.";
    }
  }
  
  createEvent(intent) {
    try {
      // Since events are stored with tasks, get tasks from storage
      let tasks = JSON.parse(localStorage.getItem('tasks') || '[]');
      
      // Create a new event (task with calendar flag)
      const newEvent = {
        id: Date.now().toString(),
        title: intent.details.title || "New Event",
        completed: false,
        date: intent.details.date || getTodayDate(),
        time: "12:00",
        priority: intent.details.priority || "medium",
        location: "",
        contact: "",
        email: "",
        reminder: false,
        isEvent: true
      };
      
      // Add the new event
      tasks.push(newEvent);
      
      // Save to localStorage
      localStorage.setItem('tasks', JSON.stringify(tasks));
      
      // Refresh the display based on active tab
      if (currentTab === 'tasks') {
        renderTasks();
      } else if (currentTab === 'calendar') {
        renderCalendar();
      }
      
      return `Created a new event: "${newEvent.title}" on ${formatDate(newEvent.date)}.`;
    } catch (error) {
      console.error("Error creating event:", error);
      return "I couldn't create the event. Please try again.";
    }
  }
  
  updateEntity(intent) {
    return "I understand you want to update something. This functionality is coming soon.";
  }
  
  deleteEntity(intent) {
    return "I understand you want to delete something. This functionality is coming soon.";
  }
  
  searchEntities(intent) {
    switch (intent.entityType) {
      case 'task':
        return this.searchTasks(intent);
      case 'note':
        return this.searchNotes(intent);
      case 'reminder':
        return this.searchReminders(intent);
      case 'event':
        return this.searchEvents(intent);
      default:
        return this.generalSearch(intent);
    }
  }
  
  searchTasks(intent) {
    try {
      // Get tasks from storage
      const tasks = JSON.parse(localStorage.getItem('tasks') || '[]');
      
      // Filter tasks based on priority if specified
      let filteredTasks = tasks;
      if (intent.details.priority) {
        filteredTasks = tasks.filter(task => task.priority === intent.details.priority);
      }
      
      // Filter by date if specified
      if (intent.details.date) {
        filteredTasks = filteredTasks.filter(task => task.date === intent.details.date);
      }
      
      // Get tasks that aren't events
      filteredTasks = filteredTasks.filter(task => !task.isEvent);
      
      // Switch to tasks tab
      const tasksNavItem = document.querySelector('.nav-item[data-tab="tasks"]');
      if (tasksNavItem) {
        tasksNavItem.click();
      }
      
      if (filteredTasks.length === 0) {
        return "I couldn't find any tasks matching your criteria.";
      }
      
      // Create a message with the results
      let message = `Found ${filteredTasks.length} task(s):<br>`;
      filteredTasks.slice(0, 5).forEach(task => {
        message += `- ${task.title}${task.date ? ' (due: ' + formatDate(task.date, task.time) + ')' : ''}<br>`;
      });
      
      if (filteredTasks.length > 5) {
        message += `... and ${filteredTasks.length - 5} more.`;
      }
      
      return message;
    } catch (error) {
      console.error("Error searching tasks:", error);
      return "I couldn't search for tasks. Please try again.";
    }
  }
  
  searchNotes(intent) {
    try {
      // Get notes from storage
      const notes = JSON.parse(localStorage.getItem('notes') || '[]');
      
      // Switch to notes tab
      const notesNavItem = document.querySelector('.nav-item[data-tab="notes"]');
      if (notesNavItem) {
        notesNavItem.click();
      }
      
      if (notes.length === 0) {
        return "You don't have any notes yet.";
      }
      
      // Create a message with the results
      let message = `Found ${notes.length} note(s):<br>`;
      notes.slice(0, 5).forEach(note => {
        message += `- ${note.title}<br>`;
      });
      
      if (notes.length > 5) {
        message += `... and ${notes.length - 5} more.`;
      }
      
      return message;
    } catch (error) {
      console.error("Error searching notes:", error);
      return "I couldn't search for notes. Please try again.";
    }
  }
  
  searchReminders(intent) {
    try {
      // Get reminders from storage
      const reminders = JSON.parse(localStorage.getItem('reminders') || '[]');
      
      // Switch to reminders tab
      const remindersNavItem = document.querySelector('.nav-item[data-tab="reminders"]');
      if (remindersNavItem) {
        remindersNavItem.click();
      }
      
      if (reminders.length === 0) {
        return "You don't have any reminders yet.";
      }
      
      // Create a message with the results
      let message = `Found ${reminders.length} reminder(s):<br>`;
      reminders.slice(0, 5).forEach(reminder => {
        message += `- ${reminder.title} (${formatDate(reminder.date, reminder.time)})<br>`;
      });
      
      if (reminders.length > 5) {
        message += `... and ${reminders.length - 5} more.`;
      }
      
      return message;
    } catch (error) {
      console.error("Error searching reminders:", error);
      return "I couldn't search for reminders. Please try again.";
    }
  }
  
  searchEvents(intent) {
    try {
      // Get tasks from storage (events are stored with tasks)
      const tasks = JSON.parse(localStorage.getItem('tasks') || '[]');
      
      // Filter for events
      const events = tasks.filter(task => task.isEvent === true);
      
      // Switch to calendar tab
      const calendarNavItem = document.querySelector('.nav-item[data-tab="calendar"]');
      if (calendarNavItem) {
        calendarNavItem.click();
      }
      
      if (events.length === 0) {
        return "You don't have any events yet.";
      }
      
      // Create a message with the results
      let message = `Found ${events.length} event(s):<br>`;
      events.slice(0, 5).forEach(event => {
        message += `- ${event.title} (${formatDate(event.date, event.time)})<br>`;
      });
      
      if (events.length > 5) {
        message += `... and ${events.length - 5} more.`;
      }
      
      return message;
    } catch (error) {
      console.error("Error searching events:", error);
      return "I couldn't search for events. Please try again.";
    }
  }
  
  generalSearch(intent) {
    return "I understand you're looking for something. Please try to be more specific about what you're looking for.";
  }
  
  // Call this function when you want to integrate with an AI service
  async callAIService(command) {
    // For now, we'll just return a placeholder response
    // In a real implementation, this would call a service like OpenAI or Anthropic
    return {
      action: "create",
      entityType: "task",
      details: {
        title: command,
        priority: "medium"
      },
      originalCommand: command
    };
  }
}

// Initialize the AI Assistant when the DOM is loaded
document.addEventListener('DOMContentLoaded', function() {
  // Initialize the AI Assistant
  const aiAssistant = new AIAssistant();
  aiAssistant.initialize();
  
  // Make it available globally
  window.aiAssistant = aiAssistant;
});