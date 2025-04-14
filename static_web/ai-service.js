/**
 * AI Service Module
 * Provides integration with AI services for natural language processing
 * Uses either OpenAI or Anthropic APIs based on available credentials
 */

class AIService {
  constructor() {
    this.serviceType = 'basic'; // 'basic', 'openai', or 'anthropic'
    this.initialized = false;
    this.initializeService();
  }
  
  async initializeService() {
    // In a production environment, we would check for API keys here
    // For the demo, we'll use the basic built-in NLP implemented in ai-assistant.js
    this.serviceType = 'basic';
    this.initialized = true;
    console.log('AI Service initialized in basic mode');
    
    // For production, uncomment the following to check for API keys
    /*
    // Check if OpenAI API key is available
    try {
      const openAiKeyAvailable = await this.checkOpenAIKey();
      if (openAiKeyAvailable) {
        this.serviceType = 'openai';
        this.initialized = true;
        console.log('AI Service initialized with OpenAI');
        return;
      }
    } catch (error) {
      console.error('Error checking OpenAI API key:', error);
    }
    
    // Check if Anthropic API key is available
    try {
      const anthropicKeyAvailable = await this.checkAnthropicKey();
      if (anthropicKeyAvailable) {
        this.serviceType = 'anthropic';
        this.initialized = true;
        console.log('AI Service initialized with Anthropic');
        return;
      }
    } catch (error) {
      console.error('Error checking Anthropic API key:', error);
    }
    
    // If no API keys are available, fall back to basic mode
    this.serviceType = 'basic';
    this.initialized = true;
    console.log('AI Service initialized in basic mode (fallback)');
    */
  }
  
  async checkOpenAIKey() {
    // In production, make a small test call to the OpenAI API to verify the key
    return false;
  }
  
  async checkAnthropicKey() {
    // In production, make a small test call to the Anthropic API to verify the key
    return false;
  }
  
  async processCommand(command) {
    // Wait for initialization to complete
    if (!this.initialized) {
      await new Promise(resolve => {
        const checkInit = () => {
          if (this.initialized) {
            resolve();
          } else {
            setTimeout(checkInit, 100);
          }
        };
        checkInit();
      });
    }
    
    // Process the command based on the service type
    switch (this.serviceType) {
      case 'openai':
        return await this.processWithOpenAI(command);
      case 'anthropic':
        return await this.processWithAnthropic(command);
      case 'basic':
      default:
        return this.processWithBasicNLP(command);
    }
  }
  
  async processWithOpenAI(command) {
    // In production, this would make an API call to OpenAI
    try {
      // the newest OpenAI model is "gpt-4o" which was released May 13, 2024. do not change this unless explicitly requested by the user
      const response = {
        action: 'create',
        entityType: 'task',
        details: {
          title: command,
          priority: 'medium'
        }
      };
      return response;
    } catch (error) {
      console.error('Error calling OpenAI API:', error);
      // Fall back to basic NLP if OpenAI fails
      return this.processWithBasicNLP(command);
    }
  }
  
  async processWithAnthropic(command) {
    // In production, this would make an API call to Anthropic
    try {
      // the newest Anthropic model is "claude-3-7-sonnet-20250219" which was released February 24, 2025
      const response = {
        action: 'create',
        entityType: 'task',
        details: {
          title: command,
          priority: 'medium'
        }
      };
      return response;
    } catch (error) {
      console.error('Error calling Anthropic API:', error);
      // Fall back to basic NLP if Anthropic fails
      return this.processWithBasicNLP(command);
    }
  }
  
