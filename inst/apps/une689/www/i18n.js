(function () {
  'use strict';
  var pairs = [
    ['UNE-EN 689: Evaluación de la exposición', 'UNE-EN 689: Exposure assessment'],
    ['1. Evaluación preliminar', '1. Preliminary assessment'],
    ['2. Evaluación estadística', '2. Statistical assessment'],
    ['3. Evaluación periódica', '3. Periodic assessment'],
    ['Muestra', 'Sample'],
    ['Tiempo (h)', 'Duration (h)'],
    ['Usa las jornadas preliminares + adicionales de la pestaña 1.', 'Use preliminary and additional measurement days from tab 1.'],
    ['Mínimo 6 válidas en total.', 'At least 6 valid days in total.'],
    ['Realizar evaluación', 'Run assessment'],
    ['Calcular periodicidad', 'Calculate monitoring interval'],
    ['Necesita haber ejecutado la evaluación estadística.', 'Run the statistical assessment first.'],
    ['Criterio:', 'Criterion:'],
    ['Opción 1: MG o MA frente al VLA', 'Option 1: GM or AM compared with the OEL'],
    ['Opción 2: LSC₉₅,₇₀ frente al VLA', 'Option 2: UCL₉₅,₇₀ compared with the OEL'],
    ['+ Añadir agente', '+ Add agent'],
    ['Idioma / Language', 'Language / Idioma'],
    ['Nombre del agente', 'Agent name'],
    ['Agente', 'Agent'],
    ['Jornadas preliminares', 'Preliminary measurement days'],
    ['Jornadas adicionales (desbloqueadas tras SIN DECISIÓN)', 'Additional days (unlocked after NO DECISION)'],
    ['Jornadas preliminares:', 'Preliminary days:'],
    ['Jornadas adicionales:', 'Additional days:'],
    ['+ Preliminar', '+ Preliminary'],
    ['− Preliminar', '− Preliminary'],
    ['+ Adicional', '+ Additional'],
    ['− Adicional', '− Additional'],
    ['Evaluar preliminar — Agente', 'Preliminary assessment — Agent'],
    ['⊕ Efectos aditivos', '⊕ Additive effects'],
    ['+ Nuevo grupo aditivo', '+ New additive group'],
    ['Eliminar grupo', 'Delete group'],
    ['Grupo', 'Group'],
    ['⊕ Grupo aditivo', '⊕ Additive group'],
    ['Agente a evaluar:', 'Agent to assess:'],
    ['Agente:', 'Agent:']
  ];
  var esToEn = new Map(pairs);
  var enToEs = new Map(pairs.map(function (p) { return [p[1], p[0]]; }));
  function convert(value, lang) {
    if (!value || !value.trim()) return value;
    var map = lang === 'en' ? esToEn : enToEs;
    var original = value;
    var trimmed = value.trim();
    if (map.has(trimmed)) return value.replace(trimmed, map.get(trimmed));
    var m = trimmed.match(/^(Muestra|Sample) (\d+) (\[mg\/m³\])$/);
    if (m) return value.replace(trimmed, (lang === 'en' ? 'Sample' : 'Muestra') + ' ' + m[2] + ' ' + m[3]);
    m = trimmed.match(/^(Nombre del agente|Agent name) (\d+)$/);
    if (m) return value.replace(trimmed, (lang === 'en' ? 'Agent name' : 'Nombre del agente') + ' ' + m[2]);
    m = trimmed.match(/^(Agente|Agent) (\d+)$/);
    if (m) return value.replace(trimmed, (lang === 'en' ? 'Agent' : 'Agente') + ' ' + m[2]);
    m = trimmed.match(/^(Evaluar preliminar — Agente|Preliminary assessment — Agent) (\d+)$/);
    if (m) return value.replace(trimmed, (lang === 'en' ? 'Preliminary assessment — Agent' : 'Evaluar preliminar — Agente') + ' ' + m[2]);
    return original;
  }
  var busy = false;
  function translate() {
    if (busy || !document.body) return;
    var sel = document.getElementById('idioma_app');
    var lang = sel && sel.value === 'en' ? 'en' : 'es';
    busy = true;
    try {
      var walker = document.createTreeWalker(document.body, NodeFilter.SHOW_TEXT, null);
      var node;
      while ((node = walker.nextNode())) {
        var p = node.parentElement;
        if (!p || /^(SCRIPT|STYLE|TEXTAREA|OPTION|PRE|CODE)$/.test(p.tagName)) continue;
        // Do not alter user-entered text or values: only static UI text nodes.
        var next = convert(node.nodeValue, lang);
        if (next !== node.nodeValue) node.nodeValue = next;
      }
    } finally { busy = false; }
  }
  var scheduled = false;
  function schedule() {
    if (scheduled) return;
    scheduled = true;
    window.requestAnimationFrame(function () { scheduled = false; translate(); });
  }
  document.addEventListener('change', function (e) { if (e.target && e.target.id === 'idioma_app') schedule(); });
  document.addEventListener('shiny:connected', schedule);
  document.addEventListener('DOMContentLoaded', function () {
    new MutationObserver(function () { if (!busy) schedule(); }).observe(document.body, { childList: true, subtree: true, characterData: true });
    schedule();
  });
})();
