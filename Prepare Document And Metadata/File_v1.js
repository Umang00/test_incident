const incidents = items.map(item => {
  const data = item.json;
  
  // 1. Format Date (YYYY-MM-DD)
  const fullDate = data['@timestamp'];
  const simpleDate = fullDate ? fullDate.split('T')[0] : null; 
  
  // Year & Quarter Calculation
  const year = simpleDate ? parseInt(simpleDate.split('-')[0]) : null;
  const quarter = simpleDate ? 'Q' + (Math.floor((parseInt(simpleDate.split('-')[1]) - 1) / 3) + 1) : null;

  // 2. Build Metadata (Consistent Schema, keeping nulls)
  const metadata = {
    incident_id: data.incident_id || null,
    date: simpleDate, 
    year: year,       // NEW
    quarter: quarter, // NEW
    severity: data.severity || null,
    status: data.status || null,
    category: data.category || null,
    type: data.type || null,
    affected_systems: data.affected_systems || [], 
    tags: data.tags || [],
    detection_method: data.detection_method || null,
    // MITRE IDs (Fixed naming)
    mitre_tactic_ids: data.mitre_tactic_ids || [],
    mitre_technique_ids: data.mitre_technique_ids || [],
    mitre_prevention_ids: data.mitre_prevention_ids || [], 
    
    // NEW METADATA FIELDS (Filtering & Aggregation)
    affected_users_count: data.affected_users_count !== undefined ? data.affected_users_count : null,
    estimated_cost: data.estimated_cost !== undefined ? data.estimated_cost : null,
    sla_met: data.sla_met !== undefined ? data.sla_met : null,
    mttr: data.mttr !== undefined ? data.mttr : null,
    mtta: data.mtta !== undefined ? data.mtta : null
  };

  // 3. Build Markdown
  // Use Nullish Coalescing (??) to avoid "null" strings
  let md = `# Incident: ${data.title ?? 'Untitled Incident'}\n\n`;
  
  // Formatting Helpers
  const formatSla = (val) => val === true ? 'Yes' : (val === false ? 'No' : 'N/A');
  const formatCost = (val) => (val !== undefined && val !== null) ? '$' + val.toLocaleString() : 'N/A'; // Added locale string for commas

  // Header: Core Info + New Metrics
  md += `**ID**: ${data.incident_id ?? 'N/A'} | **Severity**: ${data.severity ?? 'N/A'} | **Status**: ${data.status ?? 'N/A'}\n`;
  md += `**Date**: ${simpleDate ?? 'N/A'} (${quarter ?? '-'} ${year ?? '-'}) \n`;
  md += `**MTTR**: ${data.mttr ?? 'N/A'}m | **MTTA**: ${data.mtta ?? 'N/A'}m | **SLA Met**: ${formatSla(data.sla_met)}\n`;
  md += `**Cost**: ${formatCost(data.estimated_cost)} | **Affected Users**: ${data.affected_users_count ?? 'N/A'}\n\n`;
  
  md += `## Description\n${data.description ?? 'No description provided'}\n\n`;
  
  if (data.business_impact) {
    md += `**Business Impact**: ${data.business_impact}\n\n`;
  }
  
  if (data.timeline && data.timeline.length > 0) {
    md += `## Timeline\n${data.timeline.map(t => `- [${t.timestamp}] ${t.event}`).join('\n')}\n\n`;
  }
  
  md += `## Context & Impact\n`;
  if (data.affected_systems && data.affected_systems.length > 0) md += `- **Affected Systems**: ${data.affected_systems.join(', ')}\n`;
  if (data.detection_method) md += `- **Detection Method**: ${data.detection_method}\n`;
  if (data.category) md += `- **Category**: ${data.category} | **Type**: ${data.type}\n`;
  if (data.malware_hash) md += `- **Malware Hash**: ${data.malware_hash}\n`;
  if (data.source_ip) md += `- **Source IP**: ${data.source_ip}\n`;
  md += '\n';

  // Analysis & Resolution (Enhanced)
  if (data.root_cause_analysis || data.resolution_summary || data.resolution || data.action_taken) {
    md += `## Analysis & Resolution\n`;
    if (data.root_cause_analysis) md += `- **Root Cause**: ${data.root_cause_analysis}\n`;
    if (data.resolution) md += `- **Resolution**: ${data.resolution}\n`;
    else if (data.resolution_summary) md += `- **Resolution Summary**: ${data.resolution_summary}\n`;
    
    if (data.action_taken) md += `- **Action Taken**: ${data.action_taken}\n`;
    md += '\n';
  }

  // Remediation & Changes (New Section)
  if ((data.remediation_actions && data.remediation_actions.length > 0) || 
      (data.systems_remediated && data.systems_remediated.length > 0) ||
      (data.security_controls_updated && data.security_controls_updated.length > 0)) {
    
    md += `## Remediation & Changes\n`;
    
    if (data.remediation_actions && data.remediation_actions.length > 0) {
      md += `### Remediation Actions\n${data.remediation_actions.map(r => `- ${r}`).join('\n')}\n`;
    }
    
    if (data.systems_remediated && data.systems_remediated.length > 0) {
      md += `### Systems Remediated\n${data.systems_remediated.map(s => `- ${s}`).join('\n')}\n`;
    }
    
    if (data.security_controls_updated && data.security_controls_updated.length > 0) {
      md += `### Security Controls Updated\n${data.security_controls_updated.map(s => `- ${s}`).join('\n')}\n`;
    }
    md += '\n';
  }

  // Future Prevention & Lessons (New Section)
  if (data.lessons_learned || 
     (data.preventive_measures && data.preventive_measures.length > 0) || 
     (data.documentation_updated && data.documentation_updated.length > 0) ||
     (data.follow_up_tasks && data.follow_up_tasks.length > 0)) {
       
    md += `## Lessons Learned & Prevention\n`;
    
    if (data.lessons_learned) md += `- **Lessons Learned**: ${data.lessons_learned}\n\n`;
    
    if (data.preventive_measures && data.preventive_measures.length > 0) {
      md += `### Preventive Measures\n${data.preventive_measures.map(p => `- ${p}`).join('\n')}\n`;
    }
    
    if (data.documentation_updated && data.documentation_updated.length > 0) {
      md += `### Documentation Updated\n${data.documentation_updated.map(d => `- ${d}`).join('\n')}\n`;
    }
    
    if (data.follow_up_tasks && data.follow_up_tasks.length > 0) {
      md += `### Follow-up Tasks\n${data.follow_up_tasks.map(t => `- ${t}`).join('\n')}\n`;
    }
    md += '\n';
  }

  // MITRE Section (Preserved)
  const tactics = data.mitre?.tactic || [];
  const techniques = data.mitre?.technique || [];
  const prevention = data.mitre?.prevention || [];
  
  const valid = (arr) => Array.isArray(arr) && arr.length > 0 && arr.some(x => x && x.trim() !== '');

  if (valid(tactics) || valid(techniques) || valid(prevention)) {
    md += `## Defense (MITRE ATT&CK)\n`;
    if (valid(tactics)) md += `- **Tactics**: ${tactics.join(', ')}\n`;
    if (valid(techniques)) md += `- **Techniques**: ${techniques.join(', ')}\n`;
    if (valid(prevention)) md += `- **Prevention**: ${prevention.join(', ')}\n`;
  }

  return {
    json: {
      pageContent: md.trim(),
      metadata: metadata
    }
  };
});

return incidents;