#!/usr/bin/env python3
"""Builds the project website into site/ (GitHub Pages) — Arabic (main) + English.

python3 tool/site.py   — after changing texts or images; .github/workflows/pages.yml publishes it.
The download button asks GitHub for the latest release and links the right APK directly.
"""
import html
import json
import shutil
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SITE = ROOT / 'site'

C = {
    'name_ar': 'مُنجز', 'name_en': 'Mongez',
    'base': 'https://adamg00d.github.io/Mongez/', 'repo': 'https://github.com/AdamG00D/Mongez',
    'verify': {'google6da38e735cb6412d.html': 'google-site-verification: google6da38e735cb6412d.html'},
    'android': 'Android 7.0+', 'category': 'ProductivityApplication',
    'dark': '#0B3B2E', 'accent': '#10B981', 'accentInk': '#047857', 'onAccent': '#FFFFFF',
    'bg': '#F2FBF7', 'line': '#D1F0E3', 'bgDark': '#0B1512', 'cardDark': '#13231D', 'lineDark': '#1F3A30',
    'banner': 'docs/banner.png', 'icon': 'assets/icon.png',
    'ar': {
        'title': 'مُنجز — منظّم يومي مجاني لأندرويد: خطّط يومك وتابع أهدافك (Mongez)',
        'desc': 'مُنجز منظّم يومي مجاني ومفتوح المصدر لأندرويد بالعربية والإنجليزية: خطّط ليومك، وحافظ على استمراريتك، وتابع أهدافك السنوية ووقت الشاشة — بلا حساب ولا إعلانات ولا إنترنت.',
        'hero': 'خطّط يومك،<br>وأنجز أكثر',
        'heroSub': 'مهام يومية وأسبوعية، وتذكيرات، وأهداف سنوية، ووقت الشاشة — كل ذلك على هاتفك، بلا حساب ولا إعلانات ولا إنترنت.',
        'download': 'حمّل مُنجز لأندرويد', 'source': 'الكود على GitHub',
        'meta': 'مجاني • مفتوح المصدر (GPL-3.0) • أندرويد 7 فأحدث',
        'old': 'هاتف قديم أو فشل التثبيت؟ حمّل النسخة العامة', 'all': 'كل النسخ',
        'bannerAlt': 'مُنجز: خطّط يومك، تابع أهدافك، اعرف وقتك',
        'featTitle': 'المميزات',
        'feats': [
            ('✅', 'المهام', 'مهام لمرة واحدة ويومية وأسبوعية بأولوية وملاحظات ووقت تذكير، مع السحب للترتيب والسحب للإنجاز أو الحذف.'),
            ('📅', 'المهام الأسبوعية', 'اختر أول يوم في الأسبوع وطريقة التذكير حتى الإنجاز.'),
            ('📊', 'السجل والإحصاءات', 'سجل إنجاز يبقى حتى بعد حذف المهام، وسلاسل الاستمرار، ورسم لآخر 7 أيام.'),
            ('🎯', 'الأهداف السنوية', 'أهداف بمراحل أو بأرقام، وتقدّمك مقارنة بما مضى من السنة.'),
            ('📱', 'وقت الشاشة', 'وقت تشغيل الشاشة ومرات الفتح واستخدام كل تطبيق وحدود يومية — والبيانات لا تغادر جهازك.'),
            ('🔔', 'التذكيرات', 'إشعارات في وقتها بزر «تم ✓»، ومتابعة للمهام غير المنجزة، وتذكير مسائي لتخطيط الغد.'),
            ('🧩', 'ودجت الشاشة الرئيسية', 'قائمة المهام وملخص اليوم على الشاشة الرئيسية.'),
            ('🎨', 'شكل يناسبك', '9 ألوان، وفاتح وداكن وAMOLED، وخلفيات، ونسخ احتياطي واسترجاع بملف.'),
        ],
        'notesTitle': 'الخصوصية',
        'notes': [
            'لا حساب ولا إعلانات ولا تتبّع.',
            'كل بياناتك على هاتفك فقط، والتطبيق يعمل بلا إنترنت.',
            'بيانات وقت الشاشة لا تغادر جهازك.',
            'نسخ احتياطي واسترجاع بملف JSON تحتفظ به أنت.',
        ],
        'faqTitle': 'أسئلة شائعة',
        'faq': [
            ('هل مُنجز مجاني؟', 'نعم، مجاني ومفتوح المصدر (GPL-3.0) وبلا إعلانات.'),
            ('هل يحتاج إلى إنترنت أو حساب؟', 'لا، يعمل بلا إنترنت وبلا حساب، وكل بياناتك على هاتفك.'),
            ('هل يدعم العربية؟', 'نعم، بالعربية والإنجليزية مع دعم كامل للكتابة من اليمين لليسار.'),
            ('على أي هواتف يعمل؟', 'أندرويد 7 فأحدث.'),
            ('كيف أنقل بياناتي إلى هاتف جديد؟', 'من الإعدادات ← البيانات ← حفظ نسخة احتياطية، ثم استرجعها على الهاتف الجديد.'),
        ],
        'foot': 'مُنجز — مفتوح المصدر تحت رخصة GPL-3.0',
    },
    'en': {
        'title': 'Mongez — free daily planner for Android: plan your day, track your goals (مُنجز)',
        'desc': 'Mongez is a free, open-source daily planner for Android in Arabic and English: plan tomorrow before you sleep, keep your streaks, track yearly goals and screen time — no account, no ads, no internet.',
        'hero': 'Plan your day,<br>get more done',
        'heroSub': 'Daily and weekly tasks, reminders, yearly goals and screen time — all on your phone, with no account, no ads and no internet.',
        'download': 'Get Mongez for Android', 'source': 'Source on GitHub',
        'meta': 'Free • Open source (GPL-3.0) • Android 7+',
        'old': 'Older phone or install failed? Get the universal build', 'all': 'All builds',
        'bannerAlt': 'Mongez: plan your day, track your goals, know your time',
        'featTitle': 'Features',
        'feats': [
            ('✅', 'Tasks', 'One-off, daily and weekly tasks with priority, notes and reminder time; drag to reorder, swipe to complete or delete.'),
            ('📅', 'Weekly tasks', 'Choose the first day of the week and "remind until done" modes.'),
            ('📊', 'History & stats', 'A completion log that survives task deletion, streaks and a 7-day chart.'),
            ('🎯', 'Yearly goals', 'Milestone or numeric goals, with progress vs. the elapsed year.'),
            ('📱', 'Screen time', 'Screen-on time, unlocks, per-app usage and daily limits — the data never leaves your device.'),
            ('🔔', 'Reminders', 'On-time notifications with a "Done ✓" action, follow-ups and an evening "plan tomorrow" reminder.'),
            ('🧩', 'Home-screen widgets', 'A task list and a summary widget.'),
            ('🎨', 'Your look', '9 color themes, light / dark / AMOLED, backgrounds, and backup / restore to a file.'),
        ],
        'notesTitle': 'Privacy',
        'notes': [
            'No account, no ads, no tracking.',
            'All your data stays on your phone, and the app works offline.',
            'Screen-time data never leaves your device.',
            'Backup and restore to a JSON file you keep.',
        ],
        'faqTitle': 'FAQ',
        'faq': [
            ('Is Mongez free?', 'Yes — free and open source (GPL-3.0), with no ads.'),
            ('Does it need the internet or an account?', 'No. It works offline with no account; all your data stays on your phone.'),
            ('Does it support Arabic?', 'Yes — Arabic and English with full right-to-left support.'),
            ('Which phones?', 'Android 7 or newer.'),
            ('How do I move my data to a new phone?', 'Settings → Data → Save a backup, then restore it on the new phone.'),
        ],
        'foot': 'Mongez — open source under GPL-3.0',
    },
}


