#!/usr/bin/env python3
import subprocess
import json
import os
import sys
import tkinter as tk
from PIL import Image, ImageTk

THUMB_DIR = "/tmp/window-grid-thumbs"
TILE_W = 280
TILE_H = 200
PADDING = 12
COLUMNS = 4

os.makedirs(THUMB_DIR, exist_ok=True)

def get_floating_windows():
    try:
        r = subprocess.run(['hyprctl', 'clients', '-j'], capture_output=True, text=True, timeout=0.5)
        clients = json.loads(r.stdout)
        r2 = subprocess.run(['hyprctl', 'activeworkspace', '-j'], capture_output=True, text=True, timeout=0.5)
        ws = json.loads(r2.stdout)
        ws_id = ws['id']
        return [c for c in clients if c.get('floating') and c.get('workspace', {}).get('id') == ws_id]
    except Exception:
        return []

def get_monitor_geometry():
    try:
        r = subprocess.run(['hyprctl', 'monitors', '-j'], capture_output=True, text=True, timeout=0.5)
        monitors = json.loads(r.stdout)
        for m in monitors:
            if m.get('focused'):
                return m['x'], m['y'], m['width'], m['height']
        m = monitors[0]
        return m['x'], m['y'], m['width'], m['height']
    except Exception:
        return 0, 0, 1920, 1080

def capture_thumbnails(windows):
    mon_x, mon_y, mon_w, mon_h = get_monitor_geometry()

    screenshot_path = "/tmp/window-grid-screenshot.png"
    try:
        subprocess.run(['grim', '-g', f'{mon_x},{mon_y} {mon_w}x{mon_h}', screenshot_path],
                       capture_output=True, timeout=2)
    except Exception:
        return {}

    thumbnails = {}
    for i, w in enumerate(windows):
        addr = w['address']
        wx, wy = w['at']
        ww, wh = w['size']

        crop_x = wx - mon_x
        crop_y = wy - mon_y

        thumb_path = os.path.join(THUMB_DIR, f"{addr}.png")
        try:
            subprocess.run([
                'convert', screenshot_path,
                '-crop', f'{ww}x{wh}+{crop_x}+{crop_y}+0',
                '-resize', f'{TILE_W}x{TILE_H}',
                thumb_path
            ], capture_output=True, timeout=2)
            if os.path.exists(thumb_path):
                thumbnails[addr] = thumb_path
        except Exception:
            pass

    return thumbnails

def center_window_on_monitor(window, mon_x, mon_y, mon_w, mon_h):
    ww, wh = window['size']
    target_x = mon_x + (mon_w - ww) // 2
    target_y = mon_y + (mon_h - wh) // 2
    subprocess.Popen([
        'hyprctl', 'dispatch', 'movewindowpixel',
        f'exact {target_x} {target_y},address:{window["address"]}'
    ], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

def focus_window(addr):
    subprocess.Popen(['hyprctl', 'dispatch', f'focuswindow', f'address:{addr}'],
                     stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

def on_tile_click(window, mon_x, mon_y, mon_w, mon_h, root):
    center_window_on_monitor(window, mon_x, mon_y, mon_w, mon_h)
    focus_window(window['address'])
    root.destroy()

def build_grid():
    windows = get_floating_windows()
    if not windows:
        sys.exit(0)

    mon_x, mon_y, mon_w, mon_h = get_monitor_geometry()
    thumbnails = capture_thumbnails(windows)

    root = tk.Tk()
    root.title("Window Grid")
    root.configure(bg='#1e1e2e')
    root.attributes('-topmost', True)
    root.overrideredirect(True)

    cols = min(COLUMNS, len(windows))
    rows = (len(windows) + cols - 1) // cols
    grid_w = cols * (TILE_W + PADDING) + PADDING
    grid_h = rows * (TILE_H + PADDING + 28) + PADDING

    pos_x = mon_x + (mon_w - grid_w) // 2
    pos_y = mon_y + (mon_h - grid_h) // 2
    root.geometry(f'{grid_w}x{grid_h}+{pos_x}+{pos_y}')

    for i, w in enumerate(windows):
        col = i % cols
        row = i // cols

        frame = tk.Frame(root, bg='#313244', bd=0, highlightthickness=1,
                         highlightbackground='#45475a', highlightcolor='#89b4fa')
        frame.grid(row=row, column=col, padx=PADDING//2, pady=PADDING//2, sticky='nsew')

        addr = w['address']
        if addr in thumbnails and os.path.exists(thumbnails[addr]):
            try:
                img = Image.open(thumbnails[addr])
                img = img.resize((TILE_W, TILE_H), Image.LANCZOS)
                photo = ImageTk.PhotoImage(img)
                lbl = tk.Label(frame, image=photo, bg='#313244')
                lbl.image = photo
                lbl.pack(padx=4, pady=(4, 0))
            except Exception:
                lbl = tk.Label(frame, text=w.get('class', '?'), bg='#313244', fg='#cdd6f4',
                               font=('sans-serif', 14), width=20, height=8)
                lbl.pack(padx=4, pady=(4, 0))
        else:
            lbl = tk.Label(frame, text=w.get('class', '?'), bg='#313244', fg='#cdd6f4',
                           font=('sans-serif', 14), width=20, height=8)
            lbl.pack(padx=4, pady=(4, 0))

        title = w.get('title', w.get('class', ''))
        if len(title) > 30:
            title = title[:27] + '...'
        lbl_title = tk.Label(frame, text=title, bg='#313244', fg='#a6adc8',
                             font=('sans-serif', 9), wraplength=TILE_W - 10)
        lbl_title.pack(padx=4, pady=(0, 4))

        for widget in [frame, lbl, lbl_title]:
            widget.bind('<Button-1>', lambda e, win=w: on_tile_click(win, mon_x, mon_y, mon_w, mon_h, root))

    root.bind('<Escape>', lambda e: root.destroy())
    root.mainloop()

if __name__ == '__main__':
    build_grid()
