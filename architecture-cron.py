#!/usr/bin/env python3
"""
架構師每日情報彙報
每天下午 6 點自動執行，搜尋架構相關資訊並報告給 CEO
"""

import json
import subprocess
from datetime import datetime

# 搜尋關鍵詞
SEARCH_QUERIES = [
    "agent architecture skill 2026",
    "LLM multi-agent architecture design",
    "harness engineering AI agent",
    "skill artifact optimization RL",
    "subagent orchestration framework",
]

OUTPUT_FILE = "/home/amr/.openclaw/workspace-rowlet/architecture-daily-report.md"

def run_searches():
    """執行多個搜尋任務"""
    results = []
    for query in SEARCH_QUERIES:
        try:
            result = subprocess.run(
                ["cd /home/amr/llm-wiki && npx graphifyy query \"{}\" --budget 500 2>&1".format(query)],
                shell=True,
                capture_output=True,
                text=True,
                timeout=30
            )
            results.append({
                "query": query,
                "output": result.stdout[:500] if result.stdout else result.stderr[:500]
            })
        except Exception as e:
            results.append({"query": query, "error": str(e)})
    return results

def generate_report():
    """產生每日報告"""
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M UTC")
    
    report = f"""# 架構師每日情報 — {timestamp}

## 搜尋結果

"""
    search_results = run_searches()
    for r in search_results:
        report += f"### {r['query']}\n"
        if 'error' in r:
            report += f"錯誤：{r['error']}\n\n"
        else:
            report += f"```\n{r['output']}\n```\n\n"
    
    report += """
## 本次執行狀態

- 狀態：✅ 完成
- 執行時間：{timestamp}

---
*此報告由 Rowlet 自動產生，每天下午 6 點執行*
"""
    
    return report

if __name__ == "__main__":
    report = generate_report()
    with open(OUTPUT_FILE, "w") as f:
        f.write(report)
    print(f"Report saved to {OUTPUT_FILE}")