def page(lang: str) -> str:
    t = C[lang]
    e = html.escape
    up = '../' if lang == 'en' else ''
    base = C['base']
    url = base + ('en/' if lang == 'en' else '')
    repo = C['repo']
    ld = {
        '@context': 'https://schema.org', '@type': 'SoftwareApplication',
        'name': C['name_en'], 'alternateName': C['name_ar'], 'operatingSystem': C['android'],
        'applicationCategory': C['category'], 'description': t['desc'],
        'offers': {'@type': 'Offer', 'price': '0', 'priceCurrency': 'USD'},
        'downloadUrl': repo + '/releases/latest', 'license': 'https://www.gnu.org/licenses/gpl-3.0.html',
        'url': url, 'image': base + 'img/banner.png', 'codeRepository': repo, 'inLanguage': ['ar', 'en'],
    }
    faq_ld = {
        '@context': 'https://schema.org', '@type': 'FAQPage',
        'mainEntity': [{'@type': 'Question', 'name': q, 'acceptedAnswer': {'@type': 'Answer', 'text': a}} for q, a in t['faq']],
    }
    feats = '\n'.join(f'<div class="feat"><div class="ic">{i}</div><h3>{e(h)}</h3><p>{e(p)}</p></div>' for i, h, p in t['feats'])
    faq = '\n'.join(f'<details><summary>{e(q)}</summary><p>{e(a)}</p></details>' for q, a in t['faq'])
    notes = '\n'.join(f'<li>{e(n)}</li>' for n in t['notes'])
    owner_repo = repo.split('github.com/')[1]
    return f'''<!doctype html>
<html lang="{lang}" dir="{'rtl' if lang == 'ar' else 'ltr'}">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>{e(t['title'])}</title>
<meta name="description" content="{e(t['desc'])}">
<link rel="canonical" href="{url}">
<link rel="alternate" hreflang="ar" href="{base}">
<link rel="alternate" hreflang="en" href="{base}en/">
<link rel="alternate" hreflang="x-default" href="{base}">
<meta property="og:type" content="website">
<meta property="og:title" content="{e(t['title'])}">
<meta property="og:description" content="{e(t['desc'])}">
<meta property="og:url" content="{url}">
<meta property="og:image" content="{base}img/banner{'' if lang == 'ar' or not C.get('banner_en') else '.en'}.png">
<meta name="twitter:card" content="summary_large_image">
<meta name="theme-color" content="{C['dark']}">
<link rel="icon" href="{up}img/icon.png" type="image/png">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=IBM+Plex+Sans+Arabic:wght@400;600;700&display=swap" rel="stylesheet">
<link rel="stylesheet" href="{up}style.css">
<script type="application/ld+json">{json.dumps(ld, ensure_ascii=False)}</script>
<script type="application/ld+json">{json.dumps(faq_ld, ensure_ascii=False)}</script>
</head>
<body>
<header class="hero">
<nav><a class="brand" href="{up or './'}"><img src="{up}img/icon.png" alt="" width="36" height="36"><span>{e(C['name_ar'] if lang == 'ar' else C['name_en'])}</span></a>
<a class="lang" href="{'en/' if lang == 'ar' else '../'}" hreflang="{'en' if lang == 'ar' else 'ar'}">{'English' if lang == 'ar' else 'العربية'}</a></nav>
<div class="hero-in">
<h1>{t['hero']}</h1>
<p>{e(t['heroSub'])}</p>
<div class="cta"><a class="btn" data-dl="main" href="{repo}/releases/latest">⬇ {e(t['download'])}</a>
<a class="btn ghost" href="{repo}">{e(t['source'])}</a></div>
<p class="meta">{e(t['meta'])} • <span data-ver></span></p>
<p class="meta"><a data-dl="all" href="{repo}/releases/latest">{e(t['old'])}</a> • <a href="{repo}/releases/latest">{e(t['all'])}</a></p>
<img class="banner" src="{up}img/banner{'.en' if lang == 'en' and C.get('banner_en') else ''}.png" alt="{e(t['bannerAlt'])}">
</div>
</header>
<main>
<section><h2>{e(t['featTitle'])}</h2><div class="grid">
{feats}
</div></section>
<section class="band"><h2>{e(t['notesTitle'])}</h2><ul>
{notes}
</ul></section>
<section><h2>{e(t['faqTitle'])}</h2><div class="faq">
{faq}
</div></section>
</main>
<footer><p>{e(t['foot'])} • <a href="{repo}">GitHub</a></p></footer>
<script>
fetch('https://api.github.com/repos/{owner_repo}/releases/latest').then(r => r.json()).then(j => {{
  const a = j.assets || [];
  const main = a.find(x => /arm64-v8a\\.apk$/.test(x.name));
  const all = a.find(x => /universal\\.apk$/.test(x.name)) || a.find(x => /^[A-Za-z]+-[0-9.]+\\.apk$/.test(x.name));
  if (main) document.querySelectorAll('[data-dl=main]').forEach(e => e.href = main.browser_download_url);
  if (all) document.querySelectorAll('[data-dl=all]').forEach(e => e.href = all.browser_download_url);
  if (j.tag_name) document.querySelectorAll('[data-ver]').forEach(e => e.textContent = j.tag_name);
}}).catch(() => {{}});
</script>
</body>
</html>
'''


