// Sample notes
let notes = [
  {
    id: '1',
    title: 'Meeting notes',
    content: 'Discussed the new project timeline and resource allocation. Need to follow up with David about the budget.',
    createdAt: '2025-04-10T09:30:00',
    updatedAt: '2025-04-10T10:15:00',
    color: '#bbdefb',
    tags: ['work', 'meeting'],
    isArchived: false
  },
  {
    id: '2',
    title: 'Shopping list',
    content: '- Milk\n- Eggs\n- Bread\n- Apples\n- Chicken\n- Pasta',
    createdAt: '2025-04-09T18:45:00',
    updatedAt: '2025-04-09T18:45:00',
    color: '#f8bbd0',
    tags: ['personal', 'shopping'],
    isArchived: false
  },
  {
    id: '3',
    title: 'Book recommendations',
    content: '1. The Midnight Library by Matt Haig\n2. Project Hail Mary by Andy Weir\n3. Klara and the Sun by Kazuo Ishiguro',
    createdAt: '2025-04-08T14:20:00',
    updatedAt: '2025-04-08T14:20:00',
    color: '#c8e6c9',
    tags: ['personal', 'books'],
    isArchived: false
  }
];

// Note colors
const NOTE_COLORS = [
  { name: 'Blue', value: '#bbdefb' },
  { name: 'Red', value: '#ffcdd2' },
  { name: 'Green', value: '#c8e6c9' },
  { name: 'Yellow', value: '#fff9c4' },
  { name: 'Purple', value: '#e1bee7' },
  { name: 'Pink', value: '#f8bbd0' },
  { name: 'Orange', value: '#ffe0b2' },
  { name: 'White', value: '#ffffff' }
];

// Get saved notes from localStorage
function loadNotes() {
  const savedNotes = localStorage.getItem('notes');
  if (savedNotes) {
    notes = JSON.parse(savedNotes);
  }
  renderNotes();
}

// Save notes to localStorage
function saveNotes() {
  localStorage.setItem('notes', JSON.stringify(notes));
}

// Generate note item HTML
function generateNoteHTML(note) {
  // Convert newlines to <br> tags for content
  const displayContent = note.content.replace(/\n/g, '<br>');
  
  // Format date
  const updatedDate = new Date(note.updatedAt);
  const formattedDate = updatedDate.toLocaleDateString('en-US', { 
    month: 'short', 
    day: 'numeric',
    year: 'numeric'
  });
  
  // Generate tags HTML
  let tagsHTML = '';
  if (note.tags && note.tags.length > 0) {
    tagsHTML = note.tags.map(tag => `<span class="note-tag">${tag}</span>`).join('');
  }
  
  return `
    <div class="note-item" data-id="${note.id}" style="background-color: ${note.color}">
      <div class="note-header">
        <h3 class="note-title">${note.title}</h3>
        <div class="note-actions">
          <button class="note-edit-btn"><i class="material-icons">edit</i></button>
          <button class="note-archive-btn"><i class="material-icons">${note.isArchived ? 'unarchive' : 'archive'}</i></button>
          <button class="note-delete-btn"><i class="material-icons">delete</i></button>
        </div>
      </div>
      <div class="note-content hidden">${displayContent}</div>
      <div class="note-footer">
        <div class="note-tags">${tagsHTML}</div>
        <div class="note-date">Updated: ${formattedDate}</div>
      </div>
    </div>
  `;
}

// Render all notes
function renderNotes(showArchived = false) {
  const notesGrid = document.getElementById('notes-grid');
  if (!notesGrid) return;
  
  const filteredNotes = notes.filter(note => note.isArchived === showArchived);
  const sortedNotes = [...filteredNotes].sort((a, b) => 
    new Date(b.updatedAt) - new Date(a.updatedAt)
  );
  
  notesGrid.innerHTML = sortedNotes.length > 0 
    ? sortedNotes.map(generateNoteHTML).join('') 
    : `<div class="empty-state">No ${showArchived ? 'archived ' : ''}notes. ${!showArchived ? 'Click the + button to add one.' : ''}</div>`;
  
  // Add event listeners
  document.querySelectorAll('.note-edit-btn').forEach(btn => {
    btn.addEventListener('click', handleNoteEdit);
  });
  
  document.querySelectorAll('.note-archive-btn').forEach(btn => {
    btn.addEventListener('click', handleNoteArchive);
  });
  
  document.querySelectorAll('.note-delete-btn').forEach(btn => {
    btn.addEventListener('click', handleNoteDelete);
  });
}

// Handle note edit
function handleNoteEdit(e) {
  e.stopPropagation();
  const noteId = e.target.closest('.note-item').dataset.id;
  const note = notes.find(n => n.id === noteId);
  if (note) {
    showNoteForm(note);
  }
}

// Handle note archive
function handleNoteArchive(e) {
  e.stopPropagation();
  const noteId = e.target.closest('.note-item').dataset.id;
  const note = notes.find(n => n.id === noteId);
  if (note) {
    note.isArchived = !note.isArchived;
    note.updatedAt = new Date().toISOString();
    saveNotes();
    renderNotes(document.getElementById('show-archived-notes').checked);
    showSnackbar(`Note ${note.isArchived ? 'archived' : 'unarchived'}`);
  }
}

