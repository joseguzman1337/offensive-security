import os
import re
from pathlib import Path

REPLACEMENTS = {
    r"actions/checkout@[vV][0-7]": "actions/checkout@9c091bb21b7c1c1d1991bb908d89e4e9dddfe3e0 # v7.0.0",
    r"actions/checkout@[0-9a-f]{40}": "actions/checkout@9c091bb21b7c1c1d1991bb908d89e4e9dddfe3e0 # v7.0.0",
    
    r"actions/setup-python@[vV][0-6]": "actions/setup-python@53b83947a5a98c8d113130e565377fae1a50d02f # v6.3.0",
    r"actions/setup-python@[0-9a-f]{40}": "actions/setup-python@53b83947a5a98c8d113130e565377fae1a50d02f # v6.3.0",
    
    r"actions/setup-node@[vV][0-6]": "actions/setup-node@48b55a011bda9f5d6aeb4c2d9c7362e8dae4041e # v6.4.0",
    r"actions/setup-node@[0-9a-f]{40}": "actions/setup-node@48b55a011bda9f5d6aeb4c2d9c7362e8dae4041e # v6.4.0",
    
    r"actions/upload-artifact@[vV][0-7]": "actions/upload-artifact@043fb46d1a93c77aae656e7c1c64a875d1fc6a0a # v7.0.1",
    r"actions/upload-artifact@[0-9a-f]{40}": "actions/upload-artifact@043fb46d1a93c77aae656e7c1c64a875d1fc6a0a # v7.0.1",
    
    r"step-security/harden-runner@[vV][0-2]": "step-security/harden-runner@bf7454d06d71f1098171f2acdf0cd4708d7b5920 # v2.20.0",
    r"step-security/harden-runner@[0-9a-f]{40}": "step-security/harden-runner@bf7454d06d71f1098171f2acdf0cd4708d7b5920 # v2.20.0",
    
    r"github/codeql-action/(init|autobuild|analyze|upload-sarif)@[vV][0-4]": r"github/codeql-action/\1@24ea975727876cf496b1eb0c5b36e96e01600b51 # v4.37.0",
    r"github/codeql-action/(init|autobuild|analyze|upload-sarif)@[0-9a-f]{40}": r"github/codeql-action/\1@24ea975727876cf496b1eb0c5b36e96e01600b51 # v4.37.0",
    
    r"ossf/scorecard-action@[vV][0-2]": "ossf/scorecard-action@99c09fe975337306107572b4fdf4db224cf8e2f2 # v2.4.3",
    r"ossf/scorecard-action@[0-9a-f]{40}": "ossf/scorecard-action@99c09fe975337306107572b4fdf4db224cf8e2f2 # v2.4.3",
    
    r"actions/dependency-review-action@[vV][0-5]": "actions/dependency-review-action@a1d282b36b6f3519aa1f3fc636f609c47dddb294 # v5.0.0",
    r"actions/dependency-review-action@[0-9a-f]{40}": "actions/dependency-review-action@a1d282b36b6f3519aa1f3fc636f609c47dddb294 # v5.0.0",
    
    r"aquasecurity/trivy-action@[vV][0-9.]+": "aquasecurity/trivy-action@c1824fd6edce30d7ab345a9989de00bbd46ef284 # v0.34.0",
    r"aquasecurity/trivy-action@[0-9a-f]{40}": "aquasecurity/trivy-action@c1824fd6edce30d7ab345a9989de00bbd46ef284 # v0.34.0",
    r"aquasecurity/trivy-action@master": "aquasecurity/trivy-action@c1824fd6edce30d7ab345a9989de00bbd46ef284 # v0.34.0",
    
    r"microsoft/psscriptanalyzer-action@[vV][0-1]": "microsoft/psscriptanalyzer-action@6b2948b1944407914a58661c49941824d149734f # v1.1",
    r"microsoft/psscriptanalyzer-action@[0-9a-f]{40}": "microsoft/psscriptanalyzer-action@6b2948b1944407914a58661c49941824d149734f # v1.1",
}

def bump_workflows():
    workflow_dir = Path(".github/workflows")
    if not workflow_dir.exists():
        print("No .github/workflows directory found.")
        return

    for yml_file in workflow_dir.glob("*.y*ml"):
        print(f"Processing {yml_file}...")
        content = yml_file.read_text()
        new_content = content
        
        for pattern, replacement in REPLACEMENTS.items():
            # Handle cases where there might be an existing comment
            full_pattern = pattern + r"(\s*#.*)?"
            # If replacement already has a comment, we replace the whole thing
            new_content = re.sub(full_pattern, replacement, new_content)
            
        if new_content != content:
            yml_file.write_text(new_content)
            print(f"Updated {yml_file}")
        else:
            print(f"No changes for {yml_file}")

if __name__ == "__main__":
    bump_workflows()
