const fs = require('fs');
const path = require('path');

const featuresDir = path.join('C:', 'Users', 'sabar', 'StudioProjects', 'kulatheivam', 'lib', 'features');

function checkFile(filepath) {
    let content = fs.readFileSync(filepath, 'utf8');
    if (content.includes('Icons.edit_outlined') || content.includes('_editingId =')) {
        if (!content.includes('animateTo(') && !content.includes('jumpTo(')) {
            console.log('Missing scroll: ' + filepath);
        }
    }
}

function walkDir(dir) {
    fs.readdirSync(dir).forEach(file => {
        let fullPath = path.join(dir, file);
        if (fs.statSync(fullPath).isDirectory()) {
            walkDir(fullPath);
        } else if (fullPath.endsWith('.dart')) {
            checkFile(fullPath);
        }
    });
}

walkDir(featuresDir);
