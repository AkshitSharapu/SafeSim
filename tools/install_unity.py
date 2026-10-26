"""Install a Unity 6000.0.76f1 Android export into the Flutter host."""
import argparse
import re
import shutil
import time
import xml.etree.ElementTree as ET
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
ANDROID = '{http://schemas.android.com/apk/res/android}'

def install(export, android):
    export, android = Path(export).resolve(), Path(android).resolve()
    if export == android or android in export.parents or export in android.parents:
        raise ValueError('Export to a separate folder outside FlutterApp/android.')
    library = export / 'unityLibrary'
    if not (library / 'build.gradle').is_file():
        raise ValueError('Choose the exported project containing unityLibrary/build.gradle.')
    if not list(library.rglob('SafeSimUnityActivity.java')):
        raise ValueError('SafeSimUnityActivity.java is missing. Export the supplied UnityProject.')
    settings = next((p for p in [export/'settings.gradle', export/'settings.gradle.kts'] if p.exists()), None)
    text = settings.read_text() if settings else ''
    modules = sorted(set(re.findall(r"['\"](:unityLibrary(?::[\w.\-]+)*)['\"]", text)))
    if ':unityLibrary' not in modules:
        modules.insert(0, ':unityLibrary')
    # Fail clearly on nonstandard external module locations; do not silently omit code.
    if re.search(r'projectDir\s*=', text):
        raise ValueError('Export uses custom projectDir mappings. Use the supplied unmodified UnityProject export.')
    android.mkdir(parents=True, exist_ok=True)
    stamp = time.strftime('%Y%m%d-%H%M%S') + '-' + str(time.time_ns())
    for name in ['unityLibrary', 'shared']:
        source, target = export/name, android/name
        if target.exists():
            target.rename(android/(name+'.backup-'+stamp))
        if source.exists():
            shutil.copytree(source, target)
    manifest = android/'unityLibrary/src/main/AndroidManifest.xml'
    if manifest.exists():
        ET.register_namespace('android', ANDROID[1:-1])
        tree = ET.parse(manifest)
        application = tree.getroot().find('application')
        if application is not None:
            for name in ['label', 'icon', 'theme']:
                application.attrib.pop(ANDROID+name, None)
            for activity in list(application):
                for intent in list(activity.findall('intent-filter')):
                    if any(x.get(ANDROID+'name') == 'android.intent.action.MAIN' for x in intent.findall('action')):
                        activity.remove(intent)
        tree.write(manifest, encoding='utf-8', xml_declaration=True)
    (android/'unity-settings.gradle').write_text('\n'.join("include '"+m+"'" for m in modules)+'\n')
    props = android/'gradle.properties'
    current = props.read_text() if props.exists() else ''
    exported = export/'gradle.properties'
    if exported.exists():
        for line in exported.read_text().splitlines():
            if line.startswith('unityStreamingAssets='):
                current = re.sub(r'^unityStreamingAssets=.*\n?', '', current, flags=re.M)
                current += '\n'+line+'\n'
    props.write_text(current)
    print('Unity installed. In FlutterApp run flutter analyze, flutter test, then flutter run on an ARM64 Android phone.')

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('export', type=Path)
    args = parser.parse_args()
    try:
        install(args.export, ROOT/'FlutterApp/android')
    except (ValueError, OSError) as error:
        raise SystemExit(str(error))
