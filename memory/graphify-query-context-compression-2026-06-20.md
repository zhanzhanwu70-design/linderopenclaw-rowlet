# Graphify Query: Context Compression & Summarization (2026-06-20)

**Query:** "context compression summarization memory compaction MemGPT SelfMem Memory-R2 token-level advantage PPO GRPO CompactionRL"
**Budget:** 2500 tokens
**Result:** 144 nodes found, 68 shown

## Key Nodes by Category

### 🔬 Memory Management Papers (community=32)
| Node | Source |
|------|--------|
| Active Context Compression: Autonomous Memory Management in LLM Agents | `wiki/sources/active-context-compression-autonomous-memory-management.md` |
| LongLLMLingua: Accelerating and Enhancing LLMs in Long Context Scenarios via Prompt Compression | `wiki/sources/longllmlingua-prompt-compression.md` |
| MemGPT: Towards LLMs as Operating Systems | `wiki/sources/memgpt-towards-llms-as-operating-systems.md` |
| HippoRAG: Neurobiologically Inspired Long-Term Memory for Large Language Models | `wiki/sources/hipporag-neurobiological-long-term-memory.md` |
| ReSum: Unlocking Long-Horizon Search Intelligence via Context Summarization | `wiki/sources/resum-context-summarization.md` |
| Mem0: Building Production-Ready AI Agents with Scalable Long-Term Memory | `wiki/sources/mem0-scalable-long-term-memory.md` |
| A-MEM: Agentic Memory for LLM Agents | `wiki/sources/a-mem-agentic-memory.md` |
| Eywa: Provenance-Grounded Long-Term Memory for AI Agents | `wiki/sources/eywa-provenance-grounded-long-term-memory.md` |
| ElasticMem: Latent Memory as a Learnable Resource for LLM Agents | `wiki/sources/elasticmem-latent-memory-as-learnable-resource-llm-agents.md` |
| MemRouter: Memory-as-Embedding Routing for Long-Term Conversational Agents | `wiki/sources/memrouter-memory-as-embedding-routing.md` |
| MemoryBank: Enhancing Large Language Models with Long-Term Memory | `wiki/sources/memorybank-long-term-memory.md` |
| Gisting: Learning to Compress Prompts with Gist Tokens | `wiki/sources/gisting-prompt-compression-gist-tokens.md` |
| Generative Agents: Interactive Simulacra of Human Behavior | `wiki/sources/generative-agents-interactive-simulacra-human-behavior.md` |

### 🧠 Internal Concepts (community=1/6)
| Node | Source |
|------|--------|
| Context Control Plane | `wiki/concepts/context-control-plane.md` |
| Agent Skill Architecture for OpenClaw | `wiki/synthesis/Agent Skill Architecture for OpenClaw.md` |
| Code Agent Map | `wiki/maps/code-agent.md` |
| Memory Subagent Flow | `wiki/concepts/Memory Subagent Flow.md` |
| Token 預算控制 | `wiki/sources/cloud-code-dynamic-workflows-advanced.md` |
| Adaptive Retrieval | `wiki/concepts/adaptive-retrieval.md` |

### 🌿 OpenClaw-Specific
| Node | Source |
|------|--------|
| Context Control Plane | `wiki/concepts/context-control-plane.md` |
| Memory Subagent Flow | `wiki/concepts/Memory Subagent Flow.md` |
| Agent Skill Architecture for OpenClaw | `wiki/synthesis/Agent Skill Architecture for OpenClaw.md` |
| Agent Prototype Skill | `wiki/concepts/Agent Prototype Skill.md` |

### 📊 Community Distribution
- **community=32** (Memory Systems): ~14 nodes — dominant cluster
- **community=1** (OpenClaw Architecture): ~10 nodes
- **community=6** (Code/Agent Maps): ~6 nodes
- **community=636** (Context concept): ~6 nodes
- **community=55** (Cloud Code): ~2 nodes
- **community=334** (ContextWeaver): ~10 nodes

## Notable: CompactionRL NOT yet in graph
- Query searched for "CompactionRL" explicitly — **0 results**
- CompactionRL is a new paper (not yet in LLM Wiki)
- roaringmoon should add it when ready

## Notable: SelfMem / Memory-R2 NOT in graph
- Query searched for "SelfMem" and "Memory-R2" — neither returned as separate nodes
- May exist under different naming in existing papers, or not yet ingested

## Synthesis for Team Discussion

### Two Compression Paradigms in the Graph
1. **Heuristic compression** (MemGPT, HippoRAG, A-MEM): fixed rules for when/how to compress
2. **Learnable compression** (CompactionRL — not yet in graph, ElasticMem): compression as optimization target

### Gap: token-level PPO/GRPO approaches
- No nodes explicitly connecting "token-level advantage" to memory management
- CompactionRL fills this gap (PPO token-level, summarization as action)
- MemGPT-style hierarchical memory could benefit from token-level credit assignment

### OpenClaw integration point
- `Context Control Plane` concept exists in wiki but likely doesn't account for RL-based compression
- `Memory Subagent Flow` is the natural hook for a CompactionRL-style skill
- Next step: read `context-control-plane.md` to understand current design before proposing changes

## Files to Read for Deep Dive
1. `wiki/sources/active-context-compression-autonomous-memory-management.md` — closest to CompactionRL philosophy
2. `wiki/sources/elasticmem-latent-memory-as-learnable-resource-llm-agents.md` — latent memory + learnable
3. `wiki/concepts/context-control-plane.md` — OpenClaw's current context architecture
4. `wiki/concepts/Memory Subagent Flow.md` — where heartbeat-triggered actions live
