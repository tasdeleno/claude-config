#!/usr/bin/env node
/**
 * Stop Hook: PHP kalite kapisi (Laravel Pint + PHPStan)
 *
 * ecc'nin stop-format-typecheck.js'i sadece JS/TS kapsiyor. Bu hook ayni isi
 * PHP tarafinda yapar:
 *   1. `pint --dirty`  -> degisen dosyalari sessizce formatlar (blok yok)
 *   2. `phpstan analyse <degisen .php>` -> hata varsa Stop'u bloklar
 *
 * Blok oturum basina EN FAZLA BIR KEZ olur; aksi halde duzeltilemeyen bir
 * legacy hatasi kalici doenguye sokar.
 *
 * Devre disi: ECC_PHP_STOP_CHECK=off
 */

'use strict';

const fs = require('fs');
const os = require('os');
const path = require('path');
const { spawnSync } = require('child_process');

const WIN = process.platform === 'win32';
const TIMEOUT_MS = 120000;
const MAX_FILES = 50;
const STATE_DIR = path.join(os.homedir(), '.claude', '.php-stop-check');

/** vendor/bin/<name> iceren en yakin ust dizini bul. */
function findRoot(startDir, binName) {
  let dir = path.resolve(startDir);
  for (let i = 0; i < 12; i++) {
    if (fs.existsSync(path.join(dir, 'vendor', 'bin', binName))) return dir;
    const parent = path.dirname(dir);
    if (parent === dir) break;
    dir = parent;
  }
  return null;
}

function bin(root, name) {
  return path.join(root, 'vendor', 'bin', WIN ? `${name}.bat` : name);
}

function exec(cmd, args, cwd) {
  return spawnSync(cmd, args, { cwd, encoding: 'utf8', timeout: TIMEOUT_MS, shell: WIN });
}

/** git'e gore degismis + izlenmeyen .php dosyalari (repo-relative). */
function changedPhpFiles(root) {
  const out = [];
  for (const args of [
    ['diff', '--name-only', 'HEAD', '--', '*.php'],
    ['ls-files', '--others', '--exclude-standard', '--', '*.php'],
  ]) {
    const r = exec('git', args, root);
    if (r.status === 0 && r.stdout) out.push(...r.stdout.split('\n').map(s => s.trim()).filter(Boolean));
  }
  return [...new Set(out)].filter(f => fs.existsSync(path.join(root, f))).slice(0, MAX_FILES);
}

/**
 * PHPStan ciktisini satir listesine cevir.
 * Bazi projeler (phpstan.neon'daki errorFormat / eklentiler) `--error-format=raw`
 * yerine JSON dondurur; o durumda gercek hata sayisi tek satirda gizli kalirdi.
 */
function parseErrors(stdout) {
  try {
    const j = JSON.parse(stdout);
    const details = j.error_details || (j.files && j.files) || null;
    if (details && typeof details === 'object') {
      const out = [];
      for (const [file, entries] of Object.entries(details)) {
        const list = Array.isArray(entries) ? entries : entries.messages || [];
        for (const e of list) out.push(`${file}:${e.line} ${e.message}${e.identifier ? ` [${e.identifier}]` : ''}`);
      }
      if (out.length > 0) return out;
    }
  } catch { /* JSON degil -> raw satirlar */ }
  return stdout.split('\n').map(s => s.trim()).filter(Boolean);
}

/** Bu oturumda daha once blokladik mi? Hayirsa isaretle. */
function alreadyBlocked(sessionId) {
  const marker = path.join(STATE_DIR, `${String(sessionId || 'nosession').replace(/[^\w-]/g, '_')}.txt`);
  if (fs.existsSync(marker)) return true;
  fs.mkdirSync(STATE_DIR, { recursive: true });
  fs.writeFileSync(marker, new Date().toISOString());
  return false;
}

function main(raw) {
  if (String(process.env.ECC_PHP_STOP_CHECK || '').toLowerCase() === 'off') return;

  let data = {};
  try { data = JSON.parse(raw || '{}'); } catch { /* bozuk payload -> sessiz gec */ }
  if (data.stop_hook_active) return; // zaten blok sonrasi tur; tekrar bloklama

  const cwd = data.cwd || process.cwd();
  const root = findRoot(cwd, WIN ? 'pint.bat' : 'pint');
  if (!root) return; // PHP projesi degil

  const files = changedPhpFiles(root);
  if (files.length === 0) return;

  // 1) Pint — otomatik duzelt, sonucu umursama (formatlama blok sebebi degil)
  exec(bin(root, 'pint'), ['--dirty'], root);

  // 2) PHPStan — sadece config varsa, sadece degisen dosyalarda
  if (!fs.existsSync(path.join(root, 'phpstan.neon'))) return;
  const r = exec(bin(root, 'phpstan'), ['analyse', '--no-progress', '--error-format=raw', ...files], root);
  if (r.status === 0 || !r.stdout || !r.stdout.trim()) return;

  const errors = parseErrors(r.stdout.trim());
  if (errors.length === 0) return;
  if (alreadyBlocked(data.session_id)) {
    process.stderr.write(`[php-stop-check] PHPStan ${errors.length} hata (bu oturumda tekrar bloklanmadi)\n`);
    return;
  }

  process.stdout.write(JSON.stringify({
    decision: 'block',
    reason: [
      `[PHP Kalite Kapisi] PHPStan ${errors.length} hata buldu (degisen ${files.length} dosyada):`,
      '',
      ...errors.slice(0, 25),
      errors.length > 25 ? `... +${errors.length - 25} hata daha` : '',
      '',
      'Bunlari duzelt, ya da bilincli birakiyorsan kullaniciya sebebiyle birlikte bildir.',
      'Bu kapi oturum basina yalnizca bir kez bloklar.',
    ].filter(Boolean).join('\n'),
  }));
}

let input = '';
process.stdin.setEncoding('utf8');
process.stdin.on('data', c => { input += c; });
process.stdin.on('end', () => {
  try { main(input); } catch (err) {
    process.stderr.write(`[php-stop-check] hata: ${err.message}\n`); // fail-open
  }
  process.exit(0);
});
