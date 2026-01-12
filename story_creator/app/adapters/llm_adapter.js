const http = require('http');

// Simple pluggable LLM adapter.
// It first tries to POST to a local LLM HTTP server at http://127.0.0.1:8000/generate
// with payload { prompt }. If the server isn't available it falls back to
// a small, deterministic mock useful for the UI and testing.

function callLocalServer(prompt) {
  return new Promise((resolve, reject) => {
    const data = JSON.stringify({ prompt });
    const opts = { hostname: '127.0.0.1', port: 8000, path: '/generate', method: 'POST', headers: { 'Content-Type': 'application/json', 'Content-Length': Buffer.byteLength(data) } };
    const req = http.request(opts, (res) => {
      let body = '';
      res.on('data', (chunk) => body += chunk);
      res.on('end', () => {
        try { const j = JSON.parse(body); resolve(j); } catch (e) { resolve({ text: String(body) }); }
      });
    });
    req.on('error', (e) => reject(e));
    req.write(data);
    req.end();
  });
}

function simpleAnalyze(text) {
  const naughty = ['kill','blood','sex','murder','rape','bomb'];
  const flags = [];
  const lc = text.toLowerCase();
  naughty.forEach(word => {
    let idx = lc.indexOf(word);
    if (idx !== -1) {
      const span = text.substr(Math.max(0, idx-20), Math.min(60, text.length-idx+20));
      flags.push({ span: span, category: 'safety', explanation: `Found word: ${word}` });
    }
  });
  return { flags };
}

function simpleRewrite(text, analysis) {
  // return 2 alternatives replacing flagged words with safe placeholders
  let alt1 = text;
  let alt2 = text;
  (analysis.flags || []).forEach((f, i) => {
    const bad = f.explanation.replace('Found word: ', '');
    const re = new RegExp(bad, 'ig');
    alt1 = alt1.replace(re, '***');
    alt2 = alt2.replace(re, '[redacted]');
  });
  return { alternatives: [alt1, alt2] };
}

function simpleSegment(text) {
  const sentences = text.split(/(?<=[.!?])\s+/).map(s => s.trim()).filter(Boolean);
  const pages = [];
  for (let i=0;i<sentences.length;) {
    const count = Math.min(3, sentences.length - i); // 2-3 sentences per page
    pages.push(sentences.slice(i, i+count).join(' '));
    i += count;
  }
  return { pages };
}

function simpleBlurbs(pages) {
  return { blurbs: pages.map(p => {
    const words = p.split(/\W+/).filter(Boolean);
    const noun = words.find(w => w.length>4) || words[0] || 'scene';
    return `Photo of ${noun}`;
  }) };
}

async function runStepModel(stepId, prompt, context={}) {
  // Try local server first
  try {
    const serverResp = await callLocalServer(JSON.stringify({ stepId, prompt, context }));
    if (serverResp) return serverResp;
  } catch (e) {
    // ignore and fall back to mock
  }

  // Mock implementations
  const text = context.storyText || '';
  switch(stepId) {
    case 'analyze':
      return simpleAnalyze(text);
    case 'rewrite':
      return simpleRewrite(text, context.analysis || { flags: [] });
    case 'segment':
      return simpleSegment(text);
    case 'blurb':
      return simpleBlurbs(context.pages || []);
    default:
      return { text: `No model available for ${stepId}.` };
  }
}

module.exports = { runStepModel };
