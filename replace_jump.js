const fs = require('fs');
const path = require('path');

const featuresDir = path.join('C:', 'Users', 'sabar', 'StudioProjects', 'kulatheivam', 'lib', 'features');

// This regex matches the animateTo block I inserted, as well as the ones already in the code.
const animatePattern = /_scrollController\.animateTo\([\s\S]*?curve:\s*Curves\.easeInOut,\s*\);/g;

function processFile(filepath) {
    let content = fs.readFileSync(filepath, 'utf8');

    if (!content.includes('animateTo')) return;

    let updatedContent = content.replace(animatePattern, '_scrollController.jumpTo(0);');

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