def css() -> str:
    return f'''
:root{{--dark:{C['dark']};--accent:{C['accent']};--accent-ink:{C['accentInk']};--bg:{C['bg']};--card:#fff;--text:{C['dark']};--muted:#5F6368;--line:{C['line']}}}
@media (prefers-color-scheme:dark){{:root{{--bg:{C['bgDark']};--card:{C['cardDark']};--text:#F3F1EC;--muted:#A9ABB3;--line:{C['lineDark']};--accent-ink:{C['accent']}}}}}
*{{box-sizing:border-box}}
body{{margin:0;background:var(--bg);color:var(--text);font-family:"IBM Plex Sans Arabic",system-ui,-apple-system,"Segoe UI",Roboto,sans-serif;line-height:1.7}}
a{{color:inherit}}
.hero{{background:var(--dark);color:#fff;padding:0 16px 40px}}
nav{{max-width:1040px;margin:0 auto;display:flex;align-items:center;justify-content:space-between;padding:14px 0}}
.brand{{display:flex;align-items:center;gap:10px;text-decoration:none;font-weight:700;font-size:20px}}
.brand img{{border-radius:10px}}
.lang{{color:var(--accent);font-weight:700;text-decoration:none;border:1px solid var(--accent);padding:4px 12px;border-radius:999px}}
.hero-in{{max-width:860px;margin:18px auto 0;text-align:center}}
.hero h1{{font-size:clamp(28px,5.5vw,46px);line-height:1.3;margin:10px 0 12px}}
.hero p{{color:#D9DADF;font-size:18px;margin:0 auto;max-width:640px}}
.cta{{display:flex;flex-wrap:wrap;gap:12px;justify-content:center;margin-top:24px}}
.btn{{display:inline-flex;align-items:center;gap:10px;background:var(--accent);color:{C['onAccent']};font-weight:700;font-size:18px;padding:14px 22px;border-radius:16px;text-decoration:none}}
.btn.ghost{{background:transparent;color:#fff;border:1.5px solid rgba(255,255,255,.4)}}
.hero .meta{{font-size:14px;color:#B9BBC6;margin-top:12px}}
.hero .meta a{{color:var(--accent)}}
.banner{{width:100%;max-width:860px;border-radius:18px;margin-top:26px;border:1px solid rgba(255,255,255,.12)}}
main{{max-width:1040px;margin:0 auto;padding:0 16px}}
section{{padding:44px 0 6px}}
h2{{font-size:28px;margin:0 0 18px;color:var(--accent-ink);text-align:center}}
.grid{{display:grid;grid-template-columns:repeat(auto-fit,minmax(260px,1fr));gap:14px}}
.feat{{background:var(--card);border:1px solid var(--line);border-radius:20px;padding:18px}}
.feat .ic{{font-size:28px}}
.feat h3{{margin:6px 0 4px;font-size:18px}}
.feat p{{margin:0;color:var(--muted);font-size:15px}}
.band{{background:var(--card);border:1px solid var(--line);border-radius:22px;padding:26px 22px;margin-top:40px}}
.band ul{{max-width:760px;margin:0 auto;padding-inline-start:22px}}
.band li{{margin-bottom:8px}}
.faq{{max-width:760px;margin:0 auto}}
details{{background:var(--card);border:1px solid var(--line);border-radius:16px;padding:14px 18px;margin-bottom:10px}}
summary{{font-weight:700;cursor:pointer;font-size:17px}}
details p{{color:var(--muted);margin:10px 0 0}}
footer{{text-align:center;color:var(--muted);padding:40px 16px;font-size:14px}}
footer a{{color:var(--accent-ink);font-weight:700}}
'''


