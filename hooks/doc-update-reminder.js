#!/usr/bin/env node
/**
 * Stop Hook: is bitince dokumantasyon guncelleme hatirlaticisi
 *
 * Oturumda anlamli KAYNAK KOD degisikligi varsa (dokuman/config/lock dosyalari
 * haric), Claude durmadan once dokumantasyonu guncellemeye zorlanir:
 *  - Projede codemap varsa (docs/CODEMAPS veya CODEMAPS): doc-updater ile
 *    /update-docs + /update-codemaps.
 *  - Codemap yoksa: yalnizca etkilenen mevcut .md dosyalari + proje memory'si;
 *    codemap uretilmez.
 *
 * Dedupe: imza = degisen kaynak dosya KUMESI (diff icerigi degil). Ayni dosyalar
 * uzerinde yeni edit'ler tekrar bloklamaz; kumeye yeni bir dosya girerse sorar.
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
  // quotePath=false: Turkce karakterli adlar tirnakli/oktal kacisli gelmesin (yoksa .md filtresi kacirir).
  // untracked-files=all: yeni klasor tek satir "dir/" degil, icindeki dosyalar olarak gelsin.
  const r = exec('git', ['-c', 'core.quotePath=false', 'status', '--porcelain', '--untracked-files=all'], root);
  if (r.status !== 0 || !r.stdout) return [];
  return r.stdout
    .split('\n')
    .map(l => l.slice(3).trim())
    .filter(Boolean)
    .map(f => (f.includes(' -> ') ? f.split(' -> ').pop() : f));
}

function fileSetSignature(files) {
  return crypto.createHash('sha256').update(files.slice().sort().join('\n')).digest('hex');
}

function hasCodemaps(root) {
  return ['docs/CODEMAPS', 'CODEMAPS'].some(d => fs.existsSync(path.join(root, d)));
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

  const sig = fileSetSignature(meaningful);

  fs.mkdirSync(STATE_DIR, { recursive: true });
  const stateFile = path.join(STATE_DIR, `${String(data.session_id || 'nosession').replace(/[^\w-]/g, '_')}.json`);
  let last = {};
  try { last = JSON.parse(fs.readFileSync(stateFile, 'utf8')); } catch { /* ilk calisma */ }
  if (last.sig === sig) return; // bu anlamli diff icin zaten soruldu

  fs.writeFileSync(stateFile, JSON.stringify({ sig, ts: new Date().toISOString() }));

  // memory dizini transcript'in yanindadir: ~/.claude/projects/<proje>/memory
  const memoryDir = data.transcript_path ? path.join(path.dirname(data.transcript_path), 'memory') : '';
  const memoryLine = memoryDir && fs.existsSync(memoryDir)
    ? `- Proje memory'si (${memoryDir}): bu oturumda kalıcı bir karar/kısıt/workflow değiştiyse ilgili memory dosyasını güncelle (yoksa ekleme yapma). Bunu sen yap; konuşma bağlamı sende.`
    : '- Bu oturumda kalıcı bir karar/kısıt/workflow değiştiyse proje memory\'sine yaz (yoksa ekleme yapma).';

  const action = hasCodemaps(root)
    ? [
      'Durmadan önce doc-updater agentını çalıştır (/update-docs ve /update-codemaps) ki doküman ve codemap kodla senkron kalsın.',
      memoryLine,
    ]
    : [
      'Bu projede codemap yok — codemap ÜRETME. Durmadan önce yalnızca:',
      '- Değişiklikten etkilenen MEVCUT .md dosyalarını (README, docs/*.md, CLAUDE.md/AGENTS.md vb.) güncelle; yeni doküman dosyası açma. Az dosyaysa inline yap, çoksa doc-updater agentına "yalnız md modu" ve dosya listesiyle ver.',
      memoryLine,
    ];

  const shown = meaningful.slice(0, 10);
  process.stdout.write(JSON.stringify({
    decision: 'block',
    reason: [
      `[Dokümantasyon Güncelleme] Bu oturumda ${meaningful.length} kaynak dosya değişti (doküman/config/lock hariç):`,
      ...shown.map(f => `  - ${f}`),
      meaningful.length > shown.length ? `  ... +${meaningful.length - shown.length} dosya daha` : '',
      '',
      ...action,
      'Güncellenecek bir şey yoksa kullanıcıya tek satır sebeple bildir.',
      'Aynı dosya kümesi için bir daha sormaz; kümeye yeni bir kaynak dosya girerse tekrar hatırlatır.',
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