// Handle note delete
function handleNoteDelete(e) {
  e.stopPropagation();
  const noteId = e.target.closest('.note-item').dataset.id;
  const noteIndex = notes.findIndex(n => n.id === noteId);
  if (noteIndex > -1) {
    const noteTitle = notes[noteIndex].title;
    if (confirm(`Delete note "${noteTitle}"?`)) {
      notes.splice(noteIndex, 1);
      saveNotes();
      renderNotes(document.getElementById('show-archived-notes').checked);
      showSnackbar('Note deleted');
    }
  }
}

// Show note form
function showNoteForm(note = null) {
  const isEditing = !!note;
  const formTitle = isEditing ? 'Edit Note' : 'New Note';
  
  // Generate color picker options
  let colorOptionsHTML = '';
  NOTE_COLORS.forEach(color => {
    const isSelected = isEditing && note.color === color.value;
    colorOptionsHTML += `
      <label class="color-option" title="${color.name}">
        <input type="radio" name="note-color" value="${color.value}" ${isSelected ? 'checked' : ''}>
        <span class="color-sample" style="background-color: ${color.value}"></span>
      </label>
    `;
  });
  
  // Generate tags input
  const tagsValue = isEditing && note.tags ? note.tags.join(', ') : '';
  
  const modalHTML = `
    <div class="modal-overlay" id="note-modal">
      <div class="modal-content">
        <div class="modal-header">
          <h2>${formTitle}</h2>
          <button class="modal-close-btn"><i class="material-icons">close</i></button>
        </div>
        <div class="modal-body">
          <form id="note-form">
            <div class="form-group">
              <label for="note-title">Title</label>
              <input type="text" id="note-title" required value="${isEditing ? note.title : ''}">
            </div>
            <div class="form-group">
              <label for="note-content">Content</label>
              <textarea id="note-content" rows="6" required>${isEditing ? note.content : ''}</textarea>
            </div>
            <div class="form-group">
              <label>Color</label>
              <div class="color-options">
                ${colorOptionsHTML}
              </div>
            </div>
            <div class="form-group">
              <label for="note-tags">Tags (comma separated)</label>
              <input type="text" id="note-tags" placeholder="work, personal, idea" value="${tagsValue}">
            </div>
            <div class="form-actions">
              ${isEditing ? '<input type="hidden" id="note-id" value="' + note.id + '">' : ''}
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
  
  // Select first color option if none is selected
  if (!isEditing) {
    document.querySelector('input[name="note-color"]').checked = true;
  }
  
  // Add event listeners
  document.querySelector('.modal-close-btn').addEventListener('click', closeNoteForm);
  document.querySelector('.btn-cancel').addEventListener('click', closeNoteForm);
  document.getElementById('note-form').addEventListener('submit', saveNoteForm);
  
  // Show modal with animation
  setTimeout(() => {
    document.getElementById('note-modal').classList.add('active');
  }, 10);
}

// Close note form
function closeNoteForm() {
  const modal = document.getElementById('note-modal');
  modal.classList.remove('active');
  setTimeout(() => {
    modal.parentElement.remove();
  }, 300);
}

// Save note form
function saveNoteForm(e) {
  e.preventDefault();
  
  const form = document.getElementById('note-form');
  const noteId = form.querySelector('#note-id')?.value;
  const title = form.querySelector('#note-title').value.trim();
  const content = form.querySelector('#note-content').value.trim();
  const color = form.querySelector('input[name="note-color"]:checked').value;
  const tagsInput = form.querySelector('#note-tags').value.trim();
  
  // Parse tags
  let tags = [];
  if (tagsInput) {
    tags = tagsInput.split(',').map(tag => tag.trim()).filter(tag => tag);
  }
  
  const now = new Date().toISOString();
  
  if (noteId) {
    // Update existing note
    const note = notes.find(n => n.id === noteId);
    if (note) {
      note.title = title;
      note.content = content;
      note.color = color;
      note.tags = tags;
      note.updatedAt = now;
      showSnackbar('Note updated');
    }
  } else {
    // Create new note
    const newNote = {
      id: Date.now().toString(),
      title,
      content,
      createdAt: now,
      updatedAt: now,
      color,
      tags,
      isArchived: false
    };
    notes.push(newNote);
    showSnackbar('Note added');
  }
  
  saveNotes();
  renderNotes(document.getElementById('show-archived-notes').checked);
  closeNoteForm();
}

// Toggle archived notes view
function toggleArchivedNotes(e) {
  renderNotes(e.target.checked);
}

// Initialize notes
document.addEventListener('DOMContentLoaded', function() {
  const notesTab = document.querySelector('.tab-content[data-tab="notes"]');
  if (notesTab) {
    notesTab.innerHTML = `
      <div class="notes-header">
        <h2 class="tab-section-title">My Notes</h2>
        <div class="notes-options">
          <label class="checkbox-container">
            <input type="checkbox" id="show-archived-notes">
            <span class="checkbox-label">Show archived</span>
          </label>
        </div>
      </div>
      <div id="notes-grid" class="notes-grid"></div>
    `;
    
    document.getElementById('show-archived-notes').addEventListener('change', toggleArchivedNotes);
    loadNotes();
  }
});
// Handle note click
function handleNoteClick(e) {
  if (!e.target.closest('.note-actions')) {
    const noteContent = e.currentTarget.querySelector('.note-content');
    noteContent.classList.toggle('hidden');
  }
}

// Add click listeners to notes
function addNoteClickListeners() {
  document.querySelectorAll('.note-item').forEach(note => {
    note.addEventListener('click', handleNoteClick);
  });
}

// Update renderNotes to add click listeners
const originalRenderNotes = renderNotes;
renderNotes = function(showArchived = false) {
  originalRenderNotes(showArchived);
  addNoteClickListeners();
}
