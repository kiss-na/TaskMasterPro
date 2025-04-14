/**
 * Task Intelligence System
 * Handles task categorization, tagging, and intelligent suggestions
 */

const TaskIntelligence = {
  // Task categories with their respective icons and colors
  categories: {
    work: { 
      name: 'Work', 
      icon: 'business_center',
      color: '#1976d2', // blue
      keywords: ['meeting', 'presentation', 'report', 'client', 'project', 'deadline', 'boss', 'email', 'office']
    },
    personal: { 
      name: 'Personal', 
      icon: 'person',
      color: '#7b1fa2', // purple
      keywords: ['gym', 'workout', 'exercise', 'hobby', 'read', 'book', 'movie', 'show', 'watch', 'call', 'friend']
    },
    shopping: { 
      name: 'Shopping', 
      icon: 'shopping_cart',
      color: '#c2185b', // pink
      keywords: ['buy', 'purchase', 'shop', 'store', 'grocery', 'groceries', 'mall', 'online', 'order', 'amazon']
    },
    health: { 
      name: 'Health', 
      icon: 'favorite',
      color: '#d32f2f', // red
      keywords: ['doctor', 'appointment', 'medicine', 'pill', 'vitamin', 'dentist', 'workout', 'run', 'jog', 'exercise']
    },
    home: { 
      name: 'Home', 
      icon: 'home',
      color: '#388e3c', // green
      keywords: ['clean', 'laundry', 'dishes', 'repair', 'fix', 'garden', 'cook', 'vacuum', 'mow', 'lawn']
    },
    education: { 
      name: 'Education', 
      icon: 'school',
      color: '#f57c00', // orange
      keywords: ['study', 'homework', 'assignment', 'exam', 'test', 'class', 'lecture', 'course', 'learn', 'read', 'book']
    },
    travel: { 
      name: 'Travel', 
      icon: 'flight',
      color: '#0097a7', // teal
      keywords: ['trip', 'vacation', 'flight', 'hotel', 'booking', 'passport', 'pack', 'suitcase', 'reservation']
    },
    finance: { 
      name: 'Finance', 
      icon: 'account_balance',
      color: '#689f38', // light green
      keywords: ['bank', 'pay', 'bill', 'tax', 'investment', 'money', 'budget', 'expense', 'save', 'loan', 'credit']
    },
    social: { 
      name: 'Social', 
      icon: 'people',
      color: '#00796b', // teal
      keywords: ['friend', 'party', 'celebration', 'dinner', 'lunch', 'meet', 'date', 'gathering', 'birthday']
    },
    other: { 
      name: 'Other', 
      icon: 'more_horiz',
      color: '#757575', // gray
      keywords: []
    }
  },
  
  // Custom tags entered by the user
  customTags: [],
  
  // Initialize task intelligence features
  init: function() {
    // Load custom tags from localStorage
    this.loadCustomTags();
    
    // Set up UI elements
    this.setupCategoryUI();
    
    // Set up event listeners
    this.setupEventListeners();
    
    console.log('Task Intelligence initialized');
    
    // Run initial analysis on existing tasks
    this.analyzeExistingTasks();
  },
  
  // Load custom tags from localStorage
  loadCustomTags: function() {
    const savedTags = localStorage.getItem('taskCustomTags');
    
    if (savedTags) {
      try {
        this.customTags = JSON.parse(savedTags);
      } catch (error) {
        console.error('Error loading custom tags:', error);
        this.customTags = [];
      }
    }
  },
  
  // Save custom tags to localStorage
  saveCustomTags: function() {
    localStorage.setItem('taskCustomTags', JSON.stringify(this.customTags));
  },
  
  // Set up category UI elements
  setupCategoryUI: function() {
    // Add category filter to task list header if it doesn't exist
    const taskFilter = document.querySelector('.task-filter');
    
    if (taskFilter && !document.getElementById('task-category-filter')) {
      const categoryFilterHTML = `
        <select id="task-category-filter">
          <option value="all">All Categories</option>
          ${Object.entries(this.categories).map(([id, category]) => 
            `<option value="${id}">${category.name}</option>`
          ).join('')}
        </select>
      `;
      
      taskFilter.insertAdjacentHTML('beforeend', categoryFilterHTML);
      
      // Add change event handler
      document.getElementById('task-category-filter').addEventListener('change', function(e) {
        const category = e.target.value;
        TaskIntelligence.filterTasksByCategory(category);
      });
    }
  },
  
  // Set up event listeners
  setupEventListeners: function() {
    // Listen for the task form being shown
    document.addEventListener('taskFormShown', (e) => {
      const form = e.detail.form;
      const isEditing = e.detail.isEditing;
      
      // Add category and tag fields to the form
      this.enhanceTaskForm(form, isEditing);
    });
    
    // Listen for task saved event
    document.addEventListener('taskSaved', (e) => {
      const task = e.detail.task;
      
      // Process any new tags
      if (task.tags && Array.isArray(task.tags)) {
        this.processNewTags(task.tags);
      }
      
      // Generate suggestions based on the new/updated task
      this.generateSuggestions();
    });
  },
  
  // Enhance the task form with category and tag fields
  enhanceTaskForm: function(form, isEditing) {
    const task = isEditing ? form._taskData : null;
    
    // Find the location where we want to insert our new fields
    // We'll add it after the priority section
    const prioritySection = form.querySelector('.priority-options').closest('.form-group');
    
    if (!prioritySection) return;
    
    // Create category selector HTML
    const categoryOptions = Object.entries(this.categories).map(([id, category]) => {
      const selected = task && task.category === id ? 'selected' : '';
      return `<option value="${id}" data-icon="${category.icon}" ${selected}>${category.name}</option>`;
    }).join('');
    
    // Create tag selector HTML
    // Combine preset categories and custom tags for tag suggestions
    const allTags = this.getAllTagSuggestions();
    const selectedTags = task && task.tags ? task.tags : [];
    
    // Create the category and tags section HTML
    const categoryTagsHTML = `
      <div class="form-group">
        <div class="input-with-icon">
          <span class="input-icon"><i class="material-icons">category</i></span>
          <select id="task-category" class="enhanced-select">
            ${categoryOptions}
          </select>
        </div>
      </div>
      
      <div class="form-group">
        <div class="tag-input-container">
          <div class="input-with-icon">
            <span class="input-icon"><i class="material-icons">local_offer</i></span>
            <input type="text" id="tag-input" placeholder="Add tags (comma separated)">
          </div>
          <div id="tags-container" class="tags-container">
            ${selectedTags.map(tag => `
              <span class="tag" data-tag="${tag}">
                ${tag}
                <i class="material-icons tag-remove">close</i>
              </span>
            `).join('')}
          </div>
          <div id="tag-suggestions" class="tag-suggestions">
            ${allTags.slice(0, 8).map(tag => `
              <span class="tag-suggestion" data-tag="${tag}">${tag}</span>
            `).join('')}
          </div>
          <input type="hidden" id="task-tags" value="${selectedTags.join(',')}">
        </div>
      </div>
    `;
    
    // Insert after priority section
    prioritySection.insertAdjacentHTML('afterend', categoryTagsHTML);
    
    // Add event handlers for tag input
    const tagInput = document.getElementById('tag-input');
    const tagsContainer = document.getElementById('tags-container');
    const tagSuggestions = document.getElementById('tag-suggestions');
    const hiddenTagsInput = document.getElementById('task-tags');
    
    // Add tag when Enter is pressed or comma is typed
    tagInput.addEventListener('keyup', function(e) {
      const value = this.value.trim();
      
      // Show tag suggestions based on input
      if (value && value.length >= 2) {
        const suggestions = TaskIntelligence.getTagSuggestions(value);
        tagSuggestions.innerHTML = suggestions.slice(0, 8).map(tag => 
          `<span class="tag-suggestion" data-tag="${tag}">${tag}</span>`
        ).join('');
        tagSuggestions.style.display = 'flex';
      } else {
        tagSuggestions.style.display = 'none';
      }
      
      // Add tag on Enter or comma
      if ((e.key === 'Enter' || e.key === ',') && value) {
        e.preventDefault();
        
        // Remove comma if present
        const tagText = value.replace(/,/g, '').trim();
        
        if (tagText) {
          // Add tag to UI
          TaskIntelligence.addTagToUI(tagText, tagsContainer, hiddenTagsInput);
          
          // Clear input
          tagInput.value = '';
          
          // Hide suggestions
          tagSuggestions.style.display = 'none';
        }
      }
    });
    
    // Handle clicking on a tag suggestion
    tagSuggestions.addEventListener('click', function(e) {
      const suggestion = e.target.closest('.tag-suggestion');
      
      if (suggestion) {
        const tagText = suggestion.dataset.tag;
        
        // Add tag to UI
        TaskIntelligence.addTagToUI(tagText, tagsContainer, hiddenTagsInput);
        
        // Clear input
        tagInput.value = '';
        
        // Hide suggestions
        tagSuggestions.style.display = 'none';
      }
    });
    
    // Handle removing tags
    tagsContainer.addEventListener('click', function(e) {
      const tagRemove = e.target.closest('.tag-remove');
      
      if (tagRemove) {
        const tag = tagRemove.closest('.tag');
        
        if (tag) {
          // Remove tag from UI
          tag.remove();
          
          // Update hidden input value
          TaskIntelligence.updateHiddenTagsInput(hiddenTagsInput, tagsContainer);
        }
      }
    });
    
    // Change category icon when selection changes
    const categorySelect = document.getElementById('task-category');
    const updateCategoryIcon = () => {
      const selected = categorySelect.options[categorySelect.selectedIndex];
      const icon = selected.dataset.icon || 'category';
      
      const iconElement = categorySelect.previousElementSibling.querySelector('i');
      if (iconElement) {
        iconElement.textContent = icon;
      }
    };
    
    // Initialize icon
    updateCategoryIcon();
    
    // Update icon when selection changes
    categorySelect.addEventListener('change', updateCategoryIcon);
    
    // Store reference to original form submit handler
    const originalSubmitHandler = form.onsubmit;
    
    // Override form submit to include category and tags
    form.onsubmit = function(e) {
      // Get category and tags
      const category = document.getElementById('task-category').value;
      const tags = document.getElementById('task-tags').value.split(',').filter(tag => tag.trim());
      
      // Store form data so it can be accessed in the task saved event
      form._additionalData = {
        category: category,
        tags: tags
      };
      
      // Call original handler
      if (typeof originalSubmitHandler === 'function') {
        return originalSubmitHandler.call(this, e);
      }
    };
  },
  
  // Add a tag to the UI
  addTagToUI: function(tagText, tagsContainer, hiddenTagsInput) {
    // Check if tag already exists
    const existingTags = Array.from(tagsContainer.querySelectorAll('.tag'))
      .map(tag => tag.dataset.tag);
    
    if (!existingTags.includes(tagText)) {
      // Create tag element
      const tagHTML = `
        <span class="tag" data-tag="${tagText}">
          ${tagText}
          <i class="material-icons tag-remove">close</i>
        </span>
      `;
      
      // Add to container
      tagsContainer.insertAdjacentHTML('beforeend', tagHTML);
      
      // Update hidden input
      this.updateHiddenTagsInput(hiddenTagsInput, tagsContainer);
    }
  },
  
  // Update the hidden tags input
  updateHiddenTagsInput: function(hiddenInput, tagsContainer) {
    const tags = Array.from(tagsContainer.querySelectorAll('.tag'))
      .map(tag => tag.dataset.tag);
    
    hiddenInput.value = tags.join(',');
  },
  
  // Process new tags from a saved task
  processNewTags: function(tags) {
    if (!tags || !Array.isArray(tags)) return;
    
    // Add any new tags to our custom tags list
    tags.forEach(tag => {
      if (!this.customTags.includes(tag)) {
        this.customTags.push(tag);
      }
    });
    
    // Save updated custom tags
    this.saveCustomTags();
  },
  
  // Get all tag suggestions (combining category keywords and custom tags)
  getAllTagSuggestions: function() {
    // Get all category keywords
    const categoryKeywords = Object.values(this.categories)
      .flatMap(category => category.keywords);
    
    // Combine with custom tags and remove duplicates
    return [...new Set([...categoryKeywords, ...this.customTags])];
  },
  
  // Get tag suggestions based on input
  getTagSuggestions: function(input) {
    if (!input) return [];
    
    const allTags = this.getAllTagSuggestions();
    const inputLower = input.toLowerCase();
    
    // Filter tags that include the input text
    return allTags.filter(tag => 
      tag.toLowerCase().includes(inputLower)
    );
  },
  
  // Analyze existing tasks for categorization and patterns
  analyzeExistingTasks: function() {
    // Get all tasks from localStorage
    const tasksJson = localStorage.getItem('tasks');
    if (!tasksJson) return;
    
    try {
      const tasks = JSON.parse(tasksJson);
      
      // Process each task
      tasks.forEach(task => {
        // If task doesn't have a category, try to auto-categorize it
        if (!task.category) {
          task.category = this.suggestCategoryForTask(task);
        }
        
        // If task doesn't have tags, suggest some
        if (!task.tags || !Array.isArray(task.tags) || task.tags.length === 0) {
          task.tags = this.suggestTagsForTask(task);
        }
      });
      
      // Save updated tasks
      localStorage.setItem('tasks', JSON.stringify(tasks));
      
    } catch (error) {
      console.error('Error analyzing existing tasks:', error);
    }
  },
  
  // Suggest a category for a task based on its content
  suggestCategoryForTask: function(task) {
    if (!task) return 'other';
    
    const text = `${task.title} ${task.description}`.toLowerCase();
    
    // Check each category's keywords
    const matches = Object.entries(this.categories).map(([id, category]) => {
      if (id === 'other') return { id, score: 0 }; // Skip "other" for scoring
      
      // Calculate match score based on keyword occurrences
      const score = category.keywords.reduce((total, keyword) => {
        const regex = new RegExp(keyword, 'gi');
        const matches = text.match(regex);
        return total + (matches ? matches.length * 2 : 0);
      }, 0);
      
      return { id, score };
    });
    
    // Sort by score
    matches.sort((a, b) => b.score - a.score);
    
    // Return highest scoring category, or 'other' if no matches
    return matches[0].score > 0 ? matches[0].id : 'other';
  },
  
  // Suggest tags for a task based on its content
  suggestTagsForTask: function(task) {
    if (!task) return [];
    
    const text = `${task.title} ${task.description}`.toLowerCase();
    const suggestedTags = [];
    
    // Check all category keywords
    Object.values(this.categories).forEach(category => {
      category.keywords.forEach(keyword => {
        if (text.includes(keyword) && !suggestedTags.includes(keyword)) {
          suggestedTags.push(keyword);
        }
      });
    });
    
    // Limit to 5 tags
    return suggestedTags.slice(0, 5);
  },
  
  // Filter tasks by category
  filterTasksByCategory: function(category) {
    const taskItems = document.querySelectorAll('.task-item');
    
    if (category === 'all') {
      // Show all tasks
      taskItems.forEach(item => {
        item.style.display = '';
      });
    } else {
      // Filter tasks by category
      taskItems.forEach(item => {
        const taskId = item.dataset.id;
        const taskCategory = item.dataset.category || 'other';
        
        if (taskCategory === category) {
          item.style.display = '';
        } else {
          item.style.display = 'none';
        }
      });
    }
  },
  
  // Generate intelligent suggestions based on task patterns
  generateSuggestions: function() {
    // Get all tasks from localStorage
    const tasksJson = localStorage.getItem('tasks');
    if (!tasksJson) return;
    
    try {
      const tasks = JSON.parse(tasksJson);
      
      // Process patterns
      const patterns = this.analyzeTaskPatterns(tasks);
      
      // Generate suggestions from patterns
      const suggestions = this.createSuggestionsFromPatterns(patterns, tasks);
      
      // Store suggestions
      localStorage.setItem('taskSuggestions', JSON.stringify(suggestions));
      
      // Display suggestions notification if we have any
      if (suggestions.length > 0) {
        this.showSuggestionsNotification(suggestions.length);
      }
      
    } catch (error) {
      console.error('Error generating suggestions:', error);
    }
  },
  
  // Analyze tasks for patterns
  analyzeTaskPatterns: function(tasks) {
    const patterns = {
      recurring: [],    // Tasks that occur at regular intervals
      related: [],      // Tasks that are commonly done together
      forgotten: [],    // Tasks that are often incomplete
      categorical: []   // Tasks of the same category
    };
    
    // Find recurring tasks (e.g., weekly, monthly patterns)
    const recurringCandidates = tasks.filter(task => 
      task.title && tasks.filter(t => 
        t.title.toLowerCase() === task.title.toLowerCase() && 
        t.id !== task.id
      ).length > 0
    );
    
    if (recurringCandidates.length > 0) {
      // Group recurring tasks by title
      const grouped = recurringCandidates.reduce((acc, task) => {
        const titleKey = task.title.toLowerCase();
        if (!acc[titleKey]) acc[titleKey] = [];
        acc[titleKey].push(task);
        return acc;
      }, {});
      
      // Analyze each group for patterns
      Object.values(grouped).forEach(group => {
        if (group.length < 2) return;
        
        // Sort by due date
        group.sort((a, b) => new Date(a.dueDate) - new Date(b.dueDate));
        
        // Check for consistent intervals
        const intervals = [];
        for (let i = 1; i < group.length; i++) {
          const prev = new Date(group[i-1].dueDate);
          const curr = new Date(group[i].dueDate);
          const diffDays = Math.round((curr - prev) / (1000 * 60 * 60 * 24));
          intervals.push(diffDays);
        }
        
        // Check if intervals are consistent (weekly, monthly, etc.)
        const avgInterval = intervals.reduce((sum, int) => sum + int, 0) / intervals.length;
        const intervalType = this.getIntervalType(avgInterval);
        
        if (intervalType) {
          patterns.recurring.push({
            title: group[0].title,
            interval: avgInterval,
            intervalType: intervalType,
            lastDate: group[group.length - 1].dueDate,
            category: group[0].category || this.suggestCategoryForTask(group[0]),
            tags: group[0].tags || []
          });
        }
      });
    }
    
    // Find related tasks (tasks frequently done close to each other)
    const dateClusters = {};
    tasks.forEach(task => {
      if (!task.dueDate) return;
      
      // Group tasks by date
      if (!dateClusters[task.dueDate]) dateClusters[task.dueDate] = [];
      dateClusters[task.dueDate].push(task);
    });
    
    // Look for common co-occurrences
    const coOccurrences = {};
    
    Object.values(dateClusters).forEach(cluster => {
      if (cluster.length < 2) return;
      
      // Check all pairs of tasks
      for (let i = 0; i < cluster.length; i++) {
        for (let j = i + 1; j < cluster.length; j++) {
          const task1 = cluster[i];
          const task2 = cluster[j];
          
          // Create a unique key for this pair
          const pairKey = [task1.title, task2.title].sort().join('::');
          
          if (!coOccurrences[pairKey]) {
            coOccurrences[pairKey] = {
              tasks: [task1.title, task2.title],
              count: 0
            };
          }
          
          coOccurrences[pairKey].count++;
        }
      }
    });
    
    // Filter for significant co-occurrences
    Object.values(coOccurrences).forEach(pair => {
      if (pair.count >= 2) { // At least occurred twice together
        patterns.related.push({
          titles: pair.tasks,
          count: pair.count
        });
      }
    });
    
    // Find forgotten or incomplete tasks
    const incompleteTasks = tasks.filter(task => 
      !task.isCompleted && 
      task.dueDate && 
      new Date(task.dueDate) < new Date()
    );
    
    if (incompleteTasks.length > 0) {
      patterns.forgotten = incompleteTasks.map(task => ({
        id: task.id,
        title: task.title,
        dueDate: task.dueDate,
        daysPast: Math.round((new Date() - new Date(task.dueDate)) / (1000 * 60 * 60 * 24))
      }));
    }
    
    // Find categorical patterns
    const categoryCounts = {};
    
    tasks.forEach(task => {
      const category = task.category || this.suggestCategoryForTask(task);
      
      if (!categoryCounts[category]) {
        categoryCounts[category] = {
          count: 0,
          completed: 0,
          avgDuration: 0,
          durations: []
        };
      }
      
      categoryCounts[category].count++;
      
      if (task.isCompleted) {
        categoryCounts[category].completed++;
      }
      
      // Track task durations for completed tasks with start/end times
      if (task.isCompleted && task.startTime && task.completionTime) {
        const duration = new Date(task.completionTime) - new Date(task.startTime);
        categoryCounts[category].durations.push(duration);
      }
    });
    
    // Calculate average durations
    Object.keys(categoryCounts).forEach(category => {
      const durations = categoryCounts[category].durations;
      if (durations.length > 0) {
        categoryCounts[category].avgDuration = durations.reduce((sum, d) => sum + d, 0) / durations.length;
      }
      
      // Add to patterns if we have enough data
      if (categoryCounts[category].count >= 3) {
        patterns.categorical.push({
          category: category,
          count: categoryCounts[category].count,
          completionRate: categoryCounts[category].completed / categoryCounts[category].count,
          avgDuration: categoryCounts[category].avgDuration
        });
      }
    });
    
    return patterns;
  },
  
  // Determine interval type based on average days
  getIntervalType: function(avgDays) {
    if (avgDays >= 6 && avgDays <= 8) return 'weekly';
    if (avgDays >= 13 && avgDays <= 15) return 'biweekly';
    if (avgDays >= 28 && avgDays <= 31) return 'monthly';
    if (avgDays >= 89 && avgDays <= 93) return 'quarterly';
    if (avgDays >= 364 && avgDays <= 366) return 'yearly';
    return null;
  },
  
  // Create suggestions from patterns
  createSuggestionsFromPatterns: function(patterns, existingTasks) {
    const suggestions = [];
    
    // Generate recurring task suggestions
    patterns.recurring.forEach(pattern => {
      const lastDate = new Date(pattern.lastDate);
      const nextDate = new Date(lastDate);
      
      // Add the interval to get the next date
      nextDate.setDate(nextDate.getDate() + pattern.interval);
      
      // Format date as YYYY-MM-DD
      const nextDateStr = nextDate.toISOString().split('T')[0];
      
      // Check if this suggestion already exists
      const alreadyExists = existingTasks.some(task => 
        task.title.toLowerCase() === pattern.title.toLowerCase() && 
        task.dueDate === nextDateStr
      );
      
      if (!alreadyExists) {
        suggestions.push({
          type: 'recurring',
          title: pattern.title,
          suggestedDate: nextDateStr,
          category: pattern.category,
          tags: pattern.tags,
          confidence: 0.9,
          message: `You have a ${pattern.intervalType} "${pattern.title}" task.`
        });
      }
    });
    
    // Generate related task suggestions
    patterns.related.forEach(relation => {
      // Find if one task exists recently but not the other
      const recentTasks = existingTasks.filter(task => 
        new Date(task.dueDate) >= new Date(Date.now() - 7 * 24 * 60 * 60 * 1000) && // Within last week
        relation.titles.includes(task.title)
      );
      
      if (recentTasks.length === 1) {
        // One exists, suggest the other
        const existingTask = recentTasks[0];
        const suggestedTitle = relation.titles.find(title => title !== existingTask.title);
        
        // Don't suggest if it already exists
        const alreadyExists = existingTasks.some(task => 
          task.title === suggestedTitle && 
          new Date(task.dueDate) >= new Date()
        );
        
        if (!alreadyExists) {
          suggestions.push({
            type: 'related',
            title: suggestedTitle,
            suggestedDate: existingTask.dueDate,
            relatedTo: existingTask.title,
            confidence: 0.7,
            message: `You often do "${suggestedTitle}" when you do "${existingTask.title}".`
          });
        }
      }
    });
    
    // Generate forgotten task reminders
    patterns.forgotten.forEach(task => {
      suggestions.push({
        type: 'forgotten',
        taskId: task.id,
        title: task.title,
        originalDate: task.dueDate,
        daysPast: task.daysPast,
        confidence: 0.8,
        message: `You missed "${task.title}" ${task.daysPast} day${task.daysPast > 1 ? 's' : ''} ago.`
      });
    });
    
    // Generate category-based suggestions
    patterns.categorical.forEach(category => {
      // Only suggest for categories with high completion rates
      if (category.completionRate > 0.7) {
        const catData = this.categories[category.category] || { name: 'Other' };
        
        // Check recent task distribution
        const recentTasks = existingTasks.filter(task => 
          new Date(task.dueDate) >= new Date(Date.now() - 14 * 24 * 60 * 60 * 1000) // Within last 2 weeks
        );
        
        const recentCategoryCounts = {};
        recentTasks.forEach(task => {
          const taskCat = task.category || 'other';
          recentCategoryCounts[taskCat] = (recentCategoryCounts[taskCat] || 0) + 1;
        });
        
        // If this category is underrepresented in recent tasks
        const totalRecent = Object.values(recentCategoryCounts).reduce((sum, count) => sum + count, 0);
        const categoryPercentage = (recentCategoryCounts[category.category] || 0) / totalRecent;
        
        if (categoryPercentage < 0.1 && totalRecent > 5) {
          suggestions.push({
            type: 'categorical',
            category: category.category,
            categoryName: catData.name,
            confidence: 0.6,
            message: `You haven't added any ${catData.name} tasks recently. Consider adding some.`
          });
        }
      }
    });
    
    return suggestions;
  },
  
  // Show notification for available suggestions
  showSuggestionsNotification: function(count) {
    // Add an indicator to the UI
    const appHeader = document.querySelector('.app-header');
    if (!appHeader) return;
    
    if (appHeader && !document.querySelector('.suggestion-indicator')) {
      const notificationHTML = `
        <div class="suggestion-indicator" title="${count} task suggestions available">
          <i class="material-icons">lightbulb</i>
          <span class="suggestion-count">${count}</span>
        </div>
      `;
      
      appHeader.insertAdjacentHTML('beforeend', notificationHTML);
      
      // Add click handler to show suggestions
      document.querySelector('.suggestion-indicator').addEventListener('click', () => {
        this.showSuggestionsModal();
      });
    }
  },
  
  // Show modal with task suggestions
  showSuggestionsModal: function() {
    // Get saved suggestions
    const suggestionsJson = localStorage.getItem('taskSuggestions');
    if (!suggestionsJson) return;
    
    const suggestions = JSON.parse(suggestionsJson);
    
    if (suggestions.length === 0) {
      showSnackbar('No suggestions available');
      return;
    }
    
    // Create suggestions modal
    const modalHTML = `
      <div class="modal-overlay" id="suggestions-modal">
        <div class="modal-content">
          <div class="modal-header">
            <h2>Task Suggestions</h2>
            <button class="modal-close-btn"><i class="material-icons">close</i></button>
          </div>
          <div class="modal-body">
            <div class="suggestions-list">
              ${suggestions.map((suggestion, index) => `
                <div class="suggestion-item" data-index="${index}">
                  <div class="suggestion-icon">
                    ${this.getSuggestionIcon(suggestion)}
                  </div>
                  <div class="suggestion-content">
                    <div class="suggestion-message">${suggestion.message}</div>
                    <div class="suggestion-actions">
                      <button class="btn-accept-suggestion" data-index="${index}">
                        <i class="material-icons">add_task</i> Add Task
                      </button>
                      <button class="btn-dismiss-suggestion" data-index="${index}">
                        Dismiss
                      </button>
                    </div>
                  </div>
                </div>
              `).join('')}
            </div>
            ${suggestions.length === 0 ? '<div class="empty-state">No suggestions available.</div>' : ''}
          </div>
        </div>
      </div>
    `;
    
    // Add modal to body
    const modalContainer = document.createElement('div');
    modalContainer.innerHTML = modalHTML;
    document.body.appendChild(modalContainer);
    
    // Add event listeners
    document.querySelector('#suggestions-modal .modal-close-btn').addEventListener('click', () => {
      this.closeSuggestionsModal();
    });
    
    // Accept suggestion
    document.querySelectorAll('.btn-accept-suggestion').forEach(btn => {
      btn.addEventListener('click', (e) => {
        const index = parseInt(e.target.closest('.btn-accept-suggestion').dataset.index);
        this.acceptSuggestion(suggestions[index]);
        
        // Remove this suggestion from the list
        suggestions.splice(index, 1);
        localStorage.setItem('taskSuggestions', JSON.stringify(suggestions));
        
        // Update the suggestion count or remove indicator if none left
        if (suggestions.length > 0) {
          document.querySelector('.suggestion-count').textContent = suggestions.length;
        } else {
          document.querySelector('.suggestion-indicator')?.remove();
        }
        
        // Close modal
        this.closeSuggestionsModal();
      });
    });
    
    // Dismiss suggestion
    document.querySelectorAll('.btn-dismiss-suggestion').forEach(btn => {
      btn.addEventListener('click', (e) => {
        const index = parseInt(e.target.dataset.index);
        
        // Remove this suggestion
        suggestions.splice(index, 1);
        localStorage.setItem('taskSuggestions', JSON.stringify(suggestions));
        
        // Remove the suggestion item from the list
        e.target.closest('.suggestion-item').remove();
        
        // Update the suggestion count or remove indicator if none left
        if (suggestions.length > 0) {
          document.querySelector('.suggestion-count').textContent = suggestions.length;
        } else {
          document.querySelector('.suggestion-indicator')?.remove();
          this.closeSuggestionsModal();
        }
      });
    });
    
    // Show modal with animation
    setTimeout(() => {
      document.getElementById('suggestions-modal').classList.add('active');
    }, 10);
  },
  
  // Close suggestions modal
  closeSuggestionsModal: function() {
    const modal = document.getElementById('suggestions-modal');
    
    if (modal) {
      modal.classList.remove('active');
      setTimeout(() => {
        modal.parentElement.remove();
      }, 300);
    }
  },
  
  // Get icon for suggestion type
  getSuggestionIcon: function(suggestion) {
    switch (suggestion.type) {
      case 'recurring':
        return '<i class="material-icons">repeat</i>';
      case 'related':
        return '<i class="material-icons">link</i>';
      case 'forgotten':
        return '<i class="material-icons">notification_important</i>';
      case 'categorical':
        const category = this.categories[suggestion.category] || this.categories.other;
        return `<i class="material-icons">${category.icon}</i>`;
      default:
        return '<i class="material-icons">lightbulb</i>';
    }
  },
  
  // Accept a suggestion and create the task
  acceptSuggestion: function(suggestion) {
    switch (suggestion.type) {
      case 'recurring':
      case 'related':
        // Create a new task
        const newTask = {
          id: Date.now().toString(),
          title: suggestion.title,
          description: '',
          isCompleted: false,
          dueDate: suggestion.suggestedDate || getTodayDate(),
          dueTime: '',
          calendarType: 'gregorian',
          priority: 'medium',
          color: '#fb8c00',
          hasReminder: false,
          reminderTime: '',
          reminderFrequency: 'once',
          contactPhone: '',
          contactEmail: '',
          location: '',
          category: suggestion.category || 'other',
          tags: suggestion.tags || []
        };
        
        // Add the task to the list
        const tasksJson = localStorage.getItem('tasks');
        let tasks = [];
        
        if (tasksJson) {
          tasks = JSON.parse(tasksJson);
        }
        
        tasks.push(newTask);
        
        // Save updated tasks
        localStorage.setItem('tasks', JSON.stringify(tasks));
        
        // Show success message
        showSnackbar(`Added "${suggestion.title}" to your tasks`);
        
        // Refresh task list
        if (typeof renderTasks === 'function') {
          renderTasks();
        }
        break;
        
      case 'forgotten':
        // Reschedule forgotten task to today
        const tasksJsonF = localStorage.getItem('tasks');
        
        if (tasksJsonF) {
          let tasksF = JSON.parse(tasksJsonF);
          
          // Find the task
          const taskIndex = tasksF.findIndex(t => t.id === suggestion.taskId);
          
          if (taskIndex >= 0) {
            // Update due date to today
            tasksF[taskIndex].dueDate = getTodayDate();
            
            // Save updated tasks
            localStorage.setItem('tasks', JSON.stringify(tasksF));
            
            // Show success message
            showSnackbar(`Rescheduled "${suggestion.title}" to today`);
            
            // Refresh task list
            if (typeof renderTasks === 'function') {
              renderTasks();
            }
          }
        }
        break;
        
      case 'categorical':
        // Create a new task form with the suggested category
        if (typeof showTaskForm === 'function') {
          // Show regular task form
          showTaskForm();
          
          // After form is shown, set the category
          setTimeout(() => {
            const categorySelect = document.getElementById('task-category');
            if (categorySelect) {
              categorySelect.value = suggestion.category;
              // Trigger change event to update icon
              categorySelect.dispatchEvent(new Event('change'));
            }
          }, 100);
        }
        break;
    }
  }
};

// Initialize when the page is loaded
document.addEventListener('DOMContentLoaded', function() {
  TaskIntelligence.init();
});

// Add to window for access from other modules
window.TaskIntelligence = TaskIntelligence;