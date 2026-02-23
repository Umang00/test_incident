const incidents = items.map(item => {
  const data = item.json;

  // -----------------------------
  // Date Handling
  // -----------------------------
  const fullDate = data['@timestamp'] || null;
  const simpleDate = fullDate ? fullDate.split('T')[0] : null;

  const year = simpleDate ? parseInt(simpleDate.split('-')[0]) : null;
  const month = simpleDate ? parseInt(simpleDate.split('-')[1]) : null;
  const quarter = month ? `Q${Math.floor((month - 1) / 3) + 1}` : null;

  // -----------------------------
  // Metadata Builder
  // -----------------------------
  const metadata = {
    incident_id: data.incident_id ?? null,
    date: simpleDate,
    year,
    quarter,
    severity: data.severity ?? null,
    status: data.status ?? null,
    category: data.category ?? null,
    type: data.type ?? null,
    affected_systems: Array.isArray(data.affected_systems) ? data.affected_systems : [],
    tags: Array.isArray(data.tags) ? data.tags : [],
    detection_method: data.detection_method ?? null,
    mitre_tactic_ids: Array.isArray(data.mitre_tactic_ids) ? data.mitre_tactic_ids : [],
    mitre_technique_ids: Array.isArray(data.mitre_technique_ids) ? data.mitre_technique_ids : [],
    mitre_prevention_ids: Array.isArray(data.mitre_prevention_ids) ? data.mitre_prevention_ids : [],
    affected_users_count: data.affected_users_count ?? null,
    estimated_cost: data.estimated_cost ?? null,
    sla_met: data.sla_met ?? null,
    mttr: data.mttr ?? null,
    mtta: data.mtta ?? null
  };

  Object.keys(metadata).forEach(key => {
    if (metadata[key] === undefined) delete metadata[key];
  });

  // -----------------------------
  // Embedding-Optimized Content
  // -----------------------------

  const sections = [];

  // 1. Summary
  const summary = [
    `Incident ID: ${data.incident_id ?? 'N/A'}`,
    `Title: ${data.title ?? 'Untitled Incident'}`,
    `Severity: ${data.severity ?? 'N/A'}`,
    `Category: ${data.category ?? 'N/A'}`,
    `Type: ${data.type ?? 'N/A'}`,
    `Status: ${data.status ?? 'N/A'}`,
    `Date: ${simpleDate ?? 'N/A'} (${quarter ?? '-'} ${year ?? '-'})`,
    `Affected Systems: ${(data.affected_systems || []).join(', ') || 'N/A'}`,
    `Detection Method: ${data.detection_method ?? 'N/A'}`,
    `MTTR: ${data.mttr ?? 'N/A'} minutes`,
    `MTTA: ${data.mtta ?? 'N/A'} minutes`,
    `Affected Users: ${data.affected_users_count ?? 'N/A'}`,
    `Estimated Cost: ${data.estimated_cost ?? 'N/A'}`,
    `SLA Met: ${data.sla_met === true ? 'Yes' : data.sla_met === false ? 'No' : 'N/A'}`
  ];

  sections.push("=== INCIDENT SUMMARY ===");
  sections.push(summary.join('\n'));

  // 2. Description
  if (data.description) {
    sections.push("=== DESCRIPTION ===");
    sections.push(data.description);
  }

  // 3. Timeline
  if (Array.isArray(data.timeline) && data.timeline.length > 0) {
    sections.push("=== TIMELINE ===");
    data.timeline.forEach(t => {
      if (t.timestamp && t.event) {
        sections.push(`${t.timestamp} | ${t.event}`);
      }
    });
  }

  // 4. Analysis
  const analysis = [];
  if (data.root_cause_analysis)
    analysis.push(`Root Cause: ${data.root_cause_analysis}`);

  if (data.resolution)
    analysis.push(`Resolution: ${data.resolution}`);
  else if (data.resolution_summary)
    analysis.push(`Resolution Summary: ${data.resolution_summary}`);

  if (data.action_taken)
    analysis.push(`Action Taken: ${data.action_taken}`);

  if (analysis.length > 0) {
    sections.push("=== ANALYSIS ===");
    sections.push(analysis.join('\n'));
  }

  // 5. Remediation
  if (Array.isArray(data.remediation_actions) && data.remediation_actions.length > 0) {
    sections.push("=== REMEDIATION ACTIONS ===");
    sections.push(data.remediation_actions.join('\n'));
  }

  // 6. Lessons Learned
  if (data.lessons_learned) {
    sections.push("=== LESSONS LEARNED ===");
    sections.push(data.lessons_learned);
  }

  // 7. MITRE
  const mitre = [];
  if (Array.isArray(data.mitre_tactic_ids) && data.mitre_tactic_ids.length > 0)
    mitre.push(`MITRE Tactics: ${data.mitre_tactic_ids.join(', ')}`);

  if (Array.isArray(data.mitre_technique_ids) && data.mitre_technique_ids.length > 0)
    mitre.push(`MITRE Techniques: ${data.mitre_technique_ids.join(', ')}`);

  if (Array.isArray(data.mitre_prevention_ids) && data.mitre_prevention_ids.length > 0)
    mitre.push(`MITRE Prevention: ${data.mitre_prevention_ids.join(', ')}`);

  if (mitre.length > 0) {
    sections.push("=== MITRE MAPPING ===");
    sections.push(mitre.join('\n'));
  }

  const pageContent = sections.join('\n\n');

  return {
    json: {
      pageContent,
      metadata
    }
  };
});

return incidents;