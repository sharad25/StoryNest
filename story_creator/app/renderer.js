const stepsDef = [
  { id: 'analyze', title: 'Content Safety Analysis', defaultPrompt: 'Analyze the text for sexual, violent, or otherwise age-inappropriate content. Return flagged spans, categories and short explanations.' },
  { id: 'rewrite', title: 'Rewrite Suggested Sections', defaultPrompt: 'Rewrite the flagged spans to remove age-inappropriate content while preserving plot and moral. Produce 2 alternatives.' },
  { id: 'segment', title: 'Segmentation into Pages', defaultPrompt: 'Segment the approved text into pages of 2–6 sentences each, each page focused on a single theme.' },
  { id: 'blurb', title: 'Generate Page Blurbs', defaultPrompt: 'Produce a short blurb (max 10 words) that describes a photographic scene for the page text.' },
  { id: 'image', title: 'Generate Images', defaultPrompt: 'Generate photo-style images from the blurb (adapter will be used).' },
  { id: 'audio', title: 'Generate Audio Narration', defaultPrompt: 'Generate narration audio per page using selected TTS voice.' }
];

let state = {
  running: false,
  paused: false,
  currentStep: null,
  checkpoints: [],
  prompts: {}
};

// story text loaded into the pipeline
state.storyText = '';

function init() {
  const stepsEl = document.getElementById('steps');
  stepsDef.forEach(s => {
    state.prompts[s.id] = s.defaultPrompt;
    const div = document.createElement('div');
    div.className = 'step';
    div.id = 'step-' + s.id;
    div.innerHTML = `<strong>${s.title}</strong><div class="small">${s.id}</div><div style="margin-top:8px;"><button data-step="${s.id}" class="inspect">Inspect</button> <button data-step="${s.id}" class="runStep">Run</button> <button data-step="${s.id}" class="retry">Retry</button></div>`;
    stepsEl.appendChild(div);
  });

  document.getElementById('startBtn').addEventListener('click', startWorkflow);
  document.getElementById('pauseBtn').addEventListener('click', pauseWorkflow);
  document.getElementById('resumeBtn').addEventListener('click', resumeWorkflow);
  document.getElementById('addToPackBtn').addEventListener('click', addToPack);
  document.getElementById('loadStoryBtn').addEventListener('click', loadStoryFromTextarea);
  document.getElementById('clearStoryBtn').addEventListener('click', clearStory);
  document.getElementById('fileInput').addEventListener('change', handleFileInput);

  // drag & drop support for the left column (story input)
  const left = document.getElementById('left');
  left.addEventListener('dragover', (e) => { e.preventDefault(); e.dataTransfer.dropEffect = 'copy'; });
  left.addEventListener('drop', (e) => { e.preventDefault(); handleDrop(e); });

  document.addEventListener('click', (e) => {
    if (e.target.classList.contains('inspect')) {
      showInspector(e.target.dataset.step);
    }
    if (e.target.classList.contains('runStep')) {
      runStep(e.target.dataset.step);
    }
    if (e.target.classList.contains('retry')) {
      retryStep(e.target.dataset.step);
    }
  });

  renderCheckpoints();
}

function startWorkflow() {
  if (state.running) return;
  state.running = true;
  state.paused = false;
  runNextFromIndex(0);
}

function pauseWorkflow() {
  state.paused = true;
}

function resumeWorkflow() {
  state.paused = false;
  if (state.currentStep) {
    // continue current
    simulateStep(state.currentStep);
  } else {
    // find first incomplete
    const idx = state.checkpoints.length;
    runNextFromIndex(idx);
  }
}

function runNextFromIndex(index) {
  if (index >= stepsDef.length) {
    state.running = false;
    state.currentStep = null;
    return;
  }
  const step = stepsDef[index];
  state.currentStep = step.id;
  simulateStep(step.id, () => {
    if (!state.paused) runNextFromIndex(index + 1);
  });
}

const llm = require('./adapters/llm_adapter');

