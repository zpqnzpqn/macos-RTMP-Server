const NodeMediaServer = require('node-media-server');
const fs = require('fs');
const os = require('os');
const path = require('path');
const { execSync } = require('child_process');

// Parse command line arguments
const args = process.argv.slice(2);
let rtmpPort = 1935;
let httpPort = 8000;
let streamKey = '';
let streamKeyType = 'random'; // 'random' | 'fixed'

args.forEach(arg => {
  if (arg.startsWith('--rtmp-port=')) {
    rtmpPort = parseInt(arg.split('=')[1], 10);
  } else if (arg.startsWith('--http-port=')) {
    httpPort = parseInt(arg.split('=')[1], 10);
  } else if (arg.startsWith('--key=')) {
    streamKey = arg.split('=')[1];
  } else if (arg.startsWith('--type=')) {
    streamKeyType = arg.split('=')[1];
  }
});

console.log(`[NodeMediaServer] Starting with config:`);
console.log(`  RTMP Port: ${rtmpPort}`);
console.log(`  HTTP Port: ${httpPort}`);
console.log(`  Stream Key: ${streamKey}`);
console.log(`  Stream Key Type: ${streamKeyType}`);

function getFFmpegPath() {
  if (fs.existsSync('/opt/homebrew/bin/ffmpeg')) {
    return '/opt/homebrew/bin/ffmpeg';
  }
  if (fs.existsSync('/usr/local/bin/ffmpeg')) {
    return '/usr/local/bin/ffmpeg';
  }
  try {
    const resolved = execSync('which ffmpeg', { encoding: 'utf8' }).trim();
    if (resolved) return resolved;
  } catch (e) {}
  return '/usr/local/bin/ffmpeg'; // Fallback
}

const config = {
  logType: 1, // 0 = none, 1 = error/status, 2 = info, 3 = debug, 4 = trace (1 significantly reduces IPC IPC latency)
  rtmp: {
    port: rtmpPort,
    chunk_size: 60000,
    gop_cache: true,
    ping: 60,
    ping_timeout: 30
  },
  http: {
    port: httpPort,
    mediaroot: path.join(os.tmpdir(), 'local-rtmp-server-media'),
    allow_origin: '*'
  },
  trans: {
    ffmpeg: getFFmpegPath(),
    tasks: [
      {
        app: 'live',
        ac: 'aac',
        hls: true,
        hlsFlags: '[hls_time=1:hls_list_size=2:hls_flags=delete_segments]',
        dash: false
      }
    ]
  }
};

const nms = new NodeMediaServer(config);

nms.on('prePublish', (id, StreamPath, args) => {
  console.log(`[STATUS] prePublish:${id}:${StreamPath}`);
  
  const session = nms.getSession(id);
  const key = StreamPath.split('/').pop();

  if (streamKeyType === 'fixed' || streamKeyType === 'random') {
    if (key !== streamKey) {
      console.log(`[NodeMediaServer] Rejected key mismatch. Expected: ${streamKey}, Got: ${key}`);
      if (session && typeof session.reject === 'function') {
        session.reject();
      }
    } else {
      console.log(`[NodeMediaServer] Accepted key match: ${key}`);
    }
  }
});

nms.on('donePublish', (id, StreamPath, args) => {
  console.log(`[STATUS] donePublish:${id}:${StreamPath}`);
});

nms.run();

// Keep stdin open to detect parent exit
process.stdin.resume();
process.stdin.on('end', () => {
  console.log('[NodeMediaServer] Stdin closed, exiting...');
  process.exit(0);
});

// Periodic check for orphaned process
setInterval(() => {
  try {
    if (process.ppid === 1) {
      console.log('[NodeMediaServer] Parent process died (ppid is 1), exiting...');
      process.exit(0);
    }
  } catch (e) {
    process.exit(0);
  }
}, 2000);
