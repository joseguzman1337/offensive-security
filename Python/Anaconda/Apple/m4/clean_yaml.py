import yaml

# Load the YAML file
with open("x.yaml", "r") as f:
    data = yaml.safe_load(f)

# Process regular dependencies
new_dependencies = []
for item in data["dependencies"]:
    if isinstance(item, str):
        package_name = item.split("=")[0]
        new_dependencies.append(package_name)
    elif isinstance(item, dict):
        package_name = list(item.keys())[0].split("=")[0]
        new_dependencies.append(package_name)
data["dependencies"] = new_dependencies

# Process pip dependencies
new_pip_dependencies = []
for item in data["pip"]:
    package_name = item.split("==")[0]
    new_pip_dependencies.append(package_name)
data["pip"] = new_pip_dependencies

# Write the modified data back to the YAML file
with open("x.yaml", "w") as f:
    yaml.dump(data, f, indent=2)