async function simulateStep(stepId, cb) {
  const start = Date.now();
  const prompt = state.prompts[stepId];
  updateInspectorStatus(`Running ${stepId}...`);

  // For LLM-backed steps, call the adapter; otherwise keep synthetic behavior.
  const llmSteps = ['analyze','rewrite','segment','blurb'];
  if (llmSteps.includes(stepId)) {
    try {
      const ctx = { storyText: state.storyText, analysis: state.analysis, pages: state.pages };
      const resp = await llm.runStepModel(stepId, prompt, ctx);
      // normalize response and store useful state for downstream steps
      let output = '';
      if (stepId === 'analyze') {
        state.analysis = resp;
        output = JSON.stringify(resp, null, 2);
      } else if (stepId === 'rewrite') {
        state.rewrites = resp;
        output = (resp.alternatives || []).slice(0,2).map((a,i)=>`Alt ${i+1}: ${a}`).join('\n\n');
      } else if (stepId === 'segment') {
        state.pages = resp.pages || [];
        output = `Segmented into ${state.pages.length} pages.`;
      } else if (stepId === 'blurb') {
        state.blurbs = resp.blurbs || [];
        output = `Generated ${state.blurbs.length} blurbs.`;
      } else {
        output = resp.text || JSON.stringify(resp);
      }
      addCheckpoint(stepId, prompt, output, true, null);
      updateInspectorStatus(`Completed ${stepId}.`);
      state.currentStep = null;
      renderCheckpoints();
      if (cb) cb();
      return;
    } catch (e) {
      addCheckpoint(stepId, prompt, null, false, String(e));
      updateInspectorStatus(`Step ${stepId} failed: ${e.message || e}`);
      state.currentStep = null;
      renderCheckpoints();
      return;
    }
  }

  // fallback synthetic step for non-LLM steps
  const delay = 800 + Math.random() * 1200;
  const failed = Math.random() < 0.05; // small failure chance
  window.setTimeout(() => {
    if (state.paused) {
      updateInspectorStatus('Paused');
      return;
    }
    if (failed) {
      addCheckpoint(stepId, prompt, null, false, 'Provider error (simulated)');
      updateInspectorStatus(`Step ${stepId} failed (simulated).`);
      state.currentStep = null;
      renderCheckpoints();
      return;
    }
    const output = `Synthetic output for ${stepId} (generated at ${new Date().toLocaleTimeString()})`;
    addCheckpoint(stepId, prompt, output, true, null);
    updateInspectorStatus(`Completed ${stepId}.`);
    state.currentStep = null;
    renderCheckpoints();
    if (cb) cb();
  }, delay);
}

function runStep(stepId) {
  state.currentStep = stepId;
  simulateStep(stepId, () => {});
}

function retryStep(stepId) {
  // allow editing prompt before retry
  const p = prompt('Edit prompt (or leave unchanged):', state.prompts[stepId]);
  if (p !== null) state.prompts[stepId] = p;
  runStep(stepId);
}

function showInspector(stepId) {
  const step = stepsDef.find(s => s.id === stepId);
  const checkpoints = state.checkpoints.filter(c => c.stepId === stepId);
  const last = checkpoints.length ? checkpoints[checkpoints.length-1] : null;
  const inspector = document.getElementById('inspector');
  inspector.innerHTML = `
    <h4>${step.title}</h4>
    <label class="small">Prompt (editable):</label>
    <textarea id="promptEdit">${state.prompts[stepId]}</textarea>
    <div style="margin-top:8px"><button id="savePrompt">Save Prompt</button>
    <button id="runNow">Run Now</button>
    <button id="jumpTo">Jump To (and rerun downstream)</button></div>
    <h5>Last Output</h5>
    <div>${last ? last.output : '<em>none</em>'}</div>
    <h5>History</h5>
    <div id="history"></div>
  `;
  const histEl = document.getElementById('history');
  checkpoints.forEach((c) => {
    const d = document.createElement('div');
    d.className = 'checkpoint';
    d.innerHTML = `<div class="small">${new Date(c.timestamp).toLocaleString()} — ${c.status ? 'OK' : 'FAILED'}</div><div>${c.output || c.error}</div>`;
    histEl.appendChild(d);
  });

  document.getElementById('savePrompt').addEventListener('click', () => {
    const val = document.getElementById('promptEdit').value;
    state.prompts[stepId] = val;
    alert('Prompt saved for this run.');
  });
  document.getElementById('runNow').addEventListener('click', () => runStep(stepId));
  document.getElementById('jumpTo').addEventListener('click', () => jumpToStep(stepId));
}