def main() -> None:
    if SITE.exists():
        shutil.rmtree(SITE)
    (SITE / 'en').mkdir(parents=True)
    (SITE / 'img').mkdir()
    shutil.copy(ROOT / C['banner'], SITE / 'img/banner.png')
    if C.get('banner_en'):
        shutil.copy(ROOT / C['banner_en'], SITE / 'img/banner.en.png')
    shutil.copy(ROOT / C['icon'], SITE / 'img/icon.png')
    (SITE / 'style.css').write_text(css().strip() + '\n')
    (SITE / 'index.html').write_text(page('ar'))
    (SITE / 'en/index.html').write_text(page('en'))
    base = C['base']
    (SITE / 'robots.txt').write_text(f'User-agent: *\nAllow: /\nSitemap: {base}sitemap.xml\n')
    (SITE / 'sitemap.xml').write_text(
        '<?xml version="1.0" encoding="UTF-8"?>\n'
        '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9" xmlns:xhtml="http://www.w3.org/1999/xhtml">\n'
        + ''.join(
            f'  <url><loc>{base}{p}</loc><xhtml:link rel="alternate" hreflang="ar" href="{base}"/>'
            f'<xhtml:link rel="alternate" hreflang="en" href="{base}en/"/></url>\n' for p in ('', 'en/'))
        + '</urlset>\n')
    (SITE / '.nojekyll').write_text('')
    for name, content in C.get('verify', {}).items():
        (SITE / name).write_text(content)
    print('site/ built')


if __name__ == '__main__':
    main()
