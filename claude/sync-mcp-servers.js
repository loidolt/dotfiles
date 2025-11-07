#!/usr/bin/env node

/**
 * Sync global MCP servers from dotfiles to Claude Code global config
 * 
 * This script merges MCP server definitions from mcp-servers.json into
 * the Claude Code global config at ~/.claude.json
 */

const fs = require('fs');
const path = require('path');
const os = require('os');

const DOTFILES_CONFIG = path.join(__dirname, 'mcp-servers.json');
const CLAUDE_CONFIG = path.join(os.homedir(), '.claude.json');

function readJSON(filepath) {
  try {
    return JSON.parse(fs.readFileSync(filepath, 'utf-8'));
  } catch (error) {
    if (error.code === 'ENOENT') {
      return null;
    }
    throw error;
  }
}

function writeJSON(filepath, data) {
  fs.writeFileSync(filepath, JSON.stringify(data, null, 2) + '\n', 'utf-8');
}

function createBackup(filepath) {
  if (!fs.existsSync(filepath)) {
    return null;
  }
  
  const timestamp = new Date().toISOString().replace(/[:.]/g, '-').slice(0, -5);
  const backupPath = `${filepath}.backup-${timestamp}`;
  
  fs.copyFileSync(filepath, backupPath);
  return backupPath;
}

function syncMCPServers() {
  // Read dotfiles config
  const dotfilesConfig = readJSON(DOTFILES_CONFIG);
  if (!dotfilesConfig || !dotfilesConfig.mcpServers) {
    console.error('Error: Could not read mcp-servers.json or it has no mcpServers');
    process.exit(1);
  }

  // Read Claude config
  let claudeConfig = readJSON(CLAUDE_CONFIG);
  if (!claudeConfig) {
    console.log('Claude config not found, creating new one...');
    claudeConfig = {};
  } else {
    // Create backup of existing config
    const backupPath = createBackup(CLAUDE_CONFIG);
    if (backupPath) {
      console.log(`\n📦 Backup created: ${backupPath}`);
    }
  }

  // Initialize globalMcpServers if it doesn't exist
  if (!claudeConfig.globalMcpServers) {
    claudeConfig.globalMcpServers = {};
  }

  // Track changes
  let added = [];
  let updated = [];
  let unchanged = [];

  // Merge MCP servers
  for (const [serverName, serverConfig] of Object.entries(dotfilesConfig.mcpServers)) {
    const existing = claudeConfig.globalMcpServers[serverName];
    const configString = JSON.stringify(serverConfig);
    const existingString = existing ? JSON.stringify(existing) : null;

    if (!existing) {
      added.push(serverName);
    } else if (configString !== existingString) {
      updated.push(serverName);
    } else {
      unchanged.push(serverName);
    }

    claudeConfig.globalMcpServers[serverName] = serverConfig;
  }

  // Write back to Claude config
  writeJSON(CLAUDE_CONFIG, claudeConfig);

  // Report results
  console.log('\n✓ MCP servers synced successfully!\n');
  
  if (added.length > 0) {
    console.log(`Added (${added.length}):`);
    added.forEach(name => console.log(`  + ${name}`));
    console.log();
  }
  
  if (updated.length > 0) {
    console.log(`Updated (${updated.length}):`);
    updated.forEach(name => console.log(`  ↻ ${name}`));
    console.log();
  }
  
  if (unchanged.length > 0) {
    console.log(`Unchanged (${unchanged.length}):`);
    unchanged.forEach(name => console.log(`  - ${name}`));
    console.log();
  }

  console.log(`Config location: ${CLAUDE_CONFIG}\n`);
}

// Run the sync
try {
  syncMCPServers();
} catch (error) {
  console.error('Error syncing MCP servers:', error.message);
  process.exit(1);
}
