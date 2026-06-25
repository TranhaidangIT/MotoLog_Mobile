import os
import re

for root, dirs, files in os.walk('lib'):
    for file in files:
        if file.endswith('.dart'):
            filepath = os.path.join(root, file)
            with open(filepath, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # Replace 'const ClassName' -> 'ClassName'
            new_content = re.sub(r'const\s+([A-Z])', r'\1', content)
            
            # Replace 'const [' -> '['
            new_content = re.sub(r'const\s+\[', r'[', new_content)

            # Replace 'const {' -> '{'
            new_content = re.sub(r'const\s+\{', r'{', new_content)
            
            if new_content != content:
                with open(filepath, 'w', encoding='utf-8') as f:
                    f.write(new_content)
print("Done removing consts from constructors and collections.")
