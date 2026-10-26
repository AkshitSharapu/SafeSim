"""Create official Flutter wrapper files without overwriting SafeSim sources."""
import shutil
import subprocess
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

def main():
    flutter = shutil.which('flutter')
    if not flutter:
        raise SystemExit('Install Flutter 3.29 or newer and add flutter/bin to PATH first.')
    app = ROOT / 'FlutterApp'
    with tempfile.TemporaryDirectory(prefix='safesim_') as temp:
        generated = Path(temp) / 'bootstrap'
        subprocess.run([flutter, 'create', '--platforms=android', '--org=com.safesim',
                        '--project-name=safesim_bootstrap', '--no-pub', str(generated)], check=True)
        for rel in ['gradlew', 'gradlew.bat', 'gradle/wrapper/gradle-wrapper.jar', 'local.properties']:
            source = generated / 'android' / rel
            target = app / 'android' / rel
            if source.exists():
                target.parent.mkdir(parents=True, exist_ok=True)
                shutil.copy2(source, target)
    subprocess.run([flutter, 'pub', 'get'], cwd=app, check=True)
    print('Flutter prepared. Export Unity and run install_unity.py next. See START_HERE.md.')

if __name__ == '__main__':
    main()