function jumpToStep(stepId) {
  // mark downstream steps stale and run from stepId
  const idx = stepsDef.findIndex(s => s.id === stepId);
  // remove downstream checkpoints
  state.checkpoints = state.checkpoints.slice(0, idx);
  renderCheckpoints();
  runNextFromIndex(idx);
}

function addCheckpoint(stepId, prompt, output, status, error) {
  state.checkpoints.push({ stepId, prompt, output, status, error, timestamp: Date.now() });
}

function renderCheckpoints() {
  const el = document.getElementById('checkpoints');
  el.innerHTML = '';
  state.checkpoints.forEach((c, i) => {
    const d = document.createElement('div');
    d.className = 'checkpoint';
    d.innerHTML = `<div class="small">#${i+1} ${c.stepId} — ${new Date(c.timestamp).toLocaleString()}</div><div>${c.status ? c.output : ('ERROR: ' + c.error)}</div>`;
    el.appendChild(d);
  });
}

function updateInspectorStatus(s) {
  const inspector = document.getElementById('inspector');
  inspector.innerHTML = `<p class="small">${s}</p>`;
}

function addToPack() {
  const pack = prompt('Enter pack id to add this story to (any string):', 'my-pack-1');
  if (!pack) return;
  // simple simulated action
  alert('Story added to pack: ' + pack + '\nYou can run Pack Analyzer from the Pack menu (not implemented in skeleton).');
}

// Story input helpers
function loadStoryFromTextarea() {
  const t = document.getElementById('storyInput').value.trim();
  if (!t) { alert('No story text found in the textarea.'); return; }
  state.storyText = t;
  alert('Story loaded (' + Math.min(200, t.length) + ' chars shown).');
  showStoryPreview();
}

function clearStory() {
  document.getElementById('storyInput').value = '';
  state.storyText = '';
  showStoryPreview();
}

function handleFileInput(evt) {
  const f = evt.target.files && evt.target.files[0];
  if (!f) return;
  const reader = new FileReader();
  reader.onload = (e) => {
    state.storyText = String(e.target.result || '');
    document.getElementById('storyInput').value = state.storyText;
    showStoryPreview();
    alert('Story loaded from file: ' + f.name);
  };
  reader.readAsText(f);
}

function handleDrop(ev) {
  const f = ev.dataTransfer.files && ev.dataTransfer.files[0];
  if (!f) return;
  const reader = new FileReader();
  reader.onload = (e) => {
    state.storyText = String(e.target.result || '');
    document.getElementById('storyInput').value = state.storyText;
    showStoryPreview();
    alert('Story loaded from dropped file: ' + f.name);
  };
  reader.readAsText(f);
}

function showStoryPreview() {
  const inspector = document.getElementById('inspector');
  if (!state.storyText) {
    inspector.innerHTML = '<p class="small">No story loaded. Paste text or upload a file on the left.</p>';
    return;
  }
  const preview = state.storyText.length > 200 ? state.storyText.slice(0,200) + '...': state.storyText;
  inspector.innerHTML = `<h4>Loaded story preview</h4><div class="small">${preview.replace(/\n/g,'<br/>')}</div><div style="margin-top:8px"><button id="viewFull">View Full Story</button></div>`;
  document.getElementById('viewFull').addEventListener('click', () => {
    const w = window.open('', 'fullstory', 'width=800,height=600');
    w.document.write('<pre>' + escapeHtml(state.storyText) + '</pre>');
  });
}

function escapeHtml(s) { return s.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;'); }


init();
