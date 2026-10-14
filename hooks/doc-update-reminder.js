#!/usr/bin/env node
/**
 * Stop Hook: is bitince dokumantasyon guncelleme hatirlaticisi
 *
 * Oturumda anlamli KAYNAK KOD degisikligi varsa (dokuman/config/lock dosyalari
 * haric), Claude durmadan once doc-updater agent'ini (/update-docs,
 * /update-codemaps) calistirmaya zorlanir.
 *
 * Dedupe: ayni "anlamli diff" icin tekrar tekrar bloklamaz. Imza (dosya listesi +
 * diff icerigi hash'i) oturum bazli state dosyasinda tutulur; diff degismedikce
 * bir daha sormaz. Yeni bir kaynak degisikligi gelirse yeniden bloklar.
 *
 * Devre disi: DOC_UPDATE_STOP_CHECK=off
 */

'use strict';

const fs = require('fs');
const os = require('os');
const path = require('path');
const crypto = require('crypto');
const { spawnSync } = require('child_process');

const STATE_DIR = path.join(os.homedir(), '.claude', 'hooks-state', 'doc-update-reminder');
const DOC_UPDATER_AGENT = path.join(os.homedir(), '.claude', 'agents', 'doc-updater.md');

// dokuman / config / lock dosyalari -> "anlamli" sayilmaz
const EXCLUDE_RE = /(\.(md|mdx|json|ya?ml|toml|ini|cfg|lock)$)|((^|[\\/])(package-lock\.json|yarn\.lock|pnpm-lock\.yaml|composer\.lock|Gemfile\.lock|poetry\.lock|Cargo\.lock|\.gitignore|LICENSE)$)/i;

function exec(cmd, args, cwd) {
  return spawnSync(cmd, args, { cwd, encoding: 'utf8', timeout: 15000 });
}

function changedFiles(root) {
  const r = exec('git', ['status', '--porcelain'], root);
  if (r.status !== 0 || !r.stdout) return [];
  return r.stdout
    .split('\n')
    .map(l => l.slice(3).trim())
    .filter(Boolean)
    .map(f => (f.includes(' -> ') ? f.split(' -> ').pop() : f));
}

function diffSignature(root, files) {
  const tracked = exec('git', ['diff', '--', ...files], root).stdout || '';
  const staged = exec('git', ['diff', '--cached', '--', ...files], root).stdout || '';
  return crypto
    .createHash('sha256')
    .update(files.slice().sort().join('\n') + tracked + staged)
    .digest('hex');
}

function main(raw) {
  if (String(process.env.DOC_UPDATE_STOP_CHECK || '').toLowerCase() === 'off') return;
  if (!fs.existsSync(DOC_UPDATER_AGENT)) return; // agent kurulu degil -> hatirlatacak bir sey yok

  let data = {};
  try { data = JSON.parse(raw || '{}'); } catch { /* bozuk payload -> sessiz gec */ }
  if (data.stop_hook_active) return; // ayni stop-zincirinde tekrar bloklama

  const cwd = data.cwd || process.cwd();
  const inGit = exec('git', ['rev-parse', '--is-inside-work-tree'], cwd);
  if (inGit.status !== 0 || String(inGit.stdout || '').trim() !== 'true') return;

  const root = String(exec('git', ['rev-parse', '--show-toplevel'], cwd).stdout || '').trim() || cwd;
  const meaningful = changedFiles(root).filter(f => !EXCLUDE_RE.test(f));
  if (meaningful.length === 0) return;

  const sig = diffSignature(root, meaningful);

  fs.mkdirSync(STATE_DIR, { recursive: true });
  const stateFile = path.join(STATE_DIR, `${String(data.session_id || 'nosession').replace(/[^\w-]/g, '_')}.json`);
  let last = {};
  try { last = JSON.parse(fs.readFileSync(stateFile, 'utf8')); } catch { /* ilk calisma */ }
  if (last.sig === sig) return; // bu anlamli diff icin zaten soruldu

  fs.writeFileSync(stateFile, JSON.stringify({ sig, ts: new Date().toISOString() }));

  const shown = meaningful.slice(0, 10);
  process.stdout.write(JSON.stringify({
    decision: 'block',
    reason: [
      `[Dokümantasyon Güncelleme] Bu oturumda ${meaningful.length} kaynak dosya değişti (doküman/config/lock hariç):`,
      ...shown.map(f => `  - ${f}`),
      meaningful.length > shown.length ? `  ... +${meaningful.length - shown.length} dosya daha` : '',
      '',
      'Durmadan önce doc-updater agentını çalıştır (/update-docs ve /update-codemaps) ki dokümantasyon kodla senkron kalsın. Gerek yoksa (ör. dokümantasyona yansıması gereken bir değişiklik değilse) kullanıcıya sebebiyle birlikte bildir.',
      'Bu aynı değişiklik için bir daha sormaz; yeni bir kaynak değişikliği gelirse tekrar hatırlatır.',
    ].filter(Boolean).join('\n'),
  }));
}

let input = '';
process.stdin.setEncoding('utf8');
process.stdin.on('data', c => { input += c; });
process.stdin.on('end', () => {
  try { main(input); } catch (err) {
    process.stderr.write(`[doc-update-reminder] hata: ${err.message}\n`); // fail-open
  }
  process.exit(0);
});