  processWithBasicNLP(command) {
    // Basic NLP implementation (same logic as in AI Assistant)
    command = command.toLowerCase();
    
    let intent = {
      action: null,
      entityType: null,
      details: {},
      originalCommand: command
    };
    
    // Determine action and entity type
    if (command.includes('add') || command.includes('create') || command.includes('new')) {
      intent.action = 'create';
    } else if (command.includes('delete') || command.includes('remove')) {
      intent.action = 'delete';
    } else if (command.includes('edit') || command.includes('update') || command.includes('change')) {
      intent.action = 'update';
    } else if (command.includes('find') || command.includes('show') || command.includes('list') || command.includes('get')) {
      intent.action = 'search';
    } else if (command.includes('remind')) {
      intent.action = 'create';
      intent.entityType = 'reminder';
    } else {
      // Default to search if no action is detected
      intent.action = 'search';
    }
    
    // Determine entity type
    if (!intent.entityType) {
      if (command.includes('task')) {
        intent.entityType = 'task';
      } else if (command.includes('note')) {
        intent.entityType = 'note';
      } else if (command.includes('reminder')) {
        intent.entityType = 'reminder';
      } else if (command.includes('event') || command.includes('meeting') || command.includes('appointment')) {
        intent.entityType = 'event';
      } else {
        // Default to task if no entity type is detected
        intent.entityType = 'task';
      }
    }
    
    // Extract priority if mentioned
    if (command.includes('high priority') || command.includes('important')) {
      intent.details.priority = 'high';
    } else if (command.includes('medium priority')) {
      intent.details.priority = 'medium';
    } else if (command.includes('low priority')) {
      intent.details.priority = 'low';
    }
    
    // Extract date information
    const dateKeywords = [
      { keyword: 'today', days: 0 },
      { keyword: 'tomorrow', days: 1 },
      { keyword: 'next week', days: 7 },
      { keyword: 'next month', days: 30 }
    ];
    
    for (const dateInfo of dateKeywords) {
      if (command.includes(dateInfo.keyword)) {
        const date = new Date();
        date.setDate(date.getDate() + dateInfo.days);
        intent.details.date = date.toISOString().split('T')[0];
        break;
      }
    }
    
    // Extract day of week
    const dayNames = ['sunday', 'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday'];
    for (let i = 0; i < dayNames.length; i++) {
      if (command.includes(dayNames[i])) {
        const today = new Date().getDay(); // 0 = Sunday, 6 = Saturday
        const targetDay = i;
        let daysToAdd = targetDay - today;
        if (daysToAdd <= 0) daysToAdd += 7; // Next week if the day has passed
        
        const date = new Date();
        date.setDate(date.getDate() + daysToAdd);
        intent.details.date = date.toISOString().split('T')[0];
        break;
      }
    }
    
    // Extract title/content based on the context
    // This is a simplified approach - a real AI would do better
    if (intent.action === 'create' || intent.action === 'update') {
      const prepositions = ['to', 'about', 'for', 'with', 'on'];
      let contentStart = -1;
      
      for (const prep of prepositions) {
        const prepIndex = command.indexOf(` ${prep} `);
        if (prepIndex !== -1 && (contentStart === -1 || prepIndex < contentStart)) {
          contentStart = prepIndex + prep.length + 2;
        }
      }
      
      if (contentStart !== -1) {
        intent.details.title = command.substring(contentStart).trim();
      } else {
        // Extract text after the entity type if available
        const entityIndex = command.indexOf(intent.entityType);
        if (entityIndex !== -1) {
          intent.details.title = command.substring(entityIndex + intent.entityType.length).trim();
        }
      }
    }
    
    // If search action, extract search terms
    if (intent.action === 'search') {
      intent.details.searchTerms = command;
    }
    
    return intent;
  }
  
  // For potential voice transcription
  async transcribeAudio(audioBlob) {
    // In a production implementation, this would use an API like OpenAI's Whisper
    // For now, we rely on the browser's speech recognition API
    return "Speech transcription would occur here with an AI service API";
  }
}

class AIService {
  constructor() {
    this.categories = {
      work: ['meeting', 'project', 'deadline', 'presentation', 'client'],
      health: ['doctor', 'medicine', 'exercise', 'workout', 'gym'],
      grocery: ['buy', 'shopping', 'store', 'milk', 'food'],
      social: ['call', 'meet', 'party', 'birthday', 'hangout']
    };
    console.log('AI Service initialized with NLP capabilities');
  }

  detectCategory(text) {
    for (const [category, keywords] of Object.entries(this.categories)) {
      if (keywords.some(keyword => text.toLowerCase().includes(keyword))) {
        return category;
      }
    }
    return 'other';
  }

  extractDateTime(text) {
    const dateTimeRegex = {
      today: /today/i,
      tomorrow: /tomorrow/i,
      nextWeek: /next week/i,
      specificTime: /at (\d{1,2}(?::\d{2})?\s*(?:am|pm))/i,
      specificDate: /on ([a-z]+day)/i
    };

    const result = { date: null, time: null };
    
    if (dateTimeRegex.today.test(text)) {
      result.date = new Date().toISOString().split('T')[0];
    } else if (dateTimeRegex.tomorrow.test(text)) {
      const tomorrow = new Date();
      tomorrow.setDate(tomorrow.getDate() + 1);
      result.date = tomorrow.toISOString().split('T')[0];
    }

    const timeMatch = text.match(dateTimeRegex.specificTime);
    if (timeMatch) {
      result.time = timeMatch[1];
    }

    return result;
  }
}

// Initialize the AI Service when the DOM is loaded
document.addEventListener('DOMContentLoaded', function() {
  if (document.querySelector('.ai-service-container')) {
    // Initialize the AI Service
    const aiService = new AIService();
    
    // Make it available globally
    window.aiService = aiService;
  }
});