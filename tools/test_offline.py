import json
import re
import sqlite3
import unittest
import xml.etree.ElementTree as ET
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
APP = ROOT/'FlutterApp'

class OfflineTests(unittest.TestCase):
    def test_release_removes_network_permission_and_bundles_scanner(self):
        root = ET.parse(APP/'android/app/src/release/AndroidManifest.xml').getroot()
        attrs = {'android': '{http://schemas.android.com/apk/res/android}', 'tools': '{http://schemas.android.com/tools}'}
        perms = {p.get(attrs['android']+'name'): p.get(attrs['tools']+'node') for p in root.findall('uses-permission')}
        self.assertEqual(perms['android.permission.INTERNET'], 'remove')
        self.assertIn('dev.steenbakker.mobile_scanner.useUnbundled=false', (APP/'android/gradle.properties').read_text())
        for p in (APP/'lib').rglob('*.dart'):
            self.assertNotRegex(p.read_text(), r'Image\.network|NetworkImage\(|PdfGoogleFonts\.|HttpClient\(|Firebase\.|https?://')

    def test_seeded_workers_have_distinct_ids(self):
        workers=json.loads((APP/'assets/data/workers.json').read_text())
        self.assertEqual(len(workers),len({w['id'].upper() for w in workers}))
        self.assertEqual(next(w['name'] for w in workers if w['id']=='WK001'), 'Sharapu Akshit')

    def test_local_worker_lookup_is_case_insensitive_and_never_matches_name(self):
        source=(APP/'lib/database/app_database.dart').read_text()
        sql=re.search(r"'(SELECT \* FROM Workers WHERE UPPER\(id\).*?)'", source).group(1)
        db=sqlite3.connect(':memory:')
        db.execute('CREATE TABLE Workers(id TEXT PRIMARY KEY, workerCode TEXT, name TEXT)')
        db.executemany('INSERT INTO Workers VALUES(?,?,?)', [('WK001','WK001','Same name'),('WK002','WK002','Same name')])
        self.assertEqual(db.execute(sql,('WK002','WK002')).fetchone()[0], 'WK002')
        self.assertEqual(db.execute(sql,('SAME NAME','SAME NAME')).fetchall(), [])
        self.assertEqual(db.execute(sql,('UNKNOWN','UNKNOWN')).fetchall(), [])
        db.close()

    def test_worker_scan_targets_profile_and_other_tabs_do_not_mount_camera(self):
        login=(APP/'lib/screens/auth/qr_login_screen.dart').read_text()
        self.assertIn("context.go('/home?tab=profile')",login)
        self.assertIn('getAllWorkers()',login)
        self.assertNotIn('_workerBadges',login)
        tabs=(APP/'lib/screens/home/home_nav_wrapper.dart').read_text()
        self.assertIn('body: screens[_currentIndex]',tabs)

if __name__=='__main__':unittest.main()
