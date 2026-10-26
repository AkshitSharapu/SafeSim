import importlib.util
import re
import sqlite3
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location('installer', ROOT/'tools/install_unity.py')
installer = importlib.util.module_from_spec(spec)
spec.loader.exec_module(installer)

class InstallerTests(unittest.TestCase):
    def test_export_connects_library_and_removes_extra_launcher(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp); export = root/'export'; target = root/'host'
            lib = export/'unityLibrary'; (lib/'src/main/java').mkdir(parents=True)
            (lib/'build.gradle').write_text("apply plugin: 'com.android.library'")
            (lib/'src/main/java/SafeSimUnityActivity.java').write_text('// fixture')
            (lib/'src/main/AndroidManifest.xml').write_text('''<manifest xmlns:android="http://schemas.android.com/apk/res/android"><application android:label="Unity"><activity android:name="UnityPlayerActivity"><intent-filter><action android:name="android.intent.action.MAIN"/></intent-filter></activity></application></manifest>''')
            (export/'settings.gradle').write_text("include ':launcher', ':unityLibrary', ':unityLibrary:extra.androidlib'")
            (export/'shared').mkdir(); (export/'shared/keepUnitySymbols.gradle').write_text('// fixture')
            (export/'gradle.properties').write_text('unityStreamingAssets=.unity3d\n')
            installer.install(export, target)
            self.assertTrue((target/'shared/keepUnitySymbols.gradle').exists())
            self.assertIn(':unityLibrary:extra.androidlib', (target/'unity-settings.gradle').read_text())
            self.assertNotIn(':launcher', (target/'unity-settings.gradle').read_text())
            self.assertNotIn('android.intent.action.MAIN', (target/'unityLibrary/src/main/AndroidManifest.xml').read_text())
            installer.install(export, target)
            self.assertEqual(len(list(target.glob('unityLibrary.backup-*'))), 1)

    def test_missing_export_and_nested_destination_rejected(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            with self.assertRaises(ValueError): installer.install(root/'absent', root/'host')
            with self.assertRaises(ValueError): installer.install(root, root/'host')

class DatabaseContractTests(unittest.TestCase):
    def setUp(self):
        source = (ROOT/'FlutterApp/lib/database/app_database.dart').read_text()
        self.db = sqlite3.connect(':memory:')
        for table in ['SimulationAttempts', 'QuizResults']:
            sql = re.search(r"'''(CREATE TABLE IF NOT EXISTS " + table + r" .*?)'''", source, re.S).group(1)
            self.db.execute(sql)
        self.gate = re.search(r"'''(SELECT 1 FROM QuizResults q.*?)'''", source, re.S).group(1)

    def tearDown(self): self.db.close()
    def sim(self, session='s1', worker='A', passed=1):
        self.db.execute('INSERT OR IGNORE INTO SimulationAttempts VALUES (?,?,?,?,?,?,?,?)',
                        (session,worker,'FIRE',passed,85 if passed else 20,0,90,'today'))
    def quiz(self, worker='A', score=80):
        self.db.execute('INSERT OR REPLACE INTO QuizResults VALUES (?,?,?,?,?)', (worker,'FIRE',score,0,'today'))
    def eligible(self, worker='A'):
        return bool(self.db.execute(self.gate,(worker,'FIRE')).fetchall())
    def test_both_simulation_and_quiz_are_required_for_same_worker(self):
        self.quiz(); self.assertFalse(self.eligible())
        self.sim(worker='B'); self.assertFalse(self.eligible()); self.assertFalse(self.eligible('B'))
        self.sim('s2'); self.assertTrue(self.eligible())
        self.quiz(score=60); self.assertFalse(self.eligible())
    def test_failed_simulation_and_duplicate_delivery(self):
        self.quiz(); self.sim(passed=0); self.assertFalse(self.eligible())
        self.sim(passed=0)
        self.assertEqual(self.db.execute('SELECT COUNT(*) FROM SimulationAttempts').fetchone()[0],1)

if __name__ == '__main__': unittest.main()
