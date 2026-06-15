'use strict';

const STORAGE_KEY  = 'imperialTablet_layout';
const MIN_W        = 400;
const MIN_H        = 300;
const DRAG_BAR_H   = 30;
const BORDER_SIZE  = 15;  

const PRESETS = {
    sm: { w: 900,  h: 500  },
    md: { w: 1200, h: 675  },
    lg: { w: 1600, h: 800  },
    xl: { w: 1920, h: 1080 },
};

const monitor  = document.getElementById('monitor');
const dragBar  = document.getElementById('dragBar');
const handles  = document.querySelectorAll('.resize-handle');

let tabletVisible = false;
let layout = { left: 0, top: 0, w: 1600, h: 800 };
let interaction = null;

function nuiFetch(handler, payload = {}) {
    fetch(`https://${GetParentResourceName()}/${handler}`, {
        method:  'POST',
        headers: { 'Content-Type': 'application/json' },
        body:    JSON.stringify(payload),
    }).catch(() => {});
}

function saveLayout() {
    try {
        localStorage.setItem(STORAGE_KEY, JSON.stringify(layout));
    } catch (_) {}
}

function loadLayout() {
    try {
        const raw = localStorage.getItem(STORAGE_KEY);
        if (raw) Object.assign(layout, JSON.parse(raw));
    } catch (_) {}
}

function clampLayout() {
    const vw = window.innerWidth;
    const vh = window.innerHeight;

    layout.w = Math.max(MIN_W, Math.min(layout.w, vw));
    layout.h = Math.max(MIN_H, Math.min(layout.h, vh - DRAG_BAR_H));

    layout.left = Math.max(0, Math.min(layout.left, vw - layout.w));
    layout.top  = Math.max(DRAG_BAR_H, Math.min(layout.top, vh - layout.h));
}

function applyLayout() {
    clampLayout();

    monitor.style.left   = `${layout.left}px`;
    monitor.style.top    = `${layout.top}px`;
    monitor.style.width  = `${layout.w}px`;
    monitor.style.height = `${layout.h}px`;

    dragBar.style.left  = `${layout.left}px`;
    dragBar.style.top   = `${layout.top - DRAG_BAR_H}px`;
    dragBar.style.width = `${layout.w}px`;

    positionHandles();
}

function positionHandles() {
    const { left, top, w, h } = layout;
    const O = 4;  
    const CORNER = 14;
    const EDGE_W = w - CORNER * 2;
    const EDGE_H = h - CORNER * 2;

    const pos = {
        n:  { left: left + CORNER,     top: top - O,               width: EDGE_W,  height: 8 },
        s:  { left: left + CORNER,     top: top + h - 8 + O,       width: EDGE_W,  height: 8 },
        w:  { left: left - O,          top: top + CORNER,           width: 8,       height: EDGE_H },
        e:  { left: left + w - 8 + O,  top: top + CORNER,           width: 8,       height: EDGE_H },
        nw: { left: left - O,          top: top - O,                width: CORNER,  height: CORNER },
        ne: { left: left + w - CORNER + O, top: top - O,            width: CORNER,  height: CORNER },
        sw: { left: left - O,          top: top + h - CORNER + O,   width: CORNER,  height: CORNER },
        se: { left: left + w - CORNER + O, top: top + h - CORNER + O, width: CORNER, height: CORNER },
    };

    handles.forEach(handle => {
        const d = handle.dataset.dir;
        const p = pos[d];
        handle.style.left   = `${p.left}px`;
        handle.style.top    = `${p.top}px`;
        handle.style.width  = `${p.width}px`;
        handle.style.height = `${p.height}px`;
    });
}

function showTablet() {
    loadLayout();

    if (!localStorage.getItem(STORAGE_KEY)) {
        layout.left = Math.round((window.innerWidth  - layout.w) / 2);
        layout.top  = Math.round((window.innerHeight - layout.h) / 2);
    }

    applyLayout();

    monitor.style.display = 'block';
    dragBar.style.display = 'flex';
    handles.forEach(h => h.style.display = 'block');

    tabletVisible = true;
    nuiFetch('setNuiFocus', { focus: true, cursor: true });
}

function hideTablet() {
    monitor.style.display = 'none';
    dragBar.style.display = 'none';
    handles.forEach(h => h.style.display = 'none');

    tabletVisible = false;
    nuiFetch('setNuiFocus', { focus: false, cursor: false });
}

window.addEventListener('message', function (event) {
    if (event.data.type === 'DISPLAY_TABLET') {
        showTablet();
    } else if (event.data.type === 'HIDE_TABLET') {
        hideTablet();
    }
});

document.addEventListener('keydown', function (e) {
    if (e.key === 'Escape' && tabletVisible) {
        hideTablet();
        nuiFetch('closeTablet');
    }
});

dragBar.querySelectorAll('.size-btn').forEach(btn => {
    btn.addEventListener('click', function (e) {
        e.stopPropagation(); // don't trigger drag

        const preset = PRESETS[btn.dataset.preset];
        if (!preset) return;

        const cx = layout.left + layout.w / 2;
        const cy = layout.top  + layout.h / 2;

        layout.w = preset.w;
        layout.h = preset.h;
        layout.left = Math.round(cx - layout.w / 2);
        layout.top  = Math.round(cy - layout.h / 2);

        applyLayout();
        saveLayout();
    });
});

dragBar.addEventListener('mousedown', function (e) {
    if (e.target.classList.contains('size-btn')) return;
    e.preventDefault();

    interaction = {
        type:        'drag',
        startX:      e.clientX,
        startY:      e.clientY,
        startLayout: { ...layout },
    };

    monitor.classList.add('interacting');
});

handles.forEach(handle => {
    handle.addEventListener('mousedown', function (e) {
        e.preventDefault();

        interaction = {
            type:        'resize',
            dir:         handle.dataset.dir,
            startX:      e.clientX,
            startY:      e.clientY,
            startLayout: { ...layout },
        };

        monitor.classList.add('interacting');
    });
});

document.addEventListener('mousemove', function (e) {
    if (!interaction) return;

    const dx = e.clientX - interaction.startX;
    const dy = e.clientY - interaction.startY;
    const sl = interaction.startLayout;

    if (interaction.type === 'drag') {
        layout.left = sl.left + dx;
        layout.top  = sl.top  + dy;

    } else {
        const dir = interaction.dir;

        if (dir.includes('s')) {
            layout.h = Math.max(MIN_H, sl.h + dy);
        }
        if (dir.includes('n')) {
            const newH = Math.max(MIN_H, sl.h - dy);
            layout.top  = sl.top  + (sl.h - newH);
            layout.h    = newH;
        }

        if (dir.includes('e')) {
            layout.w = Math.max(MIN_W, sl.w + dx);
        }
        if (dir.includes('w')) {
            const newW = Math.max(MIN_W, sl.w - dx);
            layout.left = sl.left + (sl.w - newW);
            layout.w    = newW;
        }
    }

    applyLayout();
});

document.addEventListener('mouseup', function () {
    if (!interaction) return;

    monitor.classList.remove('interacting');
    saveLayout();
    interaction = null;
});