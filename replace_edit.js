const fs = require('fs');
const path = require('path');

const featuresDir = path.join('C:', 'Users', 'sabar', 'StudioProjects', 'kulatheivam', 'lib', 'features');

const editPattern = /(void\s+_edit[a-zA-Z]*\([^\)]+\)\s*\{)/g;
const scrollCode = '\n    if (_scrollController.hasClients) {\n      _scrollController.animateTo(\n        0,\n        duration: const Duration(milliseconds: 300),\n        curve: Curves.easeInOut,\n      );\n    }\n';

function processFile(filepath) {
    let content = fs.readFileSync(filepath, 'utf8');

    if (!editPattern.test(content)) return;
    if (!content.includes('_scrollController')) return;

    // Reset regex index
    editPattern.lastIndex = 0;

    let updatedContent = content.replace(editPattern, (match) => {
        return match + scrollCode;
    });

    if (updatedContent !== content) {
        fs.writeFileSync(filepath, updatedContent, 'utf8');
        console.log('Updated ' + filepath);
    }
}

function walkDir(dir) {
    fs.readdirSync(dir).forEach(file => {
        let fullPath = path.join(dir, file);
        if (fs.statSync(fullPath).isDirectory()) {
            walkDir(fullPath);
        } else if (fullPath.endsWith('.dart')) {
            processFile(fullPath);
        }
    });
}

walkDir(featuresDir);
