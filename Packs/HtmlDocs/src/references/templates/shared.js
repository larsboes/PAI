/* === Nav highlight === */
document.addEventListener('DOMContentLoaded', () => {
  const page = location.pathname.split('/').pop() || 'index.html';
  document.querySelectorAll('.sidebar-nav a').forEach(a => {
    const href = a.getAttribute('href');
    if (href === page || (page === '' && href === 'index.html')) {
      a.classList.add('active');
    }
  });
});

/* === Mobile nav toggle === */
document.addEventListener('DOMContentLoaded', () => {
  const toggle = document.querySelector('.nav-toggle');
  const sidebar = document.querySelector('.sidebar');
  if (toggle && sidebar) {
    toggle.addEventListener('click', () => sidebar.classList.toggle('open'));
    document.addEventListener('click', (e) => {
      if (!sidebar.contains(e.target) && !toggle.contains(e.target)) {
        sidebar.classList.remove('open');
      }
    });
  }
});

/* === Theme toggle === */
function initTheme() {
  const saved = localStorage.getItem('theme');
  if (saved) {
    document.documentElement.setAttribute('data-theme', saved);
  }
  updateToggleLabel();
}

function toggleTheme() {
  const current = document.documentElement.getAttribute('data-theme');
  const next = current === 'light' ? 'dark' : 'light';
  document.documentElement.setAttribute('data-theme', next);
  localStorage.setItem('theme', next);
  updateToggleLabel();
  // Re-render mermaid on theme change
  if (window.mermaid) {
    window.mermaid.init(undefined, document.querySelectorAll('.mermaid'));
  }
}

function updateToggleLabel() {
  const btn = document.querySelector('.theme-toggle');
  if (!btn) return;
  const isDark = document.documentElement.getAttribute('data-theme') !== 'light';
  btn.textContent = isDark ? 'Light mode' : 'Dark mode';
}

initTheme();

/* === Mermaid init === */
document.addEventListener('DOMContentLoaded', () => {
  if (window.mermaid) {
    const isDark = document.documentElement.getAttribute('data-theme') !== 'light';
    mermaid.initialize({
      startOnLoad: true,
      theme: isDark ? 'dark' : 'default',
      securityLevel: 'loose',
      flowchart: { useMaxWidth: true, htmlLabels: true },
    });
  }
});
