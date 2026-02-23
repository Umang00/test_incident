# Project: Incident Response Github Repository

# Planning

1. ✔️ Used Perplexity to generate example incidents (’incidents.json’ in repo) including resolution steps.
2. **Next:** Generate embeddings from the incident data and store in vector database.
    1. Make sure the relevant metadata is stored for easy searching. 
    2. Document the consideration we have when thinking about different approaches to RAG, model choice, combining RAG with semantic search.
3. Generate another 5 test incidnets (without resolution fields) and check if our system can come up with remediation steps. Draft a prompt and fine-tune it
    1. On Friday let’s dicuss how we want the RAG component to be architected.
    2. First we want to identify the Mitre Att&ck TTPs that the ticket should be categorized by. We can use a simple LLM node in the workflow with output parser to achieve this. It might need access to Mitre database vectors, but we can first try without the Vector DB.
    3. My thinking is that we build a multi-agent system to find similar tickets using different techniques:
        1. We just use a simple non-AI workflow to find past resolved incidents that share the same `type` or `tag` categories.
        2. We then have different sub-agents that find similar incidents and provide a reason for why the incidnet is similar and why it is not. These sub agents will typically fall into one of the following categories:
            1. **Next Steps Agents:** agent suggests investigation steps then checks against timelines of past incidents where similar next steps were taken.
            2. **Root Cause Agent:** agent tries to identify the root cuase of the new issue and finds past resolved incidents with similar root causes.
    4. take the user query and try to find incidents (without LLM) that are in the same category or share certain key properties (the ‘incident cohort’). Then introduce the LLM to reason on the similarities/differences between the new incident and the cohort and formulate next steps accordingly.
    
    # Next Steps (by February 16, 2026)
    
    1. Create embeddings from sample incident data with appropriate meta data.
        1. Vector database: as you are comfortable with Supabase let’s use that. Can you set up a project and add credentials in n8n? You can invite me to that supabase project on viraj@deployed.engineer.
    2. Build AI Agent workflow that ingests a new ticket and checks against vector DB of past incidents to find those that are similar.
        1. Document how you clean up the JSON data and convert to markdown if required. 
        2. Write some discussion of the best pre-processing strategy (chunking, using metadata effectively etc.)
        - Sample prompt
            
            You are an expert SRE assistant helping with incident triage.
            
            **NEW ALERT:**
            
            - Title: [Incident Title]
            - Description: [Incident Description]
            - Service: [Incident Service Summary]
            - Urgency: [Incident Urgency]
            
            **SIMILAR PAST INCIDENTS:**
            
            [List of similar incidents with ID, section, match percentage, service, severity, date, and a snippet of content]
            
            **TASK:**
            
            Generate a concise triage note (max 400 words) with:
            
            1. Likely Root Cause (based on similar incidents)
            2. Recommended Resolution Steps (specific and actionable)
            3. Related Incident IDs for reference
            
            Format the response in clear, professional sections using proper headers. Use plain text formatting - no bold, italics, or markdown styling. Be concise and action-oriented. Focus on what the on-call engineer should do NOW.
            
    3. AI Agent outputs a report with the following fields:
        - Likely root cause(s) based on similar incidents
        - What is specific/different about this incident
        - Step-by-step resolution procedures for each root cause.
        - Links to related incidents
        - Historical success patterns
    4. Following this we will try to make this more complicated with multiple sub-agents each providing an analysis and a main agent that decides which analyses are most relevant to the new incidnet.
    
    **Models:**
    
    - Embeddings: Qwen3 8B
    - Chat model: GPT-OSS 120B
    
    **Credentials access:**
    
    - ✅ OpenRouter - $5 daily cap, let me know if you need more. Added by Viraj.
    - Supabase to be created by Umang.
    - Github - feel free to connect your GH account if you want to read the past incident JSON directly.
    
    [https://excalidraw.com/#json=tozVGyHBlmJxjdYntYnlo,TjMDnY9u4t3-qb4wOIrSww](https://excalidraw.com/#json=tozVGyHBlmJxjdYntYnlo,TjMDnY9u4t3-qb4wOIrSww)
    

### Original Brief

### Summary

- Github repository focusing on building an AI SOC Analyst that handles incident management. Repository includes:
    - Sample data
    - Workflows
    - Write up on usage instructions and strategic importance
- Goals:
    - Positioning n8n as an expert voice for AI in cybersecurity
    - Showcasing how AI companions can do entire jobs or significant parts of the job for specific
    - Lead gen for enterprise prospects within the cybersecurity space
    - Enablement and adoption growth by using this as an asset for CS and sales teams to leverage.
    - Going beyond workflow templates for a) greater visibility, b) ability for technical users to fork and start the repository and c) including dummy data so it’s demo-ready out of the box.

### Deep dive:

- Topic: AI-powered Incident Management
    - Acquire test incident/ticket data
    - Build workflow: ingest new ticket, compare to resolved tickets
    - Output playbook: root cause matching, suggested resolution, discussion of past incidents
    - Meta: how to build n8n workflows that help automate large parts of an analyst’s job.

### Publishing & promotion:

- Published as a standalone github repository with links to n8n (contact sales/lead gen) as well as Viraj’s company website and Linkedin.
- Workflows made available for free in n8n templates library
- Aim to amplify through cybersecurity influencers on LinkedIn - e.g. [Filip Stojkovski](https://www.linkedin.com/in/filipstojkovski/)
- Opportunity to amplify through cybersecurity [executive dinner](https://www.notion.so/4255f0e6f2774e718cb55533ed5a8244?pvs=21).

###