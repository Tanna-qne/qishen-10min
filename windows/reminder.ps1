# 起身十分钟 · 后台提醒
# 按键盘和鼠标统计连续使用电脑的时间，满 60 分钟直接全屏打开锻炼，自动开始，做完 10 分钟自动关闭。
# 不弹任何提示。键盘鼠标 5 分钟以上没动，算你已经起来过，重新计时。
# 全屏窗口被关掉、没做完的话，再用 10 分钟电脑会再次全屏。
# 托盘图标：悬停看已连续用了多久，双击立刻开始锻炼，右键可以重新计时或退出。
param(
  [double]$SitMinutes = 60,
  [double]$NagMinutes = 10,
  [double]$AwayMinutes = 5,
  [switch]$Fast                  # 只用于测试：每个动作 3 秒
)

Add-Type -AssemblyName System.Windows.Forms, System.Drawing
Add-Type @"
using System;
using System.Runtime.InteropServices;
using System.Text;
public static class QsWin {
  [StructLayout(LayoutKind.Sequential)] struct LASTINPUTINFO { public uint cbSize; public uint dwTime; }
  [StructLayout(LayoutKind.Sequential)] public struct RECT { public int L, T, R, B; }
  [DllImport("user32.dll")] static extern bool GetLastInputInfo(ref LASTINPUTINFO p);
  public static double IdleSeconds() {
    var i = new LASTINPUTINFO(); i.cbSize = (uint)Marshal.SizeOf(i);
    GetLastInputInfo(ref i);
    return unchecked((uint)Environment.TickCount - i.dwTime) / 1000.0;
  }
  delegate bool EnumProc(IntPtr h, IntPtr l);
  [DllImport("user32.dll")] static extern bool EnumWindows(EnumProc f, IntPtr l);
  [DllImport("user32.dll", CharSet = CharSet.Unicode)] static extern int GetWindowText(IntPtr h, StringBuilder s, int n);
  [DllImport("user32.dll")] static extern bool IsWindowVisible(IntPtr h);
  [DllImport("user32.dll")] static extern bool ShowWindow(IntPtr h, int c);
  [DllImport("user32.dll")] static extern bool SetForegroundWindow(IntPtr h);
  [DllImport("user32.dll")] static extern bool BringWindowToTop(IntPtr h);
  [DllImport("user32.dll")] static extern bool PostMessage(IntPtr h, uint m, IntPtr w, IntPtr l);
  [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr h, out RECT r);
  [DllImport("user32.dll")] static extern void keybd_event(byte k, byte s, uint f, UIntPtr e);
  // 页面标题：平时“起身十分钟”，全屏锻炼时“起身十分钟 · 锻炼中”，做完“起身十分钟 · 已完成”，久坐提醒时闪“⏰ 该起来动一动了”
  public static IntPtr Find(string title, bool prefix) {
    IntPtr found = IntPtr.Zero;
    EnumWindows((h, l) => {
      if (!IsWindowVisible(h)) return true;
      var sb = new StringBuilder(256); GetWindowText(h, sb, 256);
      var t = sb.ToString();
      if (prefix ? t.StartsWith(title) : t == title) { found = h; return false; }
      return true;
    }, IntPtr.Zero);
    return found;
  }
  public static void Close(IntPtr h) { PostMessage(h, 0x0010, IntPtr.Zero, IntPtr.Zero); }
  static void Key(byte k) { keybd_event(k, 0, 0, UIntPtr.Zero); keybd_event(k, 0, 2, UIntPtr.Zero); }
  public static void Front(IntPtr h) {
    ShowWindow(h, 9);                     // 最小化的话先还原
    Key(0x12);                            // 轻按一下 Alt，Windows 才允许切换前台窗口
    SetForegroundWindow(h); BringWindowToTop(h);
  }
  public static void F11() { Key(0x7A); }
}
"@

# 只允许运行一个
$mutex = New-Object System.Threading.Mutex($false, 'Local\QishenTenMinReminder')
if (-not $mutex.WaitOne(0)) { exit }

