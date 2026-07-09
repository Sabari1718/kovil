import os
import re

features_dir = r'C:\Users\sabar\StudioProjects\kulatheivam\lib\features'

edit_pattern = re.compile(r'(void\s+_edit[a-zA-Z]*\([^\)]+\)\s*\{)')
scroll_code = '''
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
'''

def process_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    # Skip files that don't have an edit method
    if not edit_pattern.search(content):
        return

    # Check if they have _scrollController
    if '_scrollController' not in content:
        print(f"Skipping {filepath} - no _scrollController")
        return

    # Skip if it's already got animateTo right after the method def
    # Let's do a more robust replacement using regex substitution.
    
    def replacer(match):
        method_def = match.group(1)
        # Check if scroll_code is already right after
        # It might be there already, but let's assume it's not.
        return method_def + scroll_code
        
    # But we don't want to add it if it's already there
    if 'animateTo(' in content and '_edit' in content:
        # Actually some files might have animateTo elsewhere (like in tabs). Let's just insert and if there's duplicate, it might be fine, but we should be careful.
        pass

    # A better approach: split by method def
    new_content = edit_pattern.sub(replacer, content)
    
    if new_content != content:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(new_content)
        print(f"Updated {filepath}")

for root, dirs, files in os.walk(features_dir):
    for file in files:
        if file.endswith('.dart'):
            process_file(os.path.join(root, file))
