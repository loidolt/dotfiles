#!/usr/bin/env node

/**
 * Generate .mcp.json file for Claude Code projects
 * 
 * This script creates a project-scoped .mcp.json file that can be committed
 * to your project repository, making MCP servers available to all team members.
 */

const fs = require('fs');
const path = require('path');

const SOURCE_CONFIG = path.join(__dirname, 'mcp-servers.json');

function readJSON(filepath) {
  try {
    return JSON.parse(fs.readFileSync(filepath, 'utf-8'));
  } catch (error) {
    console.error(`Error reading ${filepath}:`, error.message);
    process.exit(1);
  }
}

function writeJSON(filepath, data) {
  fs.writeFileSync(filepath, JSON.stringify(data, null, 2) + '\n', 'utf-8');
}

function generateProjectMCP(targetDir) {
  // Read source config
  const sourceConfig = readJSON(SOURCE_CONFIG);
  if (!sourceConfig || !sourceConfig.mcpServers) {
    console.error('Error: mcp-servers.json has no mcpServers section');
    process.exit(1);
  }

  // Prepare project config
  const projectConfig = {
    mcpServers: sourceConfig.mcpServers
  };

  // Write to target directory
  const targetPath = path.join(targetDir, '.mcp.json');
  const exists = fs.existsSync(targetPath);
  
  if (exists) {
    console.log(`\n⚠️  Warning: ${targetPath} already exists`);
    console.log('   This will overwrite the existing file.\n');
  }

  writeJSON(targetPath, projectConfig);

  console.log(`\n✓ Created ${targetPath}\n`);
  console.log('MCP Servers configured:');
  Object.keys(sourceConfig.mcpServers).forEach(name => {
    console.log(`  • ${name}`);
  });
  console.log('\nNext steps:');
  console.log('1. Restart Claude Code');
  console.log('2. Approve the project MCP servers when prompted');
  console.log('3. (Optional) Commit .mcp.json to version control for team sharing\n');
}

// Get target directory from command line or use current directory
const targetDir = process.argv[2] || process.cwd();

if (!fs.existsSync(targetDir)) {
  console.error(`Error: Directory ${targetDir} does not exist`);
  process.exit(1);
}

generateProjectMCP(targetDir);