$Url = 'https://tanna-qne.github.io/qishen-10min/?auto=1' + $(if ($Fast) { '&fast=1' } else { '' })
$Edge = Join-Path ${env:ProgramFiles(x86)} 'Microsoft\Edge\Application\msedge.exe'
if (-not (Test-Path $Edge)) { $Edge = Join-Path $env:ProgramFiles 'Microsoft\Edge\Application\msedge.exe' }
$Busy = '起身十分钟 · 锻炼中'
$Done = '起身十分钟 · 已完成'
$state = @{ active = 0.0; nag = $false; last = [DateTime]::Now }

function Close-Titled([string]$title, [bool]$prefix) {
  for ($n = 0; $n -lt 5; $n++) {
    $h = [QsWin]::Find($title, $prefix)
    if ($h -eq [IntPtr]::Zero) { return }
    [QsWin]::Close($h); Start-Sleep -Milliseconds 400
  }
}

function Test-FullScreen([IntPtr]$h) {
  $r = New-Object QsWin+RECT
  [void][QsWin]::GetWindowRect($h, [ref]$r)
  $s = [System.Windows.Forms.Screen]::FromHandle($h).Bounds
  return ($r.L -le $s.Left -and $r.T -le $s.Top -and $r.R -ge $s.Right -and $r.B -ge $s.Bottom)
}

function Start-Workout {
  $h = [QsWin]::Find($Busy, $false)
  if ($h -eq [IntPtr]::Zero) {
    # 普通打开的窗口先关掉，换成自动开始的全屏窗口
    Close-Titled '起身十分钟' $false; Close-Titled '⏰' $true; Close-Titled $Done $false
    Start-Process -FilePath $Edge -ArgumentList "--app=$Url", '--start-fullscreen'
    for ($n = 0; $n -lt 40 -and $h -eq [IntPtr]::Zero; $n++) { Start-Sleep -Milliseconds 500; $h = [QsWin]::Find($Busy, $false) }
    if ($h -eq [IntPtr]::Zero) { return }
  }
  [QsWin]::Front($h)
  Start-Sleep -Milliseconds 300
  if (-not (Test-FullScreen $h)) { [QsWin]::F11() }
}

$icon = New-Object System.Windows.Forms.NotifyIcon
$icon.Icon = New-Object System.Drawing.Icon (Join-Path $PSScriptRoot 'icon.ico')
$icon.Text = '起身十分钟 · 已连续用电脑 0 分钟'
$icon.Visible = $true
$menu = New-Object System.Windows.Forms.ContextMenuStrip
$null = $menu.Items.Add('现在开始锻炼', $null, { $state.active = 0.0; $state.nag = $true; Start-Workout })
$null = $menu.Items.Add('重新计时', $null, { $state.active = 0.0; $state.nag = $false })
$null = $menu.Items.Add('退出提醒', $null, { $icon.Visible = $false; [System.Windows.Forms.Application]::Exit() })
$icon.ContextMenuStrip = $menu
$icon.add_DoubleClick({ $state.active = 0.0; $state.nag = $true; Start-Workout })

$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = 15000
$timer.add_Tick({
  $now = [DateTime]::Now
  $dt = ($now - $state.last).TotalSeconds
  $state.last = $now
  if ($dt -gt 120) { $dt = 0 }                                   # 电脑睡眠后回来，不算时间

  Close-Titled $Done $false                                      # 做完的窗口页面自己会关，没关掉的话这里补一刀
  $working = [QsWin]::Find($Busy, $false) -ne [IntPtr]::Zero

  if ($working) { $state.active = 0.0 }                          # 正在锻炼，不计时
  elseif ([QsWin]::IdleSeconds() -ge $AwayMinutes * 60) { $state.active = 0.0; $state.nag = $false }
  else { $state.active += $dt }

  $limit = if ($state.nag) { $NagMinutes * 60 } else { $SitMinutes * 60 }
  $icon.Text = '起身十分钟 · 已连续用电脑 ' + [int]($state.active / 60) + ' 分钟'
  if ($state.active -ge $limit) {
    $state.active = 0.0; $state.nag = $true
    Start-Workout
  }
})
$timer.Start()
[System.Windows.Forms.Application]::Run()
$timer.Stop(); $icon.Dispose(); $mutex.ReleaseMutex()
