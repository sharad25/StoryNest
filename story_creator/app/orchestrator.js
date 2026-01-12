// Minimal orchestrator module (simulated). In the real app this would
// manage jobs, model adapters, checkpoints and persistence.

class Orchestrator {
  constructor() {
    this.checkpoints = [];
  }

  addCheckpoint(obj) {
    obj.timestamp = Date.now();
    this.checkpoints.push(obj);
  }

  listCheckpoints() { return this.checkpoints.slice(); }
}

module.exports = { Orchestrator };
